<?php

/**
 * CHIM OStim Bridge by SaurOff - server side, shared code.
 *
 * Settings come from the game (MCM -> COB_Events.SendConfig -> "cob_state config|{json}")
 * and are kept in conf_opts, together with the needs state. Times in the state are
 * CHIM gamets (game time, 1 game hour = 416666.67 gamets); arousal and climaxes use
 * real time because they only matter for minutes.
 *
 * The other bridges of the family (CHIM ORomance Bridge, CHIM Vampire Bridge) are optional:
 * cobPeer() says whether one is installed and switched on, and only reads its settings.
 * The vampire features of 1.x live in CHIM Vampire Bridge since 2.0.
 */

const COB_VERSION = "2.0.0";
const COB_PLUGIN = "cob_ostim_bridge";
const COB_CONFIG_KEY = "cob_ostim_bridge_config";
const COB_STATE_KEY = "cob_ostim_bridge_state";
const COB_HOUR = 416666.6667;

// ---------------------------------------------------------------- storage

function cobOptGet(string $id)
{
    $db = $GLOBALS["db"] ?? null;
    if (!$db) {
        return null;
    }
    $row = $db->fetchOne("SELECT value FROM conf_opts WHERE id = $1", [$id]);
    $v = is_array($row) ? json_decode(strval($row["value"] ?? ""), true) : null;
    return is_array($v) ? $v : null;
}

function cobOptSet(string $id, array $value): void
{
    $db = $GLOBALS["db"] ?? null;
    if ($db) {
        $db->upsertRowOnConflict("conf_opts", ["id" => $id, "value" => json_encode($value, JSON_UNESCAPED_UNICODE)], "id");
    }
}

function cobConfig(): array
{
    static $cfg = null;
    if ($cfg === null) {
        $defaults = [
            "enabled" => 1, "log" => 1, "needs" => 1, "sex_names" => "", "sex_hours" => 6,
            "drunk" => 1, "jealous_names" => "", "arousal" => 1, "speech_only" => 1, "stale_input" => 1,
            "virginity" => 0,
        ];
        $cfg = array_merge($defaults, cobOptGet(COB_CONFIG_KEY) ?? []);
    }
    return $cfg;
}

function cobNames(string $csv): array
{
    return array_values(array_filter(array_map(function ($n) {
        return mb_strtolower(trim($n));
    }, explode(",", $csv))));
}

function cobListed(string $csvKey, string $npc): bool
{
    return in_array(mb_strtolower(trim($npc)), cobNames(strval(cobConfig()[$csvKey] ?? "")), true);
}

function cobNow(): float
{
    $req = $GLOBALS["gameRequest"] ?? null;
    return floatval(is_array($req) ? ($req[2] ?? 0) : 0);
}

function cobHoursSince($then, float $now): ?float
{
    if ($then === null || $now <= 0) {
        return null;
    }
    return max(0.0, ($now - floatval($then)) / COB_HOUR);
}

// ---------------------------------------------------------------- the other bridges

/**
 * Settings of another bridge of the family ("cor_oromance_bridge", "cov_vampire_bridge"),
 * or null when it is not installed on this server or is switched off in its MCM. Read only:
 * no bridge depends on another one.
 */
function cobPeer(string $plugin): ?array
{
    if (!is_dir(dirname(__DIR__) . DIRECTORY_SEPARATOR . $plugin)) {
        return null;
    }
    $cfg = cobOptGet($plugin . "_config") ?? [];
    return array_key_exists("enabled", $cfg) && empty($cfg["enabled"]) ? null : $cfg;
}

// ---------------------------------------------------------------- log

/** HerikaServer/log/cob_ostim_bridge.log (MCM: Write a log file); kept under 2 MB */
function cobLog(string $msg): void
{
    static $on = null;
    if ($on === null) {
        $on = !empty(cobConfig()["log"]);
    }
    if (!$on) {
        return;
    }
    try {
        $file = dirname(__DIR__, 2) . DIRECTORY_SEPARATOR . "log" . DIRECTORY_SEPARATOR . COB_PLUGIN . ".log";
        if (@filesize($file) > 2 * 1024 * 1024) {
            @rename($file, $file . ".1");
        }
        @file_put_contents($file, date("Y-m-d H:i:s") . " " . $msg . "\n", FILE_APPEND);
    } catch (Throwable $e) {
    }
}

// ---------------------------------------------------------------- scene kinds

/**
 * Words the model puts into "item" mapped to OStim action types and scene tags.
 * Returns [actions CSV, tags CSV]; the game tries actions, then tags, then any scene.
 */
