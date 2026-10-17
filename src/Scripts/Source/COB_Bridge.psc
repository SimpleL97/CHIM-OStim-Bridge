Scriptname COB_Bridge extends Quest
{CHIM OStim Bridge by SaurOff.
 Lets CHIM AI agents start, change and stop OStim scenes, and undress and dress.
 (The vampire actions moved to CHIM Vampire Bridge in 2.0; its thralls - StorageUtil list
 "COV_Thralls" - can still be undressed and brought into scenes here by name.)
 CHIM hands the actions over through COB.DispatchExternalCommand, which forwards
 them as the mod event "COB_Command" (npc name, command, parameter); CHIM's own
 fallback event "CHIM_CommandReceived" is heard too. Every outcome is reported
 back to CHIM as a "funcret" so the agent knows what really happened.
 Server half: HerikaServer/ext/cob_ostim_bridge.}

; Real time of the last scene this bridge started or stopped. COB_Events reads it
; so a scene the AI started itself is not announced a second time.
float Property LastBridgeAction = 0.0 Auto Hidden

string Property UndressKey = "COB_Undressed" AutoReadOnly Hidden

; the agent of the last command, in case a parameter carries no name
string LastCommandNpc = ""
string LastCommandKey = ""
float LastCommandTime = -100.0

; ---------------------------------------------------------------- registration

Event OnInit()
	Hook()
	RegisterForSingleUpdate(15.0)
EndEvent

Event OnUpdate()
	; CHIM's SKSE plugin can finish loading after this quest starts
	Hook()
EndEvent

; COB_Events calls this too, so the registration survives whatever happens to a save
Function Hook()
	RegisterForModEvent("COB_Command", "OnChimCommand")          ; from COB.DispatchExternalCommand
	RegisterForModEvent("CHIM_CommandReceived", "OnChimCommand") ; CHIM's fallback path
EndFunction

; ---------------------------------------------------------------- entry point

Event OnChimCommand(String npcname, String command, String parameter)
	If StringUtil.Find(command, "ExtCmdCOB_") != 0
		Return
	EndIf
	; the same command can come in both ways; act on it once. Real time restarts with
	; the game, so a time from before a restart (now < LastCommandTime) never matches.
	float now = Utility.GetCurrentRealTime()
	String cmdKey = command + "@" + parameter
	If cmdKey == LastCommandKey && now >= LastCommandTime && now - LastCommandTime < 5.0
		Return
	EndIf
	LastCommandKey = cmdKey
	LastCommandTime = now
	LastCommandNpc = npcname
	COB_Config.Log("command " + command + " from " + npcname + ": " + parameter)
	If !COB_Config.B("bEnabled:General")
		Report(command, parameter, "cannot: the CHIM OStim Bridge is turned off in its MCM")
		Return
	EndIf
	If command == "ExtCmdCOB_StartScene"
		StartScene(command, parameter)
	ElseIf command == "ExtCmdCOB_ChangeScene"
		ChangeScene(command, parameter)
	ElseIf command == "ExtCmdCOB_StopScene"
		StopScene(command, parameter)
	ElseIf command == "ExtCmdCOB_Undress"
		Undress(command, parameter)
	ElseIf command == "ExtCmdCOB_Redress"
		Redress(command, parameter)
	Else
		; an action of an older version (the vampire ones live in CHIM Vampire Bridge now)
		Report(command, parameter, "cannot: this action is not part of the CHIM OStim Bridge any more")
	EndIf
EndEvent

; ---------------------------------------------------------------- scenes

