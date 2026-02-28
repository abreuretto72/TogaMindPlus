[Setup]
AppName=TogaMind+
AppVersion=1.0.0
DefaultDirName={autopf}\TogaMindPlus
DefaultGroupName=TogaMind+
UninstallDisplayIcon={app}\TogaStart.exe
Compression=lzma2
SolidCompression=yes
OutputDir=Release
OutputBaseFilename=Instalar_TogaMind
SetupIconFile=icone.ico

[Files]
Source: "dist\TogaEngine.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "dist\TogaStart.exe"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\TogaMind+"; Filename: "{app}\TogaStart.exe"
Name: "{autodesktop}\TogaMind+"; Filename: "{app}\TogaStart.exe"

[Run]
Filename: "{app}\TogaStart.exe"; Description: "Launch TogaMind+"; Flags: nowait postinstall skipifsilent
