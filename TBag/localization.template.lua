-- This file serves as the template for starting a new
-- translation.  Just change the locale value below and
-- then edit the strings on the right hand side of the
-- list.  Rename the file to localization.locale.lua
-- (e.g. localization.deDE.lua).  Then add the file
-- to the TBag.toc below localization.enUS.lua but
-- above defaults.lua.
--
-- Unlocalized strings are initially set to false as
-- you translate them change them to the string value
-- in the language you are translating to.
--
-- localization files should be edited with a utf-8
-- compatable editor and done so with utf-8 encoding.

if GetLocale() ~= "deDE" then return end

-- A few of these translations are set to constants from
-- Blizzard's GlobalStrings.lua which should be translated
-- for every locale already.  They should be left to the
-- constants unless for some reason they are not translated
-- and need to be.

-- Some of these translations are setup to be passed to
-- string.format with %s and %d placeholders for
-- other text or data to be inserted later.  The
-- order of these placeholders must be preserved but
-- their exact position in the text is irrelevent.

-- Some of these translations include color codes
-- used by the game.  Most if not all of them are
-- also setup to be passed through to string.format
-- so the above note applies as well.  While the
-- color codes can be moved around they are necessary.

-- Some of these translations are actually patterns
-- used for the search list for determining what category
-- items are in.  Some of these will include character
-- class markers such as %a+ etc...  It may be difficult
-- to translate these without some understanding of lua
-- patterns.  Documentation can be found at:
-- http://www.wowwiki.com/HOWTO:_Use_Regular_Expressions

TBag.LOCALES.deDE = {}
TBag.LOCALES.current = TBag.LOCALES.deDE
local L = TBag.LOCALE

L[""] = false  -- Needed to preserve nil returns

-----------------------------------------------------------------------
-- ITEM TYPES
-----------------------------------------------------------------------

-- Slots
L["Soulbound"] = ITEM_SOULBOUND
L["Account Bound"] = ITEM_ACCOUNTBOUND

-----------------------------------------------------------------------
-- BAG DISPLAY NAMES
-----------------------------------------------------------------------

L["Bank"] = false
L["Backpack"] = false
L["First Bag"] = false
L["Second Bag"] = false
L["Third Bag"] = false
L["Fourth Bag"] = false
L["First Bank Bag"] = false
L["Second Bank Bag"] = false
L["Third Bank Bag"] = false
L["Fourth Bank Bag"] = false
L["Fifth Bank Bag"] = false
L["Sixth Bank Bag"] = false
L["Seventh Bank Bag"] = false
L["Empty Slot"] = false
L["Purchasable Reagent Bank"] = false

-----------------------------------------------------------------------
-- CHAT STRINGS
-----------------------------------------------------------------------

L["%sSetting keybind to %q"] = false
L["Unassigned category %s has been assigned to slot 1"] =
      "Unassigned category %s has been assigned to slot 1"
L["Character data cached for:"] = false
L["Removed cache for %q"] = false
L["Couldn't find and remove cache for %q"] =
      "Couldn't find and remove cache for %q"
-----------------------------------------------------------------------
-- SEARCH OUTPUT STRINGS
-----------------------------------------------------------------------
L["Search results for %q:"] = false
L["No results|r for %q"] = false
L[" found:"] = false
L["bags"] = false
L["bank"] = false
L["container"] = false
L["body"] = false
L["mail"] = false
L["tokens"] = false
L[" in %s's %s"] = false -- Used when an item is found in a characters bag or bank
L[" on %s's %s"] = false -- Used when an item is found on a characters body
L[" as %s's %s"] = false -- Used when an item is used as a container for a character

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
L["(Use: Returns you to )([^%.]*)(%.)"] = false
L["%%1%s%%3"] = false

-- Generic name for the home location if we don't have it cached.
-- The tooltip should have something like this where in the text
-- where it describes how to change your bind point.  Brackets are
-- there to imply it's a placeholder.
L["<home location>"] = false

-----------------------------------------------------------------------
-- CHARGES
-----------------------------------------------------------------------
-- Pattern to get the charges from a tooltip
-- Probably only need to chage the Charges.
-- The ? after the s implies that the s may not be there
-- as would be the case in a single Charge.
L["(%d+) Charges?"] = false
-- Format string for adding the charges tooltip.
-- %d is the number of charges.  |4 specifies this
-- is a plural/singular pair.  Up until the : is the
-- singular form after is the plural until the ;.
L["%d |4Charge:Charges;"] = false

