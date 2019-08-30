-- Russian translation maintained by GagStv  (gagst6@gmail.com)

-- localization files should be edited with a utf-8
-- compatable editor and done so with utf-8 encoding.

-- See localization.template.lua to start a new translation.

if GetLocale() ~= "ruRU" then return end

TBag.LOCALES.ruRU = {}
TBag.LOCALES.current = TBag.LOCALES.ruRU
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
L["Bank"] = "Банк"
L["Backpack"] = "Рюкзак"
L["First Bag"] = "Первая сумка"
L["Second Bag"] = "Вторая сумка"
L["Third Bag"] = "Третья сумка"
L["Fourth Bag"] = "Четвертая сумка"
L["First Bank Bag"] = "Первая сумка банка"
L["Second Bank Bag"] = "Вторая сумка банка"
L["Third Bank Bag"] = "Третья сумка банка"
L["Fourth Bank Bag"] = "Четвертая сумка банка"
L["Fifth Bank Bag"] = "Пятая сумка банка"
L["Sixth Bank Bag"] = "Шестая сумка банка"
L["Seventh Bank Bag"] = "Седьмая сумка банка"
L["Empty Slot"] = "Пустая ячейка"
L["Purchasable Reagent Bank"] = "Банк реагентов"

-----------------------------------------------------------------------
-- CHAT STRINGS
-----------------------------------------------------------------------
L["%sSetting keybind to %q"] = "%sНазначить клавишу для %q"
L["Unassigned category %s has been assigned to slot 1"] = "Нераспределенная категория %s была назначена на панель 1" 
L["Character data cached for:"] = "Данные о персонажах в кэше TBag:"
L["Removed cache for %q"] = "Кэш удалён для %q"
L["Couldn't find and remove cache for %q"] = "Не удалось найти и удалить кэш для %q"       

-----------------------------------------------------------------------
-- SEARCH OUTPUT STRINGS 
-----------------------------------------------------------------------
L["Search results for %q:"] = "Поиск результатов для %q:"
L["No results|r for %q"] = "Нет результатов для|r %q"
L[" found:"] = " найдено:"
L["bags"] = "сумки"
L["bank"] = "банк"
L["container"] = "ячейки для сумок"
L["body"] = "тело"
L["mail"] = "почта"
L["tokens"] = "валюты"
L[" in %s's %s"] = " в %s %s" -- Used when an item is found in a characters bag or bank
L[" on %s's %s"] = " на %s %s" -- Used when an item is found on a characters body
L[" as %s's %s"] = " как %s %s" -- Used when an item is used as a container for a character

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
L["(Use: Returns you to )([^%.]*)(%.)"] = "(Использование: Возвращает вас в )([^%.]*)(%.)"
L["%%1%s%%3"] = "%%1%s%%3"

-- Generic name for the home location if we don't have it cached.
-- The tooltip should have something like this where in the text
-- where it describes how to change your bind point.  Brackets are
-- there to imply it's a placeholder.
L["<home location>"] = "<домашняя локация>"

-----------------------------------------------------------------------
-- CHARGES 
-----------------------------------------------------------------------
-- Pattern to get the charges from a tooltip
-- Probably only need to chage the Charges.
-- The ? after the s implies that the s may not be there
-- as would be the case in a single Charge.
L["(%d+) Charges?"] = "(%d+) зарядов?"
-- Format string for adding the charges tooltip.
-- %d is the number of charges.  |4 specifies this
-- is a plural/singular pair.  Up until the : is the
-- singular form after is the plural until the ;.
L["%d |4Charge:Charges;"] = "%d |4заряд:заряда:зарядов;"

