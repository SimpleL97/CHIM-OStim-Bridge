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
$GLOBALS["PROMPTS"]["cob_during"] = [
    "cue" => ["({$cobNpc} is in the middle of the intimate scene described above and says one short line right now, in character: what they feel this very moment, a moan turned into words, a reaction to what just changed, or what they want next. One short line, spoken in the heat of the moment.) {$cobTail}"],
];
// cries of passion: a few words only; the Inworld voice gets its tone in context_pre.php
$cobMoanCue = "({$cobNpc} only cries out in the heat of the moment: one to four words, breathless and broken - a moan, an \"oh god\", \"deeper\", \"don't stop\", \"yes, yes, yes!\" or the like, in the language {$cobNpc} speaks. Nothing else: no sentence, no question, no description.) {$cobTail}";
foreach (["cob_moan", "cob_moan_high"] as $cobKind) {
    $GLOBALS["PROMPTS"][$cobKind] = ["cue" => [$cobMoanCue]];
}
$GLOBALS["PROMPTS"]["cob_moan_start"] = [
    "cue" => ["({$cobNpc} murmurs one to four words as the intimate scene begins: inviting, teasing or seductive - \"come here...\", \"quiet...\", \"come on...\" or the like, in the language {$cobNpc} speaks. Nothing else: no sentence, no question, no description.) {$cobTail}"],
];
$GLOBALS["PROMPTS"]["cob_moan_peak"] = [
    "cue" => ["({$cobNpc} is close to the edge and only cries out: one to four words, breathless, pleading or overwhelmed - \"don't stop\", \"more, more!\", \"I can't anymore\" or the like, in the language {$cobNpc} speaks. Nothing else: no sentence, no question, no description.) {$cobTail}"],
];
$GLOBALS["PROMPTS"]["cob_moan_after"] = [
    "cue" => ["({$cobNpc} has just climaxed and murmurs one to four words, spent and happy - a contented \"mmm... god...\", a soft laugh, \"that was...\" or the like, in the language {$cobNpc} speaks. Nothing else: no sentence, no question, no description.) {$cobTail}"],
];
$GLOBALS["PROMPTS"]["cob_moan_climax"] = [
    "cue" => ["({$cobNpc} is climaxing right now and only cries out: one to four words, breathless and broken, in the language {$cobNpc} speaks. Nothing else: no sentence, no question, no description.) {$cobTail}"],
];
// alone (masturbation): wordless sounds only - nobody is there to talk to
$cobSoloCue = "({$cobNpc} is pleasuring themselves alone and only moans: one to four wordless sounds - \"mmm...\", \"ah...\", \"ahh!\", a gasp - the way {$cobNpc} sounds. No words at all: no names, no requests, nothing said to anyone, nothing about a partner.) {$cobTail}";
foreach (["cob_moan_solo", "cob_moan_solo_high", "cob_moan_solo_peak"] as $cobKind) {
    $GLOBALS["PROMPTS"][$cobKind] = ["cue" => [$cobSoloCue]];
}
$GLOBALS["PROMPTS"]["cob_moan_solo_climax"] = [
    "cue" => ["({$cobNpc} is climaxing alone, pleasuring themselves, and only cries out: wordless sounds - a long moan, a sharp gasp. No words at all: no names, nothing said to anyone, nothing about a partner.) {$cobTail}"],
];
$GLOBALS["PROMPTS"]["cob_moan_solo_after"] = [
    "cue" => ["({$cobNpc} has just climaxed alone and only lets out a contented sigh or a soft \"mmm...\" - sounds, no words to anyone.) {$cobTail}"],
];
$GLOBALS["PROMPTS"]["cob_refused"] = [
    "cue" => ["({$cobNpc} wanted to do what is described above, but it did not happen in the game, for the reason given. {$cobNpc} says one short line in character about it - surprise, annoyance, a joke, or what to do instead - and does not try the same action again now. The reason is for {$cobNpc} to understand, not to quote: speak only in-world, never mention the game, mods, ORomance, stats or numbers.) {$cobTail}"],
];
