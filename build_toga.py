import os
import re

def auditoria_pilar_zero(diretorio_lib):
    """
    Varre os arquivos .dart em busca de strings hardcoded em Widgets (Violation do Pilar 0).
    """
    padrao_ui = re.compile(r'Text\(\s*".*"\s*\)') # Busca por Text("String")
    padrao_ui_single = re.compile(r"Text\(\s*'.*'\s*\)") # Busca por Text('String')
    
    erros_encontrados = []

    for root, _, files in os.walk(diretorio_lib):
        for file in files:
            if file.endswith(".dart"):
                with open(os.path.join(root, file), 'r', encoding='utf-8') as f:
                    content = f.read()
                    if padrao_ui.search(content) or padrao_ui_single.search(content):
                        erros_encontrados.append(file)

    if erros_encontrados:
        print(f"\nERRO: Pilar 0 violado. Strings literais de UI detectadas nos arquivos: {erros_encontrados}")
        return False
    return True

# Integração com o processo de build existente
if __name__ == "__main__":
    caminho_lib = os.path.join(os.getcwd(), "lib")
    print("Iniciando varredura de restrições do ScanNut+...")
    
    if auditoria_pilar_zero(caminho_lib):
        print("Sucesso: Código purificado e pronto para o Gabinete (Verde).")
    else:
        print("Falha: Remova as strings hardcoded (Pilar Zero) antes de prosseguir com o Build (Vermelho).")
