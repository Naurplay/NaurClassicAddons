-- Test harness don't bother to load if this isn't a dev version.
if (not string.match(TBag.VERSION,"-Alpha") and
    not string.match(TBag.VERSION,"-Beta")) then
  return
end

local TBag = TBag

-- Localization Support
local L = TBag.LOCALE;

-- Config table we'll use.
local cfg = { }

-- Table of tests to execute.
-- Key is an itemid and the value is the expected category.
-- Multiple possible category matches can be separated with a | (pipe) character.
-- This is needed for some items like items that can be opened, the tooltip
-- string for opening the item only shows if you actually have the item in your
-- inventory.
local tests = {
  [1357] = L["ACT_ON"],
  -- Note we can't test the Right click to open rule because it's
  -- added only for items actually in your inventory.
  [5759] = L["ACT_OPEN"],
  -- Garrison Salvage Yard containers
  [114120] = L["ACT_OPEN"],
  [114119] = L["ACT_OPEN"],
  [114116] = L["ACT_OPEN"],
  -- Items that create equipment
  [104347] = L["ACT_OPEN"],
  [104010] = L["ACT_OPEN"],
  [104345] = L["ACT_OPEN"],
  [102318] = L["ACT_OPEN"],
  [102284] = L["ACT_OPEN"],
  [102264] = L["ACT_OPEN"],
  [103982] = L["ACT_OPEN"],
  [114068] = L["ACT_OPEN"],
  [114066] = L["ACT_OPEN"],
  [114112] = L["ACT_OPEN"],
  [114083] = L["ACT_OPEN"],
  [114069] = L["ACT_OPEN"],
  [114099] = L["ACT_OPEN"],
  [114096] = L["ACT_OPEN"],
  [114053] = L["ACT_OPEN"],
  [114052] = L["ACT_OPEN"],
  [114111] = L["ACT_OPEN"],

  -- PVP Items
  [24579] = L["PVP"],
  [26045] = L["PVP"],
  [28558] = L["PVP"],
  [24581] = L["PVP"],

  -- Enchants
  [11643] = L["ENCHANTS"],
  [24276] = L["ENCHANTS"],
  [18170] = L["ENCHANTS"],
  [19789] = L["ENCHANTS"],
  [29533] = L["ENCHANTS"],
  [38896] = L["ENCHANTS"],

  -- Glyphs
  [43673] = L["GRAY_ITEMS"],
  [40912] = L["GRAY_ITEMS"],

  -- Hearthstones
  [6948] = L["HEARTH"],
  [19254] = L["MISC"], -- Has Hearthstone in the tooltip, but isn't one.
  -- Blizzard has a game called Hearthstone so now of course a bunch of
  -- references to it are now in WoW leading to items that arent' hearthstones
  -- in the name/tooltip.
  [110560] = L["HEARTH"],
  [118475] = L["CONSUMABLE"],
  [119210] = L["TOYS"],
  [119212] = L["TOYS"],
  [140192] = L["HEARTH"],

  -- Class Reagents
  [64670] = L["CLASS_REAGENT"],
  [63388] = L["GRAY_ITEMS"],
  [79249] = L["GRAY_ITEMS"],

  -- Followers
  -- Actual items that teach followers
  [114825] = L["FOLLOWERS"],
  [119248] = L["FOLLOWERS"],
  [114826] = L["FOLLOWERS"],
  -- Things that look like followers but aren't
  [92427] = L["CONSUMABLE"],
  [92051] = L["CONSUMABLE"],
  [92436] = L["CONSUMABLE"],
  [18628] = L["ACT_ON"],
  [3668]  = L["QUEST"],
  -- Follower weapons
  [120302] = L["FOLLOWERS"],
  [114128] = L["FOLLOWERS"],
  [114129] = L["FOLLOWERS"],
  [114131] = L["FOLLOWERS"],
  [114616] = L["FOLLOWERS"],
  [114081] = L["FOLLOWERS"],
  [114131] = L["FOLLOWERS"],
  [120313] = L["FOLLOWERS"],
  -- Follower Armor
  [120301] = L["FOLLOWERS"],
  [114745] = L["FOLLOWERS"],
  [114808] = L["FOLLOWERS"],
  [114822] = L["FOLLOWERS"],
  [114807] = L["FOLLOWERS"],
  [114806] = L["FOLLOWERS"],
  [114746] = L["FOLLOWERS"],
  -- Follower Ability/Trait items
  [118354] = L["FOLLOWERS"],
  [118475] = L["FOLLOWERS"],
  [118474] = L["FOLLOWERS"],
  [127882] = L["FOLLOWERS"],
  [140582] = L["FOLLOWERS"],

  -- Minipets
  [4401] = L["MINIPET"],
  [8492] = L["MINIPET"],
  [23083] = L["MINIPET"],
  [35223] = L["MINIPET"],
  [22200] = L["MINIPET"],
  [37431] = L["COMBATPETS"],
  [37460] = L["TOYS"],
  [43626] = L["MINIPET"],
  [44721] = L["MINIPET"],
  [44820] = L["TOYS"],
  [39898] = L["MINIPET"],
  [39899] = L["MINIPET"],
  [39896] = L["MINIPET"],
  [39286] = L["MINIPET"],
  [41133] = L["MINIPET"],
  [44738] = L["MINIPET"],
  [44723] = L["MINIPET"],
  [22235] = L["MINIPET"],
  [116429] = L["MINIPET"],
  [98715]  = L["MINIPET"],
  [86143]  = L["MINIPET"],
  [98112]  = L["MINIPET"],
  [98114]  = L["MINIPET"],
  [89906]  = L["MINIPET"],
  [71153]  = L["MINIPET"],
  [103786] = L["MINIPET"],
  [103795] = L["MINIPET"],
  [103789] = L["MINIPET"],
  [103797] = L["MINIPET"],
  [118054] = L["MINIPET"],

  -- Combat Pets
  [31666] = L["COMBATPETS"],
  [22728] = L["COMBATPETS"],
  [22729] = L["SCHEMATIC"], -- Patern for the Steam Tonk Controller
  [15778] = L["COMBATPETS"],
  [21277] = L["MINIPET"], -- Similar name but should be a MINIPET.
  [12928] = L["QUEST"], -- Similar name but should be a QUEST item.
  [3456] = L["COMBATPETS"],
  [23379] = L["COMBATPETS"],
  [13508] = L["COMBATPETS"],
  [21325] = L["COMBATPETS"],
  [15778] = L["COMBATPETS"],
  [1187] = L["COMBATPETS"],
  [4391] = L["COMBATPETS"],
  [4395] = L["COMBATPETS"],
  [10725] = L["COMBATPETS"],
  [17067] = L["13_OFFHAND"],
  [13353] = L["13_OFFHAND"],

  -- Costumes
  [31337] = L["COSTUMES"],
  [20410] = L["COSTUMES"],
  [20409] = L["COSTUMES"],
  [20399] = L["COSTUMES"],
  [20398] = L["COSTUMES"],
  [20397] = L["COSTUMES"],
  [20413] = L["COSTUMES"],
  [20411] = L["COSTUMES"],
  [20414] = L["COSTUMES"],
  [34068] = L["COSTUMES"],
  [18258] = L["COSTUMES"],
  [37816] = L["COSTUMES"],
  [21213] = L["COSTUMES"],
  [44792] = L["COSTUMES"],
  [116856] = L["TOYS"],
  [116888] = L["TOYS"],
  [116891] = L["TOYS"],
  [116889] = L["TOYS"],
  [116890] = L["TOYS"],

  -- Fireworks
  [21570] = L["FIREWORKS"],
  [21569] = L["FIREWORKS"],
  [21571] = L["FIREWORKS"],
  [21574] = L["FIREWORKS"],
  [21716] = L["FIREWORKS"],
  [21718] = L["FIREWORKS"],
  [21744] = L["FIREWORKS"],
  [21576] = L["FIREWORKS"],
  [21562] = L["FIREWORKS"],
  [21561] = L["FIREWORKS"],
  [21557] = L["FIREWORKS"],
  [21559] = L["FIREWORKS"],
  [21558] = L["FIREWORKS"],
  [21558] = L["FIREWORKS"],
  [21589] = L["FIREWORKS"],
  [21590] = L["FIREWORKS"],
  [21592] = L["FIREWORKS"],
  [9312] = L["FIREWORKS"],
  [21713] = L["FIREWORKS"],
  [9313] = L["FIREWORKS"],
  [34258] = L["FIREWORKS"],
  [9318] = L["FIREWORKS"],
  [9314] = L["FIREWORKS"],
  [9317] = L["FIREWORKS"],
  [19026] = L["FIREWORKS"],
  [9315] = L["FIREWORKS"],
  [23714] = L["FIREWORKS"], -- it's actually the old trinket that converts to the new non-trinket (that's now under TOYS)
  [21747] = L["FIREWORKS"],

  -- Toys, various non-equipable items that have no real purpose
  [34686] = L["TOYS"],
  [37863] = L["TOYS"],
  [35227] = L["TOYS"],
  [32566] = L["TOYS"],
  [34480] = L["TOYS"],
  [19035] = L["MISC"].."|"..L["ACT_OPEN"], -- Similar name, ACT_OPEN or MISC
  [38301] = L["TOYS"],
  [32542] = L["TOYS"],
  [35557] = L["TOYS"],
  [17202] = L["TOYS"],
  [33081] = L["TOYS"],
  [18662] = L["TOYS"],
  [18640] = L["TOYS"],
  [38308] = L["TOYS"],
  [38308] = L["TOYS"],
  [34497] = L["TOYS"],
  [38266] = L["TOYS"],
  [34494] = L["TOYS"],
  [33223] = L["TOYS"],
  [34499] = L["TOYS"],
  [21540] = L["TOYS"],
  [21536] = L["TOYS"],
  [22218] = L["TOYS"],
  [34191] = L["TOYS"],
  [34684] = L["TOYS"],
  [54437] = L["TOYS"],
  [22206] = L["13_OFFHAND"], -- Similar effect but equipable.
  [38233] = L["TOYS"],
  [34498] = L["TOYS"],
  [44430] = L["TOYS"],
  [44606] = L["TOYS"],
  [45057] = L["TOYS"],
  [44482] = L["TOYS"],
  [44599] = L["TOYS"],
  [44601] = L["TOYS"],
  [44481] = L["TOYS"],
  [21328] = L["TOYS"],
  [36863] = L["TOYS"],
  [36862] = L["TOYS"],
  [21745] = L["TOYS"],
  [45063] = L["TOYS"],
  [45047] = L["TOYS"],
  [92970] = L["TOYS"],
  [77158] = L["TOYS"],
  [92956] = L["TOYS"],
  [92968] = L["TOYS"],
  [92958] = L["TOYS"],
  [92969] = L["TOYS"],
  [92959] = L["TOYS"],
  [92966] = L["TOYS"],
  [92967] = L["TOYS"],
  [45984] = L["TOYS"],
  [46779] = L["TOYS"],
  [46780] = L["TOYS"],
  [38578] = L["TOYS"],
  [46709] = L["TOYS"],
  [17712] = L["TOYS"],
  [33219] = L["TOYS"],
  [33927] = L["TOYS"],
  [35275] = L["TOYS"],
  [43499] = L["TOYS"],
  [49703] = L["TOYS"],
  [49704] = L["TOYS"],
  [44719] = L["TOYS"],
  [23767] = L["TOYS"],
  [33079] = L["TOYS"],
  [119092] = L["TOYS"],

  -- Mounts
  [33977] = L["MOUNT"],
  [32861] = L["MOUNT"],
  [49288] = L["MOUNT"],
  [49289] = L["MOUNT"],
  [104287] = L["MOUNT"],
  [113543] = L["TOYS"],
  [119093] = L["TOYS"],

  -- AQ
  [20864] = L["AHN_QIRAJ"],
  [21685] = L["TRINKET"], -- similar name shouldn't match the rule though
  [19431] = L["TRINKET"], -- similar name shouldn't match the rule though
  [20873] = L["AHN_QIRAJ"],
  [29390] = L["GRAY_ITEMS"], -- Druid idols shouldn't match
  [20888] = L["AHN_QIRAJ"],
  [20884] = L["AHN_QIRAJ"],
  [20885] = L["AHN_QIRAJ"],
  [20889] = L["AHN_QIRAJ"],

  -- Darkmoon Faire
  [71083] = L["DARKMOON_FAIRE"],
  [81055] = L["DARKMOON_FAIRE"],
  [71634] = L["DARKMOON_FAIRE"],
  -- The decks actually end up in ACT_ON
  [19257] = L["ACT_ON"],
  [19258] = L["DARKMOON_FAIRE"],
  [19267] = L["ACT_ON"],
  [19268] = L["DARKMOON_FAIRE"],
  [19277] = L["ACT_ON"],
  [19276] = L["DARKMOON_FAIRE"],
  [19228] = L["ACT_ON"],
  [19227] = L["DARKMOON_FAIRE"],
  [31890] = L["ACT_ON"],
  [31882] = L["DARKMOON_FAIRE"],
  [31907] = L["ACT_ON"],
  [31901] = L["DARKMOON_FAIRE"],
  [31914] = L["ACT_ON"],
  [31910] = L["DARKMOON_FAIRE"],
  [31891] = L["ACT_ON"],
  [31892] = L["DARKMOON_FAIRE"],
  [44276] = L["ACT_ON"],
  [44284] = L["DARKMOON_FAIRE"],
  [44326] = L["ACT_ON"],
  [44274] = L["DARKMOON_FAIRE"],
  [44259] = L["ACT_ON"],
  [44266] = L["DARKMOON_FAIRE"],
  [44294] = L["ACT_ON"],
  [44292] = L["DARKMOON_FAIRE"],
  [21136] = L["QUEST"], -- Tooltip text has of Storms so it matched old Darkmoon Faire rules

  -- Timbermaw
  [21377] = L["TIMBERMAW"],
  [21383] = L["TIMBERMAW"],

  -- Ogri'la
  [32572] = L["OGRI'LA"],
  [32684] = L["OGRI'LA"],
  [32683] = L["OGRI'LA"],
  [32682] = L["OGRI'LA"],
  [32681] = L["OGRI'LA"],
  [32643] = L["OGRI'LA"],
  [33784] = L["OGRI'LA"],
  [33784] = L["OGRI'LA"],
  [32602] = L["OGRI'LA"],

  -- Netherwing
  [32506] = L["NETHERWING"],
  [32464] = L["NETHERWING"],
  [32468] = L["NETHERWING"],
  [32468] = L["NETHERWING"],
  [32427] = L["NETHERWING"],
  [32723] = L["NETHERWING"],

  -- Cenarion Expedition
  [24401] = L["CENARION_EXPEDITION"],

  -- Sporeggar
  [24290] = L["SPOREGGAR"],
  [24291] = L["SPOREGGAR"],
  [24291] = L["SPOREGGAR"],
  [24245] = L["SPOREGGAR"],
  [24449] = L["SPOREGGAR"],
  [24449] = L["SPOREGGAR"],
  [24246] = L["SPOREGGAR"],

  -- Consortium
  [25433] = L["CONSORTIUM"],
  [25416] = L["CONSORTIUM"],
  [25463] = L["CONSORTIUM"],
  [29209] = L["CONSORTIUM"],
  [31957] = L["CONSORTIUM"],
  [29460] = L["CONSORTIUM"],

  -- Halaa
  [26044] = L["HALAA"],
  [26042] = L["HALAA"],
  [26043] = L["HALAA"],

  -- Scryer
  [25744] = L["SCRYER"],
  [29426] = L["SCRYER"],
  [30810] = L["SCRYER"],
  [29739] = L["SCRYER"],
  [29736] = L["SCRYER"],

  -- Aldor
  [25802] = L["ALDOR"],
  [29425] = L["ALDOR"],
  [30809] = L["ALDOR"],
  [29740] = L["ALDOR"],
  [29735] = L["ALDOR"],
  [32897] = L["ALDOR"],

  -- Lower City
  [25719] = L["LOWER_CITY"],

  -- Artifact
  [143701] = L["ARTIFACTRELIC"],
  [140176] = L["ARTIFACTPOWER"],

  -- Trinket
  [28830] = L["TRINKET"],

  -- Quest
  [11018] = L["QUEST"],
  [7297] = L["QUEST"],
  [32649] = L["QUEST"],
  [32757] = L["02_NECK"],

  -- Gray items
  [3300] = L["GRAY_ITEMS"],

  -- Containers
  [21876] = L["BAG"],
  [29143] = L["BAG"],
  [34106] = L["BAG"],

  -- Books
  [21993] = L["BOOK"],
  [16072] = L["BOOK"],
  [21953] = L["DESIGN"],
  [33151] = L["FORMULA"],
  [22919] = L["RECIPE"],
  [25731] = L["PATTERN"],
  [12827] = L["PLANS"],
  [23887] = L["SCHEMATIC"],
  [118215] = L["BLUEPRINTS"],
  [111812] = L["BLUEPRINTS"],
  [109256] = L["BLUEPRINTS"],
  [111996] = L["BLUEPRINTS"],
  [111957] = L["BLUEPRINTS"],
  [112020] = L["QUEST"], -- quest item named Garrison Blueprints but it isn't
  [111619] = L["QUEST"], -- ditto

  -- Trade Tools
  [7005] = L["TRADE_TOOL"],
  [19901] = L["TRADE_TOOL"],
  [2901] = L["TRADE_TOOL"],
  [778] = L["TRADE_TOOL"],
  [5956] = L["TRADE_TOOL"],
  [22462] = L["TRADE_TOOL"],
  [9149] = L["TRADE_TOOL"],
  [6219] = L["TRADE_TOOL"],
  [10498] = L["TRADE_TOOL"],
  [12709] = L["TRADE_TOOL"],
  [19727] = L["TRADE_TOOL"],
  [7349] = L["TRADE_TOOL"],
  [39505] = L["TRADE_TOOL"],
  [40772] = L["TRADE_TOOL"],
  [60223] = L["TRADE_TOOL"],
  [3567] = L["WEAPON"], -- Avoid matching fishing pole
  [4598] = L["EXPLOSIVES"], -- ditto
  [19970] = L["FISHING"],
  [110293] = L["FISHING"],
  [110274] = L["FISHING"],
  [110289] = L["FISHING"],
  [110291] = L["FISHING"],
  [110292] = L["FISHING"],
  [110290] = L["FISHING"],
  [110294] = L["FISHING"],
  [85500]  = L["TOYS"],

  -- Inscription
  [43125] = L["INSCRIPTION"],
  [43117] = L["INSCRIPTION"],
  [43121] = L["INSCRIPTION"],
  [43115] = L["INSCRIPTION"],
  [43123] = L["INSCRIPTION"],
  [43123] = L["INSCRIPTION"],
  [31519] = L["11_LEGS"], -- Has ink in the name but not inscription item
  [43119] = L["INSCRIPTION"],
  [43127] = L["INSCRIPTION"],
  [10647] = L["ENGINEERING"], -- Engineer's Ink
  [43124] = L["INSCRIPTION"],
  [43126] = L["INSCRIPTION"],
  [43118] = L["INSCRIPTION"],
  [43116] = L["INSCRIPTION"],
  [39774] = L["INSCRIPTION"],
  [39469] = L["INSCRIPTION"],
  [43122] = L["INSCRIPTION"],
  [6929] = L["QUEST"], -- Bath'rah's Parchment
  [11105] = L["QUEST"], -- Curled Map Parchment
  [9553] = L["QUEST"], -- Etched Parchment
  [9323] = L["QUEST"], -- Gadrin's Parchment
  [39354] = L["INSCRIPTION"],
  [12635] = L["QUEST"], -- Simple Parchment
  [5348] = L["QUEST"], -- Worn Parchment
  [3767] = L["GRAY_ITEMS"], -- Fine Parchment
  [40737] = L["08_WRIST"], -- Pigmented Clan Bindings
  [44061] = L["05_CHEST"], -- Pigmented Clan Bindings
  [43104] = L["INSCRIPTION"],
  [43108] = L["INSCRIPTION"],
  [43109] = L["INSCRIPTION"],
  [43105] = L["INSCRIPTION"],
  [43106] = L["INSCRIPTION"],
  [43106] = L["INSCRIPTION"],
  [43107] = L["INSCRIPTION"],
  [43103] = L["INSCRIPTION"],
  [39151] = L["INSCRIPTION"],
  [39343] = L["INSCRIPTION"],
  [39334] = L["INSCRIPTION"],
  [39339] = L["INSCRIPTION"],
  [39338] = L["INSCRIPTION"],
  [39342] = L["INSCRIPTION"],
  [39341] = L["INSCRIPTION"],
  [39340] = L["INSCRIPTION"],

  -- Various equipment items
  [28757] = L["RING"],
  [33972] = L["01_HEAD"],
  [31749] = L["02_NECK"],
  [19689] = L["03_SHOULDER"],
  [29375] = L["04_BACK"],
  [4333] = L["06_SHIRT"],
  [6125] = L["06_SHIRT"],
  [31780] = L["07_TABARD"],
  [33580] = L["08_WRIST"],
  [34904] = L["09_HANDS"],
  [30042] = L["10_WAIST"],
  [28591] = L["11_LEGS"],
  [29265] = L["12_FEET"],
  [28728] = L["13_OFFHAND"],
  [18608] = L["WEAPON"],

  -- Restores
  [21991] = L["BANDAGE"],
  [5509] = L["HEALTHSTONE"]..'|'..L["CONSUMABLE"], -- If you don't have it doesn't include all the text
  [32578] = L["HEALTHSTONE"],
  [27666] = L["FOOD_BUFF"],
  [13810] = L["FOOD_BUFF"],
  [43015] = L["FOOD_BUFF"],
  [43478] = L["FOOD_BUFF"],
  [34753] = L["FOOD_BUFF"],
  [43480] = L["FOOD_BUFF"],
  [21254] = L["FOOD_BUFF"],
  [22018] = L["DRINK"],
  [19301] = L["COMBO"],
  [34062] = L["COMBO"],
  [2682] = L["COMBO"],
  [13724] = L["COMBO"],
  [32722] = L["COMBO"],
  [20031] = L["COMBO"],
  [20031] = L["COMBO"],
  [21215] = L["COMBO"], -- fruitcake 2nd pattern is for this.
  [33053] = L["COMBO"],
  [34780] = L["COMBO"],
  [3448] = L["COMBO"],
  [28112] = L["COMBO"],
  [21153] = L["COMBO"],
  [20388] = L["COMBO"],
  [20389] = L["COMBO"],
  [20390] = L["COMBO"],
  [21537] = L["COMBO"],
  [20516] = L["COMBO"],
  [113509] = L["COMBO"],
  [118935] = L["TOYS"],
  [13893] = L["FOOD"],
  [35285] = L["FOOD"],
  [28111] = L["FOOD"],
  [7676] = L["ENERGY_RESTORE"],
  [27553] = L["ENERGY_RESTORE"],
  [5631] = L["RAGE_RESTORE"],
  [22850] = L["COMBO_RESTORE"],
  [22836] = L["COMBO_RESTORE"],
  [34440] = L["COMBO_RESTORE"],
  [20002] = L["COMBO_RESTORE"],
  [12190] = L["COMBO_RESTORE"],
  [57099] = L["COMBO_RESTORE"],
  [9144] = L["COMBO_RESTORE"],
  [22832] = L["MANA_RESTORE"],
  [32902] = L["MANA_RESTORE"],
  [118262] = L["MANA_RESTORE"],
  [109221] = L["MANA_RESTORE"],
  [118278] = L["MANA_RESTORE"],
  [57194] = L["MANA_RESTORE"],
  [22829] = L["HEALTH_RESTORE"],
  [32905] = L["HEALTH_RESTORE"],
  [25883] = L["HEALTH_RESTORE"],
  [109223] = L["HEALTH_RESTORE"],
  [117415] = L["HEALTH_RESTORE"],

  -- Combat Buffs
  [6452] = L["CURE"],
  [12586] = L["CURE"],
  [31437] = L["CURE"],
  [5951] = L["CURE"],
  [9030] = L["CURE"],
  [25550] = L["CURE"],
  [17744] = L["TRINKET"], -- Might match deDE pattern for removing poisons
  [10455] = L["TRINKET"], -- ditto
  [4444] = L["ARMOR"], -- ditto
  [5613] = L["WEAPON"], -- ditto
  [4398] = L["EXPLOSIVES"],
  [4378] = L["EXPLOSIVES"],
  [24538] = L["EXPLOSIVES"],
  [27498] = L["BUFF"],
  [29529] = L["BUFF"],
  [22797] = L["BUFF"],
  [22795] = L["BUFF"],
  [22840] = L["BUFF"],
  [20007] = L["BUFF"],
  [20004] = L["BUFF"],
  [3826] = L["BUFF"],
  [3388] = L["BUFF"],
  [3382] = L["BUFF"],
  [34539] = L["BUFF"],
  [20748] = L["BUFF"],
  [20749] = L["BUFF"],
  [23529] = L["BUFF"],
  [28421] = L["BUFF"],
  [21519] = L["BUFF"],
  [21267] = L["BUFF"],
  [22788] = L["BUFF"],
  [24421] = L["BUFF"],
  [3823] = L["BUFF"],
  [9172] = L["BUFF"],
  [32079] = L["KEY_QUEST"],

  -- Reagents
  -- most of these used to be reagents for class spells that
  -- have been made obsolete and converted to gray items.
  [17056] = L["LEATHERWORKING"],
  [5565] = L["GRAY_ITEMS"],
  [22147] = L["GRAY_ITEMS"],
  [17037] = L["GRAY_ITEMS"],
  [44614] = L["GRAY_ITEMS"],
  [17020] = L["GRAY_ITEMS"],
  [17031] = L["GRAY_ITEMS"],
  [17032] = L["GRAY_ITEMS"],
  [17029] = L["GRAY_ITEMS"],
  [44615] = L["GRAY_ITEMS"],
  [17030] = L["GRAY_ITEMS"],
  [17058] = L["GRAY_ITEMS"],
  [17057] = L["GRAY_ITEMS"],
  [37201] = L["GRAY_ITEMS"],
  [5060] = L["MISC"],
  [5178] = L["MISC"],
  [5175] = L["MISC"],
  [5176] = L["MISC"],
  [5177] = L["MISC"],
  [6265] = L["MISC"],
  [4392] = L["DUMMY"],

  [7068] = L["REAGENT"],
  [7082] = L["REAGENT"],
  [7079] = L["REAGENT"],
  [7081] = L["REAGENT"],
  [7077] = L["REAGENT"],
  [7075] = L["REAGENT"],
  [22572] = L["REAGENT"],
  [23572] = L["REAGENT"],
  [21886] = L["REAGENT"],
  [22450] = L["REAGENT"],
  [30183] = L["REAGENT"],
  [32428] = L["REAGENT"],
  [34664] = L["REAGENT"],
  [43102] = L["REAGENT"],
  [37700] = L["REAGENT"],
  [37701] = L["REAGENT"],
  [37702] = L["REAGENT"],
  [37703] = L["REAGENT"],
  [37704] = L["REAGENT"],
  [37705] = L["REAGENT"],
  [35622] = L["REAGENT"],
  [35623] = L["REAGENT"],
  [35624] = L["REAGENT"],
  [35625] = L["REAGENT"],
  [35627] = L["REAGENT"],
  [36860] = L["REAGENT"],
  [45087] = L["REAGENT"],
  [47556] = L["REAGENT"],
  [49908] = L["REAGENT"],

  -- Trades
  [3371] = L["ALCHEMY"],
  [4305] = L["CLOTH"],
  [21877] = L["CLOTH"],
  [3173] = L["COOKING"],
  [11083] = L["ENCHANTING"],
  [10998] = L["ENCHANTING"],
  [11082] = L["ENCHANTING"],
  [14343] = L["ENCHANTING"],
  [14343] = L["ENCHANTING"],
  [14344] = L["ENCHANTING"],
  [22445] = L["ENCHANTING"],
  [22449] = L["ENCHANTING"],
  [22202] = L["BLACKSMITHING"], -- Similar to enchanting but shouldn't match
  [22203] = L["BLACKSMITHING"], -- ditto
  [18986] = L["TOYS"],
  [30544] = L["TOYS"],
  [18984] = L["TOYS"],
  [30542] = L["TOYS"],
  [48933] = L["TOYS"],
  [47828] = L["ENGINEERING"],
  [112059] = L["TOYS"],
  [63128]  = L["ARCHAEOLOGY"],
  [64397]  = L["ARCHAEOLOGY"],
  [63127]  = L["ARCHAEOLOGY"],
  [109585] = L["ARCHAEOLOGY"],
  [52843]  = L["ARCHAEOLOGY"],
  [79869]  = L["ARCHAEOLOGY"],
  [64395]  = L["ARCHAEOLOGY"],
  [64394]  = L["ARCHAEOLOGY"],
  [79868]  = L["ARCHAEOLOGY"],
  [109584] = L["ARCHAEOLOGY"],
  [95373]  = L["ARCHAEOLOGY"],
  [87539]  = L["ARCHAEOLOGY"],
  [87533]  = L["ARCHAEOLOGY"],
  [87535]  = L["ARCHAEOLOGY"],
  [87540]  = L["ARCHAEOLOGY"],
  [87534]  = L["ARCHAEOLOGY"],
  [117386] = L["ARCHAEOLOGY"],
  [117388] = L["ARCHAEOLOGY"],
  [117387] = L["ARCHAEOLOGY"],
  [87538]  = L["ARCHAEOLOGY"],
  [87536]  = L["ARCHAEOLOGY"],
  [87537]  = L["ARCHAEOLOGY"],
  [87541]  = L["ARCHAEOLOGY"],
  [87548]  = L["ARCHAEOLOGY"],
  [87549]  = L["ARCHAEOLOGY"],
  [104198] = L["ARCHAEOLOGY"],
  [117390] = L["ARCHAEOLOGY"],
  [87399]  = L["ARCHAEOLOGY"],
  [117389] = L["ARCHAEOLOGY"],
  [95509]  = L["ARCHAEOLOGY"],

  -- Rogue Poisons
  -- obsolete rogue poisons that are now all GRAY_ITEMS
  [3775]  = L["GRAY_ITEMS"],
  [2892]  = L["GRAY_ITEMS"],
  [2893]  = L["GRAY_ITEMS"],
  [8984]  = L["GRAY_ITEMS"],
  [8985]  = L["GRAY_ITEMS"],
  [43233] = L["GRAY_ITEMS"],
  [20844] = L["GRAY_ITEMS"],
  [22054] = L["GRAY_ITEMS"],
  [6947]  = L["GRAY_ITEMS"],
  [6949]  = L["GRAY_ITEMS"],
  [6950]  = L["GRAY_ITEMS"],
  [8926]  = L["GRAY_ITEMS"],
  [43231] = L["GRAY_ITEMS"],
  [8927]  = L["GRAY_ITEMS"],
  [8928]  = L["GRAY_ITEMS"],
  [21927] = L["GRAY_ITEMS"],
  [5237]  = L["GRAY_ITEMS"],
  [10918] = L["GRAY_ITEMS"],
  [10920] = L["GRAY_ITEMS"],
  [10921] = L["GRAY_ITEMS"],
  [10922] = L["GRAY_ITEMS"],
  [22055] = L["GRAY_ITEMS"],
  [43235] = L["GRAY_ITEMS"],
}