-----------------------------------------------------------------------
-- BINDING STRINGS 
-----------------------------------------------------------------------
L["Toggle Bank Window"] = "Показать/скрыть банк"
L["Toggle Inventory Window"] = "Показать/скрыть инвентарь"
  
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
L["TBnk Commands:"] = "TBnk команды:"
L[" /tbnk show  -- open window"] = " /tbnk show -- показать окно"
L[" /tbnk hide  -- hide window"] = " /tbnk hide -- скрыть окно"
L[" /tbnk update  -- refresh the window"] = " /tbnk update -- обновить окно"
L[" /tbnk config  -- configuration options"] = " /tbnk config -- настройки"
L[" /tbnk debug  -- turn debug info on/off"] = " /tbnk debug -- вкл./выкл. показ информации отладки"
L[" /tbnk reset  -- sets everything back to default values"] = " /tbnk reset -- сбросить все настройки"
L[" /tbnk resetpos -- put the bank back to its default position"] = " /tbnk resetpos -- сбросить позицию банка"
L[" /tbnk resetsorts -- clears the item search list"] = " /tbnk resetsorts -- сбросить настройки сортировки"
L[" /tbnk printchars -- prints a list of all the chars with cached info"] = " /tbnk printchars -- вывести информацию о других персонажах в кэше TBag"
L[" /tbnk deletechar CHAR SERVER -- clears all cached info for character "] = " /tbnk deletechar ПЕРСОНАЖ СЕРВЕР -- удалить данные о персонаже"

-- /tinv help text
L["TInv Commands:"] = "TInv команды:"
L[" /tinv show  -- open window"] = " /tbnv show -- показать окно"
L[" /tinv hide  -- hide window"] = " /tinv hide -- скрыть окно"
L[" /tinv update  -- refresh the window"] = " /tinv update -- обновить окно"
L[" /tinv config  -- configuration options"] = " /tinv config -- настройки"
L[" /tinv debug  -- turn debug info on/off"] = " /tinv debug -- вкл./выкл. показ информации отладки"
L[" /tinv reset  -- sets everything back to default values"] = " /tinv reset -- сбросить все настройки"
L[" /tinv resetpos -- put the inventory window back to its default position"] = " /tinv resetpos - сбросить позицию сумок"
L[" /tinv resetsorts -- clears the item search list"] = " /tinv resetsorts -- сбросить настройки сортировки"
L[" /tinv printchars -- prints a list of all the chars with cached info"] = " /tinv printchars -- вывести информацию о других персонажах в кэше TBag"
L[" /tinv deletechar CHAR SERVER -- clears all cached info for character "] = " /tinv deletechar ПЕРСОНАЖ СЕРВЕР -- удалить данные о персонаже"

-----------------------------------------------------------------------
-- WINDOW STRINGS
-----------------------------------------------------------------------
L["TBag v%s"] = "TBag v%s"

L["Normal"] = "Нормальный вид"
L["Stop highlighting new items."] = "Прекратить выделение новых предметов"
L["Highlight New"] = "Выделить новые предметы"
L["Highlight items marked as new."] = "Выделить предметы, помеченные как новые"
L["Clear Search"] = "Очистить поиск"
L["Stop highlighting search results."] = "Прекратить выделять результаты поиска"

L["Toggle Edit Mode"] = "Включить/выключить режим редактирования"
L["Select this option to move classes of items into different 'bars' (the red numbers)."] = "Выберите эту опцию, чтобы переместить категории предметов в панели"

L["Reload and Sort"] = "Пересортировать"
L["Reloads your items and sorts them."] = "Обновить информацию о вещах и отсортировать их"

L["Toggle Bank"] = "Показать/спрятать банк"
L["Displays bank contents in a view-only mode.  You may select another player's bank to view from the dropdown."] = "Показывает банк игрока в режиме просмотра. Вы также можете выбрать для просмотра банк другого персонажа."

L["Unlock Window"] = "Разблокировать перемещение окна"
L["Allow window to be moved by dragging it."] = "Разрешает перемещать окно"
L["Lock Window"] = "Заблокировать перемещение окна"
L["Prevent window from being moved by dragging it."] = "Запрещает перемещать окно"
  
L["<++>"] = "<++>"
L["Increase Window Size"] = "Увеличение размера окна"
L["Increase the number of columns displayed"] = "Увеличение количества отображаемых столбцов"

L[">--<"] = ">--<"
L["Decrease Window Size"] = "Уменьшение размера окна"
L["Decrease the number of columns displayed"] = "Уменьшение количества отображаемых столбцов"

