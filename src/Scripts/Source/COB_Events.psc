Scriptname COB_Events extends Quest
{CHIM OStim Bridge by SaurOff - what the AI agents hear about.
 Comment-worthy events (each can be switched off in the MCM, with a chance):
   cob_city        arriving in / leaving / travelling between the big cities
   cob_shop        walking into a shop
   cob_scene       an OStim scene starting near the player
   cob_after       an OStim scene ending: who, how it ended, who climaxed (server adds that)
   cob_wake        waking up after sleep
   cob_dragonsoul  absorbing a dragon soul
   cob_naked       the player stripping naked
   cob_home        walking into a home the player owns
 Silent bookkeeping (never reaches the LLM): cob_state lines scene, orgasm, sex
 and config (the MCM settings the server needs).}

; ---------------------------------------------------------------- state

Location[] cities
Keyword kStore
Keyword kHouse
Faction fPlayer
Location lastLoc
Location lastShop
int lastCity = -1
float lastCityMsg = -1000.0
float lastShopMsg = -1000.0
float lastSceneMsg = -1000.0
float lastNakedMsg = -1000.0
float lastHomeMsg = -1000.0
float lastSouls = -1.0
bool wasNaked = False
bool inHome = False
bool ready = False
bool configSent = False
int polls = 0

float Property PollSeconds = 3.0 AutoReadOnly Hidden

; ---------------------------------------------------------------- startup

Event OnInit()
	Setup()
	RegisterForSingleUpdate(PollSeconds)
EndEvent

Function Setup()
	; FormIDs read from Skyrim.esm / Dragonborn.esm
	cities = New Location[6]
	cities[0] = Game.GetFormFromFile(0x018A56, "Skyrim.esm") as Location     ; WhiterunLocation
	cities[1] = Game.GetFormFromFile(0x018A5A, "Skyrim.esm") as Location     ; SolitudeLocation
	cities[2] = Game.GetFormFromFile(0x018A57, "Skyrim.esm") as Location     ; WindhelmLocation
	cities[3] = Game.GetFormFromFile(0x018A58, "Skyrim.esm") as Location     ; RiftenLocation
	cities[4] = Game.GetFormFromFile(0x018A59, "Skyrim.esm") as Location     ; MarkarthLocation
	cities[5] = Game.GetFormFromFile(0x0143B9, "Dragonborn.esm") as Location ; DLC2RavenRockLocation
	kStore = Game.GetFormFromFile(0x01CB86, "Skyrim.esm") as Keyword         ; LocTypeStore
	kHouse = Game.GetFormFromFile(0x0FC1A3, "Skyrim.esm") as Keyword         ; LocTypePlayerHouse
	fPlayer = Game.GetFormFromFile(0x000DB1, "Skyrim.esm") as Faction        ; PlayerFaction
	Hook()
	Actor p = Game.GetPlayer()
	lastLoc = p.GetCurrentLocation()
	lastCity = CityOf(lastLoc)
	lastSouls = p.GetActorValue("DragonSouls")
	wasNaked = IsNaked(p)
	inHome = InOwnHome(p)
	ready = True
EndFunction

Function Hook()
	RegisterForSleep()
	RegisterForModEvent("ostim_thread_start", "OnSceneStart")
	RegisterForModEvent("ostim_actor_orgasm", "OnActorOrgasm")
	RegisterForModEvent("ostim_thread_end", "OnSceneEnd")
	COB_Bridge bridge = Game.GetFormFromFile(0x000800, "CHIMOStimBridge.esp") as COB_Bridge
	If bridge
		bridge.Hook()
	EndIf
EndFunction

; called by COB_MCM when a setting changes, the menu is first built, or a save loads
Function ConfigChanged()
	configSent = False
EndFunction

; ---------------------------------------------------------------- polling

Event OnUpdate()
	If !ready
		Setup()
	EndIf
	polls += 1
	If polls % 100 == 0
		Hook() ; cheap, keeps the registrations alive whatever happens to the save
	EndIf
	If !configSent
		SendConfig()
		configSent = True
	EndIf
	If polls % 10 == 1
		SendVampires()
	EndIf
	Poll()
	RegisterForSingleUpdate(PollSeconds)
EndEvent