; parameter: "<agent>~<partners, comma separated>~<OStim action types CSV>~<scene tags CSV>"
; "-" marks an empty field. The server maps the model's words ("oral", "doggystyle")
; to OStim action types and scene tags.
Function StartScene(String command, String parameter)
	Actor initiator = ResolveInitiator(parameter)
	If !initiator
		Report(command, parameter, "cannot start: the AI agent could not be identified in the game")
		Return
	EndIf

	; Who takes part:
	;   no name        the agent and the player
	;   one name       the agent and that person
	;   two or more    exactly the people named; the agent only if she named herself
	;                  (she may just be arranging it, e.g. the player and one other person while she watches)
	Actor player = Game.GetPlayer()
	Actor[] named = new Actor[16]
	Int count = 0
	String[] names = StringUtil.Split(ArgOf(parameter, 1), ",")
	Int i = 0
	While i < names.Length && count < 16
		String name = COB_Config.Trim(names[i])
		If name != ""
			Actor p = ResolvePartnerName(name)
			If !p
				Report(command, parameter, "cannot start: " + name + " is not here")
				Return
			EndIf
			If named.Find(p) < 0
				named[count] = p
				count += 1
			EndIf
		EndIf
		i += 1
	EndWhile
	bool selfNamed = named.Find(initiator) > -1
	; the agent alone, pleasuring herself: only her own name, and a solo kind of scene
	; (the server fills in her name when the target was left empty)
	bool solo = count == 1 && selfNamed && IsSoloKind(ArgOf(parameter, 2))
	bool agentTakesPart = count < 2 || selfNamed
	If count >= 2 && !COB_Config.B("bGroups:General")
		count = 1 ; groups off: only the first named partner
		agentTakesPart = True
	EndIf

	Actor[] acts = PapyrusUtil.ActorArray(1)
	If agentTakesPart
		acts[0] = initiator
	Else
		acts[0] = named[0]
	EndIf
	i = 0
	While i < count
		If PapyrusUtil.CountActor(acts, named[i]) == 0
			acts = PapyrusUtil.PushActor(acts, named[i])
		EndIf
		i += 1
	EndWhile
	If acts.Length == 1 && acts[0] != player && !solo
		acts = PapyrusUtil.PushActor(acts, player) ; nobody else named: the player
	EndIf
	If solo
		StartSolo(command, parameter, initiator)
		Return
	EndIf
	If acts.Length == 1
		Report(command, parameter, "cannot start: initiator and partner are the same person")
		Return
	EndIf

	i = 0
	While i < acts.Length
		Actor a = acts[i]
		If ThreadOf(a) > -1
			Report(command, parameter, "cannot start: " + a.GetDisplayName() + " is already busy in a scene")
			Return
		EndIf
		If a.IsInCombat() || a.GetCombatState() > 0
			Report(command, parameter, "refuses: there is a fight going on")
			Return
		EndIf
		If a.IsWeaponDrawn()
			Report(command, parameter, "refuses: weapons are still drawn, this is not a safe moment")
			Return
		EndIf
		If a.IsBleedingOut() || a.IsDead()
			Report(command, parameter, "refuses: someone is badly hurt")
			Return
		EndIf
		If a.GetActorValuePercentage("Health") < 0.7
			Report(command, parameter, "refuses: wounds need tending first")
			Return
		EndIf
		i += 1
	EndWhile

	; everyone gathers at the player when the player takes part, otherwise at the first one
	Actor anchor = acts[0]
	If acts.Find(player) > -1
		anchor = player
	EndIf
	i = 0
	While i < acts.Length
		If acts[i] != anchor && !BringTogether(anchor, acts[i])
			Report(command, parameter, "cannot start: " + acts[i].GetDisplayName() + " is too far away")
			Return
		EndIf
		i += 1
	EndWhile

	; OStim gives the first actor the active role
	If COB_Config.B("bMenActive:General")
		SortByRole(acts)
	EndIf

	String actions = ArgOf(parameter, 2)
	String tags = ArgOf(parameter, 3)
	String sceneId = PickScene(acts, actions, tags)
	String note = ""
	If sceneId == "" && acts.Length > 2
		; no animation for that many people: the two most active ones
		Actor[] pair = PapyrusUtil.ActorArray(2)
		pair[0] = acts[0]
		pair[1] = acts[1]
		acts = pair
		sceneId = PickScene(acts, actions, tags)
		note = " (there is no animation for all of them together, so just " + acts[0].GetDisplayName() + " and " + acts[1].GetDisplayName() + ")"
	EndIf
	If (actions != "" || tags != "") && sceneId != "" && !SceneMatches(sceneId, actions, tags)
		note += " (that exact act or position is not available, so " + OMetadata.GetName(sceneId) + " instead)"
	EndIf

	i = 0
	While i < acts.Length
		If acts[i] != player
			COB_Config.SetBusy(acts[i])
		EndIf
		i += 1
	EndWhile
	LastBridgeAction = Utility.GetCurrentRealTime()
	Int tid = OThread.QuickStart(acts, sceneId)
	If tid < 0
		i = 0
		While i < acts.Length
			If acts[i] != player
				COB_Config.ClearBusy(acts[i])
			EndIf
			i += 1
		EndWhile
		Report(command, parameter, "cannot start: OStim refused the scene")
		Return
	EndIf

	String what = ""
	If sceneId != ""
		what = ": " + OMetadata.GetName(sceneId)
	EndIf
	If acts.Find(initiator) > -1
		String others = ""
		i = 0
		While i < acts.Length
			If acts[i] != initiator
				If others != ""
					others += " and "
				EndIf
				others += acts[i].GetDisplayName()
			EndIf
			i += 1
		EndWhile
		Report(command, parameter, initiator.GetDisplayName() + " starts being intimate with " + others + what + note)
	Else
		Report(command, parameter, initiator.GetDisplayName() + " gets " + JoinAnd(acts) + " started" + what + note + "; " + initiator.GetDisplayName() + " is not part of it")
	EndIf
