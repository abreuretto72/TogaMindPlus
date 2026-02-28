@echo off
chcp 65001 >nul
title Instalador Toga Mind Plus
color 0B

echo ========================================================
echo               INSTALADOR TOGA MIND PLUS
echo ========================================================
echo.
echo Este script vai copiar o aplicativo de forma segura para o
echo seu computador e criar um atalho na sua Area de Trabalho.
echo.
echo Pressione qualquer tecla para iniciar a instalacao...
pause >nul

set "DEST_DIR=%LOCALAPPDATA%\TogaMindPlus"

:: Cria o diretorio se nao existir
if not exist "%DEST_DIR%" mkdir "%DEST_DIR%"

:: Copia os arquivos da pasta TogaMindPlus (que deve estar junto deste bat)
echo.
echo [1/2] Copiando arquivos para %DEST_DIR%...
xcopy "%~dp0TogaMindPlus\*" "%DEST_DIR%\" /E /Y /C /I >nul

if %errorlevel% neq 0 (
    echo [ERRO] Falha ao copiar os arquivos. Verifique se a pasta TogaMindPlus esta junto ao script.
    pause
    exit /b 1
)

:: Cria o atalho na área de trabalho usando PowerShell
echo [2/2] Criando atalho na Area de Trabalho...
set "SHORTCUT_PATH=%USERPROFILE%\Desktop\Toga Mind Plus.lnk"
set "TARGET_PATH=%DEST_DIR%\toga_mind_plus.exe"
set "WORK_DIR=%DEST_DIR%"

:: Comando PowerShell para criar atalho
powershell -NoProfile -Command "$wshell = New-Object -ComObject WScript.Shell; $shortcut = $wshell.CreateShortcut('%SHORTCUT_PATH%'); $shortcut.TargetPath = '%TARGET_PATH%'; $shortcut.WorkingDirectory = '%WORK_DIR%'; $shortcut.Save()"

echo.
echo ========================================================
echo INSTALACAO CONCLUIDA COM SUCESSO!
echo ========================================================
echo Voce ja pode fechar esta tela e abrir o "Toga Mind Plus" 
echo usando o icone na sua Area de Trabalho.
echo.
pause
