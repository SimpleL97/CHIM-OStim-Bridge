Scriptname COB_Config Hidden
{CHIM OStim Bridge by SaurOff - reads the MCM Helper settings (MCM/Config/CHIMOStimBridge).}

string Function ModName() global
	Return "CHIMOStimBridge"
EndFunction

string Function Version() global
	Return "1.0.0"
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
