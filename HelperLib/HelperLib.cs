﻿/*
    Copyright (C) 2020  ManlyMarco

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
*/

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Windows.Forms;
using System.Xml.Linq;
using KKManager.Util.ProcessWaiter;
using RGiesecke.DllExport;

namespace HelperLib
{
    public class HelperLib
    {
        private const string LogFileName = "HF_Patch_log.txt";

        private static void AppendLog(string targetDirectory, object message)
        {
            try
            {
                File.AppendAllText(Path.Combine(targetDirectory, LogFileName), message.ToString() + Environment.NewLine);
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
            }
        }

        [DllExport("SetConfigDefaults", CallingConvention = CallingConvention.StdCall)]
        public static void SetConfigDefaults([MarshalAs(UnmanagedType.LPWStr)] string path)
        {

        }

        [DllExport("WriteVersionFile", CallingConvention = CallingConvention.StdCall)]
        public static void WriteVersionFile([MarshalAs(UnmanagedType.LPWStr)] string path, [MarshalAs(UnmanagedType.LPWStr)] string version)
        {
            var verPath = Path.Combine(path, @"version");
            try
            {
                //var contents = File.Exists(verPath) ? File.ReadAllText(verPath) : string.Empty;
                //var versionList = contents.Split(';').Select(x => x.Trim()).Where(x => !string.IsNullOrEmpty(x)).ToList();
                //versionList.Add("HF Patch v" + version);
                //
                //var existingVersions = new HashSet<string>();
                //// Only keep latest copy of any version, remove older duplicates
                //var filteredVersionList = versionList.AsEnumerable().Reverse().Where(x => existingVersions.Add(x)).Reverse().ToArray();
                //var result = string.Join("; ", filteredVersionList);

                var result = "HF Patch v" + version;
                // Prevent crash when overwriting hidden file
                if (File.Exists(verPath)) File.SetAttributes(verPath, FileAttributes.Normal);
                File.WriteAllText(verPath, result);
                File.SetAttributes(verPath, FileAttributes.Hidden | FileAttributes.Archive);
            }
            catch (Exception e)
            {
                AppendLog(path, "Failed trying to write version file: " + e);
            }
        }

        [DllExport("FixConfig", CallingConvention = CallingConvention.StdCall)]
        public static void FixConfig([MarshalAs(UnmanagedType.LPWStr)] string path)
        {
            var ud = Path.Combine(path, @"UserData\setup.xml");

            try
            {
                using (var reader = File.OpenRead(ud))
                {
                    var r = XDocument.Load(reader).Root;

                    var s = r.Element("Size").Value;
                    var w = int.Parse(r.Element("Width").Value);
                    var h = int.Parse(r.Element("Height").Value);
                    if (w < 200 || h < 200 || w <= h
                        || !s.Contains(w.ToString(CultureInfo.InvariantCulture))
                        || !s.Contains(h.ToString(CultureInfo.InvariantCulture)))
                        throw new Exception();

                    var _ = bool.Parse(r.Element("FullScreen").Value);
                    CheckRange(r.Element("Quality").Value, 0, 2);
                    CheckRange(r.Element("Display").Value, 0, Screen.AllScreens.Length);
                    CheckRange(r.Element("Language").Value, 0, 4);
                }
            }
            catch (Exception e)
            {
                try
                {
                    File.Delete(ud);
                    if (!(e is FileNotFoundException))
                        AppendLog(path, @"Removed corrupted " + ud + "; Cause:" + e.Message);
                }
                catch { }
            }

            var sysDir = Path.Combine(path, @"UserData\config\system.xml");
            try
            {
                using (var reader = File.OpenRead(sysDir))
                    XDocument.Load(reader);
            }
            catch (Exception e)
            {
                try
                {
                    File.Delete(sysDir);

                    if (!(e is FileNotFoundException))
                        AppendLog(path, @"Reset corrupted " + sysDir + Environment.NewLine + e + Environment.NewLine);
                }
                catch { }
            }
        }

        private static void CheckRange(string instr, int min, int max)
        {
            var val = int.Parse(instr);
            if (min > val || val > max)
                throw new Exception();
        }

