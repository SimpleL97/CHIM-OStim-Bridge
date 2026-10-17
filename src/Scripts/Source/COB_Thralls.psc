Scriptname COB_Thralls Hidden
{CHIM OStim Bridge by SaurOff - thralls of the Vampire Lords.
 A Vampire Lord (an AI agent, or the player once they are one) bites someone who is not
 a Vampire Lord - ordinary vampires included - and binds their will: from then on they
 obey their master and the player in everything (the CHIM server tells them so), are on
 the player's side and never turn hostile. The same bite on one's own thrall sets them
 free. Shared by COB_Bridge (the AI actions Enthrall / Release_Thrall) and
 COB_EnthrallEffect (the player's lesser power "Vampire's Thrall").
 Kept in StorageUtil: form list "COB_Thralls", per thrall "COB_ThrallMaster" (name),
 "COB_ThrallAggression" (to restore) and "COB_ThrallTeammate".}

bool Function IsThrall(Actor a) Global
	Return a && StorageUtil.FormListFind(None, "COB_Thralls", a) > -1
EndFunction

; the player counts once they have Dawnguard's Vampire Lord power
bool Function IsLord(Actor a) Global
	If a == Game.GetPlayer()
		Spell lordPower = Game.GetFormFromFile(0x00283B, "Dawnguard.esm") as Spell ; DLC1VampireChange
		Return lordPower && a.HasSpell(lordPower)
	EndIf
	Return COB_Config.IsVampireLord(a)
EndFunction

; why master cannot enthrall target right now, or "" when they can
string Function Refusal(Actor master, Actor target) Global
	If !COB_Config.B("bThralls:Needs")
		Return "cannot: enthralling is turned off in the MCM"
	EndIf
	If !IsLord(master)
		Return "cannot: only a Vampire Lord can enthrall"
	EndIf
	If !target || target == master || target == Game.GetPlayer()
		Return "cannot: nobody to enthrall"
	EndIf
	string who = target.GetDisplayName()
	If target.IsDead() || target.IsChild()
		Return "cannot: " + who + " cannot be enthralled"
	EndIf
	If IsLord(target)
		Return "cannot: " + who + " is a Vampire Lord too; their blood is as strong"
	EndIf
	If master.IsInCombat() || target.IsInCombat()
		Return "refuses: not in the middle of a fight"
	EndIf
	If OThreadOf(master) || OThreadOf(target)
		Return "cannot: busy in a scene"
	EndIf
	Return ""
EndFunction

bool Function OThreadOf(Actor a) Global
	int[] ids = OThread.GetAllThreadIDs()
	int i = 0
	While i < ids.Length
		If OThread.GetActorPosition(ids[i], a) > -1
			Return True
		EndIf
		i += 1
	EndWhile
	Return False
EndFunction

; the bite, then the thrall (or freedom for one's own thrall). Returns the outcome.
string Function Bite(Actor master, Actor target) Global
	If IsThrall(target)
		If StorageUtil.GetStringValue(target, "COB_ThrallMaster") == master.GetDisplayName() || master == Game.GetPlayer()
			Return Release(target)
		EndIf
		Return "nothing to do: " + target.GetDisplayName() + " already is a thrall of " + StorageUtil.GetStringValue(target, "COB_ThrallMaster")
	EndIf
	string why = Refusal(master, target)
	If why != ""
		Return why
	EndIf
	COB_Bridge bridge = Game.GetFormFromFile(0x000800, "CHIMOStimBridge.esp") as COB_Bridge
	If bridge
		bridge.BringTogether(master, target)
		bridge.PlayBite(master, target)
	EndIf
	Return Bind(target, master)
EndFunction

string Function Bind(Actor target, Actor master) Global
	Actor player = Game.GetPlayer()
	string who = target.GetDisplayName()
	string lord = master.GetDisplayName()
	StorageUtil.FormListAdd(None, "COB_Thralls", target, False)
	StorageUtil.SetStringValue(target, "COB_ThrallMaster", lord)
	StorageUtil.SetFloatValue(target, "COB_ThrallAggression", target.GetBaseActorValue("Aggression"))
	target.StopCombat()
	target.StopCombatAlarm()
	target.SetActorValue("Aggression", 0.0)
	target.SetRelationshipRank(player, 3)
	player.SetRelationshipRank(target, 3)
	If COB_Config.B("bThrallTeammate:Needs") && !target.IsPlayerTeammate()
		target.SetPlayerTeammate(True)
		StorageUtil.SetIntValue(target, "COB_ThrallTeammate", 1)
	EndIf
	SendThralls()
	string result = who + " is now the thrall of " + lord
	If master != player
		result += " and " + player.GetDisplayName()
	EndIf
	result += ": their will is bound, they obey every order"
	COB_Config.Note(result)
	If COB_Config.B("bEnabled:General")
		AIAgentFunctions.requestMessage("(" + lord + " bit " + who + " and bound their will: " + who + " is now a thrall and obeys " + lord + " and " + player.GetDisplayName() + " in everything)", "cob_thrall")
	EndIf
	Return result
EndFunction

string Function Release(Actor target) Global
	string who = target.GetDisplayName()
	StorageUtil.FormListRemove(None, "COB_Thralls", target, True)
	target.SetActorValue("Aggression", StorageUtil.GetFloatValue(target, "COB_ThrallAggression", target.GetBaseActorValue("Aggression")))
	If StorageUtil.GetIntValue(target, "COB_ThrallTeammate") == 1
		target.SetPlayerTeammate(False)
	EndIf
	StorageUtil.UnsetStringValue(target, "COB_ThrallMaster")
	StorageUtil.UnsetFloatValue(target, "COB_ThrallAggression")
	StorageUtil.UnsetIntValue(target, "COB_ThrallTeammate")
	SendThralls()
	COB_Config.Note(who + " is free again")
	If COB_Config.B("bEnabled:General")
		AIAgentFunctions.requestMessage("(" + who + " was released from the thrall and has their own will again)", "cob_thrall")
	EndIf
	Return who + " is released and has their own will again"
EndFunction

; "thralls|Name=Master,Name2=Master2" (or "thralls|-" when there are none) for the server
Function SendThralls() Global
	string s = ""
	int i = StorageUtil.FormListCount(None, "COB_Thralls") - 1
	While i >= 0
		Actor a = StorageUtil.FormListGet(None, "COB_Thralls", i) as Actor
		If !a || a.IsDead()
			StorageUtil.FormListRemoveAt(None, "COB_Thralls", i)
		Else
			If s != ""
				s += ","
			EndIf
			s += Clean(a.GetDisplayName()) + "=" + Clean(StorageUtil.GetStringValue(a, "COB_ThrallMaster"))
		EndIf
		i -= 1
	EndWhile
	If s == ""
		s = "-"
	EndIf
	AIAgentFunctions.requestMessage("thralls|" + s, "cob_state")
EndFunction

string Function Clean(string s) Global
	string out = ""
	int i = 0
	int n = StringUtil.GetLength(s)
	While i < n
		string c = StringUtil.GetNthChar(s, i)
		If c != "\"" && c != "\\" && c != "|" && c != "~" && c != "," && c != "="
			out += c
		EndIf
		i += 1
	EndWhile
	Return out
EndFunction

; the player's lesser power comes with being a Vampire Lord (and goes when they are cured)
Function UpdatePlayerPower() Global
	Actor p = Game.GetPlayer()
	Spell power = Game.GetFormFromFile(0x000804, "CHIMOStimBridge.esp") as Spell ; COB_ThrallPower
	If !power
		Return
	EndIf
	bool want = COB_Config.B("bThralls:Needs") && COB_Config.B("bThrallPower:Needs") && IsLord(p)
	If want && !p.HasSpell(power)
		p.AddSpell(power, False)
		Debug.Notification("You can bind a mortal's will with a bite: Vampire's Thrall")
	ElseIf !want && p.HasSpell(power)
		p.RemoveSpell(power)
	EndIf
EndFunction