// pleasuring oneself, alone: the game plays a solo scene of the agent
const COB_SOLO_RE = '/masturbat|solo|alone|by (my|her|him)self|touch(ing)? (my|her|him)self|pleasur(e|ing) (my|her|him)self|play(ing)? with (my|her|him)self|мастурб|дроч|ласка(ть|ю|ет) себя|трога(ть|ю|ет) себя/u';

function cobIsSoloKind(string $text): bool
{
    return (bool) preg_match(COB_SOLO_RE, mb_strtolower($text));
}

function cobMapSceneKind(string $text): array
{
    $t = mb_strtolower($text);
    $rules = [
        COB_SOLO_RE                                           => [['femalemasturbation', 'malemasturbation', 'rubbingclitoris', 'vaginaltoying', 'vaginalfingering'], []],
        '/oral|blow ?job|suck|deepthroat|минет|отсос|ротом/u' => [['blowjob', 'deepthroating', 'penilelicking'], []],
        '/cunni|eat her|lick her|куни/u'                      => [['cunnilingus', 'vulvallicking', 'vulvaleating'], []],
        '/69|sixty ?nine/u'                                   => [[], ['sixtynine']],
        '/vagin|pussy/u'                                      => [['vaginalsex'], []],
        '/anal/u'                                             => [['analsex'], []],
        '/hand ?job/u'                                        => [['handjob'], []],
        '/boob ?job|tit ?job/u'                               => [['boobjob'], []],
        '/foot ?job/u'                                        => [['footjob'], []],
        '/finger/u'                                           => [['vaginalfingering'], []],
        '/kiss/u'                                             => [['kissing', 'frenchkissing'], []],
        '/cuddl|hug/u'                                        => [['cuddling', 'hugging'], []],
        '/reverse ?cowgirl/u'                                 => [[], ['reversecowgirl']],
        '/cowgirl|riding/u'                                   => [[], ['cowgirl']],
        '/doggy|from behind/u'                                => [[], ['doggystyle']],
        '/missionary/u'                                       => [[], ['missionary']],
        '/spit ?roast/u'                                      => [[], ['spitroast']],
        '/face ?sit/u'                                        => [[], ['facesitting']],
        '/prone/u'                                            => [[], ['prone']],
    ];
    $actions = [];
    $tags = [];
    foreach ($rules as $re => $hit) {
        if (preg_match($re, $t)) {
            $actions = array_merge($actions, $hit[0]);
            $tags = array_merge($tags, $hit[1]);
        }
    }
    return [implode(",", array_unique($actions)), implode(",", array_unique($tags))];
}

function cobIsAlcohol(string $item): bool
{
    return (bool) preg_match('/\b(ale|mead|wine|brandy|beer|rum|sujamma|flin|shein|matze|skooma|spiced|whiskey|cyrodilic)\b|эль|медовух|вин|бренди|пив/iu', $item);
}

// ---------------------------------------------------------------- state updates

/** "cob_state" lines from COB_Events: config|{json}, scene|A,B, orgasm|Name, sex|A,B */
function cobApplyGameState(string $data, float $now): void
{
    cobLog("state " . mb_substr($data, 0, 300));
    if (preg_match('/config\|(\{.*\})/su', $data, $m)) {
        $cfg = json_decode($m[1], true);
        if (is_array($cfg)) {
            cobOptSet(COB_CONFIG_KEY, $cfg);
        }
        return;
    }
    if (preg_match('/virgins\|([^()\r\n]*)/u', $data, $m)) {
        // OVirginity: the women near the player who are virgins ("-" = none)
        $state = cobOptGet(COB_STATE_KEY) ?? [];
        $state["virgins"] = trim($m[1]) === "-" ? [] : array_values(array_filter(array_map('trim', explode(",", $m[1]))));
        cobOptSet(COB_STATE_KEY, $state);
        return;
    }
    if (!preg_match('/(scene|orgasm|sex)\|([^()\r\n]+)/u', $data, $m)) {
        return;
    }
    $kind = $m[1];
    $names = array_values(array_filter(array_map('trim', explode(",", $m[2]))));
    if (!$names) {
        return;
    }
    $state = cobOptGet(COB_STATE_KEY) ?? [];
    $rt = time();
    foreach ($names as $name) {
        if ($kind === "scene") {
            $state["arousal"][$name] = ["stage" => "scene", "rt" => $rt];
        } elseif ($kind === "orgasm") {
            $state["arousal"][$name] = ["stage" => "orgasm", "rt" => $rt];
            $state["climax"][$name] = $rt;
        } else {
            $state["last_sex"][$name] = $now;
            $state["arousal"][$name] = ["stage" => "after", "rt" => $rt];
            cobAddAttention($state, $name, 3.0, $now);
        }
    }
    cobOptSet(COB_STATE_KEY, $state);
}

