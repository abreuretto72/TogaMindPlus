import os
import re
import shutil
from datetime import datetime
from pathlib import Path

def main():
    # Caminho base do "cérebro" do assistente
    brain_dir = Path(os.path.expanduser(r"~\.gemini\antigravity\brain"))
    
    # Pasta de destino onde os relatórios serão salvos
    output_dir = Path(os.path.expanduser(r"~\Desktop\Relatorios_Assistente"))
    output_dir.mkdir(parents=True, exist_ok=True)
    
    print(f"Iniciando coleta na pasta: {brain_dir}")
    print(f"Destino dos relatórios: {output_dir}\n")

    count = 0
    # Percorre todas as subpastas (IDs das conversas)
    for conversation_dir in brain_dir.iterdir():
        if conversation_dir.is_dir():
            walkthrough_path = conversation_dir / "walkthrough.md"
            task_path = conversation_dir / "task.md"
            
            # Se encontrou um relatorio
            if walkthrough_path.exists():
                app_name = "Aplicativo_Desconhecido"
                
                # Dicionário de apps conhecidos pelo usuário
                known_apps = ["TogaMind", "TogaMindPlus", "TogaMind Plus", "TogaEngine", "ScanNut", "ScanNutPlus", "ScanNut+"]
                
                # Tenta ler o task.md e o walkthrough.md para descobrir o nome do App
                for text_file in [task_path, walkthrough_path]:
                    if app_name != "Aplicativo_Desconhecido":
                        break
                        
                    if text_file.exists():
                        try:
                            with open(text_file, 'r', encoding='utf-8') as f:
                                content = f.read()
                                
                                # 1. Busca Direta por Nomes Conhecidos
                                for known in known_apps:
                                    if known.lower() in content.lower():
                                        app_name = known.replace(" ", "")
                                        break
                                
                                # 2. Regex Capturando Padrões como "App Mome", "aplicativo Nome" ou Títulos Fortes H1
                                if app_name == "Aplicativo_Desconhecido":
                                    app_match = re.search(r'(?:aplicativo|app|projeto|project)\s+([A-Z][a-zA-Z0-9\+]+)', content, re.IGNORECASE)
                                    if app_match:
                                        app_name = app_match.group(1).strip()
                                    else:
                                        # Último recurso, o primeiro Heading 1 principal
                                        h1_match = re.search(r'^#\s+(.+)$', content, re.MULTILINE)
                                        if h1_match:
                                            first_h1 = h1_match.group(1).strip()
                                            # Ignora headings genericas como "# Tarefas", "# Debug", "# Task"
                                            if not any(sw in first_h1.lower() for sw in ['task', 'tarefa', 'debug', 'overview', 'checklist']):
                                                app_name = first_h1

                                # Limpa caracteres inválidos para nome de arquivo Windows
                                app_name = re.sub(r'[\\/*?:"<>|]', "", app_name)
                                app_name = app_name.replace(" ", "_").replace(".", "_")
                        except Exception:
                            pass
                
                # Pega a data de modificação real do arquivo walkthrough
                mtime = os.path.getmtime(walkthrough_path)
                dt = datetime.fromtimestamp(mtime)
                date_str = dt.strftime("%Y%m%d_%H%M%S")
                
                # Define o novo nome: NomeDoApp_YYYYMMDD_HHMMSS.md
                new_filename = f"{app_name}_{date_str}.md"
                dest_path = output_dir / new_filename
                
                # Para evitar conflito caso tenha exatamente o mesmo segundo (raro, mas possível)
                suffix = 1
                while dest_path.exists():
                    dest_path = output_dir / f"{app_name}_{date_str}_{suffix}.md"
                    suffix += 1
                
                # Copia o arquivo
                shutil.copy2(walkthrough_path, dest_path)
                print(f"[Copiado] {walkthrough_path.parent.name} -> {dest_path.name}")
                count += 1

    print(f"\nColeta concluída! {count} relatórios salvos em: {output_dir}")

if __name__ == "__main__":
    main()
