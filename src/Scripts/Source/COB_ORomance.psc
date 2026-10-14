Scriptname COB_ORomance Hidden
{CHIM OStim Bridge by SaurOff - marriage through ORomance Plus, an optional mod.
 Kept apart from COB_Bridge on purpose: without ORomance installed only this script
 fails to load, and COB_Bridge checks for the plugin before it calls in here.}

ORomanceScript Function Main() Global
	Return Game.GetFormFromFile(0x000800, "ORomance.esp") as ORomanceScript ; ORomanceQuest
EndFunction

; Marries npc to the player the way ORomance Plus's own "Propose marriage" does when
; the proposal succeeds, without its odds: the first spouse gets the vanilla engagement
; and the wedding at the Temple of Mara, every later one is married at once.
; Returns the outcome as a sentence for the AI.
string Function Marry(Actor npc) Global
	ORomanceScript main = Main()
	Actor player = Game.GetPlayer()
	string who = npc.GetDisplayName()
	string you = player.GetDisplayName()
	If !main
		Return "cannot: ORomance Plus is not running"
	EndIf
	If main.IsPlayerSpouse(npc)
		Return "nothing to do: " + who + " already is married to " + you
	EndIf
	If main.IsMarried(npc)
		Return "cannot: " + who + " is married to someone else"
	EndIf
	If main.isVanillaMarriageLocked()
		Return "cannot: " + you + " is already engaged, and that wedding at the Temple of Mara has to happen first"
	EndIf
	If main.isORMarriageLocked()
		Return "cannot: ORomance Plus does not allow a marriage right now"
	EndIf
	Quest wedding = Game.GetFormFromFile(0x074793, "Skyrim.esm") as Quest ; RelationshipMarriage
	bool first = wedding && !wedding.IsStopped()
	main.Marry(npc)
	If first
		Return who + " and " + you + " are engaged; the wedding will be held at the Temple of Mara in Riften"
	EndIf
	Return who + " is now married to " + you
EndFunction