L["Reset"] = "Сброс"
L["Close"] = "Закрыть"
L["Add New Cat"] = "Новая категория"
L["Assign Cats"] = "Назначить категорию"
L["No"] = "Нет"
L["Yes"] = "Да"
L["Category"] = "Категория"
L["Keywords"] = "Ключевые слова"
L["Tooltip Search"] = "Поиск"
L["Type"] = "Тип"
L["SubType"] = "Подтип"
  
-- Menus and Tooltips
L["Main Background Color"] = "Основной цвет фона"
L["Main Border Color"] = "Основной цвет границы"
L["Set Bar Colors to Main Colors"] = "Выбрать цвет выделения ячеек для выбранной сумки"
L["Spotlight for %s"] = "Выделение для %s"
L["Current Category: %s"] = "Текущая категория: %s"
L["Assign item to category:"] = "Назначить предмет в категорию:"
L["Use default category assignment"] = "Назначить категорию, используемую по умолчанию"
L["Debug Info: "] = "Информация отладки: "
L["Categories within bar %d"] = "Категории в пределах панели %d"
L["Move: |c%s%s|r"] = "Двигать: |c%s%s|r"
L["Sort Mode:"] = "Режим сортировки:"
L["No sort"] = "Не сортировать"
L["Sort by name"] = "Сортировать по имени"
L["Sort last words first"] = "Сортировать по последним словам"
L["Highlight new items:"] = "Выделять новые предметы"
L["Don't tag new items"] = "Не выделять новые предметы"
L["Tag new items"] = "Выделять новые предметы"
L["Hide Bar:"] = "Скрыть панель"
L["Show items assigned to this bar"] = "Показать предметы, назначенные в эту панель"
L["Hide items assigned to this bar"] = "Скрыть предметы, назначенные в эту панель"
L["Color:"] = "Цвет:"
L["Background Color for Bar %d"] = "Цвет фона для панели %d"
L["Border Color for Bar %d"] = "Цвет границы для панели %d"
L["Select Character"] = "Выбрать персонажа"
L["Edit Mode"] = "Режим редактирования"
L["Lock window"] = "Закрепить окно"
L["Close Inventory"] = "Закрыть инвентарь"
L["Highlight New Items"] = "Выделить новые предметы"
L["Reset NEW tag"] = "Сбросить пометку НОВЫЕ"
L["Advanced Configuration"] = "Расширенная настройка"
L["Set Size"] = "Указать размер"
L["Set Colors"] = "Указать цвет"
L["Hide"] = "Скрыть"
L["Hide Player Dropdown"] = "Скрыть меню выбора персонажей"
L["Hide Search Box"] = "Скрыть окно поиска"
L["Hide Re-sort Button"] = "Скрыть кнопку пересортировки"
L["Hide Reagent Deposit Button"] = "Скрыть кнопку перемещения материалов в банк"
L["Hide Bank Button"] = "Скрыть кнопку банка"
L["Hide Edit Button"] = "Скрыть кнопку редактирования"
L["Hide Highlight Button"] = "Скрыть кнопку выделения новых предметов"
L["Hide Lock Button"] = "Скрыть кнопку закрепления окна"
L["Hide Close Button"] = "Скрыть кнопку закрытия окна"
L["Hide Total"] = "Скрыть счетчик свободного места в сумках"
L["Hide Bag Buttons"] = "Скрыть кнопки сумок"
L["Hide Money"] = "Скрыть деньги"
L["Hide Tokens"] = "Скрыть валюты"
L["The Bank"] = "Банк"
L["|c%sLeft click to move category |r|c%s%s|r|c%s to bar |r|c%s%s|r"] = "|c%sЛевый клик для перемещения категории |r|c%s%s|r|c%s в панель |r|c%s%s|r"
L["|c%sBar |r|c%s%s|r"] = "|c%sПанель |r|c%s%s|r"
L["|c%s%s|r"] = "|c%s%s|r"
L["Right click for options"] = "Правый клик для опций"
L["|c%sLeft click to select category to move:|r |c%s%s|r"] = "|c%sЛевый клик для перемещения в другую панель категории|r |c%s%s|r"
L["Right click to assign this item to a different category"] = "Правый клик для перемещения данного предмета в другую категорию"
L["You are viewing the selected player's bank."] = "Выберите персонажа, для просмотра его банка"
L["You are viewing the selected player's inventory."] = "Выберите персонажа, для просмотра его сумок"
L["Equip Container"] = "Одетые сумки"
L["Anchor"] = "Якорь"
L["TOPLEFT"] = "ВЕРХВЛЕВО"
L["TOPRIGHT"] = "ВЕРХВПРАВО"
L["BOTTOMLEFT"] = "НИЗВЛЕВО"
L["BOTTOMRIGHT"] = "НИЗВПРАВО"
L["Show on TBag"] = "Показать в TBag"
L["Checking this option will allow you to track this currency type in TBag for this character.\n\nYou can also Shift-click a currency to add or remove it from being tracked in TBag."] = "Выбрав этот вариант, вы позволите отслеживать этот тип валюты в TBag для этого персонажа.\n\n Также вы можете использовать комбинацию Shift-Click, чтобы добавить или удалить отслеживание валюты в TBag."
L["Deposits all Reagents in your bag."] = "Переместить все реагенты в банк"

