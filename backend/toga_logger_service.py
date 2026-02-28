import logging
import traceback
import os
from datetime import datetime

# Configuração de Logs conforme padrão ScanNut 2026
log_path = os.path.expanduser(r"~\Desktop\Relatorios_Assistente\logs")
os.makedirs(log_path, exist_ok=True)

logging.basicConfig(
    filename=os.path.join(log_path, f"error_{datetime.now().strftime('%Y%m%d')}.log"),
    level=logging.ERROR,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

def registrar_erro_com_trace(e: Exception) -> dict:
    """
    Captura o erro e gera o trace completo para o prompt.
    """
    error_msg = f"Erro detectado: {str(e)}"
    trace_info = traceback.format_exc()
    logging.error(f"{error_msg}\n{trace_info}")
    
def log_info(msg: str):
    """Grava logs informativos no mesmo arquivo do sistema."""
    logging.info(f"[AUDITORIA] {msg}")
    
def log_warning(msg: str):
    """Grava alertas que não são falhas catastróficas."""
    logging.warning(f"[ALERTA] {msg}")
    
    # Retorno estruturado para o Flutter exibir ao usuário
    return {
        "status": "error",
        "message": error_msg,
        "trace": trace_info
    }
