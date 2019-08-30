-- localization files should be edited with a utf-8
-- compatable editor and done so with utf-8 encoding.

-- See localization.template.lua to start a new translation.

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

TBag.LOCALES = {}
TBag.LOCALES.enUS = {}
TBag.LOCALES.current = TBag.LOCALES.enUS

TBag.LOCALE = setmetatable({},
  {__index = function(self,key)
    local value = rawget(TBag.LOCALES.current,key)
    if value then
      return value
    end
    rawset(TBag.LOCALES.current, key, key)
    -- Only output the warning on unpackaged versions.
    --@alpha@
    --DEFAULT_CHAT_FRAME:AddMessage(string.format("TBag: Please localize: %q", tostring(key)))
    --@end-alpha@
    return key
   end,
   __newindex = function(self, key, value)
     if not rawget(TBag.LOCALES.current, key) then
       -- Replace true with the key as the value
       rawset(TBag.LOCALES.current, key, value == true and key or value)
     else
      DEFAULT_CHAT_FRAME:AddMessage(string.format("TBag: Duplicate translation for: %q",tostring(key)))
     end
   end })

local L = TBag.LOCALE

L[""] = true -- Needed to preserve nil returns

-----------------------------------------------------------------------
-- ITEM TYPES
-----------------------------------------------------------------------

-- Slots
L["Soulbound"] = true
L["Account Bound"] = true

-----------------------------------------------------------------------
-- BAG DISPLAY NAMES
-----------------------------------------------------------------------
L["Bank"] = true
L["Backpack"] = true
L["First Bag"] = true
L["Second Bag"] = true
L["Third Bag"] = true
L["Fourth Bag"] = true
L["First Bank Bag"] = true
L["Second Bank Bag"] = true
L["Third Bank Bag"] = true
L["Fourth Bank Bag"] = true
L["Fifth Bank Bag"] = true
L["Sixth Bank Bag"] = true
L["Seventh Bank Bag"] = true
L["Empty Slot"] = true
L["Purchasable Reagent Bank"] = true

-----------------------------------------------------------------------
-- CHAT STRINGS
-----------------------------------------------------------------------
L["%sSetting keybind to %q"] = true
L["Unassigned category %s has been assigned to slot 1"] = true
L["Character data cached for:"] = true
L["Removed cache for %q"] = true
L["Couldn't find and remove cache for %q"] = true

-----------------------------------------------------------------------
-- SEARCH OUTPUT STRINGS
-----------------------------------------------------------------------
L["Search results for %q:"] = true
L["No results|r for %q"] = true
L[" found:"] = true
L["bags"] = true
L["bank"] = true
L["container"] = true
L["body"] = true
L["mail"] = true
L["tokens"] = true
L[" in %s's %s"] = true -- Used when an item is found in a characters bag or bank
L[" on %s's %s"] = true -- Used when an item is found on a characters body
L[" as %s's %s"] = true -- Used when an item is used as a container for a character

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
L["(Use: Returns you to )([^%.]*)(%.)"] = true
L["%%1%s%%3"] = true

-- Generic name for the home location if we don't have it cached.
-- The tooltip should have something like this where in the text
-- where it describes how to change your bind point.  Brackets are
-- there to imply it's a placeholder.
L["<home location>"] = true

-----------------------------------------------------------------------
-- CHARGES
-----------------------------------------------------------------------
-- Pattern to get the charges from a tooltip
-- Probably only need to chage the Charges.
-- The ? after the s implies that the s may not be there
-- as would be the case in a single Charge.
L["(%d+) Charges?"] = true
-- Format string for adding the charges tooltip.
-- %d is the number of charges.  |4 specifies this
-- is a plural/singular pair.  Up until the : is the
-- singular form after is the plural until the ;.
L["%d |4Charge:Charges;"] = true

-----------------------------------------------------------------------
-- BINDING STRINGS
-----------------------------------------------------------------------
L["Toggle Bank Window"] = true
L["Toggle Inventory Window"] = true

