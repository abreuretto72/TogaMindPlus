import fitz  # PyMuPDF
import re
import os

class TogaPDFReader:
    @staticmethod
    def extrair_resumo_peticao(caminho_pdf: str, max_pages: int = 3) -> dict:
        """
        Lê as páginas iniciais de um PDF jurídico (ex: Petição Inicial)
        e tenta capturar seções essenciais através de Regex.
        """
        if not os.path.exists(caminho_pdf):
            return {"erro": "Arquivo não encontrado."}

        try:
            doc = fitz.open(caminho_pdf)
            texto_completo = ""
            
            # Limita a extração para não explodir a RAM
            total_pages = min(len(doc), max_pages)
            for page_num in range(total_pages):
                page = doc.load_page(page_num)
                texto_completo += page.get_text("text") + "\\n"
            
            doc.close()
            
            # Limpeza de texto basica (remove quebras duplas)
            texto_limpo = re.sub(r'\\n+', '\\n', texto_completo)
            
            # Padroes Regex Corporativos do TogaMind+
            padrao_fatos = r"(?i)(DOS FATOS|SÍNTESE FÁTICA|BREVE RELATO).*?(?=(DO DIREITO|DO MÉRITO|DOS PEDIDOS|$))"
            padrao_pedidos = r"(?i)(DOS PEDIDOS|DO PEDIDO|DOS REQUERIMENTOS).*?(?=(VALOR DA CAUSA|TERMOS EM QUE|$))"
            padrao_testemunhas = r"(?i)(ROL DE TESTEMUNHAS|TESTEMUNHAS).*?(?=($|\\n\\n))"

            match_fatos = re.search(padrao_fatos, texto_limpo, re.DOTALL)
            match_pedidos = re.search(padrao_pedidos, texto_limpo, re.DOTALL)
            match_test = re.search(padrao_testemunhas, texto_limpo, re.DOTALL)

            return {
                "resumo_fato": match_fatos.group(0).strip() if match_fatos else "Trecho 'Dos Fatos' não localizado nas primeiras páginas.",
                "objetivo_prova": match_pedidos.group(0).strip() if match_pedidos else "Trecho 'Dos Pedidos' não localizado nas primeiras páginas.",
                "rol_testemunhas": match_test.group(0).strip() if match_test else "Não localizado rol de testemunhas no topo da petição."
            }
            
        except Exception as e:
            return {"erro": f"Falha na leitura do PDF: {str(e)}"}

# Teste Local
if __name__ == "__main__":
    # Apenas um print para validacao basica se chamado via terminal
    print("TogaPDFReader compilado com sucesso. Pronto para extrair Autos.")