function cobAddAttention(array &$state, string $npc, float $weight, float $now): void
{
    $list = $state["attention"] ?? [];
    $list[] = ["n" => $npc, "w" => $weight, "ts" => $now];
    $list = array_values(array_filter($list, function ($e) use ($now) {
        return ($now - floatval($e["ts"] ?? 0)) < 48 * COB_HOUR;
    }));
    $state["attention"] = array_slice($list, -300);
}

/** the player spoke to someone: "(Talking to Name)" */
function cobApplyPlayerLine(string $data, float $now): void
{
    if (!preg_match('/\(Talking to ([^)]+)\)/u', $data, $m)) {
        return;
    }
    $npc = trim($m[1]);
    if (!cobListed("jealous_names", $npc)) {
        return;
    }
    $state = cobOptGet(COB_STATE_KEY) ?? [];
    cobAddAttention($state, $npc, 1.0, $now);
    cobOptSet(COB_STATE_KEY, $state);
}

function cobRecordDrink(string $npc, float $now): void
{
    $state = cobOptGet(COB_STATE_KEY) ?? [];
    $state["drunk"][$npc] = ["level" => cobDrunkLevel($state, $npc, $now) + 1.0, "ts" => $now];
    cobOptSet(COB_STATE_KEY, $state);
}

/** "(A and B finished their intimate scene (it ended with: X))" + who climaxed */
function cobDescribeAfterScene(string $data): string
{
    $state = cobOptGet(COB_STATE_KEY) ?? [];
    $now = time();
    $came = [];
    $none = [];
    // CHIM puts "(Context location: ...)Player:" in front: the names are what follows
    // the last "(" before the phrase, never the location ("The Bee and Barb")
    if (preg_match('/(?:^|\()([^()]+?) finished their intimate scene/u', $data, $m)) {
        foreach (preg_split('/,\s*|\s+and\s+/u', trim($m[1], "( ")) as $n) {
            $n = trim($n);
            if ($n === "") {
                continue;
            }
            $rt = intval($state["climax"][$n] ?? 0);
            if ($rt > 0 && $now - $rt < 30 * 60) {
                $came[] = $n;
            } else {
                $none[] = $n;
            }
        }
    }
    $extra = [];
    if ($came) {
        $extra[] = "climaxed: " . implode(", ", $came);
    }
    if ($none) {
        $extra[] = "did not climax: " . implode(", ", $none);
    }
    if (!$extra) {
        return $data;
    }
    $data = rtrim($data);
    $close = substr($data, -1) === ")" ? ")" : "";
    if ($close !== "") {
        $data = substr($data, 0, -1);
    }
    return $data . "; " . implode("; ", $extra) . $close;
}

// ---------------------------------------------------------------- prompt text

function cobDrunkLevel(array $state, string $npc, float $now): float
{
    $d = $state["drunk"][$npc] ?? null;
    if (!is_array($d)) {
        return 0.0;
    }
    $h = cobHoursSince($d["ts"] ?? null, $now) ?? 0.0;
    return max(0.0, floatval($d["level"] ?? 0) - $h / 1.5);
}

function cobSexText(?float $h, int $base): string
{
    $base = max(1, $base);
    if ($h === null || $h < $base) {
        return "Your hunger for sex is fed for now: warm and content, though the wanting never really stops.";
    }
    $hrs = intval(round($h));
    if ($h < 2 * $base) {
        return "It has been {$hrs} hours since you last had sex. The familiar heat is starting inside you: you want it, you think about it, you hint and touch more than usual.";
    }
    if ($h < 4 * $base) {
        return "It has been {$hrs} hours since you last had sex, far too long. It burns inside you now: restless, short-tempered, you ask for it openly, again and again.";
    }
    return "It has been {$hrs} hours since you last had sex. The burning is unbearable, a terrible fire under your skin. You are angry, snapping at everyone, and you demand it at the first place where it is allowed.";
}

function cobDrunkText(float $level): string
{
    if ($level < 0.5) {
        return "";
    }
    if ($level < 2.5) {
        return "You have had a drink or two and you are tipsy: louder, bolder, quicker to grin.";
    }
    if ($level < 4.5) {
        return "You are drunk: your words run together a little, you laugh too loud, and you flirt with anyone around you.";
    }
    return "You are very drunk: slurring, swaying and completely shameless.";
}

