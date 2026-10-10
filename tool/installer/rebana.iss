; Installer Windows untuk Rebana Injector.
; Dijalankan CI setelah `flutter build windows`, atau manual:
;   ISCC.exe tool\installer\rebana.iss
; Output: installer\rebana-injector-setup.exe

#define AppName "Rebana Injector"
#define AppVersion "1.1.0"
#define AppPublisher "RebanaDev"
#define AppExeName "rebana_injector.exe"
#define SourceRoot "..\..\build\windows\x64\runner\Release"
#define DestDir "{autopf}\Rebana Injector"

[Setup]
AppId={{6F2A1C8B-6D3E-4E2C-9F41-7C0B2A9D5E31}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
DefaultDirName={#DestDir}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
OutputDir=..\..\installer
OutputBaseFilename=rebana-injector-setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
; {autopf} + lowest = install per-user, tanpa minta admin.
PrivilegesRequired=lowest
UninstallDisplayIcon={app}\{#AppExeName}
UninstallDisplayName={#AppName}

[Languages]
Name: "indonesian"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "{#SourceRoot}\{#AppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceRoot}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\..\assets\icon.jpg"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\{#AppExeName}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Buat shortcut di Desktop"; GroupDescription: "Shortcut:"