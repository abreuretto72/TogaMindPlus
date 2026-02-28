import shutil
import os
from datetime import datetime
from toga_logger_service import registrar_erro_com_trace

def executar_backup_gabinete():
    """
    Realiza o backup dos bancos de dados e configurações locais.
    """
    # Origens dos dados
    db_sqlite = os.path.join(os.getcwd(), "storage", "toga_database.db")
    config_path = os.path.join(os.getcwd(), "config.json")
    
    # Destino no Desktop conforme script de coleta do Gabinete
    backup_dir = os.path.expanduser(r"~\Desktop\Relatorios_Assistente\Backups")
    os.makedirs(backup_dir, exist_ok=True)
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    folder_name = f"Backup_TogaMind_{timestamp}"
    dest_path = os.path.join(backup_dir, folder_name)
    
    try:
        os.makedirs(dest_path)
        
        # Copia o Banco SQLite
        if os.path.exists(db_sqlite):
            shutil.copy2(db_sqlite, dest_path)
            
        # Copia Configurações
        if os.path.exists(config_path):
            shutil.copy2(config_path, dest_path)
        
        return {"status": "success", "path": dest_path, "timestamp": datetime.now().strftime("%d/%m/%Y %H:%M")}
    except Exception as e:
        return registrar_erro_com_trace(e)