        [DllExport("FixPermissions", CallingConvention = CallingConvention.StdCall)]
        public static void FixPermissions([MarshalAs(UnmanagedType.LPWStr)] string path)
        {
            try
            {
                ProcessWaiter.CheckForRunningProcesses(new[] { Path.GetFullPath(path) }, new string[0]);

                var batContents = $@"
title Fixing permissions... 
rem Get the localized version of Y/N to pass to takeown to make this work in different locales
for /f ""tokens=1,2 delims=[,]"" %%a in ('""choice <nul 2>nul""') do set ""yes=%%a"" & set ""no=%%b""
echo Press %yes% for yes and %no% for no
set target={ path.Trim(Path.AltDirectorySeparatorChar, Path.DirectorySeparatorChar, ' ') }
echo off
cls
echo Taking ownership of %target% ...
rem First find is to filter out success messages, second findstr is to filter out empty lines
takeown /F ""%target%"" /R /SKIPSL /D %yes% | find /V ""SUCCESS: The file (or folder):"" | findstr /r /v ""^$""
echo.
echo Fixing access rights ...
icacls ""%target%"" /grant *S-1-1-0:(OI)(CI)F /T /C /L /Q
";
                var batPath = Path.Combine(Path.GetTempPath(), "hfpatch_fixperms.bat");
                File.WriteAllText(batPath, batContents);

                Process.Start(new ProcessStartInfo("cmd", $"/C \"{batPath}\"") { WindowStyle = ProcessWindowStyle.Hidden, CreateNoWindow = true });
            }
            catch (Exception e)
            {
                AppendLog(path, "Failed to fix permissions for path " + path + " - " + e);
            }
        }

