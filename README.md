![preview](https://user-images.githubusercontent.com/39247311/105546483-bd756200-5cfd-11eb-84aa-9b7c18c39054.png)
# HF Patch for VR Kanojo (Steam version)
An unofficial patch for [VR Kanojo](https://store.steampowered.com/app/751440/VR_Kanojo__VR/) with all free updates, fully modeled uncensors and essential mods. This patch is meant for the Steam version of the game.

[**Read the full HF Patch manual**](https://gist.github.com/ManlyMarco/31b78470b8e190686c7ed9686c237e3f) to learn more about what it is, what it does, how to use it, and how to solve common issues.

## Important notes, please read
- Do not use uncensors that replace files inside `abdata` with this patch (or any other mods that replace game files). New uncensors should go inside `BepInEx\Uncensors` and have a `UncensorInfo.xml` file added to them, check existing uncensors for an example.
- HF Patch does not contain the full game, paid expansions or any other pirated content. You have to buy the game and expansions separately. You can buy the game [on Steam](https://store.steampowered.com/app/751440/VR_Kanojo__VR/). 
- This patch is meant for the Steam version of the game and will likely not work properly with the original Japanese release.
- Please leave the modders some positive feedback or help them in some other way!
- There is no warranty on this patch or on any of the included mods. You are installing this patch at your own risk.
- [Read the full HF Patch manual](https://gist.github.com/ManlyMarco/31b78470b8e190686c7ed9686c237e3f) for more information.

## Download
Check the [Releases](https://github.com/ManlyMarco/VRK-HF_Patch/releases) page for download links.

If the default install path of the patch doesn't work (if for example you moved your Steam library to a different folder), you have to point the patch to where the game is installed. If you are not sure where to look: Find the game in the library, then go to `Properties > Local files > Browse` and point the patch to the folder than opens (it should have `VR Kanojo.exe` in it).

Read [the full manual](https://gist.github.com/ManlyMarco/31b78470b8e190686c7ed9686c237e3f) for detailed download and install instructions.

## What mods are included?
You can see a list of all included plugins and links to their websites and authors [here](https://github.com/ManlyMarco/VRK-HF_Patch/blob/master/Plugin%20Readme.md).

## Discussion and help
If you need any help, [check the Steam discussions](https://steamcommunity.com/app/751440/discussions/) or visit the [Illusion Soft discord server](https://discord.gg/illusionsoft) if you have a more general modding question. Make sure to search for your issue to see if someone didn't already answer it.

## How to build
At least Visual Studio 2017 is needed for the helper library and latest unicode Inno Setup compiler is needed for the patch itself. All necessary mods have to be placed inside correct subfolders of the Input directory to compile. Because of massive size, they are not included here.

You can support development of HF Patch and many of the included plugins through my Patreon page: https://www.patreon.com/ManlyMarco
