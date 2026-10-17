Scriptname COB_Config Hidden
{CHIM OStim Bridge by SaurOff - reads the MCM Helper settings (MCM/Config/CHIMOStimBridge).}

string Function ModName() global
	Return "CHIMOStimBridge"
EndFunction

string Function Version() global
	Return "1.2.0"
EndFunction

bool Function B(string id) global
	Return MCM.GetModSettingBool("CHIMOStimBridge", id)
EndFunction

int Function I(string id) global
	Return MCM.GetModSettingInt("CHIMOStimBridge", id)
EndFunction

float Function F(string id) global
	Return MCM.GetModSettingFloat("CHIMOStimBridge", id)
EndFunction

string Function S(string id) global
	Return MCM.GetModSettingString("CHIMOStimBridge", id)
EndFunction

; is name one of the comma separated names in the setting (case-insensitive, Papyrus == ignores case)
bool Function InList(string id, string name) global
	string[] names = StringUtil.Split(S(id), ",")
	int i = 0
	While i < names.Length
		If Trim(names[i]) == name
			Return True
		EndIf
		i += 1
	EndWhile
	Return False
EndFunction

; a real game vampire (Vampire keyword), anyone listed in the MCM, or an NPC this mod
; turned after an untreated bite (StorageUtil list "COB_Turned")
bool Function IsVampire(Actor a) global
	If !a
		Return False
	EndIf
	Keyword kVampire = Game.GetFormFromFile(0x0A82BB, "Skyrim.esm") as Keyword
	If kVampire && a.HasKeyword(kVampire)
		Return True
	EndIf
	If StorageUtil.FormListFind(None, "COB_Turned", a) > -1
		Return True
	EndIf
	Return InList("sVampires:Needs", a.GetDisplayName()) || IsVampireLord(a)
EndFunction

; Dawnguard's Vampire Lords (the base records below, including the disguised Vampire Lords of the radiant
; quests), anyone in Vampire Lord form right now, and anyone listed in the MCM
bool Function IsVampireLord(Actor a) global
	If !a
		Return False
	EndIf
	If InList("sVampireLords:Needs", a.GetDisplayName())
		Return True
	EndIf
	If a.GetRace() == Game.GetFormFromFile(0x00283A, "Dawnguard.esm") as Race ; DLC1VampireBeastRace
		Return True
	EndIf
	ActorBase b = a.GetLeveledActorBase()
	If !b
		Return False
	EndIf
	int[] lords = new int[7]
	lords[0] = 0x002B6C ; DLC1Serana
	lords[1] = 0x003BA7 ; DLC1Harkon
	lords[2] = 0x01A93D ; DLC1HarkonCombat
	lords[3] = 0x00EC1C ; DLC1HarkonCombatMelee
	lords[4] = 0x00EC8A ; DLC1HarkonCombatMagic
	lords[5] = 0x00D1BE ; DLC1dunHarkonFontActor
	lords[6] = 0x004208 ; DLC1RadiantDisguisedVampireLord
	int i = 0
	While i < lords.Length
		If b == Game.GetFormFromFile(lords[i], "Dawnguard.esm")
			Return True
		EndIf
		i += 1
	EndWhile
	Return False
EndFunction

; CHIM's "animation busy" flag keeps an agent from being moved during a scene. The bridge
; only ever clears the flag on actors it set it on itself (StorageUtil list "COB_Busy"):
; clearing it on an agent CHIM did not have marked busy - say a companion in a scene some
; other mod started - broke CHIM's command queue for that agent (a null read on every
; following command until the game was restarted).
Function SetBusy(Actor a) global
	If a && a != Game.GetPlayer()
		AIAgentFunctions.setAnimationBusy(1, a.GetDisplayName())
		StorageUtil.FormListAdd(None, "COB_Busy", a, False)
	EndIf
EndFunction

Function ClearBusy(Actor a) global
	If a && StorageUtil.FormListFind(None, "COB_Busy", a) > -1
		StorageUtil.FormListRemove(None, "COB_Busy", a, True)
		AIAgentFunctions.setAnimationBusy(0, a.GetDisplayName())
	EndIf
EndFunction

; the game's own vampirism disease
Spell Function SanguinareVampiris() global
	Return Game.GetFormFromFile(0x0B8780, "Skyrim.esm") as Spell ; DiseaseSanguinareVampiris
EndFunction

string Function Trim(string s) global
	While StringUtil.GetLength(s) > 0 && StringUtil.GetNthChar(s, 0) == " "
		s = StringUtil.Substring(s, 1)
	EndWhile
	While StringUtil.GetLength(s) > 0 && StringUtil.GetNthChar(s, StringUtil.GetLength(s) - 1) == " "
		s = StringUtil.Substring(s, 0, StringUtil.GetLength(s) - 1)
	EndWhile
	Return s
EndFunction

; percent chance roll, 0..100
bool Function Roll(int chance) global
	If chance >= 100
		Return True
	EndIf
	If chance <= 0
		Return False
	EndIf
	Return Utility.RandomInt(1, 100) <= chance
EndFunction

Function Note(string msg) global
	Debug.Trace("[CHIM OStim Bridge] " + msg)
	If B("bNotify:Debug")
		Debug.Notification("COB: " + msg)
	EndIf
EndFunction
