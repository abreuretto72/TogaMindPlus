import os
from datetime import datetime

class TogaRAGManager:
    def __init__(self, base_path=None):
        if base_path is None:
            base_path = os.path.join(os.getcwd(), "storage", "rag_vault")
        self.vault_path = base_path
        os.makedirs(self.vault_path, exist_ok=True)

    def save_for_rag(self, content_type, title, content, judge_id="juiz_01"):
        """
        Salva petições, rascunhos e anexos para futura vetorização.
        content_type: 'peticao', 'rascunho', 'anexo'
        """
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        # Substituindo espaços por underscores e limpando o nome
        safe_title = "".join([c if c.isalnum() else "_" for c in title])
        file_name = f"{timestamp}_{content_type}_{safe_title}.txt"
        
        # Organização por pastas dentro do drive E:\
        folder_path = os.path.join(self.vault_path, judge_id, content_type)
        os.makedirs(folder_path, exist_ok=True)
        
        full_path = os.path.join(folder_path, file_name)
        
        with open(full_path, "w", encoding="utf-8") as f:
            f.write(f"--- DATA: {datetime.now()} ---\n")
            f.write(f"--- TIPO: {content_type.upper()} ---\n")
            f.write(f"--- TÍTULO: {title} ---\n\n")
            f.write(content)
            
        return full_path