-- Known items not working on any realm
-- Found from wowhead but apparently not seen on any of the realms
tests[38266] = nil

local function build_itm(id,itm)
  itm[TBag.I_ITEMLINK] = "item:"..id..":0:0:0:0:0:0:0";
  itm[TBag.I_BAG] = 1;
  itm[TBag.I_SLOT] = 1;
  itm[TBag.I_NAME], itm[TBag.I_TYPE], itm[TBag.I_SUBTYPE], itm[TBag.I_RARITY]
    = TBag:GetItemInfo(itm[TBag.I_ITEMLINK]);
end

-- Executes a single test
--   inputs: itemid and the expected category
--   output: result (boolean), itm (table produced)
local function test(id,cat)
  local itm = { };
  local result = false

  build_itm(id,itm);
  TBag:PickBar(cfg, "TBAGTEST|TBAGTEST", itm, "", "");
  for c in cat:gmatch("[^|]+") do
    if c == itm[TBag.I_CAT] then
      result = true
    end
  end
  return result, itm;
end

function TBag:GetCategory(id)
 self:InitDefVals(cfg, self.Inv_Bags, 0, 1)

 local _, itm = test(id,"TEST")
 local link = self:MakeHyperlink(itm[self.I_ITEMLINK],itm[self.I_NAME],
                                 itm[self.I_RARITY],80);
 link = tostring(link);
 TBag:Print(string.format("%s (%s) = %s",link,tostring(id),tostring(itm[self.I_CAT])))
end

function TBag:RunTests(verbose)
  local fail = false;
  -- Initialize the cfg with default values
  self:InitDefVals(cfg, self.Inv_Bags, 0, 1);

  self:Print(L["TEST RUN STARTING"]);

  for id,cat in pairs(tests) do
    local result, itm = test(id,cat)
    local link = self:MakeHyperlink(itm[self.I_ITEMLINK],itm[self.I_NAME],
                                    itm[self.I_RARITY],80);
    link = tostring(link);

    if (result == true) then
      if (verbose) then
        local output = string.format(L["SUCCESS: %s"], link);
        self:Print(output,0,1,0);
      end
    else
      fail = true;
      local output = string.format(L["FAIL: %s (%s) expected %q but got %q"], link,
                                   tostring(id),tostring(cat),tostring(itm[self.I_CAT]));
      self:Print(output,1,0,0);
    end
  end

  if (fail == false) then
    self:Print(L["ALL TESTS SUCCESSFUL"]);
  end
end
