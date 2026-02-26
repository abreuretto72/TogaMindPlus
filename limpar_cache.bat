@echo off
echo ===================================================
echo   TOGAMIND+ : Lixeira Segura RAG (Limpeza de Cache)
echo ===================================================
echo.
echo Aviso: Isso apagara todas as memorias vetoriais e logs temporarios!
echo Seus PDFs originais NAO serao afetados.
echo.
pause

echo Limpando a base de conhecimento RAG...
if exist "storage\rag_vault" (
    rmdir /s /q "storage\rag_vault"
    echo [OK] Cofre RAG limpo com sucesso.
) else (
    echo [INFO] Nenhuma memoria RAG encontrada.
)

if exist "storage\vector_db" (
    rmdir /s /q "storage\vector_db"
    echo [OK] Indices FAISS destruidos.
) else (
    echo [INFO] Nenhum indice vetorial encontrado.
)

echo.
echo Limpeza concluida! Pressione qualquer tecla para sair.
pause > nul
exit
