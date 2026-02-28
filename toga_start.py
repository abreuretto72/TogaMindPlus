import subprocess
import time
import urllib.request
import webbrowser
import sys
import os

def ping_server(url, timeout=2):
    try:
        response = urllib.request.urlopen(url, timeout=timeout)
        return response.getcode() == 200
    except Exception:
        return False

def main():
    # Caminho do executável do backend
    engine_path = os.path.join(os.getcwd(), "TogaEngine.exe")
    
    # URL do frontend servido pelo FastAPI
    app_url = "http://127.0.0.1:8000"
    health_url = "http://127.0.0.1:8000/config.json"
    
    if not os.path.exists(engine_path):
        # Exibe mensagem de erro nativa do Windows no modo windowed caso não ache o motor
        import ctypes
        ctypes.windll.user32.MessageBoxW(0, f"Erro Fatal: Arquivo essencial 'TogaEngine.exe' não encontrado na pasta raiz.\nCaminho: {engine_path}", "TogaMind+ | Orquestrador de Inicialização", 0x10)
        sys.exit(1)

    # Inicia o servidor Python FastAPI de forma oculta (Sem janela do CMD)
    creation_flags = 0
    if sys.platform == "win32":
        creation_flags = subprocess.CREATE_NO_WINDOW
        
    engine_process = subprocess.Popen(
        [engine_path],
        creationflags=creation_flags,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL
    )

    # Aguarda o servidor subir pingando a rota estática
    max_retries = 30 # 30 segundos
    retries = 0
    
    while retries < max_retries:
        if ping_server(health_url):
            # Servidor online! Lança o navegador principal
            webbrowser.open(app_url)
            break
        time.sleep(1.0)
        retries += 1
        
    if retries == max_retries:
        import ctypes
        ctypes.windll.user32.MessageBoxW(0, "Tempo limite excedido. O Motor Local do TogaMind+ falhou ao inicializar ou a porta 8000 está em uso por outro programa.", "TogaMind+ | Falha na Conexão", 0x10)
        engine_process.kill()
        sys.exit(1)

    # Monitora ativamente o processo
    try:
        engine_process.wait()
    except KeyboardInterrupt:
        engine_process.terminate()

if __name__ == "__main__":
    main()
