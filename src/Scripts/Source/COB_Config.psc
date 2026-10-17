Scriptname COB_Config Hidden
{CHIM OStim Bridge by SaurOff - reads the MCM Helper settings (MCM/Config/CHIMOStimBridge).}

string Function ModName() global
	Return "CHIMOStimBridge"
EndFunction

string Function Version() global
	Return "2.0.0"
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

; CHIM lists the people around as "Name [RefID: FE07FE69]" and the model often copies that
; into a target. NameOf gives the name part; RefActor the actor the RefID points to, which is
; exact even when several NPCs share the name (None without a RefID).
string Function NameOf(string s) global
	int i = StringUtil.Find(s, "[RefID")
	If i > -1
		s = StringUtil.Substring(s, 0, i)
	EndIf
	Return Trim(s)
EndFunction

Actor Function RefActor(string s) global
	int i = StringUtil.Find(s, "RefID")
	If i < 0
		Return None
	EndIf
	i += 5
	int n = StringUtil.GetLength(s)
	int id = 0
	int digits = 0
	While i < n && digits < 8
		string c = StringUtil.GetNthChar(s, i)
		int d = StringUtil.Find("0123456789ABCDEFabcdef", c)
		If d > 15
			d -= 6
		EndIf
		If d > -1
			id = Math.LogicalOr(Math.LeftShift(id, 4), d)
			digits += 1
		ElseIf digits > 0
			i = n ; the end of the number
		EndIf
		i += 1
	EndWhile
	If digits == 0
		Return None
	EndIf
	Return Game.GetFormEx(id) as Actor
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

; something worth knowing: always in the log file (MCM), on screen when notifications are on
Function Note(string msg) global
	Debug.Trace("[CHIM OStim Bridge] " + msg)
	Log(msg)
	If B("bNotify:Debug")
		Debug.Notification("COB: " + msg)
	EndIf
EndFunction

; Data/SKSE/Plugins/CHIMOStimBridge.log - one game launch per file (COB_Events starts it)
Function Log(string msg) global
	If B("bLog:Debug")
		MiscUtil.WriteToFile("Data/SKSE/Plugins/CHIMOStimBridge.log", msg + "\n", True, True)
	EndIf
EndFunction

Function NewLog() global
	If B("bLog:Debug")
		MiscUtil.WriteToFile("Data/SKSE/Plugins/CHIMOStimBridge.log", "==== CHIM OStim Bridge " + Version() + " - game started ====\n", False, True)
	EndIf
EndFunction