function cobArousalText(array $state, string $npc): string
{
    $a = $state["arousal"][$npc] ?? null;
    if (!is_array($a)) {
        return "";
    }
    $age = time() - intval($a["rt"] ?? 0);
    $stage = strval($a["stage"] ?? "");
    if ($stage === "scene" && $age < 30 * 60) {
        return $age < 60
            ? "You are in the middle of sex right now and your arousal is building fast."
            : "You are in the middle of sex right now and you are very aroused, close to the edge.";
    }
    if ($stage === "orgasm" && $age < 90) {
        return "You have just climaxed: breathless and shaking.";
    }
    if ($stage === "orgasm" && $age < 30 * 60) {
        return "You climaxed a little while ago and the scene is still going: sensitive, flushed, still wanting more.";
    }
    if ($stage === "after" && $age < 10 * 60) {
        return "Sex has just ended: relaxed, satisfied, in the mood to tease or cuddle.";
    }
    return "";
}

function cobJealousyText(array $state, string $npc, float $now, string $player): string
{
    $mine = 0.0;
    $best = "";
    $bestScore = 0.0;
    $scores = [];
    foreach ($state["attention"] ?? [] as $e) {
        if (($now - floatval($e["ts"] ?? 0)) >= 48 * COB_HOUR) {
            continue;
        }
        $n = strval($e["n"] ?? "");
        if (!cobListed("jealous_names", $n)) {
            continue;
        }
        $scores[$n] = ($scores[$n] ?? 0) + floatval($e["w"] ?? 1);
    }
    foreach ($scores as $n => $s) {
        if (mb_strtolower($n) === mb_strtolower($npc)) {
            $mine = $s;
        } elseif ($s > $bestScore) {
            $bestScore = $s;
            $best = $n;
        }
    }
    if ($best !== "" && $bestScore >= 6 && $bestScore >= 2 * max(1.0, $mine)) {
        return "Lately {$player} has been giving {$best} far more of their attention and their bed than you. You notice it and you are jealous; show it in your own way, toward them or toward {$best}.";
    }
    return "";
}

/** "how this NPC feels right now", or "" */
function cobNeedsPromptFor(string $npc, float $now): string
{
    $cfg = cobConfig();
    if (empty($cfg["enabled"]) || empty($cfg["needs"]) || $npc === "" || $npc === "The Narrator") {
        return "";
    }
    $state = cobOptGet(COB_STATE_KEY) ?? [];
    $player = strval($GLOBALS["PLAYER_NAME"] ?? "the player");
    $lines = [];
    $dirty = false;

    if (cobListed("sex_names", $npc)) {
        if (!isset($state["last_sex"][$npc]) && $now > 0) {
            $state["last_sex"][$npc] = $now; // first sight: start satisfied
            $dirty = true;
        }
        $lines[] = cobSexText(cobHoursSince($state["last_sex"][$npc] ?? null, $now), intval($cfg["sex_hours"] ?? 6));
    }
    if ($dirty) {
        cobOptSet(COB_STATE_KEY, $state);
    }
    if (!empty($cfg["drunk"])) {
        $lines[] = cobDrunkText(cobDrunkLevel($state, $npc, $now));
    }
    if (!empty($cfg["arousal"])) {
        $lines[] = cobArousalText($state, $npc);
    }
    if (cobListed("jealous_names", $npc)) {
        $lines[] = cobJealousyText($state, $npc, $now, $player);
    }
    if (!empty($cfg["virginity"])) {
        foreach (($state["virgins"] ?? []) as $v) {
            if (mb_strtolower($v) === mb_strtolower($npc)) {
                $lines[] = "You are a virgin - you have never had sex. How you feel about it (shy, curious, proud, eager to change it, or saving yourself) follows your own character.";
                break;
            }
        }
    }
    $lines = array_values(array_filter($lines, function ($l) {
        return trim($l) !== "";
    }));
    if (!$lines) {
        return "";
    }
    return "HOW {$npc} FEELS RIGHT NOW (let it shape tone and wishes; do not recite it):\n- " . implode("\n- ", $lines);
}

/**
 * Placed at the very end of the prompt: the action description alone is too far up
 * for the model to act on an agreement reached in conversation ("then let's start")
 * or to name everyone in an agreed threesome.
 */
