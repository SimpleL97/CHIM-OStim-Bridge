# Dependencies

What CHIM OStim Bridge needs, and exactly what each piece is used for.
None of these are bundled: the release ships only this mod's own files.

## To play

| Dependency | Link | Why it is needed |
|---|---|---|
| **Skyrim Special / Anniversary Edition** | - | The game. Tested on 1.6.1170. |
| **Dawnguard** and **Dragonborn** (DLC) | part of every SE/AE install | `Dawnguard.esm`: the vampire feeding idle `IdleVampireStandingFeedFront_Loose` (0x00E6A8) used by `Feed_On_Blood`; for the Vampire Lords the power `DLC1VampireChange` (0x00283B), the perk `DLC1VampireTurnPerk` (0x00588B) - the same steps as Dawnguard's `DLC1VampireTurnScript.ReceiveHarkonsGift`, with the bite played to its end first - the race `DLC1VampireBeastRace` (0x00283A) and the base records of the game's own Vampire Lords (recognised by default). `Skyrim.esm` also gives the disease `DiseaseSanguinareVampiris` (0x0B8780) and the `Vampire` keyword (0x0A82BB). `Dragonborn.esm`: Raven Rock (`DLC2RavenRockLocation`, 0x0143B9) for the city reactions. |
| **SKSE64** | [skse.silverlock.org](https://skse.silverlock.org/) | Script extender. The scripts use SKSE functions: `RegisterForModEvent` (receiving CHIM commands and OStim events), `GetDisplayName`, `GetWornForm`, `UnequipItemEx` / `EquipItemEx` (undress and dress back), `StringUtil` (parsing the partner names and settings), `Math.LeftShift`. |
| **Address Library for SKSE Plugins** | [Nexus 32444](https://www.nexusmods.com/skyrimspecialedition/mods/32444) | Not used by this mod directly. The SKSE plugins of CHIM and OStim Standalone need it to run on your game version. |
| **CHIM** (game plugin **and** server) | [Nexus 126330](https://www.nexusmods.com/skyrimspecialedition/mods/126330) | The AI side. In the game: the mod event `CHIM_CommandReceived` delivers the actions the AI chose, and the native `AIAgentFunctions` script is used for `getAgentByName`, `getClosestAgent`, `setAnimationBusy` (keeps CHIM from moving an agent during a scene) and `requestMessage` (reports results and events back to the AI) and `isActorTalking` (a bite waits for the line that announces it). On the server (HerikaServer, running in CHIM's WSL distro): the `ext/cob_ostim_bridge` plugin hooks into CHIM's request pipeline (`preprocessing.php`, `functions.php`, `prompts.php`, `context_pre.php` with `chimRegisterPromptInjection`) and stores its actions and state in CHIM's database (`core_action_custom`, `conf_opts`). CHIM's `ServerPluginSync` installs the bundled `Data/CHIM/server-plugins/cob_ostim_bridge/<version>.dwpkg` on its server at game start. Tested with 3.4.2. |
| **OStim Standalone** 7.3.1+ | [Nexus 98163](https://www.nexusmods.com/skyrimspecialedition/mods/98163) | The scenes themselves. `OThread` (`QuickStart`, `NavigateTo`, `Stop`, `GetActors`, `GetActorPosition`, `GetAllThreadIDs`), `OLibrary` (find a scene by action, by tag, or any scene), `OMetadata` (scene names, actions and tags for the AI), `OJSON` (scene info in events), and the mod events `ostim_thread_start`, `ostim_actor_orgasm`, `ostim_thread_end`. Tested with 7.5.1. |
| **PapyrusUtil SE/AE** | [Nexus 13048](https://www.nexusmods.com/skyrimspecialedition/mods/13048) | `PapyrusUtil` actor arrays (building the list of scene partners), `MiscUtil.ScanCellNPCs` (finding named NPCs nearby, and real game vampires), `StorageUtil` form lists (remembering exactly which clothes `Undress` took off, so `Get_Dressed` puts the same ones back). |
| **SkyUI** | [Nexus 12604](https://www.nexusmods.com/skyrimspecialedition/mods/12604) | The MCM framework: `SKI_ConfigBase` and `SKI_PlayerLoadGameAlias` (re-registers the menu on every game load), plus the `Interface/Translations` loader for the 12 menu languages. |
| **MCM Helper** | [Nexus 53000](https://www.nexusmods.com/skyrimspecialedition/mods/53000) | Builds the MCM from `MCM/Config/CHIMOStimBridge/config.json` and stores the settings. The scripts read them with `MCM.GetModSettingBool/Int/Float/String`; `COB_MCM` extends `MCM_ConfigBase`. |

Optional: OStim animation packs with 3+ actor scenes for group scenes
(for example [Billyy MFF Pack](https://www.nexusmods.com/skyrimspecialedition/mods/106582)).
Without them a group request falls back to the two main people.

## To build

See [BUILDING.md](BUILDING.md) for the steps.

| Tool / file | Used for |
|---|---|
| **Python 3.8+** (standard library only) | `make_esp.py` (writes the plugin), `localize.py` (MCM translations), `build.py` (server package + FOMOD zip), `verify_release.py`, `art/make_banner.py`. |
| **Windows PowerShell 5.1+** | `compile_scripts.ps1`, `art/render_banner.ps1`. |
| **Papyrus compiler** (`PapyrusCompiler.exe` + `TESV_Papyrus_Flags.flg`) | Compiling `src/Scripts/Source/*.psc` to `.pex`. Comes with the free Creation Kit (Steam). The 1.0.0 release was compiled with the identical Bethesda compiler bundled in Nemesis Unlimited Behavior Engine. |
| **Base game Papyrus sources** | Types such as `Actor`, `Quest`, `Debug`. Creation Kit: extract `Data\Scripts.zip`. Without the CK, `stubs/vanilla` has declaration-only stand-ins for the few types that are otherwise missing. |
| **Papyrus sources of SKSE, OStim Standalone, PapyrusUtil and CHIM** | Type checking only. Each of these mods installs its `.psc` files into `Data\Scripts\Source` or `Data\Source\Scripts`; nothing extra to download. |
| **SkyUI / MCM Helper sources** (optional) | Not needed: `stubs/MCM.psc`, `stubs/MCM_ConfigBase.psc` and `stubs/SKI_ConfigBase.psc` declare the few functions this mod calls. The real sources (SkyUI SDK, MCM Helper) work too and take precedence. |
| **Microsoft Edge** or any Chromium browser (optional) | Rendering the Nexus banner to PNG. |

### About the stubs

`stubs/` holds declaration-only `.psc` files: script names and function signatures,
no code. They exist only so the compiler can type-check calls into SkyUI, MCM Helper
and a few base game types when their sources are not installed. They are never
compiled into the release and never shipped; in the game the real scripts of those
mods run. They describe the public APIs of their respective owners (Bethesda,
the SkyUI team, Exit-9B) and are not covered by this repository's license.
