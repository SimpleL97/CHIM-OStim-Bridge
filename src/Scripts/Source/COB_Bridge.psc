Scriptname COB_Bridge extends Quest
{CHIM OStim Bridge by SaurOff.
 Lets CHIM AI agents start, change and stop OStim scenes, undress and dress,
 (vampires) feed on blood and (Vampire Lords) turn the player into a Vampire Lord.
 CHIM hands the actions over through the mod event
 "CHIM_CommandReceived" (npc name, command, parameter); every outcome is reported
 back to CHIM as a "funcret" so the agent knows what really happened.
 Server half: HerikaServer/ext/cob_ostim_bridge.}

; Real time of the last scene this bridge started or stopped. COB_Events reads it
; so a scene the AI started itself is not announced a second time.
float Property LastBridgeAction = 0.0 Auto Hidden

string Property UndressKey = "COB_Undressed" AutoReadOnly Hidden

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
	RegisterForModEvent("CHIM_CommandReceived", "OnChimCommand")
EndFunction

; ---------------------------------------------------------------- entry point

Event OnChimCommand(String npcname, String command, String parameter)
	If StringUtil.Find(command, "ExtCmdCOB_") != 0
		Return
	EndIf
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
	ElseIf command == "ExtCmdCOB_Feed"
		Feed(command, parameter)
	ElseIf command == "ExtCmdCOB_VampireLord"
		VampireLordGift(command, parameter)
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

Function Undress(String command, String parameter)
	Actor npc = ResolveInitiator(parameter)
	If !npc
		Report(command, parameter, "cannot undress: the AI agent could not be identified in the game")
		Return
	EndIf
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

; ---------------------------------------------------------------- vampires

Function Feed(String command, String parameter)
	Actor npc = ResolveInitiator(parameter)
	If !npc
		Report(command, parameter, "cannot feed: the AI agent could not be identified in the game")
		Return
	EndIf
	If !COB_Config.IsVampire(npc)
		Report(command, parameter, "cannot feed: " + npc.GetDisplayName() + " is not a vampire")
		Return
	EndIf
	Actor victim = ResolvePartner(parameter)
	If !victim
		Report(command, parameter, "cannot feed: " + ArgOf(parameter, 1) + " is not here")
		Return
	EndIf
	If victim == npc
		victim = Game.GetPlayer()
	EndIf
	If npc.IsInCombat() || npc.GetCombatState() > 0
		Report(command, parameter, "refuses: there is a fight going on")
		Return
	EndIf
	If ThreadOf(npc) > -1
		Report(command, parameter, "cannot feed: busy in a scene")
		Return
	EndIf
	If npc.GetDistance(victim) > RangeUnits()
		Report(command, parameter, "cannot feed: " + victim.GetDisplayName() + " is too far away")
		Return
	EndIf
	; the action arrives together with the line that announces it: let that line be
	; spoken first, then bite
	WaitUntilSilent(npc)
	If !BringTogether(npc, victim)
		Report(command, parameter, "cannot feed: " + victim.GetDisplayName() + " is too far away")
		Return
	EndIf
	Idle bite = Game.GetFormFromFile(0x00E6A8, "Dawnguard.esm") as Idle ; IdleVampireStandingFeedFront_Loose
	If bite
		npc.PlayIdleWithTarget(bite, victim)
	EndIf
	; a real bite, but never a dangerous one
	If victim.GetActorValuePercentage("Health") > 0.4
		victim.DamageActorValue("Health", victim.GetActorValue("Health") * 0.1)
	EndIf
	Report(command, parameter, npc.GetDisplayName() + " feeds on " + victim.GetDisplayName() + "'s blood" + Infect(victim))
EndFunction