Function Poll()
	Actor p = Game.GetPlayer()
	float now = Utility.GetCurrentRealTime()
	string who = p.GetDisplayName()
	bool calm = !p.IsInCombat()
	float cooldown = COB_Config.F("fCooldown:Reactions")
	If cooldown <= 0.0
		cooldown = 45.0
	EndIf

	; ---- dragon souls only ever go up when one is absorbed
	float souls = p.GetActorValue("DragonSouls")
	If souls > lastSouls && lastSouls >= 0.0
		Send(who + " just absorbed the soul of a slain dragon", "cob_dragonsoul", "bDragonSoul:Reactions")
	EndIf
	lastSouls = souls

	; ---- stripping naked outside a scene
	bool naked = IsNaked(p)
	If naked && !wasNaked && calm && !InAnyScene(p) && now - lastNakedMsg > cooldown
		If Send(who + " took off their clothes and is standing there naked", "cob_naked", "bNaked:Reactions")
			lastNakedMsg = now
		EndIf
	EndIf
	wasNaked = naked

	; ---- locations
	Location cur = p.GetCurrentLocation()
	If cur == lastLoc
		Return
	EndIf

	int curCity = CityOf(cur)
	If curCity != lastCity
		string msg = ""
		If lastCity >= 0 && curCity >= 0
			msg = who + " travelled from " + CityName(lastCity) + " to " + CityName(curCity)
		ElseIf curCity >= 0
			msg = who + " arrived in the city of " + CityName(curCity)
		ElseIf lastCity >= 0
			msg = who + " left the city of " + CityName(lastCity)
		EndIf
		If msg != "" && calm && now - lastCityMsg > cooldown
			If Send(msg, "cob_city", "bCity:Reactions")
				lastCityMsg = now
			EndIf
		EndIf
		lastCity = curCity
	EndIf

	If cur && kStore && cur.HasKeyword(kStore)
		If cur != lastShop && calm && now - lastShopMsg > cooldown
			string place = cur.GetName()
			If curCity >= 0
				place = place + " in " + CityName(curCity)
			EndIf
			If Send(who + " walked into a shop: " + place, "cob_shop", "bShop:Reactions")
				lastShopMsg = now
			EndIf
		EndIf
		lastShop = cur
	Else
		lastShop = None
	EndIf

	bool home = InOwnHome(p)
	If home && !inHome && now - lastHomeMsg > cooldown
		If Send(who + " walked into their own home: " + cur.GetName(), "cob_home", "bHome:Reactions")
			lastHomeMsg = now
		EndIf
	EndIf
	inHome = home

	lastLoc = cur
EndFunction

; ---------------------------------------------------------------- helpers

int Function CityOf(Location loc)
	If !loc
		Return -1
	EndIf
	int i = 0
	While i < cities.Length
		If cities[i] && (loc == cities[i] || loc.IsChild(cities[i]))
			Return i
		EndIf
		i += 1
	EndWhile
	Return -1
EndFunction

string Function CityName(int i)
	If i < 0 || i >= cities.Length || !cities[i]
		Return "the city"
	EndIf
	Return cities[i].GetName()
EndFunction

bool Function IsNaked(Actor a)
	Return a.GetWornForm(0x00000004) == None ; slot 32, body
EndFunction

bool Function InOwnHome(Actor p)
	Location loc = p.GetCurrentLocation()
	Cell c = p.GetParentCell()
	If !loc || !c || !kHouse || !c.IsInterior() || !loc.HasKeyword(kHouse)
		Return False
	EndIf
	Return c.GetActorOwner() == p.GetActorBase() || (fPlayer && c.GetFactionOwner() == fPlayer)
EndFunction

bool Function InAnyScene(Actor a)
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

; names joined with "," when anyone of them is near the player, "" otherwise
string Function NamesNear(Actor[] acts)
	If !acts
		Return ""
	EndIf
	Actor p = Game.GetPlayer()
	bool near = False
	string names = ""
	int i = 0
	While i < acts.Length
		If acts[i]
			If acts[i] == p || acts[i].GetDistance(p) < 3000.0
				near = True
			EndIf
			If names != ""
				names = names + ","
			EndIf
			names = names + acts[i].GetDisplayName()
		EndIf
		i += 1
	EndWhile
	If !near
		Return ""
	EndIf
	Return names
EndFunction

string Function JoinAnd(Actor[] acts)
	string s = ""
	int i = 0
	While i < acts.Length
		If acts[i]
			If s != ""
				If i == acts.Length - 1
					s = s + " and "
				Else
					s = s + ", "
				EndIf
			EndIf
			s = s + acts[i].GetDisplayName()
		EndIf
		i += 1
	EndWhile
	Return s
EndFunction

bool Function RecentBridgeAction()
	COB_Bridge bridge = Game.GetFormFromFile(0x000800, "CHIMOStimBridge.esp") as COB_Bridge
	If !bridge
		Return False
	EndIf
	Return Utility.GetCurrentRealTime() - bridge.LastBridgeAction < 10.0
EndFunction

; ---------------------------------------------------------------- events

Event OnSleepStop(bool abInterrupted)
	string who = Game.GetPlayer().GetDisplayName()
	If abInterrupted
		Send(who + " was woken up before they had finished sleeping", "cob_wake", "bWake:Reactions")
	Else
		Send(who + " woke up after a night's sleep", "cob_wake", "bWake:Reactions")
	EndIf
EndEvent

Event OnSceneStart(string eventName, string strArg, float numArg, Form sender)
	Actor[] acts = OThread.GetActors(numArg as int)
	string names = NamesNear(acts)
	If names == ""
		Return
	EndIf
	SendState("scene|" + names)
	; a scene the AI started itself already got its own reply
	If RecentBridgeAction()
		Return
	EndIf
	float now = Utility.GetCurrentRealTime()
	If now - lastSceneMsg < 30.0
		Return
	EndIf
	If Send(JoinAnd(acts) + " started an intimate scene", "cob_scene", "bSceneNear:Reactions")
		lastSceneMsg = now
	EndIf
