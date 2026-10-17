<?php

/**
 * CHIM OStim Bridge by SaurOff - actions.
 *
 * The LLM-facing action definitions live in CHIM's core_action_custom table, so
 * they can be toggled in the CHIM UI like any other action. This file installs or
 * updates them once per plugin version, rewrites outgoing parameters into the shape
 * the game script expects, and shapes the follow-up prompt after the game reports back.
 */

require_once(__DIR__ . DIRECTORY_SEPARATOR . "cob_lib.php");

$GLOBALS["COB_ACTIONS"] = [
    "ExtCmdCOB_StartScene" => [
        "name" => "Start_Intimate_Scene",
        "return" => "#HERIKA_NAME# starts an intimate scene.",
        "params" => [
            "target" => "Partner(s). Empty = #PLAYER_NAME#. Several people: exact names separated by commas.",
            "item" => "Kind of scene, e.g. oral, cunnilingus, vaginal, anal, doggystyle, cowgirl, missionary, sixtynine, kissing, masturbation. Empty = anything.",
        ],
        "description" => "Begin a physically intimate scene with someone who is here. This is what actually starts it in the game; describing it in words alone does nothing.\n\n"
            . "Conditions: nobody is in combat, no weapons are drawn, nobody is badly wounded, and the other person wants it (#PLAYER_NAME# asking for it directly counts). "
            . "By default not in a dungeon, cave, ruin, tomb, bandit camp or enemy fort, nor in a house you broke into - unless your own character profile says you like such places, and then only once it is quiet and no enemy is near. Follow your own character profile about where and when.\n\n"
            . "When #PLAYER_NAME# asks for it and the place is allowed, call this action right away in the same reply.\n"
            . "This also covers kissing, making out and touching between any two people present, and #PLAYER_NAME# asking two others to do it with each other (\"kiss her\", \"lick her\"): call it with the other person's name in target and the kind in item (kissing, cunnilingus, ...).\n"
            . "NO ORDER NEEDED: when the people involved have just agreed on it in this conversation (even among themselves, e.g. that #PLAYER_NAME# takes her from behind) and #PLAYER_NAME# has already shown they want it, the one speaking starts it right away with exactly what was agreed (who in target, how in item). Do not wait for a separate order. If you say \"let's start\", \"enough talk\" or similar, call this action in that same reply.\n"
            . "TARGET - who takes part: empty = you and #PLAYER_NAME#. One name = you and that person. "
            . "Two or more names = exactly the people named and nobody else, so add your own name only if you join in. "
            . "Example: it was agreed that #PLAYER_NAME# takes <her name> from behind while you watch -> target \"#PLAYER_NAME#, <her name>\", item \"doggystyle\". "
            . "You join #PLAYER_NAME# and <her name> -> target \"#PLAYER_NAME#, <her name>, <your own name>\".\n"
            . "KIND OF SCENE: put what kind of sex into item when it was asked for or you want something specific: oral (you use your mouth on him), cunnilingus, vaginal, anal, handjob, boobjob, kissing, sixtynine, cowgirl, reverse cowgirl, doggystyle, missionary. Leave item empty to let the game choose.\n"
            . "ALONE: to pleasure yourself while others watch (to tease or invite #PLAYER_NAME#, or because you are asked to), use item \"masturbation\" with target empty or your own name - only you take part.",
    ],
    "ExtCmdCOB_ChangeScene" => [
        "name" => "Change_Intimate_Scene",
        "return" => "#HERIKA_NAME# changes what they are doing.",
        "params" => [
            "target" => "leave empty",
            "item" => "What to switch to, e.g. oral, doggystyle, cowgirl, anal, missionary. Empty = something else.",
        ],
        "description" => "Change what is happening in an intimate scene that is already running: switch to another position or act. Put the new kind into item: oral, cunnilingus, vaginal, anal, handjob, boobjob, kissing, sixtynine, cowgirl, reverse cowgirl, doggystyle, missionary. Leave item empty to let the game pick something else.",
    ],
    "ExtCmdCOB_StopScene" => [
        "name" => "Stop_Intimate_Scene",
        "return" => "#HERIKA_NAME# stops and gets dressed.",
        "params" => ["target" => "leave empty"],
        "description" => "End the intimate scene that is currently running: when the moment is over, when #PLAYER_NAME# asks you to stop, or when something interrupts. If no scene is running, do not call this.",
    ],
    "ExtCmdCOB_Undress" => [
        "name" => "Undress",
        "return" => "#HERIKA_NAME# takes their clothes off.",
        "params" => ["target" => "Leave empty to undress yourself. The exact name of a thrall to undress that thrall instead."],
        "description" => "Take off your own clothes and armor, right here, without starting an intimate scene: when #PLAYER_NAME# asks you to undress, or to tease or seduce in a place where that fits. Never in combat. By default not in a dungeon or hostile place, or in a house you broke into - unless your own character profile says you like such places and it is quiet with no enemy near. Call the action instead of only describing it.",
    ],
    "ExtCmdCOB_Redress" => [
        "name" => "Get_Dressed",
        "return" => "#HERIKA_NAME# gets dressed again.",
        "params" => ["target" => "Leave empty to dress yourself. The exact name of a thrall to dress that thrall instead."],
        "description" => "Put back on the clothes and armor you took off earlier with Undress: when #PLAYER_NAME# asks, when you are about to leave or travel, when danger appears, or when the moment is over.",
    ],
];

