; Script generated by the Inno Setup Script Wizard.

#define MyAppName "pilorama"
#define MyAppVersion "2.5"
#define MyAppExeName "pilorama.exe"

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{6EB623F6-FDAB-4FC3-8559-2BBFF1605485}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
DefaultDirName={autopf64}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
; Uncomment the following line to run in non administrative install mode (install for current user only.)
;PrivilegesRequired=lowest
OutputDir=C:\Users\DELL\Desktop
OutputBaseFilename=pilorama
SetupIconFile=C:\Users\DELL\Downloads\pilorama-master\pilorama-master\src\assets\app_icons\icon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "C:\Users\DELL\Desktop\pilorama\pilorama.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\DELL\Desktop\pilorama\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"               
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\vc_redist.x64.exe"; Description: "Install vc_redist.x64 (Required)"; Flags: nowait postinstall