EndFunction

; OStim action types the server sends for "masturbation"
bool Function IsSoloKind(String actions)
	Return StringUtil.Find(actions, "masturbation") > -1 || StringUtil.Find(actions, "toying") > -1
EndFunction

; a solo scene: the agent pleasures themselves while the others watch
Function StartSolo(String command, String parameter, Actor npc)
	If ThreadOf(npc) > -1
		Report(command, parameter, "cannot start: " + npc.GetDisplayName() + " is already busy in a scene")
		Return
	EndIf
	If npc.IsInCombat() || npc.GetCombatState() > 0
		Report(command, parameter, "refuses: there is a fight going on")
		Return
	EndIf
	If npc.IsWeaponDrawn()
		Report(command, parameter, "refuses: weapons are still drawn, this is not a safe moment")
		Return
	EndIf
	Actor[] acts = PapyrusUtil.ActorArray(1)
	acts[0] = npc
	String actions = ArgOf(parameter, 2)
	String sceneId = OLibrary.GetRandomSceneWithAnyActionCSV(acts, actions)
	If sceneId == ""
		sceneId = OLibrary.GetRandomSceneWithAnyActionCSV(acts, "femalemasturbation,malemasturbation,rubbingclitoris,vaginaltoying,analtoying,vaginalfingering,analfingering")
	EndIf
	If sceneId == ""
		Report(command, parameter, "cannot start: no solo animation is installed for " + npc.GetDisplayName())
		Return
	EndIf
	COB_Config.SetBusy(npc)
	LastBridgeAction = Utility.GetCurrentRealTime()
	If OThread.QuickStart(acts, sceneId) < 0
		COB_Config.ClearBusy(npc)
		Report(command, parameter, "cannot start: OStim refused the scene")
		Return
	EndIf
	String oneself = "himself"
	If npc.GetActorBase().GetSex() == 1
		oneself = "herself"
	EndIf
	Report(command, parameter, npc.GetDisplayName() + " starts pleasuring " + oneself + " where everyone can watch: " + OMetadata.GetName(sceneId))
EndFunction

String Function JoinAnd(Actor[] acts)
	String s = ""
	Int i = 0
	While i < acts.Length
		If s != ""
			If i == acts.Length - 1
				s += " and "
			Else
				s += ", "
			EndIf
		EndIf
		s += acts[i].GetDisplayName()
		i += 1
	EndWhile
	Return s
EndFunction

; actions first ("blowjob", ...), then positions ("doggystyle", ...), then missionary, then anything
String Function PickScene(Actor[] acts, String actions, String tags)
	String s = ""
	If actions != ""
		s = OLibrary.GetRandomSceneWithAnyActionCSV(acts, actions)
	EndIf
	If s == "" && tags != ""
		s = OLibrary.GetRandomSceneWithAnySceneTagCSV(acts, tags)
	EndIf
	If s == "" && (actions != "" || tags != "")
		; the asked act or position is not available: a plain missionary first,
		; it exists for nearly every pairing
		s = OLibrary.GetRandomSceneWithAnySceneTagCSV(acts, "missionary")
	EndIf
	If s == ""
		s = OLibrary.GetRandomScene(acts)
	EndIf
	Return s
EndFunction

bool Function SceneMatches(String sceneId, String actions, String tags)
	String[] want = StringUtil.Split(actions + "," + tags, ",")
	String[] have = PapyrusUtil.MergeStringArray(OMetadata.GetActionTypes(sceneId), OMetadata.GetSceneTags(sceneId))
	Int i = 0
	While i < want.Length
		If want[i] != "" && have.Find(want[i]) > -1
			Return True
		EndIf
		i += 1
	EndWhile
	Return False
EndFunction

; insertion sort, highest ActiveRank first
Function SortByRole(Actor[] acts)
	Int i = 1
	While i < acts.Length
		Actor cur = acts[i]
		Int j = i - 1
		While j >= 0 && ActiveRank(acts[j]) < ActiveRank(cur)
			acts[j + 1] = acts[j]
			j -= 1
		EndWhile
		acts[j + 1] = cur
		i += 1
	EndWhile
