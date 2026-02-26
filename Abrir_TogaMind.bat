@echo off
title TogaMind+ [SISTEMA LOCAL]
echo Iniciando Engine de IA...
start /min "" "TogaEngine.exe"
timeout /t 3
echo Abrindo Interface de Gabinete...
start chrome "http://127.0.0.1:8000"
exit
