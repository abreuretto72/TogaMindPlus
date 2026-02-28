import os
import shutil

def criar_pacote_instalacao():
    print("Iniciando Empacotamento do TogaMind+ (Gabinete Digital)...")
    dist_dir = "TogaMindPlus_Release_Final"
    
    if os.path.exists(dist_dir):
        try:
           shutil.rmtree(dist_dir)
        except Exception:
           pass
    os.makedirs(dist_dir, exist_ok=True)

    # 1. Copiando a Engine Nativa (Cérebro PyInstaller)
    engine_path = os.path.join("dist", "TogaEngine.exe")
    if os.path.exists(engine_path):
        shutil.copy(engine_path, dist_dir)
        print("Motor Python Local recém-compilado (dist/TogaEngine.exe) inserido com sucesso.")

    # 2. Configurações Essenciais da Raiz e Cofre .env
    shutil.copy("config.json", dist_dir)
    if os.path.exists(os.path.join("backend", ".env")):
        shutil.copy(os.path.join("backend", ".env"), dist_dir)
    
    # Launcher Batch Corrigido
    with open(os.path.join(dist_dir, "Abrir_TogaMind.bat"), "w", encoding='utf-8') as f:
        f.write("@echo off\n")
        f.write("title TogaMind+ [SISTEMA LOCAL]\n")
        f.write("echo Iniciando Engine de IA (TogaEngine.exe)...\n")
        f.write("start \"\" /min \"TogaEngine.exe\"\n")
        f.write("timeout /t 3\n")
        f.write("echo Abrindo Interface de Gabinete (Flutter)...\n")
        f.write("start \"\" \"app\\toga_mind_plus.exe\"\n")
        f.write("exit\n")
         
    # 3. Criar estrutura limpa de Bancos de Dados locais
    os.makedirs(os.path.join(dist_dir, "storage"), exist_ok=True)
    
    # 4. Copiar Aplicativo Flutter Compilado
    flutter_build_dir = os.path.join("build", "windows", "x64", "runner", "Release")
    flutter_dest = os.path.join(dist_dir, "app")
    if os.path.exists(flutter_build_dir):
        if os.path.exists(flutter_dest):
             try:
                 shutil.rmtree(flutter_dest)
             except: pass
        shutil.copytree(flutter_build_dir, flutter_dest)
        print(f"Aplicativo Front-End copiado para {flutter_dest}")
    else:
        print("[!] Build do Flutter não encontrado. Execute 'flutter build windows' antes.")
    
    print(f"Pacote de pastas gerado em: {dist_dir} (Sucesso - Verde)")

    # 5. Criar o Arquivo ZIP Final
    print("Compactando em arquivo .zip para instalação...")
    shutil.make_archive(dist_dir, 'zip', dist_dir)
    print(f"Instalador Finalizado: {dist_dir}.zip pronto para entrega! 📦")

if __name__ == "__main__":
    criar_pacote_instalacao()