foreach ($GLOBALS["COB_ACTIONS"] as $code => $def) {
    $GLOBALS["F_NAMES"][$code] = $def["name"];
}

// ---------------------------------------------------------------- install / update

(function () {
    $db = $GLOBALS["db"] ?? null;
    if (!$db) {
        return;
    }
    try {
        // version + fingerprint of the definitions above: any change to an action's name,
        // description or parameters is written to CHIM's table, not only a version bump
        $stamp = COB_VERSION . "-" . md5(json_encode($GLOBALS["COB_ACTIONS"]));
        $mark = $db->fetchOne("SELECT value FROM conf_opts WHERE id = 'cob_ostim_bridge_installed'");
        if (!empty($mark) && strval($mark["value"] ?? "") === $stamp) {
            return;
        }
        foreach ($GLOBALS["COB_ACTIONS"] as $code => $def) {
            $props = [];
            foreach ($def["params"] as $p => $desc) {
                $props[$p] = ["type" => "string", "description" => $desc];
            }
            $params = json_encode(["type" => "object", "required" => [], "properties" => $props], JSON_UNESCAPED_SLASHES);
            $row = $db->fetchOne("SELECT id FROM core_action_custom WHERE code_name = $1", [$code]);
            if (!empty($row)) {
                $db->fetchOne(
                    "UPDATE core_action_custom SET action_name = $2, description = $3, return_message = $4, parameters_json = $5::jsonb, updated_at = now() WHERE code_name = $1 RETURNING id",
                    [$code, $def["name"], $def["description"], $def["return"], $params]
                );
                continue;
            }
            $clash = $db->fetchOne("SELECT code_name FROM core_action_custom WHERE action_name = $1", [$def["name"]]);
            if (!empty($clash)) {
                error_log("[cob_ostim_bridge] action name {$def['name']} is already used by {$clash['code_name']}; not installing {$code}");
                continue;
            }
            $db->fetchOne(
                "INSERT INTO core_action_custom (code_name, action_name, description, return_message, available_to_npc, available_to_followers, available_to_narrator, is_activated, parameters_json, metadata, game_function, import_version, script_proxy_program, created_at, updated_at)"
                . " VALUES ($1, $2, $3, $4, true, true, false, true, $5::jsonb, '{}'::jsonb, true, 0, '{}'::jsonb, now(), now()) RETURNING id",
                [$code, $def["name"], $def["description"], $def["return"], $params]
            );
        }
        // actions of older versions (the vampire ones moved to CHIM Vampire Bridge in 2.0):
        // gone from CHIM's list, so the LLM is not offered what this bridge no longer does
        $codes = array_keys($GLOBALS["COB_ACTIONS"]);
        $marks = implode(",", array_map(function ($i) {
            return "$" . ($i + 1);
        }, array_keys($codes)));
        $db->fetchOne("DELETE FROM core_action_custom WHERE code_name LIKE 'ExtCmdCOB\\_%' AND code_name NOT IN ({$marks}) RETURNING 1", $codes);
        $db->upsertRowOnConflict("conf_opts", ["id" => "cob_ostim_bridge_installed", "value" => $stamp], "id");
        error_log("[cob_ostim_bridge] actions installed/updated for " . $stamp);
        cobLog("actions installed/updated for " . $stamp);
    } catch (Throwable $e) {
        error_log("[cob_ostim_bridge] install: " . $e->getMessage());
    }
})();

// ---------------------------------------------------------------- outgoing parameters

/**
 * CHIM sends "<npc>|command|<Action_Name>@<parameter>" to the game, but the Papyrus
 * side needs to know which agent asked. Scenes become
 * "<agent>~<partners>~<OStim actions CSV>~<scene tags CSV>" ("-" = empty field),
 * everything else "<agent>~<target>" (also "-" when empty). Also watches CHIM's Consume for drinking.
 */