; A Vampire Lord gives the player their blood the way it happens in Dawnguard. The steps
; are those of Dawnguard's DLC1VampireTurnScript.ReceiveHarkonsGift, but the bite is
; played to its end first: there the vampire change starts in the same instant and its
; race swap cuts the bite off (the quest hides that behind a fade to black). After the
; bite: the vanilla vampire change (skipped when the player already is one), the end of
; lycanthropy like in the game, the Vampire Lord power and its perk tree. Player only.
Function VampireLordGift(String command, String parameter)
	Actor npc = ResolveInitiator(parameter)
	If !npc
		Report(command, parameter, "cannot: the AI agent could not be identified in the game")
		Return
	EndIf
	If !COB_Config.B("bLordGift:Needs")
		Report(command, parameter, "cannot: giving the Vampire Lord gift is turned off in the MCM")
		Return
	EndIf
	If !COB_Config.IsVampireLord(npc)
		Report(command, parameter, "cannot: " + npc.GetDisplayName() + " is not a Vampire Lord")
		Return
	EndIf
	Actor player = Game.GetPlayer()
	Actor target = ResolvePartner(parameter)
	If target && target != player && target != npc
		Report(command, parameter, "cannot: only " + player.GetDisplayName() + " can receive the Vampire Lord gift")
		Return
	EndIf
	Spell lordPower = Game.GetFormFromFile(0x00283B, "Dawnguard.esm") as Spell ; DLC1VampireChange
	Perk lordPerk = Game.GetFormFromFile(0x00588B, "Dawnguard.esm") as Perk ; DLC1VampireTurnPerk
	PlayerVampireQuestScript vampireQuest = Game.GetFormFromFile(0x0EAFD5, "Skyrim.esm") as PlayerVampireQuestScript ; PlayerVampireQuest
	CompanionsHousekeepingScript companions = Game.GetFormFromFile(0x04B2D9, "Skyrim.esm") as CompanionsHousekeepingScript ; C00
	If !lordPower || !vampireQuest
		Report(command, parameter, "cannot: Dawnguard is not loaded")
		Return
	EndIf
	If player.HasSpell(lordPower)
		Report(command, parameter, "cannot: " + player.GetDisplayName() + " already is a Vampire Lord")
		Return
	EndIf
	If npc.IsInCombat() || player.IsInCombat()
		Report(command, parameter, "refuses: there is a fight going on")
		Return
	EndIf
	If ThreadOf(npc) > -1 || ThreadOf(player) > -1
		Report(command, parameter, "cannot: busy in a scene")
		Return
	EndIf
	If npc.GetDistance(player) > RangeUnits()
		Report(command, parameter, "cannot: " + player.GetDisplayName() + " is too far away")
		Return
	EndIf
	WaitUntilSilent(npc)
	BringTogether(npc, player)
	Keyword kVampire = Game.GetFormFromFile(0x0A82BB, "Skyrim.esm") as Keyword
	bool wasVampire = kVampire && player.GetRace().HasKeyword(kVampire)
	PlayBite(npc, player)
	If !wasVampire
		vampireQuest.VampireChange(player)
	EndIf
	If companions && companions.PlayerHasBeastBlood
		companions.CurePlayer()
	EndIf
	player.AddSpell(lordPower, True)
	If lordPerk
		player.AddPerk(lordPerk)
	EndIf
	; the gift cures the disease too; nothing left to track
	Spell disease = COB_Config.SanguinareVampiris()
	If disease && player.HasSpell(disease)
		player.RemoveSpell(disease)
	EndIf
	If !player.HasSpell(lordPower)
		Report(command, parameter, "cannot: the gift did not take, " + player.GetDisplayName() + " has no Vampire Lord power")
		Return
	EndIf
	string who = player.GetDisplayName()
	If wasVampire
		; Dawnguard skips the vampire change for someone who already is a vampire
		Report(command, parameter, npc.GetDisplayName() + " gave " + who + " their blood: " + who + " already was a vampire and now is a Vampire Lord too - the Vampire Lord power is in their powers")
	Else
		Report(command, parameter, npc.GetDisplayName() + " gave " + who + " their blood: " + who + " is now a Vampire Lord")
	EndIf
EndFunction

