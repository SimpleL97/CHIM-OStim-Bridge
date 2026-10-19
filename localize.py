"""CHIM OStim Bridge - MCM localization.

Rewrites mcm/config.json so every page, header, option and help text is a "$COB_..."
key, and writes mcm/translations/CHIMOStimBridge_<LANGUAGE>.txt (UTF-16 LE + BOM,
"$key<TAB>text" lines, as SkyUI expects). The game picks the file matching its own
language (sLanguage in Skyrim.ini). A missing language would show raw $keys, so every
language Skyrim ships in gets a file. Run: python3 -I localize.py
"""
import json, os

ROOT = os.path.dirname(os.path.abspath(__file__))
LANGS = ["ENGLISH", "RUSSIAN", "UKRAINIAN", "GERMAN", "FRENCH", "SPANISH", "ITALIAN",
         "POLISH", "CZECH", "PORTUGUESE", "JAPANESE", "CHINESE"]

# key: config.json location -> (English, then the other languages in LANGS order)
T = {
 "pGeneral": ["General", "Общие", "Загальні", "Allgemein", "Général", "General", "Generale", "Ogólne", "Obecné", "Geral", "一般", "常规"],
 "pReactions": ["Reactions", "Реакции", "Реакції", "Reaktionen", "Réactions", "Reacciones", "Reazioni", "Reakcje", "Reakce", "Reações", "反応", "反应"],
 "pNeeds": ["Needs", "Потребности", "Потреби", "Bedürfnisse", "Besoins", "Necesidades", "Bisogni", "Potrzeby", "Potřeby", "Necessidades", "欲求", "需求"],
 "pFixes": ["CHIM fixes", "Исправления CHIM", "Виправлення CHIM", "CHIM-Korrekturen", "Correctifs CHIM", "Correcciones de CHIM", "Correzioni CHIM", "Poprawki CHIM", "Opravy CHIM", "Correções do CHIM", "CHIM修正", "CHIM 修复"],

 "Log": ["Write a log file", "Писать лог-файл", "Писати лог-файл", "Logdatei schreiben", "Écrire un fichier journal", "Escribir un archivo de registro", "Scrivi un file di log", "Zapisuj plik dziennika", "Zapisovat soubor protokolu", "Gravar arquivo de log", "ログファイルを書く", "写入日志文件"],
 "LogH": ["Writes what the mod does to Data/SKSE/Plugins/CHIMOStimBridge.log (a new file every time the game starts) and on the CHIM server to log/cob_ostim_bridge.log. Handy when something goes wrong: attach these files to a bug report.",
  "Записывает, что делает мод, в Data/SKSE/Plugins/CHIMOStimBridge.log (новый файл при каждом запуске игры) и на сервере CHIM в log/cob_ostim_bridge.log. Полезно, если что-то пошло не так: приложите эти файлы к сообщению об ошибке.",
  "Записує, що робить мод, у Data/SKSE/Plugins/CHIMOStimBridge.log (новий файл при кожному запуску гри) і на сервері CHIM у log/cob_ostim_bridge.log. Корисно, якщо щось пішло не так: додайте ці файли до повідомлення про помилку.",
  "Schreibt, was die Mod tut, nach Data/SKSE/Plugins/CHIMOStimBridge.log (bei jedem Spielstart eine neue Datei) und auf dem CHIM-Server nach log/cob_ostim_bridge.log. Hilfreich, wenn etwas schiefgeht: Hänge die Dateien an einen Fehlerbericht an.",
  "Écrit ce que fait le mod dans Data/SKSE/Plugins/CHIMOStimBridge.log (un nouveau fichier à chaque lancement du jeu) et, sur le serveur CHIM, dans log/cob_ostim_bridge.log. Utile en cas de problème : joignez ces fichiers à un rapport de bug.",
  "Escribe lo que hace el mod en Data/SKSE/Plugins/CHIMOStimBridge.log (un archivo nuevo cada vez que se inicia el juego) y en el servidor de CHIM en log/cob_ostim_bridge.log. Útil si algo falla: adjunta esos archivos a un informe de error.",
  "Scrive ciò che fa la mod in Data/SKSE/Plugins/CHIMOStimBridge.log (un nuovo file a ogni avvio del gioco) e sul server CHIM in log/cob_ostim_bridge.log. Utile quando qualcosa va storto: allega questi file a una segnalazione di bug.",
  "Zapisuje, co robi mod, do Data/SKSE/Plugins/CHIMOStimBridge.log (nowy plik przy każdym uruchomieniu gry) i na serwerze CHIM do log/cob_ostim_bridge.log. Przydatne, gdy coś pójdzie nie tak: dołącz te pliki do zgłoszenia błędu.",
  "Zapisuje, co mod dělá, do Data/SKSE/Plugins/CHIMOStimBridge.log (nový soubor při každém spuštění hry) a na serveru CHIM do log/cob_ostim_bridge.log. Užitečné, když se něco pokazí: přilož tyto soubory k hlášení chyby.",
  "Grava o que o mod faz em Data/SKSE/Plugins/CHIMOStimBridge.log (um arquivo novo a cada início do jogo) e, no servidor do CHIM, em log/cob_ostim_bridge.log. Útil quando algo dá errado: anexe esses arquivos a um relatório de bug.",
  "MODの動作をData/SKSE/Plugins/CHIMOStimBridge.log（ゲームを起動するたびに新しいファイル）と、CHIMサーバーのlog/cob_ostim_bridge.logに記録します。問題が起きたときは、これらのファイルを不具合報告に添えてください。",
  "将模组的操作写入 Data/SKSE/Plugins/CHIMOStimBridge.log（每次启动游戏都会新建文件），并写入 CHIM 服务器的 log/cob_ostim_bridge.log。出现问题时很有用：请把这些文件附在错误报告中。"],
 "hScenes": ["Scenes", "Сцены", "Сцени", "Szenen", "Scènes", "Escenas", "Scene", "Sceny", "Scény", "Cenas", "シーン", "场景"],
 "hDebug": ["Debug", "Отладка", "Налагодження", "Debug", "Débogage", "Depuración", "Debug", "Debugowanie", "Ladění", "Depuração", "デバッグ", "调试"],
 "hReactWhat": ["What the AI agents comment on", "На что реагируют ИИ-агенты", "На що реагують ШІ-агенти", "Was die KI-Agenten kommentieren", "Ce que commentent les agents IA", "Qué comentan los agentes de IA", "Cosa commentano gli agenti IA", "Co komentują agenci AI", "Co komentují AI agenti", "O que os agentes de IA comentam", "AIエージェントが反応すること", "AI 角色会评论的事件"],
 "hHowOften": ["How often", "Как часто", "Як часто", "Wie oft", "Fréquence", "Con qué frecuencia", "Con quale frequenza", "Jak często", "Jak často", "Com que frequência", "頻度", "频率"],
 "hSexHunger": ["Hunger for sex", "Сексуальный голод", "Сексуальний голод", "Lust", "Désir sexuel", "Hambre de sexo", "Desiderio sessuale", "Głód seksu", "Touha po sexu", "Fome de sexo", "性欲", "性欲"],
 "hOther": ["Other", "Прочее", "Інше", "Sonstiges", "Autres", "Otros", "Altro", "Inne", "Ostatní", "Outros", "その他", "其他"],
 "hFixes": ["Fixes for CHIM itself", "Исправления для самого CHIM", "Виправлення для самого CHIM", "Korrekturen für CHIM selbst", "Correctifs pour CHIM lui-même", "Correcciones para el propio CHIM", "Correzioni per CHIM stesso", "Poprawki samego CHIM", "Opravy samotného CHIM", "Correções para o próprio CHIM", "CHIM本体の修正", "针对 CHIM 本身的修复"],

 "Enabled": ["Enable the bridge", "Включить мост", "Увімкнути міст", "Brücke aktivieren", "Activer le pont", "Activar el puente", "Attiva il ponte", "Włącz most", "Zapnout most", "Ativar a ponte", "ブリッジを有効化", "启用桥接"],
 "EnabledH": ["Master switch. When off, AI agents are told the bridge is turned off and no events are sent to CHIM.",
  "Главный выключатель. Когда он выключен, ИИ-агенты получают ответ, что мост отключён, и события в CHIM не отправляются.",
  "Головний вимикач. Коли він вимкнений, ШІ-агенти отримують відповідь, що міст вимкнено, і події в CHIM не надсилаються.",
  "Hauptschalter. Wenn aus, erfahren die KI-Agenten, dass die Brücke abgeschaltet ist, und es werden keine Ereignisse an CHIM gesendet.",
  "Interrupteur principal. Désactivé, les agents IA apprennent que le pont est coupé et aucun événement n'est envoyé à CHIM.",
  "Interruptor principal. Si está apagado, los agentes de IA saben que el puente está desactivado y no se envían eventos a CHIM.",
  "Interruttore principale. Se spento, gli agenti IA sanno che il ponte è disattivato e nessun evento viene inviato a CHIM.",
  "Główny przełącznik. Gdy wyłączony, agenci AI dowiadują się, że most jest wyłączony, i żadne zdarzenia nie trafiają do CHIM.",
  "Hlavní vypínač. Když je vypnutý, AI agenti se dozví, že most je vypnutý, a do CHIM se neposílají žádné události.",
  "Interruptor principal. Desligado, os agentes de IA sabem que a ponte está desativada e nenhum evento é enviado ao CHIM.",
  "メインスイッチ。オフにするとAIエージェントにブリッジが無効と伝えられ、CHIMへイベントは送られません。",
  "总开关。关闭时 AI 角色会被告知桥接已关闭，也不会向 CHIM 发送任何事件。"],
 "Range": ["Partner range", "Дальность до партнёра", "Відстань до партнера", "Partnerreichweite", "Portée du partenaire", "Alcance de la pareja", "Distanza del partner", "Zasięg partnera", "Dosah partnera", "Alcance do parceiro", "相手との距離", "伴侣距离"],
 "RangeH": ["How far away a partner may be. Inside this range the partner is placed next to the other one when the scene starts.",
  "Насколько далеко может быть партнёр. В пределах этого расстояния партнёр при старте сцены оказывается рядом.",
  "Наскільки далеко може бути партнер. У межах цієї відстані партнер на старті сцени опиняється поруч.",
  "Wie weit ein Partner entfernt sein darf. Innerhalb dieser Reichweite wird er beim Szenenstart neben den anderen gesetzt.",
  "Distance maximale du partenaire. Dans cette portée, il est placé à côté de l'autre au début de la scène.",
  "Qué tan lejos puede estar la pareja. Dentro de este alcance se coloca junto a la otra persona al empezar la escena.",
  "Quanto può essere lontano il partner. Entro questa distanza viene posizionato accanto all'altro all'inizio della scena.",
  "Jak daleko może być partner. W tym zasięgu na początku sceny zostaje ustawiony obok drugiej osoby.",
  "Jak daleko smí partner být. V tomto dosahu se na začátku scény ocitne vedle druhé postavy.",
  "Quão longe o parceiro pode estar. Dentro desse alcance ele é colocado ao lado do outro quando a cena começa.",
  "相手がどこまで離れていてよいか。この範囲内ならシーン開始時に相手の隣へ移動します。",
  "伴侣最远可以离多远。在此范围内，场景开始时会被放到对方身边。"],
 "MenActive": ["Men always take the active role", "Мужчины всегда в активной роли", "Чоловіки завжди в активній ролі", "Männer übernehmen immer die aktive Rolle", "Les hommes ont toujours le rôle actif", "Los hombres siempre llevan el papel activo", "Gli uomini hanno sempre il ruolo attivo", "Mężczyźni zawsze w roli aktywnej", "Muži vždy v aktivní roli", "Homens sempre no papel ativo", "男性が常に能動側", "男性始终担任主动方"],
 "MenActiveH": ["OStim gives the first actor the active role. When on, actors are ordered male player, other men, female player, other women, so a woman who starts a scene is not given a strap-on.",
  "OStim отдаёт активную роль первому участнику. Когда включено, порядок такой: игрок-мужчина, другие мужчины, игрок-женщина, другие женщины, поэтому женщина, начавшая сцену, не получает страпон.",
  "OStim віддає активну роль першому учаснику. Коли увімкнено, порядок такий: гравець-чоловік, інші чоловіки, гравчиня, інші жінки, тож жінка, яка почала сцену, не отримує страпон.",
  "OStim gibt dem ersten Akteur die aktive Rolle. Aktiviert lautet die Reihenfolge: männlicher Spieler, andere Männer, weibliche Spielerin, andere Frauen, damit eine Frau, die eine Szene beginnt, keinen Strap-on bekommt.",
  "OStim donne le rôle actif au premier acteur. Activé, l'ordre est : joueur masculin, autres hommes, joueuse, autres femmes, pour qu'une femme qui lance une scène ne reçoive pas de gode-ceinture.",
  "OStim da el papel activo al primer actor. Activado, el orden es: jugador masculino, otros hombres, jugadora, otras mujeres, para que una mujer que inicia una escena no reciba un arnés.",
  "OStim assegna il ruolo attivo al primo attore. Se attivo, l'ordine è: giocatore maschio, altri uomini, giocatrice, altre donne, così una donna che avvia una scena non riceve uno strap-on.",
  "OStim daje aktywną rolę pierwszemu aktorowi. Po włączeniu kolejność to: gracz mężczyzna, inni mężczyźni, graczka, inne kobiety, więc kobieta rozpoczynająca scenę nie dostaje strap-onu.",
  "OStim dává aktivní roli prvnímu herci. Když je zapnuto, pořadí je: hráč muž, další muži, hráčka, další ženy, takže žena, která scénu začne, nedostane strap-on.",
  "O OStim dá o papel ativo ao primeiro ator. Ligado, a ordem é: jogador homem, outros homens, jogadora, outras mulheres, para que uma mulher que inicia a cena não receba um strap-on.",
  "OStimは最初の参加者に能動側を割り当てます。オンにすると男性プレイヤー、他の男性、女性プレイヤー、他の女性の順になり、シーンを始めた女性にストラップオンが付きません。",
  "OStim 把主动方交给第一位参与者。开启后顺序为：男性玩家、其他男性、女性玩家、其他女性，这样发起场景的女性不会被装上假阳具。"],
 "Groups": ["Allow group scenes", "Разрешить групповые сцены", "Дозволити групові сцени", "Gruppenszenen erlauben", "Autoriser les scènes de groupe", "Permitir escenas en grupo", "Consenti scene di gruppo", "Zezwalaj na sceny grupowe", "Povolit skupinové scény", "Permitir cenas em grupo", "グループシーンを許可", "允许多人场景"],
 "GroupsH": ["Let an agent start a scene with several partners at once (needs 3P+ animations). When off, only the first named partner is used.",
  "Агент может начать сцену сразу с несколькими партнёрами (нужны анимации на 3+ человек). Когда выключено, берётся только первый названный партнёр.",
  "Агент може почати сцену одразу з кількома партнерами (потрібні анімації на 3+ людей). Коли вимкнено, береться лише перший названий партнер.",
  "Ein Agent darf eine Szene mit mehreren Partnern gleichzeitig beginnen (benötigt 3P+-Animationen). Aus: nur der erste genannte Partner.",
  "Un agent peut lancer une scène avec plusieurs partenaires à la fois (animations 3P+ requises). Désactivé : seul le premier partenaire nommé est utilisé.",
  "Un agente puede iniciar una escena con varias parejas a la vez (requiere animaciones de 3+). Desactivado: solo se usa la primera pareja nombrada.",
  "Un agente può avviare una scena con più partner insieme (servono animazioni 3P+). Se disattivo, viene usato solo il primo partner nominato.",
  "Agent może zacząć scenę z kilkoma partnerami naraz (wymaga animacji 3P+). Po wyłączeniu używany jest tylko pierwszy wymieniony partner.",
  "Agent může začít scénu s více partnery najednou (vyžaduje animace 3P+). Když je vypnuto, použije se jen první jmenovaný partner.",
  "Um agente pode iniciar uma cena com vários parceiros de uma vez (requer animações 3P+). Desligado, só o primeiro parceiro nomeado é usado.",
  "エージェントが複数の相手と同時にシーンを始められます（3人以上のアニメーションが必要）。オフの場合は最初に名前の出た相手のみ。",
  "允许 AI 角色同时与多名伴侣开始场景（需要 3 人以上动画）。关闭时只使用第一个点名的伴侣。"],
 "AnyNPC": ["Any nearby NPC can be a partner", "Партнёром может быть любой NPC рядом", "Партнером може бути будь-який NPC поруч", "Jeder NPC in der Nähe kann Partner sein", "N'importe quel PNJ proche peut être partenaire", "Cualquier PNJ cercano puede ser pareja", "Qualsiasi PNG vicino può essere partner", "Partnerem może być każdy pobliski NPC", "Partnerem může být jakékoli blízké NPC", "Qualquer NPC próximo pode ser parceiro", "近くのどのNPCも相手にできる", "附近任何 NPC 都可以作为伴侣"],
 "AnyNPCH": ["Find a named partner among all NPCs around the player, not only NPCs CHIM already knows.",
  "Искать названного партнёра среди всех NPC вокруг игрока, а не только среди знакомых CHIM.",
  "Шукати названого партнера серед усіх NPC навколо гравця, а не лише серед знайомих CHIM.",
  "Einen genannten Partner unter allen NPCs um den Spieler suchen, nicht nur unter denen, die CHIM schon kennt.",
  "Chercher le partenaire nommé parmi tous les PNJ autour du joueur, pas seulement ceux que CHIM connaît.",
  "Buscar a la pareja nombrada entre todos los PNJ alrededor del jugador, no solo los que CHIM ya conoce.",
  "Cerca il partner nominato tra tutti i PNG attorno al giocatore, non solo quelli che CHIM conosce già.",
  "Szukaj wymienionego partnera wśród wszystkich NPC wokół gracza, nie tylko tych znanych CHIM.",
  "Hledat jmenovaného partnera mezi všemi NPC kolem hráče, nejen mezi těmi, které CHIM už zná.",
  "Procurar o parceiro nomeado entre todos os NPCs ao redor do jogador, não só os que o CHIM já conhece.",
  "CHIMが知っているNPCだけでなく、プレイヤー周辺の全NPCから名前の出た相手を探します。",
  "在玩家周围所有 NPC 中寻找被点名的伴侣，而不只是 CHIM 已认识的 NPC。"],
 "Notify": ["Show notifications", "Показывать уведомления", "Показувати сповіщення", "Benachrichtigungen anzeigen", "Afficher les notifications", "Mostrar notificaciones", "Mostra notifiche", "Pokazuj powiadomienia", "Zobrazovat oznámení", "Mostrar notificações", "通知を表示", "显示通知"],
 "NotifyH": ["Show a corner notification for every action result and every event sent to CHIM.",
  "Показывать в углу экрана уведомление о каждом результате действия и каждом событии, отправленном в CHIM.",
  "Показувати в куті екрана сповіщення про кожен результат дії та кожну подію, надіслану в CHIM.",
  "Für jedes Aktionsergebnis und jedes an CHIM gesendete Ereignis eine Eckbenachrichtigung zeigen.",
  "Afficher une notification pour chaque résultat d'action et chaque événement envoyé à CHIM.",
  "Mostrar un aviso en la esquina por cada resultado de acción y cada evento enviado a CHIM.",
  "Mostra una notifica in angolo per ogni risultato di azione e ogni evento inviato a CHIM.",
  "Pokazuj w rogu powiadomienie o każdym wyniku akcji i każdym zdarzeniu wysłanym do CHIM.",
  "Zobrazit v rohu oznámení o každém výsledku akce a každé události odeslané do CHIM.",
  "Mostrar uma notificação no canto para cada resultado de ação e cada evento enviado ao CHIM.",
  "アクションの結果とCHIMへ送ったイベントごとに画面隅へ通知を表示します。",
  "每个动作结果和每个发送给 CHIM 的事件都在角落显示通知。"],

 "City": ["Entering / leaving the big cities", "Вход в большие города и выход из них", "Вхід у великі міста й вихід з них", "Große Städte betreten / verlassen", "Entrer / sortir des grandes villes", "Entrar / salir de las grandes ciudades", "Entrare / uscire dalle grandi città", "Wejście do dużych miast i wyjście", "Vstup do velkých měst a odchod", "Entrar / sair das grandes cidades", "大都市への出入り", "进出大城市"],
 "CityH": ["Whiterun, Solitude, Windhelm, Riften, Markarth and Raven Rock, including fast travel between them.",
  "Вайтран, Солитьюд, Виндхельм, Рифтен, Маркарт и Вороний Камень, включая быстрое перемещение между ними.",
  "Вайтран, Солітьюд, Віндгельм, Ріфтен, Маркарт і Вороняча Скеля, включно зі швидким переміщенням між ними.",
  "Weißlauf, Einsamkeit, Windhelm, Rifton, Markarth und Rabenfels, auch per Schnellreise.",
  "Blancherive, Solitude, Vendeaume, Faillaise, Markarth et Corberoc, y compris le voyage rapide entre elles.",
  "Carrera Blanca, Soledad, Ventalia, Riften, Markarth y Cuervo Rojo, incluido el viaje rápido entre ellas.",
  "Whiterun, Solitude, Windhelm, Riften, Markarth e Raven Rock, compreso il viaggio rapido tra loro.",
  "Biegłowo, Samotnia, Wichrowy Tron, Pękninie, Markarth i Kruczy Kamień, także szybka podróż między nimi.",
  "Bílý Běh, Samota, Větrný Žleb, Riften, Markarth a Havraní Skála, včetně rychlého cestování mezi nimi.",
  "Whiterun, Solitude, Windhelm, Riften, Markarth e Raven Rock, incluindo viagem rápida entre elas.",
  "ホワイトラン、ソリチュード、ウィンドヘルム、リフテン、マルカルス、レイブン・ロック（ファストトラベルを含む）。",
  "雪漫城、独孤城、风盔城、裂谷城、马卡斯城和渡鸦岩，包括它们之间的快速旅行。"],
 "Shop": ["Walking into a shop", "Вход в магазин", "Вхід у крамницю", "Einen Laden betreten", "Entrer dans une boutique", "Entrar en una tienda", "Entrare in un negozio", "Wejście do sklepu", "Vstup do obchodu", "Entrar numa loja", "店に入る", "进入商店"],
 "Home": ["Walking into your own home", "Вход в свой дом", "Вхід у свій дім", "Das eigene Haus betreten", "Entrer dans sa propre maison", "Entrar en tu propia casa", "Entrare nella propria casa", "Wejście do własnego domu", "Vstup do vlastního domu", "Entrar na própria casa", "自宅に入る", "进入自己的房子"],
 "Wake": ["Waking up", "Пробуждение", "Пробудження", "Aufwachen", "Réveil", "Despertar", "Risveglio", "Przebudzenie", "Probuzení", "Acordar", "目覚め", "醒来"],
 "DragonSoul": ["Absorbing a dragon soul", "Поглощение души дракона", "Поглинання душі дракона", "Eine Drachenseele absorbieren", "Absorber une âme de dragon", "Absorber un alma de dragón", "Assorbire un'anima di drago", "Pochłonięcie duszy smoka", "Pohlcení dračí duše", "Absorver uma alma de dragão", "ドラゴンソウルの吸収", "吸收龙魂"],
 "Naked": ["You stripping naked", "Вы раздеваетесь догола", "Ви роздягаєтесь догола", "Du ziehst dich nackt aus", "Vous vous déshabillez", "Te desnudas", "Ti spogli completamente", "Rozbierasz się do naga", "Svlékneš se donaha", "Você fica nu", "あなたが裸になる", "你脱光衣服"],
 "SceneNear": ["An OStim scene starting nearby", "Начало сцены OStim поблизости", "Початок сцени OStim поруч", "Eine OStim-Szene beginnt in der Nähe", "Une scène OStim commence à proximité", "Una escena de OStim empieza cerca", "Una scena OStim inizia nelle vicinanze", "Scena OStim zaczyna się w pobliżu", "Poblíž začíná scéna OStim", "Uma cena OStim começa por perto", "近くでOStimシーンが始まる", "附近开始 OStim 场景"],
 "SceneNearH": ["Scenes an agent started itself are not announced twice.",
  "Сцены, которые агент начал сам, не объявляются дважды.",
  "Сцени, які агент почав сам, не оголошуються двічі.",
  "Szenen, die ein Agent selbst begonnen hat, werden nicht doppelt angekündigt.",
  "Les scènes lancées par un agent lui-même ne sont pas annoncées deux fois.",
  "Las escenas que un agente inició por sí mismo no se anuncian dos veces.",
  "Le scene avviate da un agente stesso non vengono annunciate due volte.",
  "Sceny rozpoczęte przez samego agenta nie są ogłaszane dwa razy.",
  "Scény, které agent začal sám, se neoznamují dvakrát.",
  "Cenas que um agente iniciou sozinho não são anunciadas duas vezes.",
  "エージェント自身が始めたシーンは二重に通知されません。",
  "AI 角色自己发起的场景不会被重复通报。"],
 "After": ["Talking after a scene", "Разговор после сцены", "Розмова після сцени", "Gespräch nach einer Szene", "Discussion après une scène", "Charla después de una escena", "Parlare dopo una scena", "Rozmowa po scenie", "Rozhovor po scéně", "Conversa depois da cena", "シーン後の会話", "场景结束后的交谈"],
 "AfterH": ["When a scene ends, a participant talks about it: how it was, what she liked, whether she came.",
  "Когда сцена заканчивается, участник говорит о ней: как было, что понравилось, кончил ли.",
  "Коли сцена закінчується, учасник говорить про неї: як було, що сподобалось, чи кінчив.",
  "Wenn eine Szene endet, spricht ein Teilnehmer darüber: wie es war, was gefiel, ob er gekommen ist.",
  "Quand une scène se termine, un participant en parle : comment c'était, ce qui a plu, s'il a joui.",
  "Cuando termina una escena, un participante habla de ella: cómo fue, qué le gustó, si llegó al orgasmo.",
  "Quando una scena finisce, un partecipante ne parla: com'è stata, cosa gli è piaciuto, se è venuto.",
  "Gdy scena się kończy, uczestnik o niej mówi: jak było, co się podobało, czy doszedł.",
  "Když scéna skončí, účastník o ní mluví: jaké to bylo, co se mu líbilo, jestli se udělal.",
  "Quando a cena termina, um participante fala sobre ela: como foi, do que gostou, se chegou ao clímax.",
  "シーンが終わると参加者が感想を話します：どうだったか、何が良かったか、達したかどうか。",
  "场景结束后，参与者会谈论它：感觉如何、喜欢什么、是否达到高潮。"],
 "Chance": ["Comment chance", "Шанс комментария", "Шанс коментаря", "Kommentar-Wahrscheinlichkeit", "Probabilité de commentaire", "Probabilidad de comentario", "Probabilità di commento", "Szansa na komentarz", "Šance na komentář", "Chance de comentário", "コメントの確率", "评论概率"],
 "ChanceH": ["Chance that an agent comments on an event (all of the above except talking after a scene).",
  "Вероятность, что агент прокомментирует событие (все пункты выше, кроме разговора после сцены).",
  "Ймовірність, що агент прокоментує подію (усі пункти вище, крім розмови після сцени).",
  "Wahrscheinlichkeit, dass ein Agent ein Ereignis kommentiert (alles oben außer dem Gespräch nach einer Szene).",
  "Probabilité qu'un agent commente un événement (tout ce qui précède sauf la discussion après une scène).",
  "Probabilidad de que un agente comente un evento (todo lo anterior salvo la charla después de una escena).",
  "Probabilità che un agente commenti un evento (tutto quanto sopra tranne parlare dopo una scena).",
  "Szansa, że agent skomentuje zdarzenie (wszystko powyżej oprócz rozmowy po scenie).",
  "Šance, že agent okomentuje událost (vše výše kromě rozhovoru po scéně).",
  "Chance de um agente comentar um evento (tudo acima exceto a conversa depois da cena).",
  "エージェントがイベントにコメントする確率（シーン後の会話以外の上記すべて）。",
  "AI 角色评论事件的概率（以上所有项目，场景后的交谈除外）。"],
 "AfterChance": ["After-scene talk chance", "Шанс разговора после сцены", "Шанс розмови після сцени", "Wahrscheinlichkeit für Gespräch danach", "Probabilité de discussion après", "Probabilidad de charla posterior", "Probabilità di parlare dopo", "Szansa na rozmowę po scenie", "Šance na rozhovor po scéně", "Chance de conversa depois", "シーン後の会話の確率", "场景后交谈概率"],
 "Cooldown": ["Cooldown between comments", "Пауза между комментариями", "Пауза між коментарями", "Abklingzeit zwischen Kommentaren", "Délai entre les commentaires", "Espera entre comentarios", "Pausa tra i commenti", "Odstęp między komentarzami", "Prodleva mezi komentáři", "Intervalo entre comentários", "コメント間のクールダウン", "评论冷却时间"],
 "CooldownH": ["Real seconds between two comments of the same kind.",
  "Реальные секунды между двумя комментариями одного вида.",
  "Реальні секунди між двома коментарями одного виду.",
  "Echte Sekunden zwischen zwei Kommentaren derselben Art.",
  "Secondes réelles entre deux commentaires du même type.",
  "Segundos reales entre dos comentarios del mismo tipo.",
  "Secondi reali tra due commenti dello stesso tipo.",
  "Prawdziwe sekundy między dwoma komentarzami tego samego rodzaju.",
  "Skutečné sekundy mezi dvěma komentáři stejného druhu.",
  "Segundos reais entre dois comentários do mesmo tipo.",
  "同じ種類のコメント同士の間隔（実時間の秒）。",
  "两条同类评论之间的现实秒数。"],

 "Needs": ["Enable needs", "Включить потребности", "Увімкнути потреби", "Bedürfnisse aktivieren", "Activer les besoins", "Activar necesidades", "Attiva i bisogni", "Włącz potrzeby", "Zapnout potřeby", "Ativar necessidades", "欲求を有効化", "启用需求"],
 "NeedsH": ["Tell the AI how the listed NPCs feel right now (hunger, drink, arousal, jealousy). Everything below needs this.",
  "Сообщать ИИ, как перечисленные NPC чувствуют себя сейчас (голод, выпивка, возбуждение, ревность). Всё ниже работает только с этим.",
  "Повідомляти ШІ, як перелічені NPC почуваються зараз (голод, випивка, збудження, ревнощі). Усе нижче працює лише з цим.",
  "Der KI mitteilen, wie sich die aufgeführten NPCs gerade fühlen (Hunger, Alkohol, Erregung, Eifersucht). Alles darunter braucht das.",
  "Indiquer à l'IA comment se sentent les PNJ listés (faim, boisson, excitation, jalousie). Tout ce qui suit en dépend.",
  "Decirle a la IA cómo se sienten ahora los PNJ indicados (hambre, bebida, excitación, celos). Todo lo de abajo lo necesita.",
  "Dire all'IA come si sentono ora i PNG elencati (fame, alcol, eccitazione, gelosia). Tutto ciò che segue lo richiede.",
  "Przekazuj AI, jak czują się teraz wymienieni NPC (głód, alkohol, podniecenie, zazdrość). Wszystko poniżej tego wymaga.",
  "Sdělovat AI, jak se uvedené NPC právě cítí (hlad, pití, vzrušení, žárlivost). Vše níže to vyžaduje.",
  "Informar à IA como os NPCs listados se sentem agora (fome, bebida, excitação, ciúmes). Tudo abaixo depende disso.",
  "指定したNPCの今の状態（飢え、酒、興奮、嫉妬）をAIに伝えます。以下の項目はすべてこれが必要です。",
  "告诉 AI 所列 NPC 此刻的状态（饥渴、醉酒、兴奋、嫉妒）。以下所有项目都依赖此项。"],
 "SexNPCs": ["NPCs", "NPC", "NPC", "NPCs", "PNJ", "PNJ", "PNG", "NPC", "NPC", "NPCs", "NPC", "NPC"],
 "SexNPCsH": ["Comma separated names, exactly as shown in game. Without sex they grow restless, then burning, then angry. Any OStim scene they take part in feeds it.",
  "Имена через запятую, точно как в игре. Без секса они становятся беспокойными, потом сгорают от желания, потом злятся. Любая сцена OStim с их участием утоляет голод.",
  "Імена через кому, точно як у грі. Без сексу вони стають неспокійними, потім палають від бажання, потім злостяться. Будь-яка сцена OStim з їхньою участю вгамовує голод.",
  "Namen durch Kommas getrennt, genau wie im Spiel. Ohne Sex werden sie unruhig, dann brennend, dann wütend. Jede OStim-Szene mit ihnen stillt es.",
  "Noms séparés par des virgules, exactement comme en jeu. Sans sexe ils deviennent agités, puis brûlants, puis en colère. Toute scène OStim avec eux l'apaise.",
  "Nombres separados por comas, tal como aparecen en el juego. Sin sexo se inquietan, luego arden, luego se enfadan. Cualquier escena de OStim en la que participen lo sacia.",
  "Nomi separati da virgole, esattamente come nel gioco. Senza sesso diventano irrequieti, poi ardenti, poi arrabbiati. Ogni scena OStim a cui partecipano lo placa.",
  "Imiona oddzielone przecinkami, dokładnie jak w grze. Bez seksu stają się niespokojni, potem płoną, potem się złoszczą. Każda scena OStim z ich udziałem to zaspokaja.",
  "Jména oddělená čárkou, přesně jako ve hře. Bez sexu jsou neklidní, pak hoří touhou, pak se zlobí. Každá scéna OStim s jejich účastí to utiší.",
  "Nomes separados por vírgula, exatamente como no jogo. Sem sexo ficam inquietos, depois ardentes, depois irritados. Qualquer cena OStim com eles sacia isso.",
  "ゲーム内の表示どおりの名前をカンマ区切りで。セックスがないと落ち着かず、やがて燃え上がり、怒り出します。参加したOStimシーンで満たされます。",
  "用逗号分隔的名字，与游戏中显示的一致。没有性生活他们会焦躁、继而欲火焚身、然后发怒。参与任何 OStim 场景都能满足。"],
 "SexHours": ["Hours until it starts", "Часов до начала", "Годин до початку", "Stunden bis zum Beginn", "Heures avant que ça commence", "Horas hasta que empiece", "Ore prima che inizi", "Godzin do początku", "Hodin do začátku", "Horas até começar", "始まるまでの時間", "开始前的小时数"],
 "SexHoursH": ["Game hours. The next stages come at twice and four times this.",
  "Игровые часы. Следующие стадии наступают через вдвое и вчетверо больший срок.",
  "Ігрові години. Наступні стадії настають через удвічі й учетверо довший час.",
  "Spielstunden. Die nächsten Stufen folgen beim Doppelten und Vierfachen.",
  "Heures de jeu. Les étapes suivantes arrivent au double et au quadruple.",
  "Horas de juego. Las siguientes fases llegan al doble y al cuádruple.",
  "Ore di gioco. Le fasi successive arrivano al doppio e al quadruplo.",
  "Godziny w grze. Kolejne etapy przychodzą po dwukrotności i czterokrotności.",
  "Herní hodiny. Další fáze přijdou při dvojnásobku a čtyřnásobku.",
  "Horas de jogo. As fases seguintes chegam no dobro e no quádruplo.",
  "ゲーム内時間。次の段階はこの2倍と4倍で訪れます。",
  "游戏小时。下一阶段在其两倍和四倍时到来。"],
 "Drunk": ["NPCs get drunk", "NPC пьянеют", "NPC п'яніють", "NPCs werden betrunken", "Les PNJ s'enivrent", "Los PNJ se emborrachan", "I PNG si ubriacano", "NPC się upijają", "NPC se opíjejí", "NPCs ficam bêbados", "NPCが酔う", "NPC 会喝醉"],
 "DrunkH": ["Any AI agent who drinks ale, mead, wine and similar (CHIM's Consume action) gets tipsy, then drunk. One drink wears off every 1.5 game hours.",
  "Любой ИИ-агент, который пьёт эль, мёд, вино и подобное (действие Consume в CHIM), сначала навеселе, потом пьян. Одна порция выветривается за 1,5 игровых часа.",
  "Будь-який ШІ-агент, що п'є ель, медовуху, вино тощо (дія Consume у CHIM), спершу напідпитку, потім п'яний. Одна порція вивітрюється за 1,5 ігрової години.",
  "Jeder KI-Agent, der Bier, Met, Wein und Ähnliches trinkt (CHIMs Aktion Consume), wird angeheitert, dann betrunken. Ein Getränk verfliegt alle 1,5 Spielstunden.",
  "Tout agent IA qui boit bière, hydromel, vin ou autre (action Consume de CHIM) devient éméché, puis ivre. Un verre se dissipe toutes les 1,5 heure de jeu.",
  "Cualquier agente de IA que bebe cerveza, hidromiel, vino y similares (acción Consume de CHIM) se achispa y luego se emborracha. Una bebida se pasa cada 1,5 horas de juego.",
  "Qualsiasi agente IA che beve birra, idromele, vino e simili (azione Consume di CHIM) diventa brillo, poi ubriaco. Un drink svanisce ogni 1,5 ore di gioco.",
  "Każdy agent AI, który pije piwo, miód, wino itp. (akcja Consume w CHIM), robi się wstawiony, potem pijany. Jeden napój mija co 1,5 godziny w grze.",
  "Každý AI agent, který pije pivo, medovinu, víno a podobně (akce Consume v CHIM), je nejdřív v náladě, pak opilý. Jeden nápoj vyprchá za 1,5 herní hodiny.",
  "Qualquer agente de IA que beba cerveja, hidromel, vinho e afins (ação Consume do CHIM) fica alegre, depois bêbado. Uma bebida passa a cada 1,5 hora de jogo.",
  "エール、ミード、ワインなどを飲んだAIエージェント（CHIMのConsumeアクション）はほろ酔い、そして泥酔します。1杯はゲーム内1.5時間で抜けます。",
  "任何喝麦酒、蜜酒、葡萄酒等的 AI 角色（CHIM 的 Consume 动作）会先微醺再喝醉。每一杯在游戏中 1.5 小时后消退。"],
 "Arousal": ["Arousal during scenes", "Возбуждение во время сцен", "Збудження під час сцен", "Erregung während Szenen", "Excitation pendant les scènes", "Excitación durante las escenas", "Eccitazione durante le scene", "Podniecenie podczas scen", "Vzrušení během scén", "Excitação durante as cenas", "シーン中の興奮", "场景中的兴奋"],
 "ArousalH": ["Agents in a scene know whether it is building, whether they just came, and how they feel afterwards.",
  "Агенты в сцене знают, нарастает ли возбуждение, кончили ли они только что и как чувствуют себя после.",
  "Агенти в сцені знають, чи наростає збудження, чи вони щойно кінчили і як почуваються після.",
  "Agenten in einer Szene wissen, ob es sich steigert, ob sie gerade gekommen sind und wie sie sich danach fühlen.",
  "Les agents dans une scène savent si ça monte, s'ils viennent de jouir et comment ils se sentent après.",
  "Los agentes en una escena saben si va en aumento, si acaban de llegar al orgasmo y cómo se sienten después.",
  "Gli agenti in una scena sanno se sta crescendo, se sono appena venuti e come si sentono dopo.",
  "Agenci w scenie wiedzą, czy podniecenie rośnie, czy właśnie doszli i jak czują się potem.",
  "Agenti ve scéně vědí, jestli vzrušení roste, jestli se právě udělali a jak se cítí potom.",
  "Agentes numa cena sabem se a excitação está crescendo, se acabaram de gozar e como se sentem depois.",
  "シーン中のエージェントは、興奮が高まっているか、達したばかりか、終わった後の気分を把握します。",
  "场景中的 AI 角色知道兴奋是否在升高、是否刚刚高潮以及之后的感受。"],
 "Jealous": ["Jealous companions", "Ревнивые спутники", "Ревниві супутники", "Eifersüchtige Begleiter", "Compagnons jaloux", "Compañeros celosos", "Compagni gelosi", "Zazdrośni towarzysze", "Žárliví společníci", "Companheiros ciumentos", "嫉妬する仲間", "会吃醋的同伴"],
 "JealousH": ["Comma separated names. When you give one of them much more attention (talk and sex, last 2 game days), the neglected one gets jealous.",
  "Имена через запятую. Когда вы уделяете одному из них намного больше внимания (разговоры и секс за последние 2 игровых дня), обделённый ревнует.",
  "Імена через кому. Коли ви приділяєте одному з них набагато більше уваги (розмови й секс за останні 2 ігрові дні), обділений ревнує.",
  "Namen durch Kommas getrennt. Wenn du einem von ihnen viel mehr Aufmerksamkeit schenkst (Gespräche und Sex, letzte 2 Spieltage), wird der Vernachlässigte eifersüchtig.",
  "Noms séparés par des virgules. Si vous accordez bien plus d'attention à l'un d'eux (discussions et sexe, 2 derniers jours de jeu), le délaissé devient jaloux.",
  "Nombres separados por comas. Si prestas mucha más atención a uno de ellos (charla y sexo, últimos 2 días de juego), el desatendido se pone celoso.",
  "Nomi separati da virgole. Se dai molta più attenzione a uno di loro (dialoghi e sesso, ultimi 2 giorni di gioco), quello trascurato diventa geloso.",
  "Imiona oddzielone przecinkami. Gdy jednemu z nich poświęcasz dużo więcej uwagi (rozmowy i seks, ostatnie 2 dni w grze), pominięty staje się zazdrosny.",
  "Jména oddělená čárkou. Když jednomu z nich věnuješ mnohem víc pozornosti (rozhovory a sex za poslední 2 herní dny), opomíjený začne žárlit.",
  "Nomes separados por vírgula. Quando você dá muito mais atenção a um deles (conversa e sexo, últimos 2 dias de jogo), o esquecido fica com ciúmes.",
  "名前をカンマ区切りで。誰かに他よりずっと多く構うと（直近ゲーム内2日の会話とセックス）、放っておかれた方が嫉妬します。",
  "用逗号分隔的名字。当你对其中一人关注远多于其他人时（最近 2 个游戏日的交谈和性），被冷落的一方会吃醋。"],

 "KeepLang": ["Keep the reply language", "Держать язык ответов", "Тримати мову відповідей", "Antwortsprache beibehalten", "Garder la langue des réponses", "Mantener el idioma de respuesta", "Mantieni la lingua delle risposte", "Trzymaj język odpowiedzi", "Držet jazyk odpovědí", "Manter o idioma das respostas", "返答の言語を固定", "保持回复语言"],
 "KeepLangH": ["NPCs answer in the language set in CHIM, even when you speak another one (voice input in your own language). Without it the model tends to switch to yours, and the voices are made for CHIM's language.",
  "NPC отвечают на языке, заданном в CHIM, даже если вы говорите на другом (голосовой ввод на своём языке). Без этого модель склонна переходить на ваш язык, а голоса сделаны для языка CHIM.",
  "NPC відповідають мовою, заданою в CHIM, навіть коли ви говорите іншою (голосовий ввід своєю мовою). Без цього модель схильна переходити на вашу мову, а голоси зроблені для мови CHIM.",
  "NPCs antworten in der in CHIM eingestellten Sprache, auch wenn Sie eine andere sprechen (Spracheingabe in Ihrer Sprache). Ohne dies wechselt das Modell gern zu Ihrer Sprache, die Stimmen sind aber für die CHIM-Sprache gemacht.",
  "Les PNJ répondent dans la langue réglée dans CHIM, même si vous en parlez une autre (saisie vocale dans votre langue). Sans cela, le modèle a tendance à passer à la vôtre, alors que les voix sont faites pour la langue de CHIM.",
  "Los PNJ responden en el idioma configurado en CHIM aunque usted hable otro (entrada de voz en su idioma). Sin esto el modelo tiende a cambiar al suyo, y las voces están hechas para el idioma de CHIM.",
  "I PNG rispondono nella lingua impostata in CHIM anche se parli un'altra lingua (input vocale nella tua lingua). Senza questo il modello tende a passare alla tua, mentre le voci sono fatte per la lingua di CHIM.",
  "NPC odpowiadają w języku ustawionym w CHIM, nawet gdy mówisz w innym (wejście głosowe w twoim języku). Bez tego model ma skłonność przechodzić na twój język, a głosy są zrobione dla języka CHIM.",
  "NPC odpovídají v jazyce nastaveném v CHIM, i když mluvíte jiným (hlasový vstup ve vašem jazyce). Bez toho model inklinuje k přechodu na váš jazyk, a hlasy jsou udělané pro jazyk CHIM.",
  "Os NPCs respondem no idioma definido no CHIM, mesmo quando você fala outro (entrada de voz no seu idioma). Sem isso o modelo tende a mudar para o seu, e as vozes são feitas para o idioma do CHIM.",
  "あなたが別の言語で話しても（自分の言語での音声入力）、NPCはCHIMで設定された言語で答えます。これがないとモデルはあなたの言語に切り替えがちですが、声はCHIMの言語用に作られています。",
  "即使你说另一种语言（用你自己的语言语音输入），NPC 也用 CHIM 中设置的语言回答。否则模型容易切换到你的语言，而语音是为 CHIM 的语言制作的。"],
 "SpeechOnly": ["Speech only, no self-narration", "Только речь, без описания себя", "Лише мова, без опису себе", "Nur Sprache, keine Selbsterzählung", "Parole seulement, pas d'auto-narration", "Solo habla, sin autonarración", "Solo parlato, niente autonarrazione", "Tylko mowa, bez narracji o sobie", "Jen řeč, žádné vyprávění o sobě", "Só fala, sem autonarração", "台詞のみ（自己描写なし）", "只说台词，不自我叙述"],
 "SpeechOnlyH": ["Some NPC profiles make the model narrate in the third person ('she smiles and steps closer...'), which the voice then reads out. This adds a rule for every NPC: only words spoken out loud. Wishes in the first person stay allowed.",
  "Некоторые профили NPC заставляют модель описывать себя в третьем лице («она улыбается и подходит ближе...»), а голос это зачитывает. Добавляет правило для всех NPC: только сказанные вслух слова. Желания от первого лица остаются разрешены.",
  "Деякі профілі NPC змушують модель описувати себе від третьої особи («вона усміхається й підходить ближче...»), а голос це зачитує. Додає правило для всіх NPC: лише сказані вголос слова. Бажання від першої особи лишаються дозволеними.",
  "Manche NPC-Profile lassen das Modell in der dritten Person erzählen („sie lächelt und kommt näher …“), was die Stimme dann vorliest. Fügt für jeden NPC eine Regel hinzu: nur laut gesprochene Worte. Wünsche in der ersten Person bleiben erlaubt.",
  "Certains profils de PNJ font narrer le modèle à la troisième personne (« elle sourit et s'approche... »), que la voix lit ensuite. Ajoute une règle pour chaque PNJ : seulement les paroles dites à voix haute. Les souhaits à la première personne restent permis.",
  "Algunos perfiles de PNJ hacen que el modelo narre en tercera persona («ella sonríe y se acerca...»), y la voz lo lee. Añade una regla para cada PNJ: solo palabras dichas en voz alta. Los deseos en primera persona siguen permitidos.",
  "Alcuni profili dei PNG fanno narrare il modello in terza persona («lei sorride e si avvicina...»), che la voce poi legge. Aggiunge una regola per ogni PNG: solo parole dette ad alta voce. I desideri in prima persona restano consentiti.",
  "Niektóre profile NPC sprawiają, że model opisuje siebie w trzeciej osobie („uśmiecha się i podchodzi bliżej...”), a głos to odczytuje. Dodaje regułę dla każdego NPC: tylko słowa wypowiedziane na głos. Życzenia w pierwszej osobie są dozwolone.",
  "Některé profily NPC nutí model vyprávět ve třetí osobě („usměje se a přistoupí blíž...“), což pak hlas přečte. Přidá pravidlo pro každé NPC: jen nahlas vyslovená slova. Přání v první osobě zůstávají povolena.",
  "Alguns perfis de NPC fazem o modelo narrar em terceira pessoa (\"ela sorri e se aproxima...\"), que a voz então lê. Adiciona uma regra para cada NPC: só palavras ditas em voz alta. Desejos em primeira pessoa continuam permitidos.",
  "NPCのプロフィールによっては、モデルが三人称で描写し（「彼女は微笑み近づく…」）、それが音声で読まれます。全NPCに「声に出す言葉のみ」のルールを加えます。一人称の願望は許可されます。",
  "有些 NPC 档案会让模型用第三人称叙述（“她微笑着走近……”），语音随后会把它读出来。此项为每个 NPC 添加规则：只说出口的话。第一人称的愿望仍然允许。"],
 "Stale": ["Fix 'nobody talks after a long session'", "Исправить «никто не говорит после долгой сессии»", "Виправити «ніхто не говорить після довгої сесії»", "Korrektur „niemand spricht nach langer Sitzung“", "Correctif « personne ne parle après une longue session »", "Corregir «nadie habla tras una sesión larga»", "Correggi «nessuno parla dopo una lunga sessione»", "Napraw „nikt nie mówi po długiej sesji”", "Opravit „po dlouhé relaci nikdo nemluví“", "Corrigir \"ninguém fala após uma sessão longa\"", "「長時間プレイ後に誰も話さない」を修正", "修复“长时间游戏后无人说话”"],
 "StaleH": ["CHIM stamps player input with a counter that restarts with the game. After a very long session every new request looks older than the last input and CHIM aborts every reply. On game load this resets the stale stamps.",
  "CHIM помечает ввод игрока счётчиком, который начинается заново с перезапуском игры. После очень долгой сессии каждый новый запрос выглядит старше последнего ввода, и CHIM обрывает все ответы. При загрузке игры старые метки сбрасываются.",
  "CHIM позначає ввід гравця лічильником, який починається заново з перезапуском гри. Після дуже довгої сесії кожен новий запит виглядає старшим за останній ввід, і CHIM обриває всі відповіді. При завантаженні гри старі мітки скидаються.",
  "CHIM versieht Spielereingaben mit einem Zähler, der mit dem Spiel neu startet. Nach einer sehr langen Sitzung wirkt jede neue Anfrage älter als die letzte Eingabe und CHIM bricht jede Antwort ab. Beim Laden werden die veralteten Stempel zurückgesetzt.",
  "CHIM marque les saisies du joueur avec un compteur qui repart avec le jeu. Après une très longue session, chaque nouvelle requête paraît plus ancienne que la dernière saisie et CHIM annule chaque réponse. Au chargement, les marques périmées sont réinitialisées.",
  "CHIM marca la entrada del jugador con un contador que se reinicia con el juego. Tras una sesión muy larga, cada nueva petición parece más antigua que la última entrada y CHIM cancela todas las respuestas. Al cargar la partida se reinician las marcas viejas.",
  "CHIM marca l'input del giocatore con un contatore che riparte con il gioco. Dopo una sessione molto lunga ogni nuova richiesta sembra più vecchia dell'ultimo input e CHIM annulla ogni risposta. Al caricamento le marcature vecchie vengono azzerate.",
  "CHIM oznacza wejście gracza licznikiem, który startuje od nowa z grą. Po bardzo długiej sesji każde nowe żądanie wygląda na starsze niż ostatnie wejście i CHIM przerywa każdą odpowiedź. Przy wczytaniu gry stare znaczniki są zerowane.",
  "CHIM označuje vstup hráče počítadlem, které se s hrou spouští znovu. Po velmi dlouhé relaci vypadá každý nový požadavek starší než poslední vstup a CHIM přeruší každou odpověď. Při načtení hry se staré značky vynulují.",
  "O CHIM marca a entrada do jogador com um contador que reinicia com o jogo. Após uma sessão muito longa, cada novo pedido parece mais antigo que a última entrada e o CHIM cancela toda resposta. Ao carregar o jogo, as marcas antigas são zeradas.",
  "CHIMはプレイヤー入力にゲーム再起動でリセットされるカウンターを付けます。非常に長いプレイの後は新しい要求が最後の入力より古く見え、CHIMが全返答を中断します。ロード時に古い印をリセットします。",
  "CHIM 用一个随游戏重启而清零的计数器标记玩家输入。在很长的游戏之后，每个新请求看起来都比上次输入更旧，CHIM 会中止所有回复。读档时会重置这些过期标记。"],
}

