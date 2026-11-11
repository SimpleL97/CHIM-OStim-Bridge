<?php
// Names in a target (cob_lib.php: cobResolveTargets, cobNameRetry), against a fake CHIM database.
// Run from the repository: php tests/test_names.php

class FakeDb
{
    public $opts = [];
    public $infonpc = "";
    public $close = "";
    function fetchOne($sql, $p = [])
    {
        if (strpos($sql, "FROM eventlog") !== false) {
            $d = ($p[0] ?? "") === "infonpc" ? $this->infonpc : $this->close;
            return $d === "" ? [] : ["data" => $d];
        }
        if (strpos($sql, "FROM conf_opts") !== false) {
            return isset($this->opts[$p[0]]) ? ["value" => $this->opts[$p[0]]] : [];
        }
        return [];
    }
    function upsertRowOnConflict($t, $row, $k)
    {
        $this->opts[$row["id"]] = $row["value"];
    }
}

$db = new FakeDb();
$db->infonpc = "(beings in range:Hilde the Lioness (far away),Ярл Torvald the Greater,Ulf [Стражник Вайтрана],Asta [RefID: FE07FE69],Gunnar [Bandit Defender] (dead),Freya,Valdimar (busy),Курица,Курица)";
$db->close = "Freya/Valdimar (busy)/Brenna//Aldric";
$GLOBALS["db"] = $db;
$GLOBALS["PLAYER_NAME"] = "Aldric";

require __DIR__ . "/../server/cob_ostim_bridge/cob_lib.php";

$fail = 0;
function check($label, $got, $want)
{
    global $fail;
    $ok = $got === $want;
    if (!$ok) {
        $fail++;
    }
    printf("%s %-46s %s\n", $ok ? "ok  " : "FAIL", $label, $ok ? $got : "got <$got> want <$want>");
}

$cases = [
    ["TheNarrator", "player"],
    ["The Narrator", "player"],
    ["you", "player"],
    ["Aldric", "player"],
    ["aldric", "player"],
    ["Aldric Varro", "player"],
    ["Thane Aldric", "player"],
    ["\"Aldric\"", "player"],
    ["me", "Brenna"],
    ["Brenna", "Brenna"],
    ["Hilde", "Hilde the Lioness"],
    ["Torvald the Greater", "Ярл Torvald the Greater"],
    ["Jarl Torvald the Greater", "Jarl Torvald the Greater"],
    ["Ulf", "Ulf [Стражник Вайтрана]"],
    ["Ulf [Стражник Вайтрана]", "Ulf [Стражник Вайтрана]"],
    ["Valdimer", "Valdimar"],
    ["Freya (busy)", "Freya"],
    ["Asta [RefID: FE07FE69]", "Asta [RefID: FE07FE69]"],
    ["Somebody Else", "Somebody Else"],
    ["Aldric, Hilde and Freya", "player, Hilde the Lioness, Freya"],
    ["Aldric; Aldric, you", "player"],
    ["Gunnar", "Gunnar [Bandit Defender]"],
    ["", ""],
    ["-", "-"],
];
foreach ($cases as [$in, $want]) {
    check("COB <$in>", cobResolveTargets($in, "Brenna"), $want);
}

// the name the player has in CHIM's settings differs from the game: any of the player words still mean the player
$GLOBALS["PLAYER_NAME"] = "Prisoner";
check("COB CHIM name differs <Prisoner>", cobResolveTargets("Prisoner", "Brenna"), "player");
$GLOBALS["PLAYER_NAME"] = "Aldric";

// a name nobody here has: an instruction once, then the plain refusal
$data = "command@ExtCmdCOB_ChangeScene@Brenna~Bob~-~-@cannot start: nobody called Bob is here";
$r1 = cobNameRetry($data);
check("COB retry, first", $r1 !== null && strpos($r1, "The Narrator: Brenna tried Change_Intimate_Scene") === 0 && strpos($r1, "Aldric, Hilde the Lioness") !== false, true);
check("COB retry, second within a minute", cobNameRetry($data), null);
check("COB other refusal is no retry", cobNameRetry("command@ExtCmdCOB_StartScene@Brenna~-~-~-@refuses: there is a fight going on"), null);
check("COB refusal event still made", cobRefusalEvent($data) !== null, true);
echo $fail === 0 ? "ALL PASS\n" : "$fail FAILED\n";
exit($fail ? 1 : 0);
