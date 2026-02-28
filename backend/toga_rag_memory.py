import json
import os
from toga_logger_service import registrar_erro_com_trace

def carregar_contexto_historico():
    """
    Carrega o histórico de conversas anteriores para refinar o RAG.
    Mergulha na pasta Brain para absorver as decisões diárias da IA.
    """
    aprendizados = []
    
    # Busca o histórico local conforme o fluxo de 'brain' do assistente (Zero Cloud)
    historico_path = os.path.expanduser(r"~\.gemini\antigravity\brain")
    
    try:
        if os.path.exists(historico_path):
            for pasta in os.listdir(historico_path):
                pasta_completa = os.path.join(historico_path, pasta)
                if os.path.isdir(pasta_completa):
                    task_file = os.path.join(pasta_completa, "task.md")
                    if os.path.exists(task_file):
                        with open(task_file, 'r', encoding='utf-8') as f:
                            # Extrai aprendizados da pauta rastreada para anexar na base RAG
                            aprendizados.append(f.read())
                            
        return {"status": "success", "historico_carregado": len(aprendizados), "dados": aprendizados}
    except Exception as e:
        return registrar_erro_com_trace(e)
