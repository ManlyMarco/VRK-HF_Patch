; Copyright (C) 2020  ManlyMarco
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;--------------------------------------------Full game name for naming patch itself and desktop icons
#define NAME "VR Kanojo"
;----------------------------------------------------------------------------Current HF Patch version
#define VERSION "1.1"
;----------------------------------------------------------------------------------------------------
#include "Assets\Header.iss"

[Setup]
AppName=HF Patch for VR Kanojo (Steam version)
OutputBaseFilename=VR Kanojo HF Patch v{#VERSION}
ArchitecturesInstallIn64BitMode=x64
CloseApplications=yes
RestartApplications=no
CloseApplicationsFilter=*.exe,*.dll
Compression=lzma2/ultra64
;lzma2/ultra64 | zip | lzma2/fast
LZMAUseSeparateProcess=yes
;LZMADictionarySize=208576
LZMADictionarySize=208576
LZMANumFastBytes=273
LZMANumBlockThreads=5
;DiskSpanning=yes
DefaultDirName=C:\Program Files (x86)\Steam\steamapps\common\VR_Kanojo\

;WindowResizable=yes
WizardStyle=modern

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"
Name: "jp"; MessagesFile: "compiler:Languages\Japanese.isl"
Name: "sc"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"

#include "Translations.iss"

[Types]
Name: "full_en";  Description: "{cm:fullInstall}"; Languages: en;
Name: "full";     Description: "{cm:fullInstall}"; Languages: jp sc;
Name: "extra_en"; Description: "{cm:extraInstall}"; Languages: en;
Name: "extra";    Description: "{cm:extraInstall}"; Languages: jp sc;
Name: "bare";     Description: "{cm:bareInstall}"
Name: "none";     Description: "{cm:noneInstall}"
Name: "custom";   Description: "{cm:customInstall}"; Flags: iscustom

#define CurrentDate GetDateTimeString('yyyy-mm-dd', '-', ':');

[Components]
Name: "Patch"; Description: "Unlock R18 content + game repair"; Types: full_en full extra_en extra custom bare none; Flags: fixed

[Files]
Source: "HelperLib.dll";                  DestDir: "{app}"                 ; Flags: dontcopy
Source: "Input\VR_Kanojo_ChangeResolution.bat"; DestDir: "{app}"
Source: "Plugin Readme.md";               DestDir: "{app}"
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Source: "Input\_Patch\restore\*";         DestDir: "{app}"                 ; Flags: ignoreversion recursesubdirs createallsubdirs;   Components: Patch
Source: "Input\_Patch\hpatch\*";          DestDir: "{app}"                 ; Flags: ignoreversion recursesubdirs createallsubdirs;   Components: Patch
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Source: "Input\BepInEx_config\*";         DestDir: "{app}"                 ; Flags: ignoreversion recursesubdirs createallsubdirs;   Components: BepInEx

#include "components.iss"

[InstallDelete]
; Clean up old patches and packs
Type: files; Name: "{app}\start.bat"
Type: files; Name: "{app}\desktop.ini"
Type: files; Name: "{app}\*.ico"
Type: files; Name: "{app}\[BR]*"

; Always not necessary
Type: files; Name: "{app}\0Harmony.dll"
Type: files; Name: "{app}\BepInEx.dll"
Type: files; Name: "{app}\Mono.Cecil.dll"

; Junk
Type: filesandordirs; Name: "{app}\BepInEx\bepinex4_backup"
Type: filesandordirs; Name: "{app}\BepInEx\cache"
Type: filesandordirs; Name: "{app}\BepInEx_Shim_Backup"
Type: files; Name: "{app}\README.*"
Type: files; Name: "{app}\*.log"
Type: files; Name: "{app}\*.pdb"
Type: files; Name: "{app}\changelog.txt"
Type: files; Name: "{app}\HF_Patch_log.txt"
Type: files; Name: "{app}\output_log.txt"
Type: files; Name: "{app}\VR_Kanojo_Data\output_log.txt"

; Will get replaced, makes sure there are no stale files left
Type: filesandordirs; Name: "{app}\BepInEx\cache"; Components: BepInEx
Type: filesandordirs; Name: "{app}\BepInEx\core"; Components: BepInEx
Type: files; Name: "{app}\BepInEx.Patcher.exe"; Components: BepInEx
Type: files; Name: "{app}\version.dll"; Components: BepInEx
Type: files; Name: "{app}\winhttp.dll"; Components: BepInEx
Type: files; Name: "{app}\doorstop_config.ini"; Components: BepInEx

; Clean dlls completely to fix problems with copied/unnecessary/old dlls. All dlls are included in the patch data
Type: filesandordirs; Name: "{app}\VR_Kanojo_Data\Managed"; Components: Patch
Type: filesandordirs; Name: "{app}\VR_Kanojo_Data\Mono"; Components: Patch

Type: filesandordirs; Name: "{app}\BepInEx\Uncensors"; Components: XUnityResourceRedirector\Selector\Pack

[Tasks]
Name: desktopicon; Description: "{cm:TaskIcon}"; Flags: unchecked
Name: delete; Description: "{cm:TaskDelete}";
Name: delete\Plugins; Description: "{cm:TaskDeletePlugins}";
Name: delete\Config; Description: "{cm:TaskDeletePluginSettings}"; Flags: unchecked
Name: delete\scripts; Description: "Delete old scripts"

[Icons]
Name: "{userdesktop}\{#NAME}"; Filename: "{app}\VR_Kanojo.exe"; IconFilename: "{app}\VR_Kanojo.exe"; WorkingDir: "{app}\"; Flags: createonlyiffileexists; Tasks: desktopicon; Comment: "{cm:IconGame}"

[Run]
Filename: "{app}\VR_Kanojo_ChangeResolution.bat"; Description: "Change game resolution and fullscreen/windowed mode (Can be later changed from plugin settings, press F1)"; Flags: postinstall runasoriginaluser nowait skipifsilent skipifdoesntexist
;Filename: "{app}\VR_Kanojo.exe"; Description: "{cm:RunGame}"; Flags: postinstall runasoriginaluser nowait skipifsilent skipifdoesntexist unchecked

Filename: "notepad.exe"; Parameters: """{app}\Plugin Readme.md"""; Description: "Show information about included plugins"; Flags: postinstall runasoriginaluser nowait skipifsilent skipifdoesntexist unchecked

Filename: "https://github.com/ManlyMarco/VRK-HF_Patch"; Description: "Latest releases and source code"; Flags: shellexec runasoriginaluser postinstall unchecked nowait skipifsilent

Filename: "https://discord.gg/F3bDEFE"; Description: "{cm:RunDiscord}"; Flags: shellexec runasoriginaluser postinstall unchecked nowait skipifsilent;

Filename: "https://www.patreon.com/ManlyMarco"; Description: "ManlyMarco Patreon (Creator of this patch)"; Flags: shellexec runasoriginaluser postinstall unchecked nowait skipifsilent;

[Code]
procedure CreateBackup(path: String);
external 'CreateBackup@files:HelperLib.dll stdcall';

procedure FixConfig(path: String);
external 'FixConfig@files:HelperLib.dll stdcall';

procedure PostInstallCleanUp(path: String);
external 'PostInstallCleanUp@files:HelperLib.dll stdcall';

procedure WriteVersionFile(path, version: String);
external 'WriteVersionFile@files:HelperLib.dll stdcall';

procedure SetConfigDefaults(path: String);
external 'SetConfigDefaults@files:HelperLib.dll stdcall';

procedure FixPermissions(path: String);
external 'FixPermissions@files:HelperLib.dll stdcall';

procedure RemoveJapaneseCards(path: String);
external 'RemoveJapaneseCards@files:HelperLib.dll stdcall';

procedure RemoveNonstandardListfiles(path: String);
external 'RemoveNonstandardListfiles@files:HelperLib.dll stdcall';

procedure RemoveSideloaderDuplicates(path: String);
external 'RemoveSideloaderDuplicates@files:HelperLib.dll stdcall';

procedure RemoveModsExceptModpacks(path: String);
external 'RemoveModsExceptModpacks@files:HelperLib.dll stdcall';

function NextButtonClick(CurPageID: Integer): Boolean;
var
  ResultCode: Integer;
begin
  // allow the setup turning to the next page
  Result := True;

  if (CurPageID = wpSelectDir) then
  begin
    if (not FileExists(ExpandConstant('{app}\VR_Kanojo_Data\resources.assets'))) then
    begin
      if(SuppressibleMsgBox(ExpandConstant('{cm:MsgExeNotFound}'), mbError, MB_YESNO, 0) = IDNO) then
        Result := False;
    end;

    if Result = True then
    begin
      if (Length(ExpandConstant('{app}')) > 100) then
      begin
        MsgBox(ExpandConstant('{cm:MsgDeepPath}'), mbError, MB_OK);
        Result := False;
      end
    end;

    if Result = True then
    begin
      if (Pos(LowerCase(ExpandConstant('{app}\')), LowerCase(ExpandConstant('{src}\'))) > 0) then
      begin
        MsgBox('This patch is inside of the game directory you are attempting to install to. You have to move the patch files outside of the game directory and try again.', mbError, MB_OK);
        Result := False;
      end
    end;

    if Result = True then
    begin
      if (FileExists(ExpandConstant('{app}\EmotionCreators.exe'))
      or FileExists(ExpandConstant('{app}\Koikatu.exe'))
      or FileExists(ExpandConstant('{app}\Koikatsu Party.exe'))
      or FileExists(ExpandConstant('{app}\PlayHome.exe'))
      or FileExists(ExpandConstant('{app}\HoneySelect2.exe'))
      or FileExists(ExpandConstant('{app}\AI-Syoujyo.exe'))
      or FileExists(ExpandConstant('{app}\AI-Shoujo.exe'))) then
      begin
        MsgBox('It looks like a different game is installed to the selected directory. This is very likely to break one or both of the games, and to break the patch.' + #13#10 + #13#10 + 'Make sure you selected the correct directory, and that you downloaded the correct patch for your game. If you installed 2 games to the same directory you will have to reinstall them both to separate directories to fix this.', mbError, MB_OK);
        Result := False;
      end
    end;

    if Result = True then
    begin
      // Check for file corruptions
      if (not FileExists(ExpandConstant('{app}\abdata\adv\00.unity3d'))
      or not FileExists(ExpandConstant('{app}\abdata\sound\data\systemse.unity3d'))
      or not FileExists(ExpandConstant('{app}\abdata\list\characustom\03.unity3d'))) then
      begin
        MsgBox(ExpandConstant('{cm:MsgMissingGameFiles}'), mbError, MB_OK);
        Result := False;
      end;
    end;
  end;

  // After install completes
  if (CurPageID = wpFinished) then
  begin
    // Delete Japanese versions of cards and bgs if English versions are installed (only those with different names)
    //if IsComponentSelected('AT\TL\EnglishTranslation\UserData') then
    //    RemoveJapaneseCards(ExpandConstant('{app}'));

    // Always clean up sideloader mods in case user already messed up
    //if IsTaskSelected('fixSideloaderDupes') then
    //    RemoveSideloaderDuplicates(ExpandConstant('{app}'));

    //FixConfig(ExpandConstant('{app}'));
    //WriteVersionFile(ExpandConstant('{app}'), '{#VERSION}');

    PostInstallCleanUp(ExpandConstant('{app}'));
  end;
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  ResultCode: Integer;
begin
  NeedsRestart := false;
  try
    // Close the game if it's running
    Exec('taskkill', '/F /IM VR_Kanojo.exe', ExpandConstant('{app}'), SW_HIDE, ewWaitUntilTerminated, ResultCode);
    Exec('taskkill', '/F /IM StandaloneUpdater.exe', ExpandConstant('{app}'), SW_HIDE, ewWaitUntilTerminated, ResultCode);

    // Fix file permissions
    FixPermissions(ExpandConstant('{app}'));
  except
    ShowExceptionMessage();
  end;

  CreateBackup(ExpandConstant('{app}'));

  // Backup plugin settings
  if (not IsTaskSelected('delete\Config') and FileExists(ExpandConstant('{app}\BepInEx\config.ini'))) then
    FileCopy(ExpandConstant('{app}\BepInEx\config.ini'), ExpandConstant('{app}\config.ini'), false);

  // Remove BepInEx folder
  if (IsTaskSelected('delete\Config') and IsTaskSelected('delete\Plugins')) then begin
    DelTree(ExpandConstant('{app}\BepInEx'), True, True, True);
  end
  else
  begin
    // Or only remove plugins
    if (IsTaskSelected('delete\Plugins')) then begin
      DelTree(ExpandConstant('{app}\BepInEx\plugins'), True, True, True);
      DelTree(ExpandConstant('{app}\BepInEx\patchers'), True, True, True);
      DelTree(ExpandConstant('{app}\BepInEx\IPA'), True, True, True);
      DelTree(ExpandConstant('{app}\scripts'), True, True, True);
      Exec(ExpandConstant('{cmd}'), '/c del *.dll', ExpandConstant('{app}\BepInEx'), SW_SHOW, ewWaitUntilTerminated, ResultCode);
      Exec(ExpandConstant('{cmd}'), '/c del *.dl_', ExpandConstant('{app}\BepInEx'), SW_SHOW, ewWaitUntilTerminated, ResultCode);
    end;
  end;

  if (not IsTaskSelected('delete\Config')) then
  begin
    // Restore the settings and remove the backup
    CreateDir(ExpandConstant('{app}\BepInEx'));
    if(FileExists(ExpandConstant('{app}\config.ini'))) then
    begin
      FileCopy(ExpandConstant('{app}\config.ini'), ExpandConstant('{app}\BepInEx\config.ini'), false);
      DeleteFile(ExpandConstant('{app}\config.ini'));
    end;
  end
  else
  begin
    // Or remove settings
    DeleteFile(ExpandConstant('{app}\BepInEx\config.ini'));
  end;

  if (IsTaskSelected('delete\Sidemods')) then
    RemoveModsExceptModpacks(ExpandConstant('{app}'));

  //if (IsTaskSelected('delete\Listfiles')) then
  //  RemoveNonstandardListfiles(ExpandConstant('{app}'));
  
  if (IsTaskSelected('delete\scripts')) then
    DelTree(ExpandConstant('{app}\scripts'), True, True, True);

  SetConfigDefaults(ExpandConstant('{app}'));
end;