<?php

/**
 * CHIM OStim Bridge by SaurOff - runs before CHIM logs a request or takes its lock.
 *
 *   cob_state   silent bookkeeping from COB_Events (config, scene, orgasm, sex):
 *               stored and answered here, never reaches the history or the LLM.
 *   cob_after   gets "who climaxed" appended before the agent talks about the scene.
 *   inputtext   who the player talks to, for the jealousy need.
 *   init        CHIM fix: eventlog.ts is a game-session counter that restarts with the
 *               game. user_input markers from a long previous session then look newer
 *               than every new request and CHIM aborts each reply as "interrupted by
 *               newer player input". On game load any marker ahead of the counter is stale.
 */

require_once(__DIR__ . DIRECTORY_SEPARATOR . "cob_lib.php");

if (isset($gameRequest) && is_array($gameRequest)) {
    $cobType = strval($gameRequest[0] ?? "");
    try {
        if ($cobType === "cob_state") {
            // CHIM splits every request on "|" (main.php: explode("|", ...)), and the
            // state lines use "|" themselves: glue everything after the third field back
            cobApplyGameState(implode("|", array_slice($gameRequest, 3)), cobNow());
            terminate();
        }
        if ($cobType === "cob_after") {
            $gameRequest[3] = cobDescribeAfterScene(strval($gameRequest[3] ?? ""));
        }
        if ($cobType === "init" && !empty(cobConfig()["stale_input"]) && isset($GLOBALS["db"]) && is_numeric($gameRequest[1] ?? null)) {
            $GLOBALS["db"]->fetchOne(
                "UPDATE eventlog SET ts = 0 WHERE type = 'user_input' AND ts > $1 RETURNING 1",
                [strval($gameRequest[1])]
            );
        }
        if (in_array($cobType, ["inputtext", "inputtext_s"], true)) {
            cobApplyPlayerLine(strval($gameRequest[3] ?? ""), cobNow());
        }
    } catch (Throwable $e) {
        error_log("[cob_ostim_bridge] preprocessing: " . $e->getMessage());
        if ($cobType === "cob_state") {
            terminate();
        }
    }
}