-- Option Window Strings
L["Main Sizing Preferences"] = "Настройки размеров:"
L["Number of Item Columns:"] = "Количество колонок:"
L["Number of Horizontal Bars:"] = "Количество горизонтальных панелей:"
L["Window Scale:"] = "Масштаб окна:"
L["Item Button Size:"] = "Размер ячеек:"
L["Item Button Padding:"] = "Отступ в ячейке:"
L["Spacing - X Button:"] = "Отступ по X между ячейками:"
L["Spacing - Y Button:"] = "Отступ по Y между ячейками:"
L["Spacing - X Pool:"] = "Отступ по X между панелями:"
L["Spacing - Y Pool:"] = "Отступ по Y между панелями:"
L["Count Font Size:"] = "Размер шрифта:"
L["Count Placement - X:"] = "Отступ текста в ячейке по Х:"
L["Count Placement - Y:"] = "Отступ текста в ячейке по Y:"
L["New Tag Font Size:"] = "Размер шрифта меток:"
L["Bag Contents Show"] = "Показать содержимое сумки"
L["Show %s:"] = "Показать %s:"
L["General Display Preferences"] = "Главные настройки отображения"
L["Show Size on Bag Count:"] = "Показать размер на сумках:"
L["Show Bag Icons on Empty Slots:"] = "Показать иконку сумки в пустых ячейках:"
L["Spotlight Open or Selected Bags:"] = "Подсвечивать ячейки выбранных сумок:"
L["Spotlight Mouseover:"] = "Подсвечивать указатель мыши"
L["Show Item Rarity Color:"] = "Окрашивать рамку вокруг предметов:"
L["Auto Stack:"] = "Автоматически собирать в стопки"
L["Stack on Re-sort:"] = "Собирать в стопки при пересортировке"
L["Profession Bags precede Sorting:"] = "Профессиональные сумки предшествуют сортировке:"
L["Trade Creation precedes Sorting (Reopen Window):"] = "Профессии предшествуют сортировке:"
L["New Tag Options"] = "Новые варианты Показа"
L["New Tag Text:"] = "Метка нового предмета:"
L["Increased Tag Text:"] = "Количество в стопке увеличилось:"
L["Decreased Tag Text:"] = "Количество в стопке уменьшилось:"
L["New Tag Timeout (minutes):"] = "Время для определения новизны предмета (минуты):"
L["Recent Tag Timeout (minutes):"] = "Время для определения новизны предмета (минуты):"
L["Alt Key Auto-Pickup:"] = "Alt - автопогрузка:"
L["Alt Key Auto-Panel:"] = "Alt - автопанель:"

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
L[" Lockbox"] = "[Сс]ейф"
L["Hearthstone%s"] = "Камень возвращения%s"
L["Use: Adds this toy to your Toy Box"] = "Использование: добавить игрушку в коллекцию"
L["[Aa]rchaeology"] = "[Аа]рхеолог"
L["digsite"] = "[Рр]аскоп"
L["Use:.*pet"] = "Использование:.*питомц"
L["Use: Increases.*Champion"] = "Использование: Повы.*защитник"
L["Use: Equip.*Champion"] = "Использование: Снаря.*защитник"
