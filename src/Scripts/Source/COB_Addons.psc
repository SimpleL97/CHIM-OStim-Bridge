Scriptname COB_Addons Hidden
{CHIM OStim Bridge by SaurOff - what other OStim mods know about a scene, read from their own
 storage and forms, so none of them is needed (each is checked with Game.IsPluginInstalled).
 MCM page "OStim addons".
   OVirginity            StorageUtil int "IsVirgin" on the actor (1 virgin, 0 not, -1 not
                         decided yet); a woman whose virginity is taken goes into the string
                         list "ovirginity_virginities_taken_list"
   OCum                  OCum_ChestStageFaction 0xF3C, OCum_ButtStageFaction 0xF3E,
                         OCum_BellyStageFaction 0xF40: rank > 0 = cum there
   OISeeYouMasturbating  ONMAllowLookMeFaction 0x836 (let the player watch her),
                         ONMDontLookAtMeFaction 0x800 (did not want to be watched)
   OMerchants            WD05FortifyBarterEffect 0x805 on the player: a merchant's discount
                         for a scene
   OTrainers             WD03DialogueTrainersSex 0xD62, alias TrainerFollower: the trainer of
                         a training session paid with a scene}

string Function VirginListKey() Global
	Return "ovirginity_virginities_taken_list"
EndFunction

; how many virginities OVirginity has recorded so far (its list is global or on the player)
int Function VirginsTaken() Global
	Return StorageUtil.StringListCount(None, VirginListKey()) + StorageUtil.StringListCount(Game.GetPlayer(), VirginListKey())
EndFunction

; is this actor a virgin as far as OVirginity knows: 1 yes, 0 no, -1 unknown or switched off
int Function Virgin(Actor a) Global
	If !a || !COB_Config.B("bVirginity:Addons") || !Game.IsPluginInstalled("OVirginity.esp")
		Return -1
	EndIf
	Return StorageUtil.GetIntValue(a, "IsVirgin", -1)
EndFunction

; before a scene: OVirginity's count of taken virginities, kept for the thread
Function SceneStarted(int threadId) Global
	If COB_Config.B("bVirginity:Addons") && Game.IsPluginInstalled("OVirginity.esp")
		StorageUtil.SetIntValue(None, "COB_Virgins_" + threadId, VirginsTaken())
	EndIf
EndFunction

; after a scene: what the other mods add, as sentences for the reaction ("" when nothing)
string Function AfterNotes(Actor[] acts, int threadId, string sceneId) Global
	Actor p = Game.GetPlayer()
	string notes = ""
	; OVirginity: the women in the scene whose virginity it recorded during it
	If COB_Config.B("bVirginity:Addons") && Game.IsPluginInstalled("OVirginity.esp")
		int before = StorageUtil.GetIntValue(None, "COB_Virgins_" + threadId, -1)
		StorageUtil.UnsetIntValue(None, "COB_Virgins_" + threadId)
		If before >= 0 && VirginsTaken() > before
			int i = 0
			While i < acts.Length
				If acts[i] && acts[i].GetActorBase().GetSex() == 1 && StorageUtil.GetIntValue(acts[i], "IsVirgin", -1) == 0 && WasListed(acts[i])
					notes += " " + acts[i].GetDisplayName() + " lost her virginity in it."
				EndIf
				i += 1
			EndWhile
		EndIf
	EndIf
	; OCum: where it landed on the women
	If COB_Config.B("bCum:Addons") && Game.IsPluginInstalled("OCum.esp")
		Faction chest = Game.GetFormFromFile(0x000F3C, "OCum.esp") as Faction
		Faction butt = Game.GetFormFromFile(0x000F3E, "OCum.esp") as Faction
		Faction belly = Game.GetFormFromFile(0x000F40, "OCum.esp") as Faction
		int i = 0
		While i < acts.Length
			Actor a = acts[i]
			If a && a.GetActorBase().GetSex() == 1
				string where = ""
				where = AddArea(where, a, chest, "her breasts")
				where = AddArea(where, a, belly, "her belly")
				where = AddArea(where, a, butt, "her butt")
				If where != ""
					notes += " There is cum on " + a.GetDisplayName() + "'s body: " + where + "."
				EndIf
			EndIf
			i += 1
		EndWhile
	EndIf
	; OISeeYouMasturbating: a woman touching herself, and whether she let the player watch
	If COB_Config.B("bWatching:Addons") && Game.IsPluginInstalled("OISeeYouMasturbating.esp") && acts.Length == 1 && acts[0] != p
		Faction allowed = Game.GetFormFromFile(0x000836, "OISeeYouMasturbating.esp") as Faction
		Faction denied = Game.GetFormFromFile(0x000800, "OISeeYouMasturbating.esp") as Faction
		If allowed && acts[0].IsInFaction(allowed)
			notes += " " + acts[0].GetDisplayName() + " knew " + p.GetDisplayName() + " was watching her and let " + Pronoun(p) + " watch."
		ElseIf denied && acts[0].IsInFaction(denied)
			notes += " " + acts[0].GetDisplayName() + " caught " + p.GetDisplayName() + " watching her and did not want to be watched."
		EndIf
	EndIf
	; OMerchants / OTrainers: the scene was payment
	If COB_Config.B("bPaid:Addons") && acts.Find(p) > -1
		If Game.IsPluginInstalled("OMerchants.esp")
			MagicEffect discount = Game.GetFormFromFile(0x000805, "OMerchants.esp") as MagicEffect
			If discount && p.HasMagicEffect(discount)
				notes += " In return " + Others(acts, p) + " gave " + p.GetDisplayName() + " better prices in their shop."
			EndIf
		EndIf
		If Game.IsPluginInstalled("WD03OTrainers.esp")
			Quest lessons = Game.GetFormFromFile(0x000D62, "WD03OTrainers.esp") as Quest
			If lessons && lessons.IsRunning()
				ReferenceAlias trainer = lessons.GetAliasByName("TrainerFollower") as ReferenceAlias
				If trainer && trainer.GetActorReference() && acts.Find(trainer.GetActorReference()) > -1
					notes += " It paid for a training lesson: " + trainer.GetActorReference().GetDisplayName() + " trained " + p.GetDisplayName() + " in return."
				EndIf
			EndIf
		EndIf
	EndIf
	Return notes
EndFunction

bool Function WasListed(Actor a) Global
	string n = a.GetDisplayName()
	Return StorageUtil.StringListFind(None, VirginListKey(), n) > -1 || StorageUtil.StringListFind(Game.GetPlayer(), VirginListKey(), n) > -1
EndFunction

string Function AddArea(string where, Actor a, Faction f, string area) Global
	If !f || a.GetFactionRank(f) <= 0
		Return where
	EndIf
	If where != ""
		Return where + ", " + area
	EndIf
	Return area
EndFunction

string Function Pronoun(Actor a) Global
	If a.GetActorBase().GetSex() == 1
		Return "her"
	EndIf
	Return "him"
EndFunction

; the other people of the scene, the player left out
string Function Others(Actor[] acts, Actor p) Global
	string s = ""
	int i = 0
	While i < acts.Length
		If acts[i] && acts[i] != p
			If s != ""
				s += " and "
			EndIf
			s += acts[i].GetDisplayName()
		EndIf
		i += 1
	EndWhile
	Return s
EndFunction