EndFunction

; male player 3, other men 2, female player 1, other women 0
Int Function ActiveRank(Actor a)
	Int rank = 0
	If a.GetActorBase().GetSex() == 0
		rank = 2
	EndIf
	If a == Game.GetPlayer()
		rank += 1
	EndIf
	Return rank
EndFunction

Function ChangeScene(String command, String parameter)
	Actor initiator = ResolveInitiator(parameter)
	If !initiator
		Report(command, parameter, "cannot change the scene: the AI agent could not be identified")
		Return
	EndIf
	Int tid = ThreadOf(initiator)
	If tid < 0
		; models often believe a scene is running when an earlier start failed
		StartScene(command, parameter)
		Return
	EndIf
	Actor[] acts = OThread.GetActors(tid)
	String sceneId = PickScene(acts, ArgOf(parameter, 2), ArgOf(parameter, 3))
	If sceneId == ""
		Report(command, parameter, "cannot change the scene: nothing matching is available")
		Return
	EndIf
	OThread.NavigateTo(tid, sceneId)
	Report(command, parameter, initiator.GetDisplayName() + " changes what they are doing: " + OMetadata.GetName(sceneId))
EndFunction

Function StopScene(String command, String parameter)
	Actor initiator = ResolveInitiator(parameter)
	Int tid = -1
	If initiator
		tid = ThreadOf(initiator)
	EndIf
	If tid < 0
		tid = ThreadOf(Game.GetPlayer())
	EndIf
	If tid < 0
		Report(command, parameter, "nothing to stop: no scene is running")
		Return
	EndIf
	LastBridgeAction = Utility.GetCurrentRealTime()
	OThread.Stop(tid)
	If initiator
		COB_Config.ClearBusy(initiator)
		Report(command, parameter, initiator.GetDisplayName() + " stops and gets dressed")
	Else
		Report(command, parameter, "the scene is over")
	EndIf
EndFunction

; ---------------------------------------------------------------- clothes

