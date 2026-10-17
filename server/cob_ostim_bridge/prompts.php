<?php

/**
 * CHIM OStim Bridge by SaurOff - how agents react to the events COB_Events sends.
 * Toggles and chances are applied in the game (MCM), so every event that arrives
 * here gets an answer. Loaded inside a function: use $GLOBALS.
 */

$cobNpc  = $GLOBALS["HERIKA_NAME"] ?? "";
$cobTail = $GLOBALS["TEMPLATE_DIALOG"] ?? "";

$GLOBALS["PROMPTS"]["cob_city"] = [
    "cue" => ["({$cobNpc} remarks in character on the city they just arrived in, left, or travelled to: the walls, the crowd, the smell, what the place is known for, or what they want to do there. One or two short lines.) {$cobTail}"],
];
$GLOBALS["PROMPTS"]["cob_shop"] = [
    "cue" => ["({$cobNpc} remarks in character on the shop they just walked into: the owner, the goods, the prices, or something they would like to buy. One or two short lines.) {$cobTail}"],
];
$GLOBALS["PROMPTS"]["cob_home"] = [
    "cue" => ["({$cobNpc} remarks in character on coming into this home: comfort, the bed, a meal, what they want to do now that they are safe. One or two short lines.) {$cobTail}"],
];
$GLOBALS["PROMPTS"]["cob_wake"] = [
    "cue" => ["({$cobNpc} greets the morning in character now that everyone is awake: how they slept and what they want from the day. One or two short lines.) {$cobTail}"],
];
$GLOBALS["PROMPTS"]["cob_dragonsoul"] = [
    "cue" => ["({$cobNpc} reacts in character to watching a dragon's soul being absorbed: awe, fear, pride or desire. One or two short lines.) {$cobTail}"],
];
$GLOBALS["PROMPTS"]["cob_naked"] = [
    "cue" => ["({$cobNpc} reacts in character to the player standing there naked. One or two short lines.) {$cobTail}"],
];
$GLOBALS["PROMPTS"]["cob_scene"] = [
    "cue" => ["({$cobNpc} reacts in character to the intimate scene described above, whether they are part of it, watching it, or only overhearing it. One or two short lines.) {$cobTail}"],
];
$GLOBALS["PROMPTS"]["cob_after"] = [
    "cue" => ["({$cobNpc} talks about the intimate scene that just ended, in character and in their own voice. If they took part: how it was for them, what they liked most, whether they came, how they feel now and what they want next. If they only watched or heard it: their honest reaction. One to three short lines.) {$cobTail}"],
];
$GLOBALS["PROMPTS"]["cob_refused"] = [
    "cue" => ["({$cobNpc} wanted to do what is described above, but it did not happen in the game, for the reason given. {$cobNpc} says one short line in character about it - surprise, annoyance, a joke, or what to do instead - and does not try the same action again now.) {$cobTail}"],
];