-----------------------------------------------------------------------
-- COMMAND LINE STRINGS
-----------------------------------------------------------------------
-- commands
L["hide"] = true
L["show"] = true
L["update"] = true
L["debug"] = true
L["reset"] = true
L["resetpos"] = true
L["resetsorts"] = true
L["printchars"] = true
L["deletechar"] = true
L["config"] = true
L["tests"] = true
L["getcat"] = true

-- /tbnk help text
L["TBnk Commands:"] = true
L[" /tbnk show  -- open window"] = true
L[" /tbnk hide  -- hide window"] = true
L[" /tbnk update  -- refresh the window"] = true
L[" /tbnk config  -- configuration options"] = true
L[" /tbnk debug  -- turn debug info on/off"] = true
L[" /tbnk reset  -- sets everything back to default values"] = true
L[" /tbnk resetpos -- put the bank back to its default position"] = true
L[" /tbnk resetsorts -- clears the item search list"] = true
L[" /tbnk printchars -- prints a list of all the chars with cached info"] = true
L[" /tbnk deletechar CHAR SERVER -- clears all cached info for character "] = true

-- /tinv help text
L["TInv Commands:"] = true
L[" /tinv show  -- open window"] = true
L[" /tinv hide  -- hide window"] = true
L[" /tinv update  -- refresh the window"] = true
L[" /tinv config  -- configuration options"] = true
L[" /tinv debug  -- turn debug info on/off"] = true
L[" /tinv reset  -- sets everything back to default values"] = true
L[" /tinv resetpos -- put the inventory window back to its default position"] = true
L[" /tinv resetsorts -- clears the item search list"] = true
L[" /tinv printchars -- prints a list of all the chars with cached info"] = true
L[" /tinv deletechar CHAR SERVER -- clears all cached info for character "] = true

-----------------------------------------------------------------------
-- WINDOW STRINGS
-----------------------------------------------------------------------
L["TBag v%s"] = true

L["Normal"] = true
L["Stop highlighting new items."] = true
L["Highlight New"] = true
L["Highlight items marked as new."] = true
L["Clear Search"] = true
L["Stop highlighting search results."] = true

L["Toggle Edit Mode"] = true
L["Select this option to move classes of items into different 'bars' (the red numbers)."] = true

L["Reload and Sort"] = true
L["Reloads your items and sorts them."] = true

L["Toggle Bank"] = true
L["Displays bank contents in a view-only mode.  You may select another player's bank to view from the dropdown."] = true

L["Unlock Window"] = true
L["Allow window to be moved by dragging it."] = true
L["Lock Window"] = true
L["Prevent window from being moved by dragging it."] = true

L["<++>"] = true
L["Increase Window Size"] = true
L["Increase the number of columns displayed"] = true

L[">--<"] = true
L["Decrease Window Size"] = true
L["Decrease the number of columns displayed"] = true

L["Reset"] = true
L["Close"] = true
L["Add New Cat"] = true
L["Assign Cats"] = true
L["No"] = true
L["Yes"] = true
L["Category"] = true
L["Keywords"] = true
L["Tooltip Search"] = true
L["Type"] = true
L["SubType"] = true

