-- German translation by Dessa <dessa@gmake.de>.

-- localization files should be edited with a utf-8
-- compatable editor and done so with utf-8 encoding.

-- See localization.template.lua to start a new translation.

if GetLocale() ~= "deDE" then return end

TBag.LOCALES.deDE = {}
TBag.LOCALES.current = TBag.LOCALES.deDE
local L = TBag.LOCALE

L[""] = ""  -- Needed to preserve nil returns

-----------------------------------------------------------------------
-- ITEM TYPES
-----------------------------------------------------------------------

-- Slots
L["Soulbound"] = ITEM_SOULBOUND
L["Account Bound"] = ITEM_ACCOUNTBOUND

-----------------------------------------------------------------------
-- BAG DISPLAY NAMES
-----------------------------------------------------------------------

L["Bank"] = "Bank"
L["Backpack"] = "Rucksack"
L["First Bag"] = "Erste Tasche"
L["Second Bag"] = "Zweite Tasche"
L["Third Bag"] = "Dritte Tasche"
L["Fourth Bag"] = "Vierte Tasche"
L["First Bank Bag"] = "Erste Banktasche"
L["Second Bank Bag"] = "Zweite Banktasche"
L["Third Bank Bag"] = "Dritte Banktasche"
L["Fourth Bank Bag"] = "Vierte Banktasche"
L["Fifth Bank Bag"] = "F\195\188nfte Banktasche"
L["Sixth Bank Bag"] = "Sechste Banktasche"
L["Seventh Bank Bag"] = "Siebte Banktasche"
L["Empty Slot"] = "Leerer Platz"
L["Purchasable Reagent Bank"] = "Kaufbares Materiallager"

-----------------------------------------------------------------------
-- CHAT STRINGS
-----------------------------------------------------------------------

L["%sSetting keybind to %q"] = "%sSetze Tastenk\195\188rzel auf %q"
L["Unassigned category %s has been assigned to slot 1"] =
      "Unzugeordnete Kategorie %s wurde dem Slot 1 zugewiesen"
L["Character data cached for:"] = "Charakterdaten gespeichert f\195\188r:"
L["Removed cache for %q"] = "Cache gel\195\182scht f\195\188r %q"
L["Couldn't find and remove cache for %q"] =
      "Kann den Cache nicht finden f\195\188r %q"
-----------------------------------------------------------------------
-- SEARCH OUTPUT STRINGS
-----------------------------------------------------------------------
L["Search results for %q:"] = "Suchergebnis f\195\188r %q:"
L["No results|r for %q"] = "Keine Ergebnisse|r f\195\188r %q"
L[" found:"] = " gefunden:"
L["bags"] = "Taschen"
L["bank"] = "Bank"
L["container"] = "Tasche"
L["body"] = "K\195\182rper"
L["mail"] = "Post"
L["tokens"] = "Abzeichen"
L[" in %s's %s"] = " in %s's %s" -- Used when an item is found in a characters bag or bank
L[" on %s's %s"] = " an %s's %s" -- Used when an item is found on a characters body
L[" as %s's %s"] = " als %s's %s" -- Used when an item is used as a container for a character

-----------------------------------------------------------------------
-- HEARTHSTONE
-----------------------------------------------------------------------
-- These two strings are used to replace the home location on the tooltip
-- for Hearthstones.  The first string should be translated to match the
-- text from the Use: up to the actual location and end on the period.
-- If you keep it to just 3 captures with the 2nd capture from the
-- expression being the location then you probably don't need to change
-- the 2nd line.  The 2nd line controls putting the string back together.
-- %%1 and %%3 represent the first and third captures from the previous
-- expresion.  %s is the location that will be replaced.
L["(Use: Returns you to )([^%.]*)(%.)"] = "(Benutzen: Bringt euch zur\195\188ck nach )([^%.]*)(%.)"
L["%%1%s%%3"] = "%%1%s%%3"

-- Generic name for the home location if we don't have it cached.
-- The tooltip should have something like this where in the text
-- where it describes how to change your bind point.  Brackets are
-- there to imply it's a placeholder.
L["<home location>"] = "<Heimatort>"