        [DllExport("CreateBackup", CallingConvention = CallingConvention.StdCall)]
        public static void CreateBackup([MarshalAs(UnmanagedType.LPWStr)] string path)
        {
            try
            {
                var fullPath = Path.GetFullPath(path);
                var filesToBackup = new List<string>();

                var bepinPath = Path.Combine(fullPath, "BepInEx");
                if (Directory.Exists(bepinPath))
                    filesToBackup.AddRange(Directory.GetFiles(bepinPath, "*", SearchOption.AllDirectories));

                var scriptsPath = Path.Combine(fullPath, "scripts");
                if (Directory.Exists(scriptsPath))
                    filesToBackup.AddRange(Directory.GetFiles(scriptsPath, "*", SearchOption.AllDirectories));

                var dhhPath = Path.Combine(fullPath, "DHH_Data");
                if (Directory.Exists(dhhPath))
                    filesToBackup.AddRange(Directory.GetFiles(dhhPath, "*", SearchOption.AllDirectories));

                if (!filesToBackup.Any()) return;

                using (var file = File.OpenWrite(Path.Combine(fullPath, $"Plugin_Backup_{DateTime.Now.ToString("yyyy-MM-dd_HH-mm-ss")}.zip")))
                using (var zip = new ZipArchive(file, ZipArchiveMode.Create, false, Encoding.UTF8))
                {
                    foreach (var toAdd in filesToBackup)
                    {
                        try
                        {
                            using (var toAddStream = File.OpenRead(toAdd))
                            {
                                var entry = zip.CreateEntry(toAdd.Substring(fullPath.Length + 1), CompressionLevel.Fastest);
                                using (var entryStream = entry.Open())
                                    toAddStream.CopyTo(entryStream);
                            }
                        }
                        catch (Exception ex)
                        {
                            AppendLog(path, $"Failed to add file {toAdd} to backup - {ex}");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                AppendLog(path, $"Failed to create backup - {ex}");
            }
        }

        [DllExport("RemoveModsExceptModpacks", CallingConvention = CallingConvention.StdCall)]
        public static void RemoveModsExceptModpacks([MarshalAs(UnmanagedType.LPWStr)] string path)
        {
            try
            {
                var modsPath = Path.GetFullPath(Path.Combine(path, "mods"));
                if (!Directory.Exists(modsPath)) return;

                var acceptableDirs = new[]{
                    "Sideloader Modpack",
                    "Sideloader Modpack - Bleeding Edge",
                    "Sideloader Modpack - Exclusive AIS",
                    "Sideloader Modpack - Exclusive HS2",
                    "Sideloader Modpack - Maps",
                    "Sideloader Modpack - Maps (HS2 Game)",
                    "Sideloader Modpack - MaterialEditor Shaders",
                    "Sideloader Modpack - Studio",
                    "Sideloader Modpack - Uncensor Selector",
                };

                var fullAcceptableDirs = acceptableDirs.Select(s => Path.Combine(modsPath, s) + "\\").ToArray();

                foreach (var file in Directory.GetFiles(modsPath, "*", SearchOption.AllDirectories))
                {
                    if (fullAcceptableDirs.Any(x => file.StartsWith(x, StringComparison.OrdinalIgnoreCase))) continue;

                    try
                    {
                        File.Delete(file);
                    }
                    catch (Exception ex)
                    {
                        AppendLog(path, $"Failed to remove file {file} from mods directory - {ex}");
                    }
                }
            }
            catch (Exception ex)
            {
                AppendLog(path, $"Failed to remove old mods from the mods directory - {ex}");
            }
        }


        [DllExport("RemoveJapaneseCards", CallingConvention = CallingConvention.StdCall)]
        public static void RemoveJapaneseCards([MarshalAs(UnmanagedType.LPWStr)] string path)
        {
        }

        [DllExport("RemoveNonstandardListfiles", CallingConvention = CallingConvention.StdCall)]
        public static void RemoveNonstandardListfiles([MarshalAs(UnmanagedType.LPWStr)] string path)
        {
            try
            {
                foreach (var subdir in new[] { @"abdata\list\characustom", @"abdata\studio\info", @"abdata\housing\info" })
                {
                    var ld = Path.Combine(path, subdir);
                    if (Directory.Exists(ld))
                    {
                        foreach (var filePath in Directory.GetFiles(ld))
                        {
                            if (!IsStandardListFile(filePath))
                                SafeFileDelete(filePath);
                        }
                    }
                }
            }
            catch (Exception e)
            {
                AppendLog(path, e);
            }
        }

        [DllExport("PostInstallCleanUp", CallingConvention = CallingConvention.StdCall)]
        public static void PostInstallCleanUp([MarshalAs(UnmanagedType.LPWStr)] string path)
        {
        }

        [DllExport("RemoveSideloaderDuplicates", CallingConvention = CallingConvention.StdCall)]
        public static void RemoveSideloaderDuplicates([MarshalAs(UnmanagedType.LPWStr)] string path)
        {
            try
            {
                var ld = Path.Combine(path, @"mods");
                if (!Directory.Exists(ld)) return;

                var allMods = (from file in Directory.GetFiles(ld, "*", SearchOption.AllDirectories)
                               where file.EndsWith(".zip", StringComparison.OrdinalIgnoreCase)
                                     || file.EndsWith(".zi_", StringComparison.OrdinalIgnoreCase)
                                     || FileHasZipmodExtension(file)
                               select file).ToList();

                SideloaderCleanupByManifest(allMods);
                SideloaderCleanupByFilename(allMods.Where(File.Exists));
            }
            catch (Exception e)
            {
                AppendLog(path, e);
            }
        }

        private static void SideloaderCleanupByManifest(IEnumerable<string> allMods)
        {
            try
            {
                var mods = new List<SideloaderModInfo>();

                foreach (var mod in allMods)
                {
                    try
                    {
                        using (var zs = new FileStream(mod, FileMode.Open, FileAccess.Read))
                        using (var zf = new ZipArchive(zs))
                        {
                            var manifestEntry = zf.Entries.FirstOrDefault(
                                x =>
                                    x.Name.Equals("manifest.xml", StringComparison.OrdinalIgnoreCase));

                            if (manifestEntry == null)
                            {
                                if (FileHasZipmodExtension(mod))
                                    throw new InvalidDataException("zipmod has no manifest");
                                continue;
                            }

                            using (var fileStream = manifestEntry.Open())
                            {
                                var manifest = XDocument.Load(fileStream, LoadOptions.None);

                                if (manifest.Root == null || !manifest.Root.HasElements)
                                    throw new InvalidDataException("The manifest.xml file is in an invalid format");

                                var guid = manifest.Root.Element("guid")?.Value;
                                if (string.IsNullOrWhiteSpace(guid))
                                    continue;

                                mods.Add(new SideloaderModInfo(mod, guid,
                                        manifest.Root.Element("version")?.Value));
                            }
                        }
                    }
                    catch (SystemException)
                    {
                        // Kill it with fire
                        SafeFileDelete(mod);
                    }
                }

                foreach (var modGroup in mods.GroupBy(x => x.Guid))
                {
                    var orderedMods = modGroup.All(x => !string.IsNullOrWhiteSpace(x.Version))
                        ? modGroup.OrderByDescending(x => x.Path.ToLower().Contains("sideloader modpack")).ThenByDescending(x => x.Version, new VersionComparer())
                        : modGroup.OrderByDescending(x => x.Path.ToLower().Contains("sideloader modpack")).ThenByDescending(x => File.GetLastWriteTime(x.Path));

                    // Prefer .zipmod extension and then longer paths (so the mod has either longer name or is arranged in a subdirectory)
                    orderedMods = orderedMods.ThenByDescending(x => FileHasZipmodExtension(x.Path))
                        .ThenByDescending(x => x.Path.Length);

                    foreach (var oldMod in orderedMods.Skip(1).Where(x => !x.Path.ToLower().Contains("sideloader modpack"))) SafeFileDelete(oldMod.Path);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
            }
        }

        private static void SideloaderCleanupByFilename(IEnumerable<string> allMods)
        {
            var modDuplicates = allMods.GroupBy(Path.GetFileNameWithoutExtension);

            foreach (var modVersions in modDuplicates)
            {
                if (modVersions.Count() <= 1) continue;

                // Figure out the newest mod and remove all others. Favor .zipmod versions if both have the same creation date
                var orderedVersions = modVersions.OrderByDescending(File.GetLastWriteTime)
                    .ThenByDescending(FileHasZipmodExtension)
                    // Prefer non-disabled mods
                    .ThenByDescending(x => !Path.GetExtension(x).Contains("_"));
                foreach (var oldModPath in orderedVersions.Skip(1))
                    SafeFileDelete(oldModPath);
            }
        }

        private static bool FileHasZipmodExtension(string fileName)
        {
            return fileName.EndsWith(".zipmod", StringComparison.OrdinalIgnoreCase) || fileName.EndsWith(".zi_mod", StringComparison.OrdinalIgnoreCase);
        }

        private static void SafeFileDelete(string file)
        {
            try
            {
                File.Delete(file);
            }
            catch (SystemException)
            {
                // Nom nom nom
            }
        }

        private static bool IsStandardListFile(string fileName)
        {
            // Get rid of invalid files like .csv .zipmod or other junk that people somehow manage to put there
            return fileName.EndsWith(".unity3d", StringComparison.OrdinalIgnoreCase)
                // Official list files only have numbers in them while all custom ones seem to have at least one letter, so this is enough
                && IsDigitsOnly(Path.GetFileNameWithoutExtension(fileName));
        }

        private static bool IsStandardHListFile(string fileName)
        {
            // Get rid of invalid files like .csv .zipmod or other junk that people somehow manage to put there
            if (fileName.EndsWith(".unity3d", StringComparison.OrdinalIgnoreCase))
            {
                // 13_00.unity3d filename format
                var name = Path.GetFileNameWithoutExtension(fileName);

                if (name.Length == 5 && name[2] == '_')
                    return true;
            }
            return false;
        }

        private static bool IsDigitsOnly(string str)
        {
            foreach (var c in str)
                if (c < '0' || c > '9')
                    return false;

            return true;
        }

        private class SideloaderModInfo
        {
            public readonly string Guid;
            public readonly string Path;
            public readonly string Version;

            public SideloaderModInfo(string path, string guid, string version)
            {
                Path = path;
                Guid = guid;
                Version = version;
            }
        }

        public class VersionComparer : IComparer<string>
        {
            public int Compare(string x, string y)
            {
                if (x == y) return 0;
                var version = new { First = GetVersion(x), Second = GetVersion(y) };
                var limit = Math.Max(version.First.Length, version.Second.Length);
                for (var i = 0; i < limit; i++)
                {
                    var first = version.First.ElementAtOrDefault(i) ?? string.Empty;
                    var second = version.Second.ElementAtOrDefault(i) ?? string.Empty;
                    try
                    {
                        var result = first.CompareTo(second);
                        if (result != 0)
                            return result;
                    }
                    catch (ArgumentException)
                    {
                        if (first is string s1 && second is string s2)
                        {
                            // Handle invalid characters in strings by comparing them byte by byte
                            var result = string.CompareOrdinal(s1, s2);
                            if (result != 0)
                                return result;
                        }
                    }
                }
                return version.First.Length.CompareTo(version.Second.Length);
            }

            private IComparable[] GetVersion(string version)
            {
                return (from part in version.Trim().Split('.', ' ', '-', ',', '_')
                        select Parse(part)).ToArray();
            }

            private IComparable Parse(string version)
            {
                if (int.TryParse(version, out var result))
                    return result;
                return version;
            }
        }
    }
}