EndEvent

Event OnActorOrgasm(string eventName, string sceneId, float threadId, Form sender)
	Actor a = sender as Actor
	If a
		SendState("orgasm|" + a.GetDisplayName())
	EndIf
EndEvent

Event OnSceneEnd(string eventName, string json, float numArg, Form sender)
	Actor[] acts = OJSON.GetActors(json)
	If !acts
		Return
	EndIf
	string names = ""
	int i = 0
	While i < acts.Length
		If acts[i]
			If names != ""
				names = names + ","
			EndIf
			names = names + acts[i].GetDisplayName()
		EndIf
		i += 1
	EndWhile
	; recorded for everyone, near or far: hunger must not depend on distance
	SendState("sex|" + names)

	; The bridge marks the initiator "animation busy" for CHIM when it starts a scene,
	; but only cleared it when it stopped the scene itself. A scene that ended on its
	; own left the flag set, and CHIM's command queue then crashed (null read) on the
	; next command, so nothing after the first scene of a session reached the bridge.
	i = 0
	While i < acts.Length
		If acts[i] && acts[i] != Game.GetPlayer()
			AIAgentFunctions.setAnimationBusy(0, acts[i].GetDisplayName())
		EndIf
		i += 1
	EndWhile
	If NamesNear(acts) != ""
		string what = ""
		string sceneId = OJSON.GetScene(json)
		If sceneId != ""
			what = " (it ended with: " + OMetadata.GetName(sceneId) + ")"
		EndIf
		Send(JoinAnd(acts) + " finished their intimate scene" + what, "cob_after", "bAfter:Reactions")
	EndIf
EndEvent

; ---------------------------------------------------------------- send

; a comment-worthy event: obeys its MCM toggle and chance; True when it was sent
bool Function Send(string msg, string kind, string toggleKey)
	If !COB_Config.B("bEnabled:General") || !COB_Config.B(toggleKey)
		Return False
	EndIf
	int chance = COB_Config.I("iChance:Reactions")
	If kind == "cob_after"
		chance = COB_Config.I("iAfterChance:Reactions")
	EndIf
	If !COB_Config.Roll(chance)
		Return False
	EndIf
	COB_Config.Note(kind + ": " + msg)
	AIAgentFunctions.requestMessage("(" + msg + ")", kind)
	Return True
EndFunction

; Real game vampires near the player (Vampire keyword). They get blood thirst by
; default; the MCM list adds anyone else. Sent only when it changes.
string lastVampires = ""
Function SendVampires()
	Keyword kVampire = Game.GetFormFromFile(0x0A82BB, "Skyrim.esm") as Keyword
	If !kVampire
		Return
	EndIf
	Actor p = Game.GetPlayer()
	Actor[] around = MiscUtil.ScanCellNPCs(p, 4000.0)
	string names = ""
	int i = 0
	While i < around.Length
		If around[i] && around[i] != p && around[i].HasKeyword(kVampire)
			If names != ""
				names += ","
			EndIf
			names += Clean(around[i].GetDisplayName())
		EndIf
		i += 1
	EndWhile
	If names != lastVampires
		lastVampires = names
		If names != ""
			SendState("vampires|" + names)
		EndIf
	EndIf
EndFunction

Function SendState(string s)
	AIAgentFunctions.requestMessage(s, "cob_state")
EndFunction

; the settings the server side needs, as JSON (names lose any double quotes)
Function SendConfig()
	string j = "{"
	j += "\"version\":\"" + COB_Config.Version() + "\""
	j += ",\"enabled\":" + Bit(COB_Config.B("bEnabled:General"))
	j += ",\"needs\":" + Bit(COB_Config.B("bNeeds:Needs"))
	j += ",\"sex_names\":\"" + Clean(COB_Config.S("sSexHunger:Needs")) + "\""
	j += ",\"sex_hours\":" + COB_Config.I("iSexHours:Needs")
	j += ",\"vampires\":\"" + Clean(COB_Config.S("sVampires:Needs")) + "\""
	j += ",\"blood_hours\":" + COB_Config.I("iBloodHours:Needs")
	j += ",\"drunk\":" + Bit(COB_Config.B("bDrunk:Needs"))
	j += ",\"jealous_names\":\"" + Clean(COB_Config.S("sJealous:Needs")) + "\""
	j += ",\"arousal\":" + Bit(COB_Config.B("bArousal:Needs"))
	j += ",\"speech_only\":" + Bit(COB_Config.B("bSpeechOnly:Fixes"))
	j += ",\"stale_input\":" + Bit(COB_Config.B("bStaleInput:Fixes"))
	j += "}"
	SendState("config|" + j)
EndFunction

string Function Clean(string s)
	string out = ""
	int i = 0
	int n = StringUtil.GetLength(s)
	While i < n
		string c = StringUtil.GetNthChar(s, i)
		If c != "\"" && c != "\\" && c != "|" && c != "~"
			out += c
		EndIf
		i += 1
	EndWhile
	Return out
EndFunction

string Function Bit(bool b)
	If b
		Return "1"
	EndIf
	Return "0"
EndFunction