-----------------------------------------------------------------------
-- BINDING STRINGS
-----------------------------------------------------------------------
L["Toggle Bank Window"] = false
L["Toggle Inventory Window"] = false

-----------------------------------------------------------------------
-- COMMAND LINE STRINGS
-----------------------------------------------------------------------
-- commands
L["hide"] = false
L["show"] = false
L["update"] = false
L["debug"] = false
L["reset"] = false
L["resetpos"] = false
L["resetsorts"] = false
L["printchars"] = false
L["deletechar"] = false
L["config"] = false
L["tests"] = false
L["getcat"] = false

-- /tbnk help text
L["TBnk Commands:"] = false
L[" /tbnk show  -- open window"] = false
L[" /tbnk hide  -- hide window"] = false
L[" /tbnk update  -- refresh the window"] = false
L[" /tbnk config  -- configuration options"] = false
L[" /tbnk debug  -- turn debug info on/off"] = false
L[" /tbnk reset  -- sets everything back to default values"] = false
L[" /tbnk resetpos -- put the bank back to its default position"] = false
L[" /tbnk resetsorts -- clears the item search list"] = false
L[" /tbnk printchars -- prints a list of all the chars with cached info"] = false
L[" /tbnk deletechar CHAR SERVER -- clears all cached info for character "] = false

-- /tinv help text
L["TInv Commands:"] = false
L[" /tinv show  -- open window"] = false
L[" /tinv hide  -- hide window"] = false
L[" /tinv update  -- refresh the window"] = false
L[" /tinv config  -- configuration options"] = false
L[" /tinv debug  -- turn debug info on/off"] = false
L[" /tinv reset  -- sets everything back to default values"] = false
L[" /tinv resetpos -- put the inventory window back to its default position"] = false
L[" /tinv resetsorts -- clears the item search list"] = false
L[" /tinv printchars -- prints a list of all the chars with cached info"] = false
L[" /tinv deletechar CHAR SERVER -- clears all cached info for character "] = false

-----------------------------------------------------------------------
-- WINDOW STRINGS
-----------------------------------------------------------------------
L["TBag v%s"] = false

L["Normal"] = false
L["Stop highlighting new items."] = false
L["Highlight New"] = false
L["Highlight items marked as new."] = false
L["Clear Search"] = false
L["Stop highlighting search results."] = false

L["Toggle Edit Mode"] = false
L["Select this option to move classes of items into different 'bars' (the red numbers)."] = false

L["Reload and Sort"] = false
L["Reloads your items and sorts them."] = false

L["Toggle Bank"] = false
L["Displays bank contents in a view-only mode.  You may select another player's bank to view from the dropdown."] = false

L["Unlock Window"] = false
L["Allow window to be moved by dragging it."] = false
L["Lock Window"] = false
L["Prevent window from being moved by dragging it."] = false

L["<++>"] = false
L["Increase Window Size"] = false
L["Increase the number of columns displayed"] = false

L[">--<"] = false
L["Decrease Window Size"] = false
L["Decrease the number of columns displayed"] = false

L["Reset"] = false
L["Close"] = false
L["Add New Cat"] = false
L["Assign Cats"] = false
L["No"] = false
L["Yes"] = false
L["Category"] = false
L["Keywords"] = false
L["Tooltip Search"] = false
L["Type"] = false
L["SubType"] = false