# which config.json text each key replaces (English text -> key)
BY_TEXT = {v[0]: k for k, v in T.items()}

cfg_path = os.path.join(ROOT, "mcm", "config.json")
cfg = json.load(open(cfg_path, encoding="utf-8"))

def key_for(text):
    if text.startswith("$"):
        return text
    if text not in BY_TEXT:
        return None
    return "$COB_" + BY_TEXT[text]

# config.json still has English or already $keys; map English back from T when needed
REV = {"$COB_" + k: v[0] for k, v in T.items()}
missing = []
for page in cfg["pages"]:
    k = key_for(REV.get(page["pageDisplayName"], page["pageDisplayName"]))
    if k: page["pageDisplayName"] = k
    else: missing.append(page["pageDisplayName"])
    for e in page["content"]:
        for field in ("text", "help"):
            if field in e:
                src = REV.get(e[field], e[field])
                if src.startswith("CHIM OStim Bridge"):  # title with version and author stays as is
                    continue
                k = key_for(src)
                if k: e[field] = k
                else: missing.append(src)
if missing:
    raise SystemExit("no translation for: " + " | ".join(missing))
json.dump(cfg, open(cfg_path, "w", encoding="utf-8", newline="\n"), indent=4, ensure_ascii=False)

out = os.path.join(ROOT, "mcm", "translations")
os.makedirs(out, exist_ok=True)
for i, lang in enumerate(LANGS):
    lines = []
    for k, vals in T.items():
        text = vals[i].replace("\t", " ").replace("\n", " ")
        lines.append(f"$COB_{k}\t{text}")
    body = "\r\n".join(lines) + "\r\n"
    with open(os.path.join(out, f"CHIMOStimBridge_{lang}.txt"), "wb") as f:
        f.write(b"\xff\xfe" + body.encode("utf-16-le"))
# SkyUI has no fallback language: a game language without its own file shows raw
# $keys. These are language names players set in sLanguage beyond the ones above;
# they get the English text, which is the closest thing to an English fallback.
FALLBACK_TO_ENGLISH = ["TURKISH", "KOREAN", "DUTCH", "HUNGARIAN", "GREEK", "SWEDISH", "DANISH",
                       "NORWEGIAN", "FINNISH", "ROMANIAN", "BULGARIAN", "SERBIAN", "CROATIAN",
                       "SLOVAK", "ARABIC", "HEBREW", "THAI", "VIETNAMESE", "INDONESIAN",
                       "BRAZILIAN", "PTBR", "LATAM", "MEXICAN", "TRADITIONAL_CHINESE", "CHINESE_TRADITIONAL"]
english = open(os.path.join(out, "CHIMOStimBridge_ENGLISH.txt"), "rb").read()
for lang in FALLBACK_TO_ENGLISH:
    with open(os.path.join(out, f"CHIMOStimBridge_{lang}.txt"), "wb") as f:
        f.write(english)
print(f"{len(T)} strings x {len(LANGS)} languages written to {out}, plus {len(FALLBACK_TO_ENGLISH)} English fallbacks")