$GLOBALS["action_post_process_fnct_ex"][] = function ($actions) {
    if (!is_array($actions)) {
        return $actions;
    }
    foreach ($actions as $n => $action) {
        try {
            $parts = explode("|", strval($action));
            if (count($parts) < 3) {
                continue;
            }
            $call = explode("@", $parts[2], 2);
            $actionName = $call[0];
            $codeName = function_exists('getFunctionCodeName') ? getFunctionCodeName($actionName) : false;
            if ($codeName === false || trim(strval($codeName)) === '') {
                $codeName = $actionName;
            }
            $actorName = trim($parts[0]);
            $parameter = isset($call[1]) ? trim($call[1]) : "";

            if ($codeName === "Consume") {
                $cfg = cobConfig();
                if (!empty($cfg["enabled"]) && !empty($cfg["needs"]) && !empty($cfg["drunk"]) && cobIsAlcohol($parameter)) {
                    cobRecordDrink($actorName, cobNow());
                }
                continue;
            }
            if (!isset($GLOBALS["COB_ACTIONS"][$codeName])) {
                continue;
            }

            $item = "";
            if ($parameter !== "" && $parameter[0] === "{" && function_exists('decodeFunctionExecutionParameterPayload')) {
                $payload = decodeFunctionExecutionParameterPayload($parameter);
                if (is_array($payload)) {
                    $parameter = trim(strval($payload["target"] ?? ""));
                    $item = trim(strval($payload["item"] ?? ""));
                }
            }
            // "~" separates the fields on the Papyrus side; "|" separates the action line itself
            $parameter = str_replace(["~", "|"], " ", $parameter);
            $field = function ($v) {
                return trim($v) === "" ? "-" : $v;
            };

            if ($codeName === "ExtCmdCOB_StartScene" || $codeName === "ExtCmdCOB_ChangeScene") {
                if ($codeName === "ExtCmdCOB_ChangeScene" && $item === "") {
                    // the kind written into target ("doggystyle") rather than a name
                    list($a, $t) = cobMapSceneKind($parameter);
                    if ($a !== "" || $t !== "") {
                        $item = $parameter;
                        $parameter = "";
                    }
                }
                // Change keeps its target: when no scene is running the game starts
                // one, and these are the partners the model meant
                list($sceneActions, $sceneTags) = cobMapSceneKind($item);
                // alone: the game plays a solo scene when the agent is the only one named
                if ($codeName === "ExtCmdCOB_StartScene" && cobIsSoloKind($item)
                    && (trim($parameter) === "" || mb_strtolower(trim($parameter)) === mb_strtolower($actorName))) {
                    $parameter = $actorName;
                }
                $parts[2] = $actionName . "@" . $actorName . "~" . $field($parameter) . "~" . $field($sceneActions) . "~" . $field($sceneTags);
            } else {
                // never end the parameter with an empty field: CHIM's command queue
                // crashes on "Name~" (null read) before the game ever sees the command
                $parts[2] = $actionName . "@" . $actorName . "~" . $field($parameter);
            }
            $actions[$n] = implode("|", $parts);
            cobLog("action " . $parts[2]);
        } catch (Throwable $e) {
            error_log("[cob_ostim_bridge] post_process: " . $e->getMessage());
        }
    }
    return $actions;
};

// ---------------------------------------------------------------- after the game reports back

$cobFuncret = function ($gameRequest) {
    // data: "command@<CodeName>@<parameter>@<result sentence>"
    $data = is_array($gameRequest) ? strval($gameRequest[3] ?? "") : "";
    $herika = $GLOBALS["HERIKA_NAME"] ?? "";
    $GLOBALS["FORCE_MAX_TOKENS"] = 120;
    cobLog("result " . mb_substr($data, 0, 300));
    $refused = (stripos($data, "refuses") !== false) || (stripos($data, "cannot") !== false) || (stripos($data, "nothing to ") !== false);
    if ($refused) {
        $reason = $data;
        $cut = strrpos($data, "@");
        if ($cut !== false) {
            $reason = trim(substr($data, $cut + 1));
        }
        return [
            "argName" => "target",
            "request" => "{$herika} wanted this but it did not happen: {$reason}. Say one short line in character about it and drop the subject. Do not try the same action again this turn.",
        ];
    }
    return ["argName" => "target"];
};
foreach (array_keys($GLOBALS["COB_ACTIONS"]) as $code) {
    $GLOBALS["FUNCRET"][$code] = $cobFuncret;
}