-- Menus and Tooltips
L["Main Background Color"] = false
L["Main Border Color"] = false
L["Set Bar Colors to Main Colors"] = false
L["Spotlight for %s"] = false
L["Current Category: %s"] = false
L["Assign item to category:"] = false
L["Use default category assignment"] = false
L["Debug Info: "] = false
L["Categories within bar %d"] = false
L["Move: |c%s%s|r"] = false
L["Sort Mode:"] = false
L["No sort"] = false
L["Sort by name"] = false
L["Sort last words first"] = false
L["Highlight new items:"] = false
L["Don't tag new items"] = false
L["Tag new items"] = false
L["Hide Bar:"] = false
L["Show items assigned to this bar"] = false
L["Hide items assigned to this bar"] = false
L["Color:"] = false
L["Background Color for Bar %d"] = false
L["Border Color for Bar %d"] = false
L["Select Character"] = false
L["Edit Mode"] = false
L["Lock window"] = false
L["Close Inventory"] = false
L["Highlight New Items"] = false
L["Reset NEW tag"] = false
L["Advanced Configuration"] = false
L["Set Size"] = false
L["Set Colors"] = false
L["Hide"] = false
L["Hide Player Dropdown"] = false
L["Hide Search Box"] = false
L["Hide Re-sort Button"] = false
L["Hide Reagent Deposit Button"] = true
L["Hide Bank Button"] = false
L["Hide Edit Button"] = false
L["Hide Highlight Button"] = false
L["Hide Lock Button"] = false
L["Hide Close Button"] = false
L["Hide Total"] = false
L["Hide Bag Buttons"] = false
L["Hide Money"] = false
L["Hide Tokens"] = false
L["The Bank"] = false
L["|c%sLeft click to move category |r|c%s%s|r|c%s to bar |r|c%s%s|r"] = false
L["|c%sBar |r|c%s%s|r"] = false
L["|c%s%s|r"] = false
L["Right click for options"] = false
L["|c%sLeft click to select category to move:|r |c%s%s|r"] = false
L["Right click to assign this item to a different category"] = false
L["You are viewing the selected player's bank."] = false
L["You are viewing the selected player's inventory."] = false
L["Equip Container"] = false
L["Anchor"] = false
L["TOPLEFT"] = false
L["TOPRIGHT"] = false
L["BOTTOMLEFT"] = false
L["BOTTOMRIGHT"] = false
L["Show on TBag"] = false
L["Checking this option will allow you to track this currency type in TBag for this character.\n\nYou can also Shift-click a currency to add or remove it from being tracked in TBag."] = false
L["Deposits all Reagents in your bag."] = true

-- Option Window Strings
L["Main Sizing Preferences"] = false
L["Number of Item Columns:"] = false
L["Number of Horizontal Bars:"] = false
L["Window Scale:"] = false
L["Item Button Size:"] = false
L["Item Button Padding:"] = false
L["Spacing - X Button:"] = false
L["Spacing - Y Button:"] = false
L["Spacing - X Pool:"] = false
L["Spacing - Y Pool:"] = false
L["Count Font Size:"] = false
L["Count Placement - X:"] = false
L["Count Placement - Y:"] = false
L["New Tag Font Size:"] = false
L["Bag Contents Show"] = false
L["Show %s:"] = false
L["General Display Preferences"] = false
L["Show Size on Bag Count:"] = false
L["Show Bag Icons on Empty Slots:"] = false
L["Spotlight Open or Selected Bags:"] = false
L["Spotlight Mouseover:"] = false
L["Show Item Rarity Color:"] = false
L["Auto Stack:"] = false
L["Stack on Re-sort:"] = false
L["Profession Bags precede Sorting:"] = false
L["Trade Creation precedes Sorting (Reopen Window):"] = false
L["New Tag Options"] = false
L["New Tag Text:"] = false
L["Increased Tag Text:"] = false
L["Decreased Tag Text:"] = false
L["New Tag Timeout (minutes):"] = false
L["Recent Tag Timeout (minutes):"] = false
L["Alt Key Auto-Pickup:"] = false
L["Alt Key Auto-Panel:"] = false

-----------------------------------------------------------------------
-- Unit Tests
-----------------------------------------------------------------------
L["TEST RUN STARTING"] = false
L[" Retrieving item information"] = false
L["SUCCESS: %s"] = false
L["FAIL: %s (%s) expected %q but got %q"] = false
L["ALL TESTS SUCCESSFUL"] = false

-----------------------------------------------------------------------
-- Default Search List Strings
-----------------------------------------------------------------------
L["This Item Begins a Quest"] = ITEM_STARTS_QUEST
L["<Right Click to Open>"] = ITEM_OPENABLE
L[" Lockbox"] = false
L["Hearthstone%s"] = false
L["Use: Adds this toy to your Toy Box"] = false
L["[Aa]rchaeology"] = false
L["digsite"] = false
L["Use:.*pet"] = false
L["Use: Increases.*Champion"] = false
L["Use: Equip.*Champion"] = false