-----------------------------------------------------------------------
-- CHARGES
-----------------------------------------------------------------------
-- Pattern to get the charges from a tooltip
-- Probably only need to chage the Charges.
-- The ? after the s implies that the s may not be there
-- as would be the case in a single Charge.
L["(%d+) Charges?"] = "(%d+) Aufladung?n?"
-- Format string for adding the charges tooltip.
-- %d is the number of charges.  |4 specifies this
-- is a plural/singular pair.  Up until the : is the
-- singular form after is the plural until the ;.
L["%d |4Charge:Charges;"] = "%d |4Aufladung:Aufladungen;"

-----------------------------------------------------------------------
-- BINDING STRINGS
-----------------------------------------------------------------------
L["Toggle Bank Window"] = "Zeige Bankfester"
L["Toggle Inventory Window"] = "Zeige Inventarfester"

-----------------------------------------------------------------------
-- COMMAND LINE STRINGS
-----------------------------------------------------------------------
-- commands
L["hide"] = "hide"
L["show"] = "show"
L["update"] = "update"
L["debug"] = "debug"
L["reset"] = "reset"
L["resetpos"] = "resetpos"
L["resetsorts"] = "resetsorts"
L["printchars"] = "printchars"
L["deletechar"] = "deletechar"
L["config"] = "config"
L["tests"] = "tests"
L["getcat"] = "getcat"

-- /tbnk help text
L["TBnk Commands:"] = "TBnk Kommandos"
L[" /tbnk show  -- open window"] = " /tbnk show  -- \195\150ffne Fenster"
L[" /tbnk hide  -- hide window"] = " /tbnk hide  -- Verstecke Fenster"
L[" /tbnk update  -- refresh the window"] = " /tbnk update  -- Fenster neu laden"
L[" /tbnk config  -- configuration options"] = " /tbnk config  -- Konfiguration"
L[" /tbnk debug  -- turn debug info on/off"] = " /tbnk debug  -- Debugmodus an- und ausschalten"
L[" /tbnk reset  -- sets everything back to default values"] = " /tbnk reset  -- alles auf Standardwerte zur\195\188cksetzen"
L[" /tbnk resetpos -- put the bank back to its default position"] = " /tbnk resetpos -- Das Bankfenster auf die Standardposition zur\195\188cksetzen"
L[" /tbnk resetsorts -- clears the item search list"] = " /tbnk resetsorts -- l\195\182scht die Item Suchliste"
L[" /tbnk printchars -- prints a list of all the chars with cached info"] = " /tbnk printchars -- Gibt eine Liste aller Charaktere mit gespeicherten Infos aus"
L[" /tbnk deletechar CHAR SERVER -- clears all cached info for character "] = " /tbnk deletechar CHAR SERVER -- L\195\182scht die gespeicherten Daten f\195\188r den gew\195\164hlten Charakter "

-- /tinv help text
L["TInv Commands:"] = "TInv Kommandos:"
L[" /tinv show  -- open window"] = " /tinv show  -- \195\150ffne Fenster"
L[" /tinv hide  -- hide window"] = " /tinv hide  -- Verstecke Fenster"
L[" /tinv update  -- refresh the window"] = " /tinv update  -- Fenster neu laden"
L[" /tinv config  -- configuration options"] = " /tinv config  -- Konfiguration"
L[" /tinv debug  -- turn debug info on/off"] = " /tinv debug  -- Debugmodus an- und ausschalten"
L[" /tinv reset  -- sets everything back to default values"] = " /tinv reset  -- alles auf Standardwerte zur\195\188cksetzen"
L[" /tinv resetpos -- put the inventory window back to its default position"] = " /tinv resetpos -- Das Inventarfenster auf die Standardposition zur\195\188cksetzen"
L[" /tinv resetsorts -- clears the item search list"] = " /tinv resetsorts -- l\195\182scht die Item Suchliste"
L[" /tinv printchars -- prints a list of all the chars with cached info"] = " /tinv printchars -- Gibt eine Liste aller Charaktere mit gespeicherten Infos aus"
L[" /tinv deletechar CHAR SERVER -- clears all cached info for character "] = " /tinv deletechar CHAR SERVER -- L\195\182scht die gespeicherten Daten f\195\188r den gew\195\164hlten Charakter"

