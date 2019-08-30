-- Localization Support
local L = TBag.LOCALE;

TBag.S_RARITY  = "R_";

TBag.DefaultItemOverrides = {
};

-- Category, Keywords, Tooltip Search, ItemType, ItemSubType, EquipLoc
TBag.DefaultSearchList = {
  { "GRAY_ITEMS", TBag.S_RARITY.."0",  "", "", "", "" },

-- Universal settings for English and localized categories
  { "TOYS", "", "Use: Adds this toy to your Toy Box", "", "", "" },
  { "ARCHAEOLOGY", "", "[Aa]rchaeology", "7", "", "" },
  { "ARCHAEOLOGY", "", "[Aa]rchaeology", "15", "", "" },
  { "ARCHAEOLOGY", "", "digsite", "7", "", "" },
  { "ACT_OPEN", "", " Lockbox", "15", "", "" },
  { "HEARTH", "", "Hearthstone%s", "15", "", "" },
  { "COMBATPETS", "", "Use:.*pet", "0", "", ""},
  { "FOLLOWERS", "", "Use: Equip.*Champion", "0", "", ""},
  { "FOLLOWERS_LVL", "", "Use: Increases.*Champion", "0", "", ""},

  { "ACT_ON", "", "This Item Begins a Quest", "", "", "" },
  { "ACT_OPEN", "", "<Right Click to Open>", "", "", "" },

-- Localized categories
  { "TOYS", "", L["Use: Adds this toy to your Toy Box"], "", "", "" },
  { "ARCHAEOLOGY", "", L["[Aa]rchaeology"], "7", "", "" },
  { "ARCHAEOLOGY", "", L["[Aa]rchaeology"], "15", "", "" },
  { "ARCHAEOLOGY", "", L["digsite"], "7", "", "" },
  { "ACT_OPEN", "", L[" Lockbox"], "15", "", "" },
  { "HEARTH", "", L["Hearthstone%s"], "15", "", "" },
  { "COMBATPETS", "", L["Use:.*pet"], "0", "", ""},
  { "FOLLOWERS", "", L["Use: Equip.*Champion"], "0", "", ""},
  { "FOLLOWERS_LVL", "", L["Use: Increases.*Champion"], "0", "", ""},

  { "ACT_ON", "", L["This Item Begins a Quest"], "", "", "" },
  { "ACT_OPEN", "", L["<Right Click to Open>"], "", "", "" },

  { "CONSUMABLE", "", "", "0", "0", "" },
  { "POTION", "", "", "0", "1", "" },
  { "ELIXIR", "", "", "0", "2", "" },
  { "FLASK", "", "", "0", "3", "" },
  { "FOOD", "", "", "0", "5", "" },
  { "BANDAGE", "", "", "0", "7", "" },
  { "VANTUS_RUNES", "", "", "0", "9", "" },
  { "CONSUMABLE", "", "", "0", "", "" },

  { "BAG", "", "", "1", "", "" },

  { "FISHING", "", "", "2", "20", ""},

  { "ARTIFACTRELIC", "", "", "3", "11", ""},
  { "GEM", "", "", "3", "", ""},

  { "COSTUMES", "", "", "4", "5", "" },

  { "REAGENT", "", "", "5", "", ""},

  { "AMMO", "", "", "6", "", "" },

  { "ENGINEERING", "", "", "7", "1", "" },
  { "EXPLOSIVES", "", "", "7", "2", "" },
  { "MINIPET", "", "", "7", "3", ""},
  { "JEWELCRAFTING", "", "", "7", "4", "" },
  { "TAILORING", "", "", "7", "5", "" },
  { "LEATHERWORKING", "", "", "7", "6", "" },
  { "BLACKSMITHING", "", "", "7", "7", "" },
  { "COOKING", "", "", "7", "8", "" },
  { "ALCHEMY", "", "", "7", "9", "" },
  { "REAGENT", "", "", "7", "10", "" },
  { "ENCHANTING", "", "", "7", "12", "" },
  { "INSCRIPTION", "", "", "7", "16", "" },
  { "TRADE_GOODS", "", "", "7", "", "" },

  { "ENHANCEMENTS", "", "", "8", "", "" },

  { "BOOK", "", "", "9", "0", "" },
  { "PATTERN", "", "", "9", "1", "" },
  { "PATTERN", "", "", "9", "2", "" },
  { "SCHEMATIC", "", "", "9", "3", "" },
  { "PLANS", "", "", "9", "4", "" },
  { "RECIPE", "", "", "9", "6", "" },
  { "FORMULA", "", "", "9", "8", "" },
  { "DESIGN", "", "", "9", "10", "" },
  { "RECIPE_OTHER", "", "", "9", "", "" },

  { "BAG", "", "", "11", "", "" },

  { "QUEST", "", "", "12", "", "" },

  { "KEY_QUEST", "", "", "13", "", "" },

  { "REAGENT", "", "", "15", "1", ""},
  { "MINIPET", "", "", "15", "2", ""},
  { "HOLIDAY", "", "", "15", "3", "" },
  { "MOUNT", "", "", "15", "5", "" },
  { "MISC", "", "", "15", "", "" },

  { "GLYPHS", "", "", "16", "", "" },

  { "LEGENDARIES", TBag.S_RARITY.."5",  "", "", "", "" },

  { string.format("EQUIPPED_%s","TRINKET"), "EQUIPPED", "", "4", "", "INVTYPE_TRINKET" },

  { string.format("EQUIPPED_%s","RING"), "EQUIPPED", "", "4", "", "INVTYPE_FINGER" },
  { string.format("EQUIPPED_%s","01_HEAD"), "EQUIPPED", "", "4", "", "INVTYPE_HEAD" },
  { string.format("EQUIPPED_%s","02_NECK"), "EQUIPPED", "", "4", "", "INVTYPE_NECK" },
  { string.format("EQUIPPED_%s","03_SHOULDER"), "EQUIPPED", "", "4", "", "INVTYPE_SHOULDER" },
  { string.format("EQUIPPED_%s","04_BACK"), "EQUIPPED", "", "4", "", "INVTYPE_CLOAK" },

  { string.format("EQUIPPED_%s","05_CHEST"), "EQUIPPED", "", "4", "", "INVTYPE_CHEST" },
  { string.format("EQUIPPED_%s","05_CHEST"), "EQUIPPED", "", "4", "", "INVTYPE_ROBE" },

  { string.format("EQUIPPED_%s","06_SHIRT"), "EQUIPPED", "", "4", "", "INVTYPE_BODY" },
  { string.format("EQUIPPED_%s","07_TABARD"), "EQUIPPED", "", "4", "", "INVTYPE_TABARD" },
  { string.format("EQUIPPED_%s","08_WRIST"), "EQUIPPED", "", "4", "", "INVTYPE_WRIST" },
  { string.format("EQUIPPED_%s","09_HANDS"), "EQUIPPED", "", "4", "", "INVTYPE_HAND" },
  { string.format("EQUIPPED_%s","10_WAIST"), "EQUIPPED", "", "4", "", "INVTYPE_WAIST" },
  { string.format("EQUIPPED_%s","11_LEGS"), "EQUIPPED", "", "4", "", "INVTYPE_LEGS" },
  { string.format("EQUIPPED_%s","12_FEET"), "EQUIPPED", "", "4", "", "INVTYPE_FEET" },
  { string.format("EQUIPPED_%s","13_OFFHAND"), "EQUIPPED", "", "4", "", "INVTYPE_HOLDABLE" },
  { string.format("EQUIPPED_%s","ARMOR"), "EQUIPPED", "", "4", "", "" },
  { string.format("EQUIPPED_%s","WEAPON"), "EQUIPPED", "", "2", "", "" },
  { string.format("EQUIPPED_%s","OTHER"), "EQUIPPED", "", "", "", "" },

  { string.format("SOULBOUND_%s","TRINKET"), "SOULBOUND", "", "4", "", "INVTYPE_TRINKET" },

  { string.format("SOULBOUND_%s","RING"), "SOULBOUND", "", "4", "", "INVTYPE_FINGER" },
  { string.format("SOULBOUND_%s","01_HEAD"), "SOULBOUND", "", "4", "", "INVTYPE_HEAD" },
  { string.format("SOULBOUND_%s","02_NECK"), "SOULBOUND", "", "4", "", "INVTYPE_NECK" },
  { string.format("SOULBOUND_%s","03_SHOULDER"), "SOULBOUND", "", "4", "", "INVTYPE_SHOULDER" },
  { string.format("SOULBOUND_%s","04_BACK"), "SOULBOUND", "", "4", "", "INVTYPE_CLOAK" },

  { string.format("SOULBOUND_%s","05_CHEST"), "SOULBOUND", "", "4", "", "INVTYPE_CHEST" },
  { string.format("SOULBOUND_%s","05_CHEST"), "SOULBOUND", "", "4", "", "INVTYPE_ROBE" },

  { string.format("SOULBOUND_%s","06_SHIRT"), "SOULBOUND", "", "4", "", "INVTYPE_BODY" },
  { string.format("SOULBOUND_%s","07_TABARD"), "SOULBOUND", "", "4", "", "INVTYPE_TABARD" },
  { string.format("SOULBOUND_%s","08_WRIST"), "SOULBOUND", "", "4", "", "INVTYPE_WRIST" },
  { string.format("SOULBOUND_%s","09_HANDS"), "SOULBOUND", "", "4", "", "INVTYPE_HAND" },
  { string.format("SOULBOUND_%s","10_WAIST"), "SOULBOUND", "", "4", "", "INVTYPE_WAIST" },
  { string.format("SOULBOUND_%s","11_LEGS"), "SOULBOUND", "", "4", "", "INVTYPE_LEGS" },
  { string.format("SOULBOUND_%s","12_FEET"), "SOULBOUND", "", "4", "", "INVTYPE_FEET" },
  { string.format("SOULBOUND_%s","13_OFFHAND"), "SOULBOUND", "", "4", "", "INVTYPE_HOLDABLE" },
  { string.format("SOULBOUND_%s","ARMOR"), "SOULBOUND", "", "4", "", "" },
  { string.format("SOULBOUND_%s","WEAPON"), "SOULBOUND", "", "2", "", "" },

  { string.format("ACCOUNTBOUND_%s","TRINKET"), "ACCOUNTBOUND", "", "4", "", "INVTYPE_TRINKET" },

  { string.format("ACCOUNTBOUND_%s","RING"), "ACCOUNTBOUND", "", "4", "", "INVTYPE_FINGER" },
  { string.format("ACCOUNTBOUND_%s","01_HEAD"), "ACCOUNTBOUND", "", "4", "", "INVTYPE_HEAD" },
  { string.format("ACCOUNTBOUND_%s","02_NECK"), "ACCOUNTBOUND", "", "4", "", "INVTYPE_NECK" },
  { string.format("ACCOUNTBOUND_%s","03_SHOULDER"), "ACCOUNTBOUND", "", "4", "", "INVTYPE_SHOULDER" },
  { string.format("ACCOUNTBOUND_%s","04_BACK"), "ACCOUNTBOUND", "", "4", "", "INVTYPE_CLOAK" },

  { string.format("ACCOUNTBOUND_%s","05_CHEST"), "ACCOUNTBOUND", "", "4", "", "INVTYPE_CHEST" },
  { string.format("ACCOUNTBOUND_%s","05_CHEST"), "ACCOUNTBOUND", "", "4", "", "INVTYPE_ROBE" },

  { string.format("ACCOUNTBOUND_%s","06_SHIRT"), "ACCOUNTBOUND", "", "4", "", "INVTYPE_BODY" },
  { string.format("ACCOUNTBOUND_%s","07_TABARD"), "ACCOUNTBOUND", "", "4", "", "INVTYPE_TABARD" },
  { string.format("ACCOUNTBOUND_%s","08_WRIST"), "ACCOUNTBOUND", "", "4", "", "INVTYPE_WRIST" },
  { string.format("ACCOUNTBOUND_%s","09_HANDS"), "ACCOUNTBOUND", "", "4", "", "INVTYPE_HAND" },
  { string.format("ACCOUNTBOUND_%s","10_WAIST"), "ACCOUNTBOUND", "", "4", "", "INVTYPE_WAIST" },
  { string.format("ACCOUNTBOUND_%s","11_LEGS"), "ACCOUNTBOUND", "", "4", "", "INVTYPE_LEGS" },
  { string.format("ACCOUNTBOUND_%s","12_FEET"), "ACCOUNTBOUND", "", "4", "", "INVTYPE_FEET" },
  { string.format("ACCOUNTBOUND_%s","13_OFFHAND"), "ACCOUNTBOUND", "", "4", "", "INVTYPE_HOLDABLE" },
  { string.format("ACCOUNTBOUND_%s","ARMOR"), "ACCOUNTBOUND", "", "4", "", "" },
  { string.format("ACCOUNTBOUND_%s","WEAPON"), "ACCOUNTBOUND", "", "2", "", "" },

  { "TRINKET", "", "", "4", "", "INVTYPE_TRINKET" },

  { "RING", "", "", "4", "", "INVTYPE_FINGER" },
  { "01_HEAD", "", "", "4", "", "INVTYPE_HEAD" },
  { "02_NECK", "", "", "4", "", "INVTYPE_NECK" },
  { "03_SHOULDER", "", "", "4", "", "INVTYPE_SHOULDER" },
  { "04_BACK", "", "", "4", "", "INVTYPE_CLOAK" },

  { "05_CHEST", "", "", "4", "", "INVTYPE_CHEST" },
  { "05_CHEST", "", "", "4", "", "INVTYPE_ROBE" },

  { "06_SHIRT", "", "", "4", "", "INVTYPE_BODY" },
  { "07_TABARD", "", "", "4", "", "INVTYPE_TABARD" },
  { "08_WRIST", "", "", "4", "", "INVTYPE_WRIST" },
  { "09_HANDS", "", "", "4", "", "INVTYPE_HAND" },
  { "10_WAIST", "", "", "4", "", "INVTYPE_WAIST" },
  { "11_LEGS", "", "", "4", "", "INVTYPE_LEGS" },
  { "12_FEET", "", "", "4", "", "INVTYPE_FEET" },
  { "13_OFFHAND", "", "", "4", "", "INVTYPE_HOLDABLE" },
  { "ARMOR", "", "", "4", "", "" },
  { "WEAPON", "", "", "2", "", "" },

  { string.format("SOULBOUND_%s","OTHER"), "SOULBOUND", "", "", "", "" },
  { "UNKNOWN", "", "", "", "", "" }
};