; Undress / Get_Dressed act on the agent itself - or on a thrall the agent names: a thrall
; obeys, and one that is not a CHIM agent cannot be told anything directly. Any other name
; keeps the old behaviour (the agent's own clothes). Thralls come from CHIM Vampire Bridge;
; without it the list is simply empty.
Actor Function WhoToDress(String parameter, Actor npc)
	String name = ArgOf(parameter, 1)
	If name == "" || name == npc.GetDisplayName()
		Return npc
	EndIf
	Actor t = ResolvePartnerName(name)
	If t && t != Game.GetPlayer() && IsThrall(t)
		Return t
	EndIf
	Return npc
EndFunction

; a thrall of CHIM Vampire Bridge (its StorageUtil list; nothing to read without that mod)
bool Function IsThrall(Actor a)
	Return a && StorageUtil.FormListFind(None, "COV_Thralls", a) > -1
EndFunction

Function Undress(String command, String parameter)
	Actor npc = ResolveInitiator(parameter)
	If !npc
		Report(command, parameter, "cannot undress: the AI agent could not be identified in the game")
		Return
	EndIf
	npc = WhoToDress(parameter, npc)
	If npc.IsInCombat() || npc.GetCombatState() > 0
		Report(command, parameter, "refuses: there is a fight going on")
		Return
	EndIf
	If ThreadOf(npc) > -1
		Report(command, parameter, "nothing to do: the scene already takes care of clothes")
		Return
	EndIf

	Int taken = 0
	Int slot = 30
	While slot <= 61
		; keep hair (31, 41), decapitation (50, 51) and FX (61) slots
		If slot != 31 && slot != 41 && slot != 50 && slot != 51 && slot != 61
			Form worn = npc.GetWornForm(Math.LeftShift(1, slot - 30))
			If worn && worn.IsPlayable() && StorageUtil.FormListFind(npc, UndressKey, worn) < 0
				StorageUtil.FormListAdd(npc, UndressKey, worn, False)
				npc.UnequipItemEx(worn, 0, True) ; True: the AI will not put it straight back on
				taken += 1
			EndIf
		EndIf
		slot += 1
	EndWhile
	If taken == 0
		Report(command, parameter, "nothing to take off: " + npc.GetDisplayName() + " is already undressed")
	Else
		Report(command, parameter, npc.GetDisplayName() + " takes their clothes off")
	EndIf
EndFunction

Function Redress(String command, String parameter)
	Actor npc = ResolveInitiator(parameter)
	If !npc
		Report(command, parameter, "cannot get dressed: the AI agent could not be identified in the game")
		Return
	EndIf
	npc = WhoToDress(parameter, npc)
	Int n = StorageUtil.FormListCount(npc, UndressKey)
	If n == 0
		Report(command, parameter, "nothing to put back on: " + npc.GetDisplayName() + " took nothing off")
		Return
	EndIf
	Int i = 0
	While i < n
		Form item = StorageUtil.FormListGet(npc, UndressKey, i)
		If item && npc.GetItemCount(item) > 0
			npc.EquipItemEx(item, 0, False, False)
		EndIf
		i += 1
	EndWhile
	StorageUtil.FormListClear(npc, UndressKey)
	Report(command, parameter, npc.GetDisplayName() + " gets dressed again")
EndFunction

; ---------------------------------------------------------------- helpers

String Function ArgOf(String parameter, Int index)
	String[] parts = StringUtil.Split(parameter, "~")
	If index < 0 || index >= parts.Length
		Return ""
	EndIf
	String v = COB_Config.Trim(parts[index])
	If v == "-" ; the server writes "-" for an empty field so Split never drops it
		Return ""
	EndIf
	Return v
EndFunction

Actor Function ResolveInitiator(String parameter)
	String name = ArgOf(parameter, 0)
	Actor a = None
	If name != ""
		a = AIAgentFunctions.getAgentByName(name)
	EndIf
	If !a
		a = AIAgentFunctions.getClosestAgent()
	EndIf
	Return a
EndFunction

Actor Function ResolvePartner(String parameter)
	Return ResolvePartnerName(ArgOf(parameter, 1))
EndFunction

Actor Function ResolvePartnerName(String name)
	name = COB_Config.Trim(name)
	Actor player = Game.GetPlayer()
	If name == "" || name == "player" || name == "self" || name == player.GetDisplayName()
		Return player
	EndIf
	Actor a = AIAgentFunctions.getAgentByName(name)
	If a
		Return a
	EndIf
	; any NPC around (MCM), and always a thrall: a thrall obeys, CHIM agent or not
	Actor[] around = MiscUtil.ScanCellNPCs(player, RangeUnits())
	Int i = 0
	While i < around.Length
		If around[i] && around[i].GetDisplayName() == name && (COB_Config.B("bAnyNPC:General") || IsThrall(around[i]))
			Return around[i]
		EndIf
		i += 1
	EndWhile
	; a name was given but nobody by that name is here: refuse rather than
	; silently pairing the agent with the player instead
	Return None
EndFunction

float Function RangeUnits()
	float m = COB_Config.F("fRange:General")
	If m <= 0.0
		m = 50.0
	EndIf
	Return m * 70.0 ; about 70 game units per metre
EndFunction

; within range the one who is not the player is placed next to the other
bool Function BringTogether(Actor a, Actor b)
	If a.GetDistance(b) <= 250.0
		Return True
	EndIf
	If a.GetDistance(b) > RangeUnits() || a.GetParentCell() != b.GetParentCell() && a.GetParentCell().IsInterior()
		Return False
	EndIf
	Actor mover = b
	Actor goal = a
	If b == Game.GetPlayer()
		mover = a
		goal = b
	EndIf
	; PathToReference is latent and never returns when the path is blocked or the
	; goal moves, which froze the whole bridge; place the partner directly instead
	; (OStim aligns everyone when the scene starts anyway)
	mover.MoveTo(goal, 60.0, 0.0, 0.0)
	Return True
EndFunction

; -1 when the actor is not in any running scene
Int Function ThreadOf(Actor a)
	If !a
		Return -1
	EndIf
	Int[] ids = OThread.GetAllThreadIDs()
	Int i = 0
	While i < ids.Length
		If OThread.GetActorPosition(ids[i], a) > -1
			Return ids[i]
		EndIf
		i += 1
	EndWhile
	Return -1
EndFunction

; The result goes back the way CHIM's own actions report theirs: logMessageForActor with
; "funcret" and the agent's name. CHIM keeps the agent's command open until that arrives;
; an unaddressed requestMessage left it open, and from then on every further command of
; the session crashed CHIM's queue (null read) before it reached the game - only the
; first action after starting the game ever worked.
Function Report(String command, String parameter, String result)
	COB_Config.Note(command + " -> " + result)
	String npc = ArgOf(parameter, 0)
	If npc == ""
		npc = LastCommandNpc
	EndIf
	AIAgentFunctions.logMessageForActor("command@" + command + "@" + parameter + "@" + result, "funcret", npc)
EndFunction