-----------------------------------------------------------------------
-- WINDOW STRINGS
-----------------------------------------------------------------------
L["TBag v%s"] = "TBag v%s"

L["Normal"] = "Normal"
L["Stop highlighting new items."] = "Neue Items nicht mehr hervorheben."
L["Highlight New"] = "Neue Hervorheben"
L["Highlight items marked as new."] = "Items die als neu Markiert sind hervorheben."
L["Clear Search"] = "Suche l\195\182schen"
L["Stop highlighting search results."] = "Suchergebnisse nicht mehr hervorheben."

L["Toggle Edit Mode"] = "Bearbeitungsmodus Ein- und Ausschalten"
L["Select this option to move classes of items into different 'bars' (the red numbers)."] = "W\195\164hle diese Option um Itemklassen in andere \"Felder\" zu verschieben (die roten Zahlen)."

L["Reload and Sort"] = "Neuladen und Sortieren"
L["Reloads your items and sorts them."] = "L\195\164d die Items neu und sortiert sie."

L["Toggle Bank"] = "Zeige Bank"
L["Displays bank contents in a view-only mode.  You may select another player's bank to view from the dropdown."] = "Zeigt den Bankinhalt im Nur-Lesen Modus. Du kannst aus dem Men\195\188 die Bank eines anderen Spielers w\195\164hlen."

L["Unlock Window"] = "Entsperre Fenster"
L["Allow window to be moved by dragging it."] = "Erlaubt das Fenster durch Ziehen zu verschieben."
L["Lock Window"] = "Sperre Fenster"
L["Prevent window from being moved by dragging it."] = "Verbietet das Fenster durch Ziehen zu verschieben."

L["<++>"] = "<++>"
L["Increase Window Size"] = "Erh\195\182he Fenstergr\195\182\195\159e"
L["Increase the number of columns displayed"] = "Erh\195\182he die Anzahl der Reihen"

L[">--<"] = ">--<"
L["Decrease Window Size"] = "Verringere Fenstergr\195\182\195\159e"
L["Decrease the number of columns displayed"] = "Verringere die Anzahl der Reihen"

L["Reset"] = "Reset"
L["Close"] = "Schlie\195\159en"
L["Add New Cat"] = "neue Kat. hinzuf\195\188gen"
L["Assign Cats"] = "Kat. zuweisen"
L["No"] = "Nein"
L["Yes"] = "Ja"
L["Category"] = "Kategorie"
L["Keywords"] = "Schl\195\188sselw\195\182rter"
L["Tooltip Search"] = "Tooltip Suche"
L["Type"] = "Typ"
L["SubType"] = "SubTyp"

