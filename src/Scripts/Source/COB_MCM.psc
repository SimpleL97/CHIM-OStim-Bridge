Scriptname COB_MCM extends MCM_ConfigBase
{CHIM OStim Bridge by SaurOff - the MCM (MCM Helper reads MCM/Config/CHIMOStimBridge/config.json).
 Any change is pushed to the CHIM server on the next COB_Events poll.}

Event OnConfigInit()
	Push()
EndEvent

Event OnSettingChange(string a_ID)
	Push()
EndEvent

Event OnGameReload()
	parent.OnGameReload()
	Push()
EndEvent

Function Push()
	COB_Events ev = Game.GetFormFromFile(0x000801, "CHIMOStimBridge.esp") as COB_Events
	If ev
		ev.ConfigChanged()
	EndIf
EndFunction