-- Menus and Tooltips
L["Main Background Color"] = true
L["Main Border Color"] = true
L["Set Bar Colors to Main Colors"] = true
L["Spotlight for %s"] = true
L["Current Category: %s"] = true
L["Assign item to category:"] = true
L["Use default category assignment"] = true
L["Debug Info: "] = true
L["Categories within bar %d"] = true
L["Move: |c%s%s|r"] = true
L["Sort Mode:"] = true
L["No sort"] = true
L["Sort by name"] = true
L["Sort last words first"] = true
L["Highlight new items:"] = true
L["Don't tag new items"] = true
L["Tag new items"] = true
L["Hide Bar:"] = true
L["Show items assigned to this bar"] = true
L["Hide items assigned to this bar"] = true
L["Color:"] = true
L["Background Color for Bar %d"] = true
L["Border Color for Bar %d"] = true
L["Select Character"] = true
L["Edit Mode"] = true
L["Lock window"] = true
L["Close Inventory"] = true
L["Highlight New Items"] = true
L["Reset NEW tag"] = true
L["Advanced Configuration"] = true
L["Set Size"] = true
L["Set Colors"] = true
L["Hide"] = true
L["Hide Player Dropdown"] = true
L["Hide Search Box"] = true
L["Hide Re-sort Button"] = true
L["Hide Reagent Deposit Button"] = true
L["Hide Bank Button"] = true
L["Hide Edit Button"] = true
L["Hide Highlight Button"] = true
L["Hide Lock Button"] = true
L["Hide Close Button"] = true
L["Hide Total"] = true
L["Hide Bag Buttons"] = true
L["Hide Money"] = true
L["Hide Tokens"] = true
L["The Bank"] = true
L["|c%sLeft click to move category |r|c%s%s|r|c%s to bar |r|c%s%s|r"] = true
L["|c%sBar |r|c%s%s|r"] = true
L["|c%s%s|r"] = true
L["Right click for options"] = true
L["|c%sLeft click to select category to move:|r |c%s%s|r"] = true
L["Right click to assign this item to a different category"] = true
L["You are viewing the selected player's bank."] = true
L["You are viewing the selected player's inventory."] = true
L["Equip Container"] = true
L["Anchor"] = true
L["TOPLEFT"] = true
L["TOPRIGHT"] = true
L["BOTTOMLEFT"] = true
L["BOTTOMRIGHT"] = true
L["Show on TBag"] = true
L["Checking this option will allow you to track this currency type in TBag for this character.\n\nYou can also Shift-click a currency to add or remove it from being tracked in TBag."] = true
L["Deposits all Reagents in your bag."] = true

-- Option Window Strings
L["Main Sizing Preferences"] = true
L["Number of Item Columns:"] = true
L["Number of Horizontal Bars:"] = true
L["Window Scale:"] = true
L["Item Button Size:"] = true
L["Item Button Padding:"] = true
L["Spacing - X Button:"] = true
L["Spacing - Y Button:"] = true
L["Spacing - X Pool:"] = true
L["Spacing - Y Pool:"] = true
L["Count Font Size:"] = true
L["Count Placement - X:"] = true
L["Count Placement - Y:"] = true
L["New Tag Font Size:"] = true
L["Bag Contents Show"] = true
L["Show %s:"] = true
L["General Display Preferences"] = true
L["Show Size on Bag Count:"] = true
L["Show Bag Icons on Empty Slots:"] = true
L["Spotlight Open or Selected Bags:"] = true
L["Spotlight Mouseover:"] = true
L["Show Item Rarity Color:"] = true
L["Auto Stack:"] = true
L["Stack on Re-sort:"] = true
L["Profession Bags precede Sorting:"] = true
L["Trade Creation precedes Sorting (Reopen Window):"] = true
L["New Tag Options"] = true
L["New Tag Text:"] = true
L["Increased Tag Text:"] = true
L["Decreased Tag Text:"] = true
L["New Tag Timeout (minutes):"] = true
L["Recent Tag Timeout (minutes):"] = true
L["Alt Key Auto-Pickup:"] = true
L["Alt Key Auto-Panel:"] = true

-----------------------------------------------------------------------
-- Unit Tests
-----------------------------------------------------------------------
L["TEST RUN STARTING"] = true
L[" Retrieving item information"] = true
L["SUCCESS: %s"] = true
L["FAIL: %s (%s) expected %q but got %q"] = true
L["ALL TESTS SUCCESSFUL"] = true

-----------------------------------------------------------------------
-- Default Search List Strings
-----------------------------------------------------------------------
L["This Item Begins a Quest"] = true
L["<Right Click to Open>"] = true
L[" Lockbox"] = true
L["Hearthstone%s"] = true
L["Use: Adds this toy to your Toy Box"] = true
L["[Aa]rchaeology"] = true
L["digsite"] = true
L["Use:.*pet"] = true
L["Use: Increases.*Champion"] = true
L["Use: Equip.*Champion"] = true
