[Setup]
AppId={{E681A7D1-0161-41B0-9F22-5B4B6C908DCD}
AppName=Toga Mind Plus
AppVersion=1.0.0
AppPublisher=Toga Mind Plus
AppPublisherURL=https://togamindplus.com/
AppSupportURL=https://togamindplus.com/
AppUpdatesURL=https://togamindplus.com/
DefaultDirName={autopf}\Toga Mind Plus
DisableProgramGroupPage=yes
; Uncomment the following line to run in non administrative install mode (install for current user only.)
;PrivilegesRequired=lowest
OutputDir=build\windows\installer
OutputBaseFilename=TogaMindPlus_Installer
SetupIconFile=windows\runner\resources\app_icon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "build\windows\x64\runner\Release\toga_mind_plus.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs
; Add other DLLs if they exist
Source: "build\windows\x64\runner\Release\*.dll"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\Toga Mind Plus"; Filename: "{app}\toga_mind_plus.exe"
Name: "{autodesktop}\Toga Mind Plus"; Filename: "{app}\toga_mind_plus.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\toga_mind_plus.exe"; Description: "{cm:LaunchProgram,Toga Mind Plus}"; Flags: nowait postinstall skipifsilent
