<?php

/**
 * CHIM OStim Bridge by SaurOff - text added at the bottom of every prompt:
 * the "speech only" rule (MCM: CHIM fixes) and how the NPC feels right now
 * (MCM: Needs). Loaded by main.php just before the prompt_bottom slot is rendered.
 */

require_once(__DIR__ . DIRECTORY_SEPARATOR . "cob_lib.php");

if (function_exists('chimRegisterPromptInjection')) {
    chimRegisterPromptInjection("prompt_bottom", "cob_needs", function ($slot, $context) {
        try {
            return cobNeedsPromptFor(trim(strval($GLOBALS["HERIKA_NAME"] ?? "")), cobNow());
        } catch (Throwable $e) {
            error_log("[cob_ostim_bridge] needs: " . $e->getMessage());
            return "";
        }
    }, 800);
    chimRegisterPromptInjection("prompt_bottom", "cob_thralls", function ($slot, $context) {
        try {
            return cobThrallPromptFor(trim(strval($GLOBALS["HERIKA_NAME"] ?? "")));
        } catch (Throwable $e) {
            error_log("[cob_ostim_bridge] thralls: " . $e->getMessage());
            return "";
        }
    }, 820);
    chimRegisterPromptInjection("prompt_bottom", "cob_action_rule", function ($slot, $context) {
        try {
            return cobActionRule(trim(strval($GLOBALS["HERIKA_NAME"] ?? "")));
        } catch (Throwable $e) {
            return "";
        }
    }, 850);
    chimRegisterPromptInjection("prompt_bottom", "cob_speech_only", function ($slot, $context) {
        try {
            return cobSpeechOnlyRule(trim(strval($GLOBALS["HERIKA_NAME"] ?? "")));
        } catch (Throwable $e) {
            return "";
        }
    }, 900);
}
