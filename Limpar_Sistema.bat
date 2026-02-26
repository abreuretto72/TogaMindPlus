@echo off
color 0C
echo Encerrando TogaMind+ e limpando temporarios...
taskkill /f /im TogaEngine.exe >nul 2>&1
if exist "backend\__pycache__" rd /s /q "backend\__pycache__"
echo Sistema otimizado com sucesso!
timeout /t 3
exit