function cobActionRule(string $npc): string
{
    if ($npc === "" || $npc === "The Narrator" || empty(cobConfig()["enabled"])) {
        return "";
    }
    $player = strval($GLOBALS["PLAYER_NAME"] ?? "the player");
    return "WORDS DO NOT MOVE BODIES: in the game nothing happens unless you set the action field. "
        . "If in this reply {$npc} says that sex, kissing or touching starts now (\"let's start\", \"come here\", \"take me\", \"enough talk\"), "
        . "set action to Start_Intimate_Scene in this same reply, or Change_Intimate_Scene if a scene is already running. "
        . "Put into target everyone who takes part as agreed (\"{$player}, <her name>, <other name>\" for a threesome; your own name only if you join) "
        . "and the agreed act or position into item. Do this even when you are talking to another NPC and {$player} did not give a separate order. "
        . "Giving an order counts too: when you tell someone else to do it with {$player} (to pleasure {$player}, to go down on {$player}), YOU set Start_Intimate_Scene in this same reply - nobody else will start it - "
        . "with target \"{$player}, <their name>\": a single name means you and that person.";
}

function cobSpeechOnlyRule(string $npc): string
{
    if ($npc === "" || $npc === "The Narrator" || empty(cobConfig()["speech_only"])) {
        return "";
    }
    return "SPEECH ONLY: the \"message\" field holds nothing but the words {$npc} says out loud, in the first person. "
        . "{$npc} may say what they want or are about to do (\"I want you\", \"come here\", \"let me take this off\"). "
        . "Never narrate or comment on their own actions, looks, gestures or feelings in the third person "
        . "(not \"she smiles\", not \"she slowly turns her head\", not \"her eyes flash\"), no stage directions, no *asterisks*, "
        . "no descriptive prose between dialogue dashes. Anything physical goes into the action field, not into the message.";
}

/**
 * The "speech only" rule, enforced on what the model wrote anyway: CHIM passes every sentence
 * of a reply through the request's transformer on its way to the voice, the subtitles and the
 * history. Narration the way prose writes it - a dialogue dash, then she/he and what they do -
 * is cut out up to the next dialogue dash or the end ("Are you serious? - She falls silent,
 * studying his face. - I thought..." keeps "Are you serious? I thought..."). After the end of a
 * sentence any pronoun counts ("...bold? - she crosses her arms"); inside one only a capitalised
 * one, so "a stranger - he is my lord" stays.
 */
function cobStripNarration($sentence)
{
    $s = strval($sentence);
    $pron = "(?:Она|Он|Её|Ее|Его|Вона|Він|Її|Його|She|He|Her|His)";
    $dash = "[\x{2014}\x{2013}-]";
    $cut = preg_replace("/(?:(?:^|(?<=[.!?\x{2026}]))\s*{$dash}\s+(?i:{$pron})|\s+{$dash}\s+{$pron})\s[^\x{2014}\x{2013}]*?(?:{$dash}\s+|$)/u", " ", $s);
    if ($cut === null) {
        return $s;
    }
    $cut = trim($cut);
    if ($cut !== trim($s)) {
        cobLog("speech only: cut narration from " . strval($GLOBALS["HERIKA_NAME"] ?? "") . ": " . $s);
    }
    return $cut;
}

// ---------------------------------------------------------------- refused actions

/** the LLM-facing names of this bridge's actions, for the refusal event */
const COB_ACTION_NAMES = [
    "ExtCmdCOB_StartScene" => "Start_Intimate_Scene",
    "ExtCmdCOB_ChangeScene" => "Change_Intimate_Scene",
    "ExtCmdCOB_StopScene" => "Stop_Intimate_Scene",
    "ExtCmdCOB_Undress" => "Undress",
    "ExtCmdCOB_Redress" => "Get_Dressed",
];

/**
 * A refused action of this bridge, as the event "cob_refused" the agent answers at once,
 * or null. The game reports every outcome as "funcret": "command@<CodeName>@<agent>~<parameter>@<result>".
 * Newer CHIM versions no longer call a plugin's FUNCRET handler for it (only an action's
 * follow-up setting, which cannot tell a refusal from a success), so a refusal would only
 * be seen in the next reply; as an event the agent says right away why it did not happen.
 * Successful actions stay a plain funcret: no extra reply.
 */
function cobRefusalEvent(string $data): ?string
{
    $parts = explode("@", $data, 4);
    if (count($parts) < 4 || !isset(COB_ACTION_NAMES[$parts[1]])) {
        return null;
    }
    $result = trim($parts[3]);
    if (!preg_match('/^(cannot|refuses|nothing to)\b/i', $result)) {
        return null;
    }
    $agent = trim(explode("~", $parts[2])[0]);
    cobLog("refused {$parts[1]} by {$agent}: {$result}");
    return "({$agent} tried " . COB_ACTION_NAMES[$parts[1]] . ", but it did not happen - {$result})";
}
