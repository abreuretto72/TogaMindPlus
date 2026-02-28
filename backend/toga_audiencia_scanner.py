import os
import json
import sqlite3
import re
from typing import Optional
from toga_pdf_reader import TogaPDFReader

class TogaAudienciaScanner:
    def __init__(self, db_path: str = "storage/toga_database.db"):
        self.db_path = db_path
    
    def get_db_connection(self):
        conn = sqlite3.connect(self.db_path, check_same_thread=False)
        conn.row_factory = sqlite3.Row
        return conn

    def varrer_processos(self, judge_id: str, pasta_processos: str, api_key: str, active_model: str) -> dict:
        """
        Varre a pasta de processos do juiz, identifica novos PDFs e extrai as pautas.
        """
        import google.generativeai as genai
        genai.configure(api_key=api_key)
        
        if not os.path.exists(pasta_processos):
            return {"status": "error", "message": "Pasta de processos não encontrada.", "processados": 0}

        arquivos_pdf = [f for f in os.listdir(pasta_processos) if f.lower().endswith('.pdf')]
        
        conn = self.get_db_connection()
        c = conn.cursor()
        
        c.execute("SELECT id_processo FROM audiencias")
        processos_existentes = {row['id_processo'] for row in c.fetchall()}
        
        processados = 0
        novos = 0
        
        for pdf in arquivos_pdf:
            # Tenta inferir o id do processo baseando no nome do arquivo (ex: "0000000-00.2026.8.26.0000.pdf")
            id_proc = pdf.rsplit('.', 1)[0]
            
            if id_proc in processos_existentes:
                continue # Já está na pauta
                
            caminho_completo = os.path.join(pasta_processos, pdf)
            
            # 1. Extração Nativa PyMuPDF (Ultra rápida)
            extracao_bruta = TogaPDFReader.extrair_resumo_peticao(caminho_completo, max_pages=3)
            resumo_fato = extracao_bruta.get("resumo_fato", "")
            objetivo_prova = extracao_bruta.get("objetivo_prova", "")
            
            # 2. IA / RAG para Extração de Ponto Controvertido 
            # O modelo analisa o extrato bruto para não explodir a memoria com a petição inteira
            ponto_controvertido = "Análise RAG pendente."
            resumo_ia = "Indefinido."
            
            if "erro" not in extracao_bruta and resumo_fato.strip() != "":
                try:
                    prompt_rag = (
                        "CONTEXTO DE GABINETE:\n"
                        "Atuando como assessor jurídico (Protocolo ScanNut), extraia do texto abaixo os pontos cruciais para a audiência de hoje:\n"
                        "1. RESUMO DOS FATOS.\n"
                        "2. PONTOS CONTROVERTIDOS (O que precisa de prova).\n"
                        "3. SUGESTÕES DE PERGUNTAS (Para o magistrado fazer às testemunhas/partes).\n\n"
                        f"TEXTO BASE:\n{resumo_fato[:1500]}\n"
                        f"{objetivo_prova[:1000]}\n\n"
                        "---\n"
                        "RESPONDA EM FORMATO JSON VÁLIDO contendo estas duas chaves:\n"
                        "{\n"
                        "  \"ponto_controvertido\": \"O texto completo com os resumos, pontos e sugestões de perguntas formatados em tópicos limpos.\",\n"
                        "  \"resumo_previa\": \"Breve resumo da lide em 1 linha (ex: Ação de Cobrança - Acidente de Trânsito)\"\n"
                        "}"
                    )
                    
                    model = genai.GenerativeModel(
                        model_name=active_model,
                        generation_config={
                            "temperature": 0.0,
                            "response_mime_type": "application/json"
                        }
                    )
                    
                    resposta_ia = model.generate_content(prompt_rag)
                    dados_ia = json.loads(resposta_ia.text)
                    
                    ponto_controvertido = dados_ia.get("ponto_controvertido", "Não foi possível gerar a extração.")
                    resumo_ia = dados_ia.get("resumo_previa", "Indefinido.")
                except Exception as e:
                    ponto_controvertido = f"Erro na IA: {str(e)}"

            # Mock partes and horario for simulation based on protocol
            partes_mock = json.dumps({"polo_ativo": "A apurar", "polo_passivo": "A apurar"})
            horario = "13:30"
            tipo_aud = "INSTRUÇÃO"
            
            # Inserir no SQLite
            c.execute('''
                INSERT INTO audiencias (id_processo, horario, tipo, partes, ponto_controvertido, status_video, resumo_previa)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            ''', (id_proc, horario, tipo_aud, partes_mock, ponto_controvertido, 1, resumo_ia))
            
            novos += 1
            processados += 1
            
        conn.commit()
        conn.close()
        
        return {"status": "success", "message": "Varredura concluída.", "processados": novos}

