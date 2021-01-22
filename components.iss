[Components]
Name: "BepInEx";                               Description: "BepInEx v5.4.5 (Plugin framework)"                                                    ; Types: full_en full extra extra_en custom bare; Flags: fixed
Name: "BepInEx\Dev";                           Description: "{cm:CompDev}"                                                                         
Name: "BepInEx\MessageCenter";                 Description: "Message Center v1.1.1 (Allows plugins to show messages in top left corner of the game)"; Types: full_en full extra extra_en custom bare
Name: "BepInEx\ConfigurationManager";          Description: "Configuration Manager v16.1 (Can change plugin settings. Press F1 to open, not visible inside HMD)"; Types: full_en full extra extra_en custom bare
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Name: "XUnityResourceRedirector";              Description: "XUnity Resource Redirector v1.1.3 (Modding API for overriding resources)"             ; Types: full_en full extra extra_en custom bare
Name: "XUnityResourceRedirector\Selector";     Description: "Uncensor Selector v1.0 (Support for user-selectable uncensors, change in plugin settings)"; Types: full_en full extra extra_en
Name: "XUnityResourceRedirector\Selector\Pack"; Description: "Collection of male and female uncensors up to {#CurrentDate} (Dynamically loaded, no game files are replaced)"; Types: full_en full extra extra_en
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Name: "Content";                               Description: "Additional content (Needed to properly load most character cards and scenes)"         ; Types: full_en full extra extra_en
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Name: "FIX";                                   Description: "{cm:CompFIX}"                                                                         ; Types: extra extra_en
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Name: "Feature";                               Description: "Improvements and additional features"                                                 ; Types: extra extra_en
Name: "Feature\PlayWithoutVR";                 Description: "Play Without VR v1.0 (If no HMD is connected, allows playing with keyboard and mouse)"; Types: full_en full extra extra_en
Name: "Feature\PlayWithoutVR\MouseConfig";     Description: "Mouse optimized config v1.0 (Config optimized for control with mouse and keyboard (disables features that don't work properly and bumps up some settings))"
Name: "Feature\MuteInBackground";              Description: "Mute In Background v1.1 (Mute the game when not focused)"                             ; Types: full_en full extra extra_en
Name: "Feature\GraphicsSettings";              Description: "Graphics Settings v1.2.1 (More settings to make graphics more or less demanding)"     ; Types: full_en full extra extra_en
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Name: "MISC";                                  Description: "{cm:CompMISC}"                                                                        
Name: "MISC\FPS";                              Description: "FPS Counter v3.1 (Useful for performance testing)"                                    ; Types: full_en full extra extra_en
Name: "MISC\Trainer";                          Description: "Runtime Unity Editor v2.2.1.0 (Tool for making arbitrary modifications to the game, press F12 or Pause key)"; Types: full_en full extra extra_en
Name: "MISC\ScriptLoader";                     Description: "C# Script Loader v1.2.4 (Runs custom user scripts)"                                   ; Types: full_en full extra extra_en
Name: "MISC\FullSave";                         Description: "Full save (WARNING - OVERWRITES CURRENT SAVE)"                                        

[Files]
Source: "Input\_Plugins\_out\BepInEx.ConfigurationManager\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Components: BepInEx\ConfigurationManager; Excludes: "manifest.xml"
Source: "Input\_Plugins\_out\BepInEx.MessageCenter\*";      DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Components: BepInEx\MessageCenter; Excludes: "manifest.xml"
Source: "Input\_Plugins\_out\BepInEx_Dev\*";                DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Components: BepInEx\Dev; Excludes: "manifest.xml"
Source: "Input\_Plugins\_out\BepInEx.MuteInBackground\*";   DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Components: Feature\MuteInBackground; Excludes: "manifest.xml"
Source: "Input\_Plugins\_out\GraphicsSettings\*";           DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Components: Feature\GraphicsSettings; Excludes: "manifest.xml"
Source: "Input\_Plugins\_out\Mouse optimized config\*";     DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Components: Feature\PlayWithoutVR\MouseConfig; Excludes: "manifest.xml"
Source: "Input\_Plugins\_out\VRK_PlayWithoutVR\*";          DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Components: Feature\PlayWithoutVR; Excludes: "manifest.xml"
Source: "Input\_Plugins\_out\BepInEx_x64\*";                DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Components: BepInEx; Excludes: "manifest.xml"
Source: "Input\_Plugins\_out\FPSCounter\*";                 DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Components: MISC\FPS; Excludes: "manifest.xml"
Source: "Input\_Plugins\_out\FullSave\*";                   DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Components: MISC\FullSave; Excludes: "manifest.xml"
Source: "Input\_Plugins\_out\RuntimeUnityEditor_BepInEx5\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Components: MISC\Trainer; Excludes: "manifest.xml"
Source: "Input\_Plugins\_out\ScriptLoader\*";               DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Components: MISC\ScriptLoader; Excludes: "manifest.xml"
Source: "Input\_Plugins\_out\UncensorPack\*";               DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Components: XUnityResourceRedirector\Selector\Pack; Excludes: "manifest.xml"
Source: "Input\_Plugins\_out\VRK_UncensorLoader\*";         DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Components: XUnityResourceRedirector\Selector; Excludes: "manifest.xml"
Source: "Input\_Plugins\_out\XUnity.ResourceRedirector\*";  DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Components: XUnityResourceRedirector; Excludes: "manifest.xml"