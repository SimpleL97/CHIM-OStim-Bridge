# Building CHIM OStim Bridge

This repository holds everything the Nexus release is made from. Every file in the
release archive is either a source file from here, copied as is, or is generated from
the sources by the scripts below. Nothing is edited by hand after the build.

## 1. What you need

- **Python 3.8+** - standard library only, no packages to install. On Windows use
  `py -3` or `python` instead of `python3` in the commands below; WSL works too.
- **Windows PowerShell 5.1+** (built into Windows) - for the Papyrus compile step.
- **Papyrus compiler** - `PapyrusCompiler.exe` and `TESV_Papyrus_Flags.flg`. The usual
  source is the free **Creation Kit** from Steam: it installs the compiler to
  `<Skyrim>\Papyrus Compiler\` and the base game sources as `Data\Scripts.zip`
  (extract it into `Data`; you get `Data\Source\Scripts\*.psc` including the flags file).
  The 1.0.0 release was compiled with the same Bethesda compiler as bundled in
  *Nemesis Unlimited Behavior Engine* (`Nemesis_Engine\Papyrus Compiler`).
- **The mods this one calls into, installed in the game** - SKSE64, OStim Standalone,
  PapyrusUtil and CHIM. Each installs its own `.psc` sources into `Data\Scripts\Source`
  or `Data\Source\Scripts`; the compiler reads them from there to type-check the calls.
  SkyUI and MCM Helper sources are not needed (see `stubs/`).

Exactly what each dependency is used for: [DEPENDENCIES.md](DEPENDENCIES.md).

## 2. Build, step by step

Run everything from the repository root.

### Step 1 - MCM translations (only after changing menu texts)

```
python3 -I localize.py
```

Reads the string table `T` inside `localize.py` (60 strings x 12 languages) and writes:

- `mcm/config.json` - the MCM Helper menu, with every visible text as a `$COB_...` key
- `mcm/translations/CHIMOStimBridge_<LANGUAGE>.txt` - one file per game language,
  UTF-16 LE with BOM, `$key<TAB>text` lines, CRLF (the format SkyUI requires). The 25
  game languages without a translation get a copy of English, because SkyUI has no
  fallback and would show raw `$keys`.

The outputs are committed, so this step can be skipped when the texts did not change.
Running it on an unchanged tree changes nothing.

### Step 2 - the game plugin

```
python3 -I make_esp.py
```

Writes `build/CHIMOStimBridge.esp` (732 bytes). The plugin has no art or world edits -
just three start-game-enabled quests that carry the scripts - so it is written byte by
byte from `make_esp.py` instead of being saved in the Creation Kit. The output is
deterministic: it is byte-identical to the released 1.0.0 plugin.

| FormID | EditorID | Script | Purpose |
|---|---|---|---|
| `xx000800` | `COB_BridgeQuest` | `COB_Bridge` | executes the AI actions |
| `xx000801` | `COB_EventsQuest` | `COB_Events` | events, needs, sends settings to CHIM |
| `xx000802` | `COB_MCMQuest` | `COB_MCM` + `SKI_PlayerLoadGameAlias` on a player alias | MCM menu |

ESL flagged, master `Skyrim.esm` only, author SaurOff.

### Step 3 - compile the Papyrus scripts

```
powershell -ExecutionPolicy Bypass -File compile_scripts.ps1 -Compiler "<folder with PapyrusCompiler.exe>" -GameData "<Skyrim>\Data"
```

Example with the Creation Kit:

```
powershell -ExecutionPolicy Bypass -File compile_scripts.ps1 -Compiler "C:\Steam\steamapps\common\Skyrim Special Edition\Papyrus Compiler" -GameData "C:\Steam\steamapps\common\Skyrim Special Edition\Data"
```

Compiles `src/Scripts/Source/COB_Config.psc`, `COB_Bridge.psc`, `COB_Events.psc`,
`COB_MCM.psc` into `build/Scripts/*.pex`. Import order: `src/Scripts/Source`, the game's
`Data\Scripts\Source` and `Data\Source\Scripts`, any `-Imports` you add, then `stubs` and
`stubs/vanilla`. The compiler takes the first file it finds for each type, so real
sources always win and the stubs only fill gaps. Options: `-Flags <path to .flg>` if it is
not found automatically, `-Out <folder>` for another output folder.

Note: Bethesda's compiler writes the compile time and an unordered string table into
each `.pex`, so two compiles of the same source never match byte for byte. The size and
the code are the same.

### Step 4 - package

```
python3 -I build.py [release folder]
```

Default release folder: `release/`. `build.py` first checks that the version is the same
in all four places (see *Versioning*), then:

1. Builds the CHIM server plugin package `build/cob_ostim_bridge-<version>.dwpkg`
   from `server/cob_ostim_bridge/`.
2. Lays out the FOMOD tree in `build/stage/`.
3. Zips it to `<release folder>/CHIM OStim Bridge.zip`. The current release never has a
   version in its name; if that file already holds an older version, it is first moved
   to `<release folder>/archive/CHIM OStim Bridge-<old version>.zip`. Rebuilding the
   same version just replaces the file.

### Step 5 - check the archive

```
python3 -I verify_release.py "release/CHIM OStim Bridge.zip"
```

Compares every file in the zip with its source or build output, checks that each `.pex`
is newer than its `.psc`, and that every translation file has every menu key. Optional
extra arguments compare against a live CHIM server plugin folder and an installed game
`Data` folder: `verify_release.py <zip> <HerikaServer/ext/cob_ostim_bridge> <Data>`.

## 3. Where every file in the release comes from

| In the release zip | Source in this repository | Made by |
|---|---|---|
| `fomod/info.xml`, `fomod/ModuleConfig.xml` | `fomod/` | copied |
| `README.txt`, `CHANGELOG.txt` | `docs/` | copied |
| `00 Core/CHIMOStimBridge.esp` | `make_esp.py` | step 2 |
| `00 Core/Scripts/COB_*.pex` | `src/Scripts/Source/COB_*.psc` | step 3 |
| `00 Core/MCM/Config/CHIMOStimBridge/config.json`, `settings.ini` | `mcm/` | copied (config.json from step 1) |
| `00 Core/Interface/Translations/CHIMOStimBridge_*.txt` | `mcm/translations/` | copied (from step 1) |
| `00 Core/CHIM/server-plugins/cob_ostim_bridge/<version>.dwpkg` | `server/cob_ostim_bridge/*` | step 4 |
| `10 Server Tools/CHIM OStim Bridge Server Tools/*.bat, *.ps1` | `server/*.bat`, `server/*.ps1` | copied |
| `10 Server Tools/CHIM OStim Bridge Server Tools/cob_ostim_bridge/*` | `server/cob_ostim_bridge/*` | copied |
| `20 Source/Source/Scripts/COB_*.psc` | `src/Scripts/Source/` | copied |

FOMOD options: `00 Core` is always installed. `10 Server Tools` (manual install of the
server plugin, for CHIM versions that do not install bundled server plugins) and
`20 Source` (the `.psc` files) are optional.

### The `.dwpkg` server package

A plain zip in the format CHIM's `ServerPluginSync` / `DwemerPluginPackageManager` reads:

```
manifest.json      {"schema_version": 4, "name": "cob_ostim_bridge", "version": "1.0.1",
                    "author": "SaurOff", "description": "...", "server": {"mutable_paths": []}}
checksums.sha256   sha256 of every other file in the package
server/cob_lib.php, context_pre.php, functions.php, manifest.json, preprocessing.php, prompts.php
```

It is installed in the game at `Data/CHIM/server-plugins/cob_ostim_bridge/<version>.dwpkg`.
At game start CHIM's SKSE plugin uploads every package there to its server, which unpacks
`server/` to `HerikaServer/ext/cob_ostim_bridge/`. A package is only re-installed when its
version changes. The PHP files are the same as in `server/cob_ostim_bridge/`; read them there.

### The `.bat` / `.ps1` server tools

`Install-ServerPlugin.bat` starts `Install-ServerPlugin.ps1`, which finds the WSL distro
running the CHIM server (normally `DwemerAI4Skyrim3`) and copies the `cob_ostim_bridge`
folder next to it into `/var/www/html/HerikaServer/ext/`. `Uninstall-ServerPlugin.*`
removes that folder, and the plugin's six actions and its stored settings and state from
CHIM's database (`core_action_custom` rows `ExtCmdCOB_*`, `conf_opts` rows
`cob_ostim_bridge*`). They do nothing
else, download nothing and change no system settings; read them in `server/`.

## 4. Versioning

The version must be the same in four places - `build.py` stops if they differ:

- `server/cob_ostim_bridge/cob_lib.php` - `const COB_VERSION`
- `server/cob_ostim_bridge/manifest.json` - `"version"`
- `fomod/info.xml` - `MachineVersion` and the text
- `src/Scripts/Source/COB_Config.psc` - `Version()`

Also update `docs/CHANGELOG.txt` and the version line in `docs/README.txt`. Every
published change needs a new version: CHIM only re-installs the server package when the
version changes.

## 5. Other files

- `docs/NEXUS_DESCRIPTION.bbcode.txt`, `docs/NEXUS_UPLOAD_FIELDS.txt` - the Nexus page
  text and upload form values. Not part of the archive.
- `art/make_banner.py` -> `art/banner.svg` / `banner.html`; `art/render_banner.ps1`
  renders it to `art/banner.png` (1920x1080) with Edge headless. Original artwork, no
  third-party logos.
- `stubs/` - declaration-only Papyrus files for the compiler; see DEPENDENCIES.md.

## 6. Quick test in game

1. Install the release zip with Vortex or MO2 (choose nothing extra in the installer).
2. Start the CHIM server, then the game, and load a save.
3. `SKSE/AIAgent.log` should contain `[SERVER_PLUGIN_SYNC] Installed cob_ostim_bridge`,
   and the CHIM server should have `HerikaServer/ext/cob_ostim_bridge/`.
4. The MCM *CHIM OStim Bridge* appears; turn on *Show notifications* and ask an AI
   follower to kiss you - the action result is shown in the top left corner.
