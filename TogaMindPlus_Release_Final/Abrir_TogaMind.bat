@echo off
title TogaMind+ [SISTEMA LOCAL]
echo Iniciando Engine de IA (TogaEngine.exe)...
start "" /min "TogaEngine.exe"
timeout /t 3
echo Abrindo Interface de Gabinete (Flutter)...
start "" "app\toga_mind_plus.exe"
exit
