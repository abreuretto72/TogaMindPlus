@echo off
title TogaMind+ [SISTEMA LOCAL]
color 0B
echo ==========================================
echo    TOGAMIND+ : AMBIENTE DE GABINETE
echo ==========================================
echo.
echo 1. Iniciando Engine de IA e Servidor Web...
start /min "" cmd /c "cd /d E:\antigravity_projetos\toga_mind_plus\backend && uvicorn main:app --host 0.0.0.0 --port 8000"
timeout /t 5
echo 2. Abrindo Interface Segura Local...
start chrome "http://127.0.0.1:8000"
echo.
echo [OK] Sistema operando offline no Drive E:\
exit
