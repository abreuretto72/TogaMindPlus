Set objShell = CreateObject("WScript.Shell")
strPath = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)

' Inicia o Motor de IA Oculto (WindowStyle 0)
objShell.CurrentDirectory = strPath
objShell.Run "TogaEngine.exe", 0, False

' Aguarda 3 segundos para garantir que a porta 8000 abriu (FastAPI)
WScript.Sleep 3000

' Inicia a Interface do Gabinete (Normal)
objShell.Run "toga_mind_plus.exe", 1, True

' Como o True acima trava a execucao ate fechar o app Flutter, quando ele voltar, mata a tela do IA.
objShell.Run "taskkill /IM TogaEngine.exe /F", 0, False