; MCM "The bite passes on vampirism": the game's Sanguinare Vampiris, with the chance
; lowered by disease resistance. The player then follows the game's own course (a vampire
; after 3 days unless cured); NPCs are tracked by COB_Events.CheckInfected. Returns the
; text added to the action result, so the AI knows what happened.
String Function Infect(Actor victim)
	If !COB_Config.B("bBiteCurse:Needs") || COB_Config.IsVampire(victim)
		Return ""
	EndIf
	Spell disease = COB_Config.SanguinareVampiris()
	If !disease || victim.HasSpell(disease)
		Return ""
	EndIf
	float resist = victim.GetActorValue("DiseaseResist")
	If resist >= 100.0
		Return ""
	EndIf
	int chance = COB_Config.I("iCurseChance:Needs")
	If resist > 0.0
		chance = (chance * (100.0 - resist) / 100.0) as int
	EndIf
	If !COB_Config.Roll(chance)
		Return ""
	EndIf
	victim.AddSpell(disease, False)
	int days = 3
	If victim != Game.GetPlayer()
		days = COB_Config.I("iTurnDays:Needs")
		If days <= 0
			days = 3
		EndIf
		StorageUtil.FormListAdd(None, "COB_Infected", victim, False)
		StorageUtil.SetFloatValue(victim, "COB_InfectedAt", Utility.GetCurrentGameTime())
	EndIf
	COB_Config.Note(victim.GetDisplayName() + " caught Sanguinare Vampiris")
	Return "; the bite passed on Sanguinare Vampiris: unless " + victim.GetDisplayName() + " is cured within " + days + " days, they will turn into a vampire"
EndFunction

; the vanilla feeding bite, played to its end: third person so it can be seen, weapons
; away (a paired animation does not start otherwise), a few tries while the game is
; still busy, then wait while the two are locked in the synced animation
Function PlayBite(Actor npc, Actor victim)
	Idle bite = Game.GetFormFromFile(0x00E6A8, "Dawnguard.esm") as Idle ; IdleVampireStandingFeedFront_Loose
	If !bite
		Return
	EndIf
	If victim == Game.GetPlayer()
		Game.ForceThirdPerson()
	EndIf
	If victim.IsWeaponDrawn()
		victim.SheatheWeapon()
	EndIf
	If npc.IsWeaponDrawn()
		npc.SheatheWeapon()
	EndIf
	bool started = False
	int tries = 0
	While !started && tries < 8
		started = npc.PlayIdleWithTarget(bite, victim)
		If !started
			Utility.Wait(0.5)
		EndIf
		tries += 1
	EndWhile
	If !started
		Return
	EndIf
	Utility.Wait(1.0)
	float t = 0.0
	While t < 12.0 && (npc.GetAnimationVariableBool("bIsSynced") || victim.GetAnimationVariableBool("bIsSynced"))
		Utility.Wait(0.25)
		t += 0.25
	EndWhile
	If t == 0.0
		Utility.Wait(3.0) ; no sync flag to watch: give the bite its usual length
	EndIf
	Utility.Wait(0.5)
EndFunction

; waits (at most about half a minute) until the agent has finished speaking; the line
; can start a moment after the command arrives, so first give it a chance to begin
Function WaitUntilSilent(Actor npc)
	string n = npc.GetDisplayName()
	float t = 0.0
	While t < 2.0 && AIAgentFunctions.isActorTalking(n) == 0
		Utility.Wait(0.25)
		t += 0.25
	EndWhile
	t = 0.0
	While t < 30.0 && AIAgentFunctions.isActorTalking(n) != 0
		Utility.Wait(0.25)
		t += 0.25
	EndWhile
	Utility.Wait(0.3)
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
	If COB_Config.B("bAnyNPC:General")
		Actor[] around = MiscUtil.ScanCellNPCs(player, RangeUnits())
		Int i = 0
		While i < around.Length
			If around[i] && around[i].GetDisplayName() == name
				Return around[i]
			EndIf
			i += 1
		EndWhile
	EndIf
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

Function Report(String command, String parameter, String result)
	COB_Config.Note(command + " -> " + result)
	AIAgentFunctions.requestMessage("command@" + command + "@" + parameter + "@" + result, "funcret")
EndFunction