-- Menus and Tooltips
L["Main Background Color"] = "Allgemeine Hintergrundfarbe"
L["Main Border Color"] = "Allgemeine Randfarbe"
L["Set Bar Colors to Main Colors"] = "Verwende Feldfarben als allgemeine Farben"
L["Spotlight for %s"] = "Hervorhebung f\195\188r %s"
L["Current Category: %s"] = "Aktuelle Kategorie: %s"
L["Assign item to category:"] = "Item der Kategorie zuordnen:"
L["Use default category assignment"] = "Verwende Standard Kategorie Zuordnung"
L["Debug Info: "] = "Debug Info: "
L["Categories within bar %d"] = "Kategorien in Feld %d"
L["Move: |c%s%s|r"] = "Bewegen: |c%s%s|r"
L["Sort Mode:"] = "Sortiermodus:"
L["No sort"] = "Keine Sortierung"
L["Sort by name"] = "nach Name Sortieren"
L["Sort last words first"] = "nach letzter Verwendung Sotieren"
L["Highlight new items:"] = "Neue Items hervorheben:"
L["Don't tag new items"] = "Neue Items nicht Markieren"
L["Tag new items"] = "neue Items Markieren"
L["Hide Bar:"] = "Verstecke Feld:"
L["Show items assigned to this bar"] = "Zeige Items die dem Feld zugewiesen sind"
L["Hide items assigned to this bar"] = "Verstecke Items die dem Feld zugewiesen sind"
L["Color:"] = "Farbe:"
L["Background Color for Bar %d"] = "Hintergrundfarbe f\195\188r Felder %d"
L["Border Color for Bar %d"] = "Randfarbe f\195\188r Felder %d"
L["Select Character"] = "Zeige Charakter"
L["Edit Mode"] = "Bearbeitungsmodus"
L["Lock window"] = "Fenster sperren"
L["Close Inventory"] = "Inventar Schlie\195\159en"
L["Highlight New Items"] = "Neue Items Hervorheben"
L["Reset NEW tag"] = "Setze NEU Markierung zur\195\188ck"
L["Advanced Configuration"] = "Erweiterte Konfiguration"
L["Set Size"] = "Gr\195\182\195\159e"
L["Set Colors"] = "Farben"
L["Hide"] = "Verstecken"
L["Hide Player Dropdown"] = "Verstecke Spieler"
L["Hide Search Box"] = "Verstecke Suchfeld"
L["Hide Re-sort Button"] = "Verstecke neu Sortieren"
L["Hide Reagent Deposit Button"] = "Verstecke Material einlagern"
L["Hide Bank Button"] = "Verstecke Bank Knopf"
L["Hide Edit Button"] = "Verstecke bearbeiten Knopf"
L["Hide Highlight Button"] = "Verstecke Hervorheben Knopf"
L["Hide Lock Button"] = "Verstecke Sperren Knopf"
L["Hide Close Button"] = "Verstecke Schlie\195\159en Knopf"
L["Hide Total"] = "Verstecke Gesamt"
L["Hide Bag Buttons"] = "Verstecke Taschenkn\195\182pfe"
L["Hide Money"] = "Verstecke Geld"
L["Hide Tokens"] = "Verstecke Abzeichen"
L["The Bank"] = "Die Bank"
L["|c%sLeft click to move category |r|c%s%s|r|c%s to bar |r|c%s%s|r"] = "|c%sLinksklick um Kategorie |r|c%s%s|r|c%s zu Felder zu verschieben |r|c%s%s|r"
L["|c%sBar |r|c%s%s|r"] = "|c%sFeld |r|c%s%s|r"
L["|c%s%s|r"] = "|c%s%s|r"
L["Right click for options"] = "Rechtsklick f\195\188r Optionen"
L["|c%sLeft click to select category to move:|r |c%s%s|r"] = "|c%sLinksklick um die Kategorie zum Verschieben zu w\195\164hlen:|r |c%s%s|r"
L["Right click to assign this item to a different category"] = "Rechtsklick um dieses Item einer anderen Kategorie zuzuweisen"
L["You are viewing the selected player's bank."] = "Du siehst die Bank des ausgew\195\164hlten Spielers an"
L["You are viewing the selected player's inventory."] = "Du siehst das Inventar des ausgew\195\164hlten Spielers an."
L["Equip Container"] = "Tasche anlegen"
L["Anchor"] = "Anker"
L["TOPLEFT"] = "OBENLINKS"
L["TOPRIGHT"] = "OBENRECHTS"
L["BOTTOMLEFT"] = "UNTENLINKS"
L["BOTTOMRIGHT"] = "UNTENRECHTS"
L["Show on TBag"] = "Zeige in TBag"
L["Checking this option will allow you to track this currency type in TBag for this character.\n\nYou can also Shift-click a currency to add or remove it from being tracked in TBag."] = "Ist diese Option aktiviert wird diese W\195\164hrung in TBag f\195\188r diesen Charakter angezeigt.\n\nDu kannst auch auf eine W\195\164hrung Shift-Rechtsklicken um sie in TBag anzuzeigen oder zu entfernen."
L["Deposits all Reagents in your bag."] = "Verstaut alle Materialien in deiner Tasche"

