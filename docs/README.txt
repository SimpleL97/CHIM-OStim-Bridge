CHIM OStim Bridge 1.0.1 by SaurOff
==================================

Lets CHIM AI agents use OStim Standalone by themselves, react to the world, and
live with a few simple needs. Everything is configured in the MCM.


REQUIREMENTS
------------
- Skyrim Special / Anniversary Edition with SKSE64 and Address Library
- CHIM (AI agents, Nexus 126330), plugin and server (tested with 3.4.2)
- OStim Standalone 7.3.1 or newer (Nexus 98163, tested with 7.5.1)
- PapyrusUtil SE/AE (Nexus 13048)
- SkyUI (Nexus 12604)
- MCM Helper (Nexus 53000)
- Dawnguard (for the blood-feeding animation; part of every SE/AE install)
Optional: OStim animation packs with 3+ actor scenes for group scenes
(for example Billyy MFF Pack, Nexus 106582).


INSTALLATION
------------
1. Install with Vortex or MO2 and enable CHIMOStimBridge.esp (ESL flagged,
   it does not use a load order slot). Load order does not matter.
2. Start the CHIM server as usual, then the game. The server side installs
   itself: the mod ships it as Data/CHIM/server-plugins/cob_ostim_bridge/1.0.1.dwpkg,
   and CHIM's game plugin uploads bundled server plugins to its server at startup
   (HerikaServer/ext/cob_ostim_bridge). The six actions are added to CHIM's
   action list on the first request.
3. Load a save. The MCM "CHIM OStim Bridge" appears after a few seconds.

If your CHIM version does not install bundled server plugins (the CHIM log
SKSE/AIAgent.log has no "[SERVER_PLUGIN_SYNC] Installed cob_ostim_bridge" line),
choose "Manual server install tools" in the installer and run
CHIM OStim Bridge Server Tools/Install-ServerPlugin.bat once (Vortex: right
click the mod > Open in File Manager).

Updating: install the new version; CHIM updates the server side on the next
game start.
Uninstalling: run Uninstall-ServerPlugin.bat from the manual tools (removes the
server folder and the six actions), then remove the mod.


The MCM is translated into English, Russian, Ukrainian, German, French, Spanish, Italian, Polish, Czech, Portuguese, Japanese and Chinese and follows the game language; other game languages show it in English.


WHAT IT DOES
------------
Actions the AI can use (they show up in CHIM's action list and can be switched
off there like any other action):
  Start_Intimate_Scene   start an OStim scene with you, another NPC, or a group.
                         "target" = partners (comma separated), "item" = the
                         kind: oral, cunnilingus, vaginal, anal, handjob, boobjob,
                         kissing, sixtynine, cowgirl, reverse cowgirl,
                         doggystyle, missionary.
  Change_Intimate_Scene  switch the running scene to another act or position.
  Stop_Intimate_Scene    end the scene.
  Undress / Get_Dressed  take clothes off without a scene and put exactly those
                         back on later.
  Feed_On_Blood          vampires only (real game vampires, or NPCs you list in
                         the MCM): bite someone present.
Every outcome is reported back to CHIM, so a refused action ("weapons are still
drawn", "she is not here") is answered in character instead of failing quietly.

Scene logic:
  - Men take the active role (no strap-ons for the woman who started it).
  - Partners up to 50 m away (MCM) are brought next to each other at scene start.
  - Any nearby NPC can be named as a partner, not only NPCs CHIM knows.
  - Who takes part: no name = the agent and you; one name = the agent and that
    person; two or more names = exactly those people (the agent can arrange a
    scene for others and just watch).
  - When the asked act or position is not installed, a missionary scene is used,
    then any scene; when no animation fits the whole group, the two main people.
  - When the people involved agree on it in conversation (even among
    themselves), the agent starts it without a separate order from you.

Reactions (MCM toggles, chance and cooldown): entering, leaving and travelling
between the big cities, shops, your own home, waking up, dragon souls, you
undressing, a scene starting nearby, and talking after a scene (who came and how
it ended is passed to the AI).

Needs (MCM: names of the NPCs it applies to):
  - Hunger for sex: restless, then burning, then angry the longer it has been.
  - Blood thirst for vampires: thirsty, then starving.
  - Drinking: any agent who drinks ale, mead or wine gets tipsy, then drunk;
    it wears off with game time.
  - Arousal during a scene and right after it.
  - Jealousy between the companions you list when one gets much more attention.

CHIM fixes (MCM):
  - Speech only: NPC lines stay spoken words, no third-person self-narration
    ("she smiles and steps closer...") read out by the voice.
  - Nobody talks after a long session: CHIM compares new requests against player
    input stamped by a counter that restarts with the game; after a long session
    every reply is aborted. The stale stamps are reset on game load.


COMPATIBILITY
-------------
- Uses its own plugin, scripts (COB_*) and CHIM action codes (ExtCmdCOB_*).
- Do not install it together with other mods that add the same action names to
  CHIM (Start_Intimate_Scene, ...): the installer skips names already in use and
  logs it in the CHIM server log.
- Safe to add to an existing save. To remove: uninstall the server plugin first.


TROUBLESHOOTING
---------------
- The AI never starts scenes: check that HerikaServer/ext/cob_ostim_bridge exists
  and that the actions are enabled in CHIM's action list. Turn on "Show
  notifications" in the MCM to see every action result in game.
- MCM missing: SkyUI and MCM Helper must be installed; wait a few seconds after
  loading.
- Group scenes fall back to two people: no installed animation fits that group.


CREDITS
-------
CHIM by Dwemer Dynamics, OStim Standalone by the OStim team, PapyrusUtil by
exiledviper and meh321, SkyUI by the SkyUI team, MCM Helper by Exit-9B.