-- Option Window Strings
L["Main Sizing Preferences"] = "Allgemeine Gr\195\182\195\159eneinstellungen"
L["Number of Item Columns:"] = "Anzahl der Itemspalten:"
L["Number of Horizontal Bars:"] = "Anzahl der Horizontalen Felder:"
L["Window Scale:"] = "Fensterskalierung:"
L["Item Button Size:"] = "Itemknopf Gr\195\182\195\159e:"
L["Item Button Padding:"] = "Itemknopf Abstand:"
L["Spacing - X Button:"] = "Leerraum - X Knopf:"
L["Spacing - Y Button:"] = "Leerraum - Y Knopf:"
L["Spacing - X Pool:"] = "Leerraum - X Pool:"
L["Spacing - Y Pool:"] = "Leerraum - Y Pool:"
L["Count Font Size:"] = "Zahlen Schriftgr\195\182\195\159e:"
L["Count Placement - X:"] = "Zahlenplatzierung - X:"
L["Count Placement - Y:"] = "Zahlenplatzierung - Y:"
L["New Tag Font Size:"] = "Neue Markierungs Schriftgr\195\182\195\159e:"
L["Bag Contents Show"] = "Tascheninhalt anzeigen"
L["Show %s:"] = "Zeige %s:"
L["General Display Preferences"] = "Allgemeine Anzeigeeigenschaften"
L["Show Size on Bag Count:"] = "Zeige Gr\195\182\195\159e auf Taschenzahl:"
L["Show Bag Icons on Empty Slots:"] = "Zeige Taschensymbol auf leeren Pl\195\164tzen:"
L["Spotlight Open or Selected Bags:"] = "Hebe Offene oder Ausgew\195\164hlte Taschen hervor:"
L["Spotlight Mouseover:"] = "Mouseover Hervorhebung:"
L["Show Item Rarity Color:"] = "Zeige Item Seltenheitsfarbe:"
L["Auto Stack:"] = "Automatisches Stapeln:"
L["Stack on Re-sort:"] = "Stapeln beim neu Sortieren:"
L["Profession Bags precede Sorting:"] = "Berufstaschen beim Sortieren Bevorzugen:"
L["Trade Creation precedes Sorting (Reopen Window):"] = "Handel beim Sortieren Bevorzugen (Fenster neu \195\150ffnen):"
L["New Tag Options"] = "Neu Markierungs Optionen"
L["New Tag Text:"] = "Neu Markierungs Text:"
L["Increased Tag Text:"] = "Ver\195\182\195\159erter Markierungstext:"
L["Decreased Tag Text:"] = "Verkleinerter Markierungstext:"
L["New Tag Timeout (minutes):"] = "Neu Markierungs Timeout (Minuten):"
L["Recent Tag Timeout (minutes):"] = "K\195\188rzlich Markierungs Timeout (Minuten):"
L["Alt Key Auto-Pickup:"] = "Alternative Auto-Pickup Taste:"
L["Alt Key Auto-Panel:"] = "Alternative Auto-Panel Taste:"

-----------------------------------------------------------------------
-- Unit Tests
-----------------------------------------------------------------------
L["TEST RUN STARTING"] = "TESTLAUF STARTET"
L[" Retrieving item information"] = " Frage Gegenstandsinformationen ab"
L["SUCCESS: %s"] = "ERFOLGREICH: %s"
L["FAIL: %s (%s) expected %q but got %q"] = "FEHLGESCHLAGEN: %s (%s) erwartet %q aber %q erhalten"
L["ALL TESTS SUCCESSFUL"] = "ALLE TESTS ERFOLGREICH"

-----------------------------------------------------------------------
-- Default Search List Strings
-----------------------------------------------------------------------
L["This Item Begins a Quest"] = ITEM_STARTS_QUEST
L["<Right Click to Open>"] = ITEM_OPENABLE
L[" Lockbox"] = "schlie\195\159kassette"
L["Hearthstone%s"] = "%s*[Rr]uhestein%s"
L["Use: Adds this toy to your Toy Box"] = "Benutzen: F\195\188gt dieses Spielzeug Eurer Spielzeugkiste hinzu%."
L["[Aa]rchaeology"] = "[Aa]rch\195\164ologi" -- sic!
L["digsite"] = "A?u?s?[Gg]rabungsst\195\164tte"
L["Use:.*pet"] = false
L["Use: Increases.*Champion"] = false
L["Use: Equip.*Champion"] = false
