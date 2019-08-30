----------------------------------------------------------------------
-- 	Leatrix Plus 1.13.26 (28th August 2019, www.leatrix.com)
----------------------------------------------------------------------

--	01:Functions	20:Live			50:RunOnce		70:Logout			
--	02:Locks		30:Isolated 	60:Events		80:Commands
--	03:Restarts		40:Player		62:Profile		90:Panel	

----------------------------------------------------------------------
-- 	Leatrix Plus
----------------------------------------------------------------------

--  Create global table
	_G.LeaPlusDB = _G.LeaPlusDB or {}

-- 	Create locals
	local LeaPlusLC, LeaPlusCB, LeaDropList, LeaConfigList = {}, {}, {}, {}
	local ClientVersion = GetBuildInfo()
	local GameLocale = GetLocale()
	local void

--	Version
	LeaPlusLC["AddonVer"] = "1.13.26"
	LeaPlusLC["RestartReq"] = nil

--	If client restart is required and has not been done, show warning and quit
	if LeaPlusLC["RestartReq"] then
		local metaVer = GetAddOnMetadata("Leatrix_Plus", "Version")
		if metaVer and metaVer ~= LeaPlusLC["AddonVer"] then
			C_Timer.After(1, function()
				print("NOTICE!|nYou must fully restart your game client before you can use this version of Leatrix Plus.")
			end)
			return
		end
	end

----------------------------------------------------------------------
--	L00: Leatrix Plus
----------------------------------------------------------------------

-- 	Get locale table
	local void, Leatrix_Plus = ...
	local L = Leatrix_Plus.L

--	Initialise variables
	LeaPlusLC["ShowErrorsFlag"] = 1
	LeaPlusLC["NumberOfPages"] = 9
	LeaPlusLC["RaidColors"] = RAID_CLASS_COLORS

--	Create event frame
	local LpEvt = CreateFrame("FRAME")
	LpEvt:RegisterEvent("ADDON_LOADED")
	LpEvt:RegisterEvent("PLAYER_LOGIN")
	LpEvt:RegisterEvent("PLAYER_ENTERING_WORLD")

----------------------------------------------------------------------
--	L01: Functions
----------------------------------------------------------------------

	-- Print text
	function LeaPlusLC:Print(text)
		DEFAULT_CHAT_FRAME:AddMessage(L[text], 1.0, 0.85, 0.0)
	end

	-- Lock and unlock an item
	function LeaPlusLC:LockItem(item, lock)
		if lock then
			item:Disable()
			item:SetAlpha(0.3)
		else
			item:Enable()
			item:SetAlpha(1.0)
		end
	end

	-- Hide configuration panels
	function LeaPlusLC:HideConfigPanels()
		for k, v in pairs(LeaConfigList) do
			v:Hide()
		end
	end

	-- Load a string variable or set it to default if it's not set to "On" or "Off"
	function LeaPlusLC:LoadVarChk(var, def)
		if LeaPlusDB[var] and type(LeaPlusDB[var]) == "string" and LeaPlusDB[var] == "On" or LeaPlusDB[var] == "Off" then
			LeaPlusLC[var] = LeaPlusDB[var]
		else
			LeaPlusLC[var] = def
			LeaPlusDB[var] = def
		end
	end

	-- Load a numeric variable and set it to default if it's not within a given range
	function LeaPlusLC:LoadVarNum(var, def, valmin, valmax)
		if LeaPlusDB[var] and type(LeaPlusDB[var]) == "number" and LeaPlusDB[var] >= valmin and LeaPlusDB[var] <= valmax then
			LeaPlusLC[var] = LeaPlusDB[var]
		else
			LeaPlusLC[var] = def
			LeaPlusDB[var] = def
		end
	end

	-- Load an anchor point variable and set it to default if the anchor point is invalid
	function LeaPlusLC:LoadVarAnc(var, def)
		if LeaPlusDB[var] and type(LeaPlusDB[var]) == "string" and LeaPlusDB[var] == "CENTER" or LeaPlusDB[var] == "TOP" or LeaPlusDB[var] == "BOTTOM" or LeaPlusDB[var] == "LEFT" or LeaPlusDB[var] == "RIGHT" or LeaPlusDB[var] == "TOPLEFT" or LeaPlusDB[var] == "TOPRIGHT" or LeaPlusDB[var] == "BOTTOMLEFT" or LeaPlusDB[var] == "BOTTOMRIGHT" then
			LeaPlusLC[var] = LeaPlusDB[var]
		else
			LeaPlusLC[var] = def
			LeaPlusDB[var] = def
		end
	end

	-- Show tooltips for checkboxes
	function LeaPlusLC:TipSee()
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		local parent = self:GetParent()
		local pscale = parent:GetEffectiveScale()
		local gscale = UIParent:GetEffectiveScale()
		local tscale = GameTooltip:GetEffectiveScale()
		local gap = ((UIParent:GetRight() * gscale) - (parent:GetRight() * pscale))
		if gap < (250 * tscale) then
			GameTooltip:SetPoint("TOPRIGHT", parent, "TOPLEFT", 0, 0)
		else
			GameTooltip:SetPoint("TOPLEFT", parent, "TOPRIGHT", 0, 0)
		end
		GameTooltip:SetText(self.tiptext, nil, nil, nil, nil, true)
	end

	-- Show tooltips for configuration buttons and dropdown menus
	function LeaPlusLC:ShowTooltip()
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		local parent = LeaPlusLC["PageF"]
		local pscale = parent:GetEffectiveScale()
		local gscale = UIParent:GetEffectiveScale()
		local tscale = GameTooltip:GetEffectiveScale()
		local gap = ((UIParent:GetRight() * gscale) - (LeaPlusLC["PageF"]:GetRight() * pscale))
		if gap < (250 * tscale) then
			GameTooltip:SetPoint("TOPRIGHT", parent, "TOPLEFT", 0, 0)
		else
			GameTooltip:SetPoint("TOPLEFT", parent, "TOPRIGHT", 0, 0)
		end
		GameTooltip:SetText(self.tiptext, nil, nil, nil, nil, true)
	end

	-- Create configuration button
	function LeaPlusLC:CfgBtn(name, parent)
		local CfgBtn = CreateFrame("BUTTON", nil, parent)
		LeaPlusCB[name] = CfgBtn
		CfgBtn:SetWidth(20)
		CfgBtn:SetHeight(20)
		CfgBtn:SetPoint("LEFT", parent.f, "RIGHT", 0, 0)

		CfgBtn.t = CfgBtn:CreateTexture(nil, "BORDER")
		CfgBtn.t:SetAllPoints()
		CfgBtn.t:SetTexture("Interface\\WorldMap\\Gear_64.png")
		CfgBtn.t:SetTexCoord(0, 0.50, 0, 0.50);
		CfgBtn.t:SetVertexColor(1.0, 0.82, 0, 1.0)

		CfgBtn:SetHighlightTexture("Interface\\WorldMap\\Gear_64.png")
		CfgBtn:GetHighlightTexture():SetTexCoord(0, 0.50, 0, 0.50);

		CfgBtn.tiptext = L["Click to configure the settings for this option."]
		CfgBtn:SetScript("OnEnter", LeaPlusLC.ShowTooltip)
		CfgBtn:SetScript("OnLeave", GameTooltip_Hide)
	end

	-- Capitalise first character in a string
	function LeaPlusLC:CapFirst(str)
		return gsub(string.lower(str), "^%l", strupper)
	end

	-- Toggle Zygor addon
	function LeaPlusLC:ZygorToggle()
		if select(2, GetAddOnInfo("ZygorGuidesViewer")) then
			if not IsAddOnLoaded("ZygorGuidesViewer") then
				if LeaPlusLC:PlayerInCombat() then
					return
				else
					EnableAddOn("ZygorGuidesViewer")
					ReloadUI();
				end
			else
				DisableAddOn("ZygorGuidesViewer")
				ReloadUI();
			end
		else
			-- Zygor cannot be found
			LeaPlusLC:Print("Zygor addon not found.");
		end
		return
	end

	-- Show memory usage stat
	function LeaPlusLC:ShowMemoryUsage(frame, anchor, x, y)

		-- Create frame
		local memframe = CreateFrame("FRAME", nil, frame)
		memframe:ClearAllPoints()
		memframe:SetPoint(anchor, x, y)
		memframe:SetWidth(100)
		memframe:SetHeight(20)

		-- Create labels
		local pretext = memframe:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		pretext:SetPoint("TOPLEFT", 0, 0)
		pretext:SetText(L["Memory Usage"])

		local memtext = memframe:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		memtext:SetPoint("TOPLEFT", 0, 0 - 30)

		-- Create stat
		local memstat = memframe:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		memstat:SetPoint("BOTTOMLEFT", memtext, "BOTTOMRIGHT")
		memstat:SetText("(calculating...)")

		-- Create update script
		local memtime = -1
		memframe:SetScript("OnUpdate", function(self, elapsed)
			if memtime > 2 or memtime == -1 then
				UpdateAddOnMemoryUsage();
				memtext = GetAddOnMemoryUsage("Leatrix_Plus")
				memtext = math.floor(memtext + .5) .. " KB"
				memstat:SetText(memtext);
				memtime = 0;
			end
			memtime = memtime + elapsed;
		end)

		-- Release memory
		LeaPlusLC.ShowMemoryUsage = nil

	end

	-- Check if player is in combat
	function LeaPlusLC:PlayerInCombat()
		if (UnitAffectingCombat("player")) then
			LeaPlusLC:Print("You cannot do that in combat.")
			return true
		end
	end

	--  Hide panel and pages
	function LeaPlusLC:HideFrames()

		-- Hide option pages
		for i = 0, LeaPlusLC["NumberOfPages"] do
			if LeaPlusLC["Page"..i] then
				LeaPlusLC["Page"..i]:Hide();
			end;
		end

		-- Hide options panel
		LeaPlusLC["PageF"]:Hide();

	end

	-- Find out if Leatrix Plus is showing (main panel or config panel)
	function LeaPlusLC:IsPlusShowing()
		if LeaPlusLC["PageF"]:IsShown() then return true end
		for k, v in pairs(LeaConfigList) do
			if v:IsShown() then
				return true
			end
		end
	end

	-- Check if a name is in your friends list or guild
	function LeaPlusLC:FriendCheck(name)

		-- Update friends list
		C_FriendList.ShowFriends()

		-- Check character friends
		for i = 1, C_FriendList.GetNumOnlineFriends() do
			-- Return true if name matches with or without realm
			local charFriendName = C_FriendList.GetFriendInfoByIndex(i).name
			if name == charFriendName or name == strsplit("-", charFriendName, 2) then
				return true
			end
		end

		-- Get realm name or set to player's own realm (same realm does not return realm)
		local void, myRealm = UnitFullName(name)
		if not myRealm or myRealm == "" then void, myRealm = UnitFullName("player") end

		-- Add realm name to character name
		if not string.find(name, "-") then
			name = name .. "-" .. myRealm
		end

		-- Check Battle.net friends
		local numfriends = BNGetNumFriends()
		for i = 1, numfriends do
			local numtoons = BNGetNumFriendGameAccounts(i)
			for j = 1, numtoons do
				local void, toon, client, realm = BNGetFriendGameAccountInfo(i, j)
				local toonname = toon .. "-" ..realm
				if client == "WoW" and toonname == name then
					return true
				end
			end
		end

		-- Check guild roster (new members may need to press J to refresh roster)
		local gCount = GetNumGuildMembers()
		for i = 1, gCount do
			local gName, void, void, void, void, void, void, void, gOnline, void, void, void, void, gMobile = GetGuildRosterInfo(i)
			if gOnline and not gMobile then
				local gCompare = gName
				if not string.find(gName, "-") then
					gCompare = gName .. "-" .. myRealm
				end
				if gCompare == name then
					return true
				end
			end
		end

	end

----------------------------------------------------------------------
--	L02: Locks
----------------------------------------------------------------------

	-- Function to set lock state for configuration buttons
	function LeaPlusLC:LockOption(option, item, reloadreq)
		if reloadreq then
			-- Option change requires UI reload
			if LeaPlusLC[option] ~= LeaPlusDB[option] or LeaPlusLC[option] == "Off" then
				LeaPlusLC:LockItem(LeaPlusCB[item], true)
			else
				LeaPlusLC:LockItem(LeaPlusCB[item], false)
			end
		else
			-- Option change does not require UI reload
			if LeaPlusLC[option] == "Off" then
				LeaPlusLC:LockItem(LeaPlusCB[item], true)
			else
				LeaPlusLC:LockItem(LeaPlusCB[item], false)
			end
		end
	end

--	Set lock state for configuration buttons
	function LeaPlusLC:SetDim()
		LeaPlusLC:LockOption("MailFontChange", "MailTextBtn", true)				-- Resize mail text
		LeaPlusLC:LockOption("QuestFontChange", "QuestTextBtn", true)			-- Resize quest text
		LeaPlusLC:LockOption("MinimapMod", "ModMinimapBtn", true)				-- Customise minimap
		LeaPlusLC:LockOption("TipModEnable", "MoveTooltipButton", true)			-- Manage tooltip
		LeaPlusLC:LockOption("ShowCooldowns", "CooldownsButton", true)			-- Show cooldowns
		LeaPlusLC:LockOption("FrmEnabled", "MoveFramesButton", true)			-- Manage frames
		LeaPlusLC:LockOption("ShowPlayerChain", "ModPlayerChain", true)			-- Show player chain
		LeaPlusLC:LockOption("ViewPortEnable", "ModViewportBtn", true)			-- Enable viewport
	end

----------------------------------------------------------------------
--	L03: Restarts
----------------------------------------------------------------------

	-- Set the reload button state
	function LeaPlusLC:ReloadCheck()

		-- Chat
		if	(LeaPlusLC["UseEasyChatResizing"]	~= LeaPlusDB["UseEasyChatResizing"])	-- Use easy resizing
		or	(LeaPlusLC["NoCombatLogTab"]		~= LeaPlusDB["NoCombatLogTab"])			-- Hide the combat log
		or	(LeaPlusLC["NoChatButtons"]			~= LeaPlusDB["NoChatButtons"])			-- Hide chat buttons
		or	(LeaPlusLC["UnclampChat"]			~= LeaPlusDB["UnclampChat"])			-- Unclamp chat frame
		or	(LeaPlusLC["MoveChatEditBoxToTop"]	~= LeaPlusDB["MoveChatEditBoxToTop"])	-- Move editbox to top
		or	(LeaPlusLC["NoStickyChat"]			~= LeaPlusDB["NoStickyChat"])			-- Disable sticky chat
		or	(LeaPlusLC["UseArrowKeysInChat"]	~= LeaPlusDB["UseArrowKeysInChat"])		-- Use arrow keys in chat
		or	(LeaPlusLC["NoChatFade"]			~= LeaPlusDB["NoChatFade"])				-- Disable chat fade
		or	(LeaPlusLC["RecentChatWindow"]		~= LeaPlusDB["RecentChatWindow"])		-- Recent chat window
		or	(LeaPlusLC["MaxChatHstory"]			~= LeaPlusDB["MaxChatHstory"])			-- Increase chat history

		-- Text
		or	(LeaPlusLC["HideErrorMessages"]		~= LeaPlusDB["HideErrorMessages"])		-- Hide error messages
		or	(LeaPlusLC["NoHitIndicators"]		~= LeaPlusDB["NoHitIndicators"])		-- Hide portrait text
		or	(LeaPlusLC["HideZoneText"]			~= LeaPlusDB["HideZoneText"])			-- Hide zone text
		or	(LeaPlusLC["MailFontChange"]		~= LeaPlusDB["MailFontChange"])			-- Resize mail text
		or	(LeaPlusLC["QuestFontChange"]		~= LeaPlusDB["QuestFontChange"])		-- Resize quest text

		-- Interface
		or	(LeaPlusLC["MinimapMod"]			~= LeaPlusDB["MinimapMod"])				-- Customise minimap
		or	(LeaPlusLC["TipModEnable"]			~= LeaPlusDB["TipModEnable"])			-- Manage tooltip
		or	(LeaPlusLC["EnhanceDressup"]		~= LeaPlusDB["EnhanceDressup"])			-- Enhance dressup
		or	(LeaPlusLC["ShowVolume"]			~= LeaPlusDB["ShowVolume"])				-- Show volume slider
		or	(LeaPlusLC["AhExtras"]				~= LeaPlusDB["AhExtras"])				-- Show auction controls
		or	(LeaPlusLC["ShowCooldowns"]			~= LeaPlusDB["ShowCooldowns"])			-- Show cooldowns
		or	(LeaPlusLC["DurabilityStatus"]		~= LeaPlusDB["DurabilityStatus"])		-- Show durability status
		or	(LeaPlusLC["ShowVanityControls"]	~= LeaPlusDB["ShowVanityControls"])		-- Show vanity controls
		or	(LeaPlusLC["ShowWowheadLinks"]		~= LeaPlusDB["ShowWowheadLinks"])		-- Show Wowhead links

		-- Frames
		or	(LeaPlusLC["FrmEnabled"]			~= LeaPlusDB["FrmEnabled"])				-- Manage frames
		or	(LeaPlusLC["ClassColFrames"]		~= LeaPlusDB["ClassColFrames"])			-- Class colored frames
		or	(LeaPlusLC["ShowPlayerChain"]		~= LeaPlusDB["ShowPlayerChain"])		-- Show player chain
		or	(LeaPlusLC["ShowRaidToggle"]		~= LeaPlusDB["ShowRaidToggle"])			-- Show raid toggle button
		or	(LeaPlusLC["CombatPlates"]			~= LeaPlusDB["CombatPlates"])			-- Combat plates
		or	(LeaPlusLC["NoGryphons"]			~= LeaPlusDB["NoGryphons"])				-- Hide gryphons
		or	(LeaPlusLC["NoClassBar"]			~= LeaPlusDB["NoClassBar"])				-- Hide stance bar

		-- System
		or	(LeaPlusLC["ViewPortEnable"]		~= LeaPlusDB["ViewPortEnable"])			-- Enable viewport
		or	(LeaPlusLC["NoRestedEmotes"]		~= LeaPlusDB["NoRestedEmotes"])			-- Silence rested emotes
		or	(LeaPlusLC["NoBagAutomation"]		~= LeaPlusDB["NoBagAutomation"])		-- Disable bag automation
		or	(LeaPlusLC["CharAddonList"]			~= LeaPlusDB["CharAddonList"])			-- Show character addons
		or	(LeaPlusLC["FasterLooting"]			~= LeaPlusDB["FasterLooting"])			-- Faster auto loot
		or	(LeaPlusLC["FasterMovieSkip"]		~= LeaPlusDB["FasterMovieSkip"])		-- Faster movie skip
		or	(LeaPlusLC["StandAndDismount"]		~= LeaPlusDB["StandAndDismount"])		-- Stand and dismount
		or	(LeaPlusLC["ShowVendorPrice"]		~= LeaPlusDB["ShowVendorPrice"])		-- Show vendor price

		-- Settings
		or	(LeaPlusLC["EnableHotkey"]			~= LeaPlusDB["EnableHotkey"])			-- Enable hotkey

		then
			-- Enable the reload button
			LeaPlusLC:LockItem(LeaPlusCB["ReloadUIButton"], false)
			LeaPlusCB["ReloadUIButton"].f:Show()
		else
			-- Disable the reload button
			LeaPlusLC:LockItem(LeaPlusCB["ReloadUIButton"], true)
			LeaPlusCB["ReloadUIButton"].f:Hide()
		end

	end

----------------------------------------------------------------------
--	L20: Live
----------------------------------------------------------------------

	function LeaPlusLC:Live()

		----------------------------------------------------------------------
		--	Invite from whispers
		----------------------------------------------------------------------

		if LeaPlusLC["InviteFromWhisper"] == "On" then
			LpEvt:RegisterEvent("CHAT_MSG_WHISPER");
			LpEvt:RegisterEvent("CHAT_MSG_BN_WHISPER");
		else
			LpEvt:UnregisterEvent("CHAT_MSG_WHISPER");
			LpEvt:UnregisterEvent("CHAT_MSG_BN_WHISPER");
		end

		----------------------------------------------------------------------
		--	Block duels
		----------------------------------------------------------------------

		if LeaPlusLC["NoDuelRequests"] == "On" then
			LpEvt:RegisterEvent("DUEL_REQUESTED");
		else
			LpEvt:UnregisterEvent("DUEL_REQUESTED");
		end

		----------------------------------------------------------------------
		--	Block party invites and Party from friends
		----------------------------------------------------------------------

		if LeaPlusLC["NoPartyInvites"] == "On" or LeaPlusLC["AcceptPartyFriends"] == "On" then
			LpEvt:RegisterEvent("PARTY_INVITE_REQUEST");
		else
			LpEvt:UnregisterEvent("PARTY_INVITE_REQUEST");
		end

		----------------------------------------------------------------------
		--	Release in PvP
		----------------------------------------------------------------------

		if LeaPlusLC["AutoReleasePvP"] == "On" then
			LpEvt:RegisterEvent("PLAYER_DEAD");
		else
			LpEvt:UnregisterEvent("PLAYER_DEAD");
		end

		----------------------------------------------------------------------
		--	Accept resurrection
		----------------------------------------------------------------------

		if LeaPlusLC["AutoAcceptRes"] == "On" then
			LpEvt:RegisterEvent("RESURRECT_REQUEST");
		else
			LpEvt:UnregisterEvent("RESURRECT_REQUEST");
		end

		----------------------------------------------------------------------
		--	Automatic summon
		----------------------------------------------------------------------

		if LeaPlusLC["AutoAcceptSummon"] == "On" then
			LpEvt:RegisterEvent("CONFIRM_SUMMON");
		else
			LpEvt:UnregisterEvent("CONFIRM_SUMMON");
		end

		----------------------------------------------------------------------
		--	Disable loot warnings
		----------------------------------------------------------------------

		if LeaPlusLC["NoConfirmLoot"] == "On" then
			LpEvt:RegisterEvent("CONFIRM_LOOT_ROLL")
			LpEvt:RegisterEvent("LOOT_BIND_CONFIRM")
			LpEvt:RegisterEvent("MERCHANT_CONFIRM_TRADE_TIMER_REMOVAL")
			LpEvt:RegisterEvent("MAIL_LOCK_SEND_ITEMS")
		else
			LpEvt:UnregisterEvent("CONFIRM_LOOT_ROLL")
			LpEvt:UnregisterEvent("LOOT_BIND_CONFIRM")
			LpEvt:UnregisterEvent("MERCHANT_CONFIRM_TRADE_TIMER_REMOVAL")
			LpEvt:UnregisterEvent("MAIL_LOCK_SEND_ITEMS")
		end

	end

----------------------------------------------------------------------
--	L30: Isolated
----------------------------------------------------------------------

	function LeaPlusLC:Isolated()

		----------------------------------------------------------------------
		-- Faster movie skip
		----------------------------------------------------------------------

		if LeaPlusLC["FasterMovieSkip"] == "On" then

			-- Allow space bar, escape key and enter key to cancel cinematic without confirmation
			CinematicFrame:HookScript("OnKeyDown", function(self, key)
				if key == "ESCAPE" then
					if CinematicFrame:IsShown() and CinematicFrame.closeDialog and CinematicFrameCloseDialogConfirmButton then
						CinematicFrameCloseDialog:Hide()
					end
				end
			end)
			CinematicFrame:HookScript("OnKeyUp", function(self, key)
				if key == "SPACE" or key == "ESCAPE" or key == "ENTER" then
					if CinematicFrame:IsShown() and CinematicFrame.closeDialog and CinematicFrameCloseDialogConfirmButton then
						CinematicFrameCloseDialogConfirmButton:Click()
					end
				end
			end)
			MovieFrame:HookScript("OnKeyUp", function(self, key)
				if key == "SPACE" or key == "ESCAPE" or key == "ENTER" then
					if MovieFrame:IsShown() and MovieFrame.CloseDialog and MovieFrame.CloseDialog.ConfirmButton then
						MovieFrame.CloseDialog.ConfirmButton:Click()
					end
				end
			end)

		end

		----------------------------------------------------------------------
		-- Unclamp chat frame
		----------------------------------------------------------------------

		if LeaPlusLC["UnclampChat"] == "On" then

			-- Process normal and existing chat frames on startup
			for i = 1, 50 do
				if _G["ChatFrame" .. i] then 
					_G["ChatFrame" .. i]:SetClampRectInsets(0, 0, 0, 0);
				end
			end

			-- Process new chat frames and combat log
			hooksecurefunc("FloatingChatFrame_UpdateBackgroundAnchors", function(self)
				self:SetClampRectInsets(0, 0, 0, 0);
			end)

			-- Process temporary chat frames
			hooksecurefunc("FCF_OpenTemporaryWindow", function()
				local cf = FCF_GetCurrentChatFrame():GetName() or nil
				if cf then
					_G[cf]:SetClampRectInsets(0, 0, 0, 0);
				end
			end)

		end

		----------------------------------------------------------------------
		-- Wowhead Links
		----------------------------------------------------------------------

		if LeaPlusLC["ShowWowheadLinks"] == "On" then

			-- Get localised Wowhead URL
			local wowheadLoc
			if GameLocale == "deDE" then wowheadLoc = "de.classic.wowhead.com"
			elseif GameLocale == "esMX" then wowheadLoc = "es.classic.wowhead.com"
			elseif GameLocale == "esES" then wowheadLoc = "es.classic.wowhead.com"
			elseif GameLocale == "frFR" then wowheadLoc = "fr.classic.wowhead.com"
			elseif GameLocale == "itIT" then wowheadLoc = "it.classic.wowhead.com"
			elseif GameLocale == "ptBR" then wowheadLoc = "pt.classic.wowhead.com"
			elseif GameLocale == "ruRU" then wowheadLoc = "ru.classic.wowhead.com"
			elseif GameLocale == "koKR" then wowheadLoc = "ko.classic.wowhead.com"
			elseif GameLocale == "zhCN" then wowheadLoc = "cn.classic.wowhead.com"
			elseif GameLocale == "zhTW" then wowheadLoc = "cn.classic.wowhead.com"
			else							 wowheadLoc = "classic.wowhead.com"
			end

			-- Create editbox
			local mEB = CreateFrame("EditBox", nil, QuestLogFrame)
			mEB:ClearAllPoints()
			mEB:SetPoint("TOPLEFT", 70, 4)
			mEB:SetHeight(16)
			mEB:SetFontObject("GameFontNormal")
			mEB:SetBlinkSpeed(0)
			mEB:SetAutoFocus(false)
			mEB:EnableKeyboard(false)
			mEB:SetHitRectInsets(0, 90, 0, 0)
			mEB:SetScript("OnKeyDown", function() end)
			mEB:SetScript("OnMouseUp", function()
				if mEB:IsMouseOver() then 
					mEB:HighlightText()
				else
					mEB:HighlightText(0, 0)
				end
			end)

			-- Set the background color
			mEB.t = mEB:CreateTexture(nil, "BACKGROUND")
			mEB.t:SetPoint(mEB:GetPoint())
			mEB.t:SetSize(mEB:GetSize())
			mEB.t:SetColorTexture(0.05, 0.05, 0.05, 1.0)

			-- Create hidden font string (used for setting width of editbox)
			mEB.z = mEB:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
			mEB.z:Hide()

			-- Function to set editbox value
			local function SetQuestInBox(questListID)

				local questTitle, void, void, isHeader, void, void, void, questID = GetQuestLogTitle(questListID)
				if questID and not isHeader then

					-- Hide editbox if quest ID is invalid
					if questID == 0 then mEB:Hide() else mEB:Show() end

					-- Set editbox text
					mEB:SetText("https://" .. wowheadLoc .. "/quest=" .. questID)

					-- Set hidden fontstring then resize editbox to match
					mEB.z:SetText(mEB:GetText())
					mEB:SetWidth(mEB.z:GetStringWidth() + 90)
					mEB.t:SetWidth(mEB.z:GetStringWidth())

					-- Get quest title for tooltip
					if questTitle then
						mEB.tiptext = questTitle .. "|n" .. L["Press CTRL/C to copy."]
					else
						mEB.tiptext = ""
						if mEB:IsMouseOver() and GameTooltip:IsShown() then GameTooltip:Hide() end
					end

				end
			end

			-- Set URL when quest is selected
			hooksecurefunc("QuestLog_SetSelection", function(questListID)
				SetQuestInBox(questListID)
			end)

			-- Create tooltip
			mEB:HookScript("OnEnter", function()
				mEB:HighlightText()
				mEB:SetFocus()
				GameTooltip:SetOwner(mEB, "ANCHOR_BOTTOM", 0, -10)
				GameTooltip:SetText(mEB.tiptext, nil, nil, nil, nil, true)
				GameTooltip:Show()
			end)

			mEB:HookScript("OnLeave", function()
				mEB:HighlightText(0, 0)
				mEB:ClearFocus()
				GameTooltip:Hide()
			end)

		end

		----------------------------------------------------------------------
		-- Enhance dressup
		----------------------------------------------------------------------

		if LeaPlusLC["EnhanceDressup"] == "On" then

			----------------------------------------------------------------------
			-- Nude and tabard buttons
			----------------------------------------------------------------------

			-- Add buttons to main dressup frames
			LeaPlusLC:CreateButton("DressUpNudeBtn", DressUpFrame, "Nude", "BOTTOMLEFT", 106, 79, 80, 22, false, "")
			LeaPlusCB["DressUpNudeBtn"]:SetFrameLevel(3)
			LeaPlusCB["DressUpNudeBtn"]:ClearAllPoints()
			LeaPlusCB["DressUpNudeBtn"]:SetPoint("RIGHT", DressUpFrameResetButton, "LEFT", 0, 0)
			LeaPlusCB["DressUpNudeBtn"]:SetScript("OnClick", function()
				DressUpFrameResetButton:Click() -- Done first in case any slots refuse to clear
				DressUpFrame.DressUpModel:Undress()
			end)

			LeaPlusLC:CreateButton("DressUpTabBtn", DressUpFrame, "Tabard", "BOTTOMLEFT", 26, 79, 80, 22, false, "")
			LeaPlusCB["DressUpTabBtn"]:SetFrameLevel(3)
			LeaPlusCB["DressUpTabBtn"]:ClearAllPoints()
			LeaPlusCB["DressUpTabBtn"]:SetPoint("RIGHT", LeaPlusCB["DressUpNudeBtn"], "LEFT", 0, 0)
			LeaPlusCB["DressUpTabBtn"]:SetScript("OnClick", function()
				DressUpFrame.DressUpModel:UndressSlot(19)
			end)

			-- Only show dressup buttons if its a player (reset button will show too)
			hooksecurefunc(DressUpFrameResetButton, "Show", function()
				LeaPlusCB["DressUpNudeBtn"]:Show()
				LeaPlusCB["DressUpTabBtn"]:Show()
			end)

			hooksecurefunc(DressUpFrameResetButton, "Hide", function()
				LeaPlusCB["DressUpNudeBtn"]:Hide()
				LeaPlusCB["DressUpTabBtn"]:Hide()
			end)

			local BtnStrata, BtnLevel = SideDressUpModelResetButton:GetFrameStrata(), SideDressUpModelResetButton:GetFrameLevel()

			-- Add buttons to auction house dressup frame
			LeaPlusLC:CreateButton("DressUpSideBtn", SideDressUpFrame, "Tabard", "BOTTOMLEFT", 14, 20, 60, 22, false, "")
			LeaPlusCB["DressUpSideBtn"]:SetFrameStrata(BtnStrata);
			LeaPlusCB["DressUpSideBtn"]:SetFrameLevel(BtnLevel);
			LeaPlusCB["DressUpSideBtn"]:SetScript("OnClick", function()
				SideDressUpModel:UndressSlot(19)
			end)

			LeaPlusLC:CreateButton("DressUpSideNudeBtn", SideDressUpFrame, "Nude", "BOTTOMRIGHT", -18, 20, 60, 22, false, "")
			LeaPlusCB["DressUpSideNudeBtn"]:SetFrameStrata(BtnStrata);
			LeaPlusCB["DressUpSideNudeBtn"]:SetFrameLevel(BtnLevel);
			LeaPlusCB["DressUpSideNudeBtn"]:SetScript("OnClick", function()
				SideDressUpModelResetButton:Click() -- Done first in case any slots refuse to clear
				for i = 1, 19 do
					SideDressUpModel:UndressSlot(i) -- Done this way to prevent issues with Undress
				end
			end)

			-- Only show side dressup buttons if its a player (reset button will show too)
			hooksecurefunc(SideDressUpModelResetButton, "Show", function()
				LeaPlusCB["DressUpSideBtn"]:Show()
				LeaPlusCB["DressUpSideNudeBtn"]:Show()
			end)

			hooksecurefunc(SideDressUpModelResetButton, "Hide", function()
				LeaPlusCB["DressUpSideBtn"]:Hide()
				LeaPlusCB["DressUpSideNudeBtn"]:Hide()
			end)

			----------------------------------------------------------------------
			-- Controls
			----------------------------------------------------------------------

			-- Hide model rotation controls
			CharacterModelFrameRotateLeftButton:HookScript("OnShow", CharacterModelFrameRotateLeftButton.Hide)
			CharacterModelFrameRotateRightButton:HookScript("OnShow", CharacterModelFrameRotateRightButton.Hide)
			DressUpModelFrameRotateLeftButton:HookScript("OnShow", DressUpModelFrameRotateLeftButton.Hide)
			DressUpModelFrameRotateRightButton:HookScript("OnShow", DressUpModelFrameRotateRightButton.Hide)
			SideDressUpModelControlFrame:HookScript("OnShow", SideDressUpModelControlFrame.Hide)

			----------------------------------------------------------------------
			-- Inspect system
			----------------------------------------------------------------------

			-- Inspect System
			local function DoInspectSystemFunc()
				-- Hide model rotation controls
				InspectModelFrameRotateLeftButton:Hide()
				InspectModelFrameRotateRightButton:Hide()
			end

			if IsAddOnLoaded("Blizzard_InspectUI") then
				DoInspectSystemFunc()
			else
				local waitFrame = CreateFrame("FRAME")
				waitFrame:RegisterEvent("ADDON_LOADED")
				waitFrame:SetScript("OnEvent", function(self, event, arg1)
					if arg1 == "Blizzard_InspectUI" then
						DoInspectSystemFunc()
						waitFrame:UnregisterAllEvents()
					end
				end)
			end

		end

		----------------------------------------------------------------------
		-- Automate gossip (no reload required)
		----------------------------------------------------------------------

		do

			-- Function to skip gossip
			local function SkipGossip()
				if IsShiftKeyDown() then return end
				local void, gossipType = GetGossipOptions()
				if gossipType then
					-- Completely automate gossip
					if gossipType == "banker"
					or gossipType == "taxi"
					or gossipType == "trainer"
					or gossipType == "vendor"
					then
						SelectGossipOption(1)
					end
					-- Automate gossip with ALT key
					if IsAltKeyDown() then
						if gossipType == "gossip"
						then
							SelectGossipOption(1)
						end
					end
				end
			end

			-- Create gossip event frame
			local gossipFrame = CreateFrame("FRAME")

			-- Function to setup events
			local function SetupEvents()
				if LeaPlusLC["AutomateGossip"] == "On" then
					gossipFrame:RegisterEvent("GOSSIP_SHOW")
				else
					gossipFrame:UnregisterEvent("GOSSIP_SHOW")
				end
			end

			-- Setup events when option is clicked and on startup (if option is enabled)
			LeaPlusCB["AutomateGossip"]:HookScript("OnClick", SetupEvents)
			if LeaPlusLC["AutomateGossip"] == "On" then SetupEvents() end

			-- Event handler
			gossipFrame:SetScript("OnEvent", function()
				-- Special treatment for specific NPCs
				local npcGuid = UnitGUID("target") or nil
				if npcGuid then
					local void, void, void, void, void, npcID = strsplit("-", npcGuid)
					if npcID then
						if npcID == "9999999999" -- Reserved for future use
						then
							SkipGossip()
							return
						end
					end
				end

				-- Process gossip
				if GetNumGossipOptions() == 1 and GetNumGossipAvailableQuests() == 0 and GetNumGossipActiveQuests() == 0 then
					SkipGossip()
				end
			end)

		end

		----------------------------------------------------------------------
		--	Enable hotkey
		----------------------------------------------------------------------

		if LeaPlusLC["EnableHotkey"] == "On" then

			-- Create global binding function
			local BindBtn = CreateFrame("Button", "LeaPlusGlobalBinding", LeaPlusGlobalPanel)
			BindBtn:SetScript("OnClick", function() LeaPlusLC:SlashFunc() end)

			-- Clear all bindings bound to panel and set hotkey
			ClearOverrideBindings(LeaPlusGlobalPanel)
			SetOverrideBindingClick(LeaPlusGlobalPanel, true, "CTRL-Z", "LeaPlusGlobalBinding")

		end

		----------------------------------------------------------------------
		--	Faster looting
		----------------------------------------------------------------------

		if LeaPlusLC["FasterLooting"] == "On" then

			-- Time delay
			local tDelay = 0

			-- Fast loot function
			local function FastLoot()
				if GetTime() - tDelay >= 0.3 then
					tDelay = GetTime()
 					if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
						for i = GetNumLootItems(), 1, -1 do
							LootSlot(i)
						end
						tDelay = GetTime()
					end
				end
			end

			-- Event frame
			local faster = CreateFrame("Frame")
			faster:RegisterEvent("LOOT_READY")
			faster:SetScript("OnEvent", FastLoot)

		end

		----------------------------------------------------------------------
		--	Disable bag automation
		----------------------------------------------------------------------

		if LeaPlusLC["NoBagAutomation"] == "On" then
			RunScript("hooksecurefunc('OpenAllBags', CloseAllBags)")
		end

		----------------------------------------------------------------------
		--	Automate quests (no reload required)
		----------------------------------------------------------------------

		do

			-- Funcion to ignore specific NPCs
			local function isNpcBlocked(actionType)
				local npcGuid = UnitGUID("target") or nil
				if npcGuid then
					local void, void, void, void, void, npcID = strsplit("-", npcGuid)
					if npcID then
						-- Ignore specific NPCs for selecting, accepting and turning-in quests (required if automation has consequences)
						if npcID == "15192"	-- Anachronos (Caverns of Time)
						or npcID == "3430" 	-- Mangletooth (Blood Shard quests, Barrens)
						then
							return true
						end
						-- Ignore specific NPCs for selecting quests only (only used for items that have no other purpose)
						if actionType == "Select" then
							if npcID == "12944" -- Lokhtos Darkbargainer (Thorium Brotherhood, Blackrock Depths)
							-- Ahn'Qiraj War Effort (Alliance, Ironforge)
							or npcID == "15446" -- Bonnie Stoneflayer (Light Leather Collector)
							or npcID == "15458" -- Commander Stronghammer (Alliance Ambassador)
							or npcID == "15431" -- Corporal Carnes (Iron Bar Collector)
							or npcID == "15432" -- Dame Twinbraid (Thorium Bar Collector)
							or npcID == "15453" -- Keeper Moonshade (Runecloth Bandage Collector)
							or npcID == "15457" -- Huntress Swiftriver (Spotted Yellowtail Collector)
							or npcID == "15450" -- Marta Finespindle (Thick Leather Collector)
							or npcID == "15437" -- Master Nightsong (Purple Lotus Collector)
							or npcID == "15452" -- Nurse Stonefield (Silk Bandage Collector)
							or npcID == "15434" -- Private Draxlegauge (Stranglekelp Collector)
							or npcID == "15448" -- Private Porter (Medium Leather Collector)
							or npcID == "15456" -- Sarah Sadwhistle (Roast Raptor Collector)
							or npcID == "15451" -- Sentinel Silversky (Linen Bandage Collector)
							or npcID == "15445" -- Sergeant Major Germaine (Arthas' Tears Collector)
							or npcID == "15383" -- Sergeant Stonebrow (Copper Bar Collector)
							or npcID == "15455" -- Slicky Gastronome (Rainbow Fin Albacore Collector)
							-- Ahn'Qiraj War Effort (Horde, Orgrimmar)
							or npcID == "15512" -- Apothecary Jezel (Purple Lotus Collector)
							or npcID == "15508" -- Batrider Pele'keiki (Firebloom Collector)
							or npcID == "15533" -- Bloodguard Rawtar (Lean Wolf Steak Collector)
							or npcID == "15535" -- Chief Sharpclaw (Baked Salmon Collector)
							or npcID == "15525" -- Doctor Serratus (Rugged Leather Collector)
							or npcID == "15534" -- Fisherman Lin'do (Spotted Yellowtail Collector)
							or npcID == "15539" -- General Zog (Horde Ambassador)
							or npcID == "15460" -- Grunt Maug (Tin Bar Collector)
							or npcID == "15528" -- Healer Longrunner (Wool Bandage Collector)
							or npcID == "15477" -- Herbalist Proudfeather (Peacebloom Collector)
							or npcID == "15529" -- Lady Callow (Mageweave Bandage Collector)
							or npcID == "15459" -- Miner Cromwell (Copper Bar Collector)
							or npcID == "15469" -- Senior Sergeant T'kelah (Mithril Bar Collector)
							or npcID == "15522" -- Sergeant Umala (Thick Leather Collector)
							or npcID == "15515" -- Skinner Jamani (Heavy Leather Collector)
							or npcID == "15532" -- Stoneguard Clayhoof (Runecloth Bandage Collector)
							-- Alliance Cloth Quartermasters
							or npcID == "14724" -- Bubulo Acerbus (Ironforge)
							or npcID == "14722" -- Clavicus Knavingham (Stormwind)
							or npcID == "14723" -- Mistina Steelshield (Ironforge)
							or npcID == "14725" -- Raedon Duskstriker (Darnassus)
							-- Horde Cloth Quartermasters
							or npcID == "14729" -- Ralston Farnsley (Undercity)
							or npcID == "14728" -- Rumstag Proudstrider (Thunder Bluff)
							or npcID == "14726" -- Rashona Straglash (Orgrimmar)
							or npcID == "14727" -- Vehena (Orgrimmar)
							-- Alliance Commendations
							or npcID == "15764" -- Officer Ironbeard (Ironforge Commendations)
							or npcID == "15762" -- Officer Lunalight (Darnassus Commendations)
							or npcID == "15766" -- Officer Maloof (Stormwind Commendations)
							or npcID == "15763" -- Officer Porterhouse (Gnomeregan Commendations)
							-- Horde Commendations
							or npcID == "15768" -- Officer Gothena (Undercity Commendations)
							or npcID == "15765" -- Officer Redblade (Orgrimmar Commendations)
							or npcID == "15767" -- Officer Thunderstrider (Thunder Bluff Commendations)
							or npcID == "15761" -- Officer Vu'Shalay (Darkspear Commendations)
							then
								return true
							end
						end
					end
				end
			end

			-- Function to check if quest requires a blocked item
			local function QuestRequiresBlockedItem()
				for i = 1, 6 do
					local progItem = _G["QuestProgressItem" ..i] or nil
					if progItem and progItem:IsShown() and progItem.type == "required" then
						if progItem.objectType == "item" then
							local name, texture, numItems = GetQuestItemInfo("required", i)
							if name then
								local itemID = GetItemInfoInstant(name)
								if itemID then
									if itemID == 9999999999 then -- Reserved for future use
										return true
									end
								end
							end
						end
					end
				end
			end

			-- Function to check if quest requires gold
			local function QuestRequiresGold()
				local goldRequiredAmount = GetQuestMoneyToGet()
				if goldRequiredAmount and goldRequiredAmount > 0 then
					return true
				end
			end

			-- Create event frame
			local qFrame = CreateFrame("FRAME")

			-- Function to setup events
			local function SetupEvents()
				if LeaPlusLC["AutomateQuests"] == "On" then
					qFrame:RegisterEvent("QUEST_DETAIL")
					qFrame:RegisterEvent("QUEST_ACCEPT_CONFIRM")
					qFrame:RegisterEvent("QUEST_PROGRESS")
					qFrame:RegisterEvent("QUEST_COMPLETE")
					qFrame:RegisterEvent("QUEST_GREETING")
					qFrame:RegisterEvent("QUEST_AUTOCOMPLETE")
					qFrame:RegisterEvent("GOSSIP_SHOW")
					qFrame:RegisterEvent("QUEST_FINISHED")
				else
					qFrame:UnregisterAllEvents()
				end
			end

			-- Setup events when option is clicked and on startup (if option is enabled)
			LeaPlusCB["AutomateQuests"]:HookScript("OnClick", SetupEvents)
			if LeaPlusLC["AutomateQuests"] == "On" then SetupEvents() end

			-- Event handler
			qFrame:SetScript("OnEvent", function(self, event, arg1)

				-- Clear progress items when quest interaction has ceased
				if event == "QUEST_FINISHED" then
					for i = 1, 6 do
						local progItem = _G["QuestProgressItem" ..i] or nil
						if progItem and progItem:IsShown() then
							progItem:Hide()
						end
					end
					return
				end

				-- Do nothing if SHIFT key is being held
				if IsShiftKeyDown() then return end

				----------------------------------------------------------------------
				-- Accept quests automatically
				----------------------------------------------------------------------

				-- Accept quests with a quest detail window
				if event == "QUEST_DETAIL" then
					-- Don't accept blocked quests
					if isNpcBlocked("Accept") then return end
					-- Accept quest
					AcceptQuest()
					HideUIPanel(QuestFrame)
				end

				-- Accept quests which require confirmation (such as sharing escort quests)
				if event == "QUEST_ACCEPT_CONFIRM" then
					ConfirmAcceptQuest() 
					StaticPopup_Hide("QUEST_ACCEPT")
				end

				----------------------------------------------------------------------
				-- Turn-in quests automatically
				----------------------------------------------------------------------

				-- Turn-in progression quests
				if event == "QUEST_PROGRESS" and IsQuestCompletable() then
					-- Don't continue quests for blocked NPCs
					if isNpcBlocked("Complete") then return end
					-- Don't continue if quest requires blocked item
					if QuestRequiresBlockedItem() then return end
					-- Don't continue if quest requires gold
					if QuestRequiresGold() then return end
					-- Continue quest
					CompleteQuest()
				end

				-- Turn in completed quests if only one reward item is being offered
				if event == "QUEST_COMPLETE" then
					-- Don't complete quests for blocked NPCs
					if isNpcBlocked("Complete") then return end
					-- Don't complete if quest requires blocked item
					if QuestRequiresBlockedItem() then return end
					-- Don't complete if quest requires gold
					if QuestRequiresGold() then return end
					-- Complete quest
					if GetNumQuestChoices() <= 1 then
						GetQuestReward(GetNumQuestChoices())
					end
				end

				-- Show quest dialog for quests that use the objective tracker (it will be completed automatically)
				if event == "QUEST_AUTOCOMPLETE" then
					local index = GetQuestLogIndexByID(arg1)
					if GetQuestLogIsAutoComplete(index) then
						ShowQuestComplete(index)
					end
				end

				----------------------------------------------------------------------
				-- Select quests automatically
				----------------------------------------------------------------------

				if event == "GOSSIP_SHOW" or event == "QUEST_GREETING" then

					-- Select quests
					if UnitExists("npc") or QuestFrameGreetingPanel:IsShown() or GossipFrameGreetingPanel:IsShown() then

						-- Don't select quests for blocked NPCs
						if isNpcBlocked("Select") then return end

						-- Select quests
						if event == "QUEST_GREETING" then
							-- Select quest greeting completed quests
							for i = 1, GetNumActiveQuests() do
								local title, isComplete = GetActiveTitle(i)
								if title and isComplete then
									return SelectActiveQuest(i)
								end
							end
							-- Select quest greeting available quests
							for i = 1, GetNumAvailableQuests() do
								local title, isComplete = GetAvailableTitle(i)
								if title and not isComplete then
									return SelectAvailableQuest(i)
								end
							end
						else
							-- Select gossip completed quests
							for i = 1, GetNumGossipActiveQuests() do
								local title, level, isTrivial, isComplete, isLegendary, isIgnored = select(i * 6 - 5, GetGossipActiveQuests())
								if title and isComplete then
									return SelectGossipActiveQuest(i)
								end
							end
							-- Select gossip available quests
							for i = 1, GetNumGossipAvailableQuests() do
								local title, level, isTrivial, isDaily, isRepeatable, isLegendary, isIgnored = select(i * 7 - 6, GetGossipAvailableQuests())
								if title then
									return SelectGossipAvailableQuest(i)
								end
							end
						end
					end
				end

			end)

		end

		----------------------------------------------------------------------
		--	Sort game options addon list
		----------------------------------------------------------------------

		if LeaPlusLC["CharAddonList"] == "On" then
			-- Set the addon list to character by default
			if AddonCharacterDropDown and AddonCharacterDropDown.selectedValue then
				AddonCharacterDropDown.selectedValue = UnitName("player");
				AddonCharacterDropDownText:SetText(UnitName("player"))
			end
		end

		----------------------------------------------------------------------
		--	Sell junk automatically (no reload required)
		----------------------------------------------------------------------

		do

			-- Create sell junk banner
			local StartMsg = CreateFrame("FRAME", nil, MerchantFrame)
			StartMsg:ClearAllPoints()
			StartMsg:SetPoint("BOTTOMLEFT", 4, 4)
			StartMsg:SetSize(160, 22)
			StartMsg:SetToplevel(true)
			StartMsg:Hide()

			StartMsg.s = StartMsg:CreateTexture(nil, "BACKGROUND")
			StartMsg.s:SetAllPoints()
			StartMsg.s:SetColorTexture(0.1, 0.1, 0.1, 1.0)

			StartMsg.f = StartMsg:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge") 
			StartMsg.f:SetAllPoints();
			StartMsg.f:SetText(L["SELLING JUNK"])

			-- Declarations
			local IterationCount, totalPrice = 500, 0
			local SellJunkFrame = CreateFrame("FRAME")
			local SellJunkTicker, mBagID, mBagSlot

			-- Function to stop selling
			local function StopSelling()
				if SellJunkTicker then SellJunkTicker:Cancel() end
				StartMsg:Hide()
				SellJunkFrame:UnregisterEvent("ITEM_LOCKED")
				SellJunkFrame:UnregisterEvent("ITEM_UNLOCKED")
			end

			-- Vendor function
			local function SellJunkFunc()

				-- Variables
				local SoldCount, Rarity, ItemPrice = 0, 0, 0
				local CurrentItemLink, void

				-- Traverse bags and sell grey items
				for BagID = 0, 4 do
					for BagSlot = 1, GetContainerNumSlots(BagID) do
						CurrentItemLink = GetContainerItemLink(BagID, BagSlot)
						if CurrentItemLink then
							void, void, Rarity, void, void, void, void, void, void, void, ItemPrice = GetItemInfo(CurrentItemLink)
							local void, itemCount = GetContainerItemInfo(BagID, BagSlot)
							if Rarity == 0 and ItemPrice ~= 0 then
								SoldCount = SoldCount + 1
								if MerchantFrame:IsShown() then
									-- If merchant frame is open, vendor the item
									UseContainerItem(BagID, BagSlot)
									-- Perform actions on first iteration
									if SellJunkTicker._remainingIterations == IterationCount then
										-- Calculate total price
										totalPrice = totalPrice + (ItemPrice * itemCount)
										-- Store first sold bag slot for analysis
										if SoldCount == 1 then
											mBagID, mBagSlot = BagID, BagSlot
										end
									end
								else
									-- If merchant frame is not open, stop selling
									StopSelling()
									return
								end
							end
						end
					end
				end

				-- Stop selling if no items were sold for this iteration or iteration limit was reached
				if SoldCount == 0 or SellJunkTicker and SellJunkTicker._remainingIterations == 1 then 
					StopSelling() 
					if totalPrice > 0 then 
						LeaPlusLC:Print(L["Sold junk for"] .. " " .. GetCoinText(totalPrice) .. ".")
					end
				end

			end

			-- Function to setup events
			local function SetupEvents()
				if LeaPlusLC["AutoSellJunk"] == "On" then
					SellJunkFrame:RegisterEvent("MERCHANT_SHOW");
					SellJunkFrame:RegisterEvent("MERCHANT_CLOSED");
				else
					SellJunkFrame:UnregisterEvent("MERCHANT_SHOW")
					SellJunkFrame:UnregisterEvent("MERCHANT_CLOSED")
				end
			end

			-- Setup events when option is clicked and on startup (if option is enabled)
			LeaPlusCB["AutoSellJunk"]:HookScript("OnClick", SetupEvents)
			if LeaPlusLC["AutoSellJunk"] == "On" then SetupEvents() end

			-- Event handler
			SellJunkFrame:SetScript("OnEvent", function(self, event)
				if event == "MERCHANT_SHOW" then
					-- Reset variables
					totalPrice, mBagID, mBagSlot = 0, -1, -1
					-- Do nothing if shift key is held down
					if IsShiftKeyDown() then return end
					-- Cancel existing ticker if present
					if SellJunkTicker then SellJunkTicker:Cancel() end
					-- Sell grey items using ticker (ends when all grey items are sold or iteration count reached)
					SellJunkTicker = C_Timer.NewTicker(0.2, SellJunkFunc, IterationCount)
					SellJunkFrame:RegisterEvent("ITEM_LOCKED")
					SellJunkFrame:RegisterEvent("ITEM_UNLOCKED")
				elseif event == "ITEM_LOCKED" then
					StartMsg:Show()
					SellJunkFrame:UnregisterEvent("ITEM_LOCKED")
				elseif event == "ITEM_UNLOCKED" then
					SellJunkFrame:UnregisterEvent("ITEM_UNLOCKED")
					-- Check whether vendor refuses to buy items
					if mBagID and mBagSlot and mBagID ~= -1 and mBagSlot ~= -1 then
						local texture, count, locked = GetContainerItemInfo(mBagID, mBagSlot)
						if count and not locked then
							-- Item has been unlocked but still not sold so stop selling
							StopSelling()
						end
					end
				elseif event == "MERCHANT_CLOSED" then
					-- If merchant frame is closed, stop selling
					StopSelling()
				end
			end)

		end

		----------------------------------------------------------------------
		--	Repair automatically (no reload required)
		----------------------------------------------------------------------

		do

			-- Repair when suitable merchant frame is shown
			local function RepairFunc()
				if IsShiftKeyDown() then return end
				if CanMerchantRepair() then -- If merchant is capable of repair
					-- Process repair
					local RepairCost, CanRepair = GetRepairAllCost()
					if CanRepair then -- If merchant is offering repair
						if GetMoney() >= RepairCost then
							RepairAllItems()
							-- Show cost summary
							LeaPlusLC:Print(L["Repaired for"] .. " " .. GetCoinText(RepairCost) .. ".")
						end
					end
				end
			end

			-- Create event frame
			local RepairFrame = CreateFrame("FRAME")

			-- Function to setup event
			local function SetupEvent()
				if LeaPlusLC["AutoRepairGear"] == "On" then
					RepairFrame:RegisterEvent("MERCHANT_SHOW")
				else
					RepairFrame:UnregisterEvent("MERCHANT_SHOW")
				end
			end

			-- Setup event when option is clicked and on startup (if option is enabled)
			LeaPlusCB["AutoRepairGear"]:HookScript("OnClick", SetupEvent)
			if LeaPlusLC["AutoRepairGear"] == "On" then SetupEvent() end

			-- Event handler
			RepairFrame:SetScript("OnEvent", RepairFunc)

		end

		----------------------------------------------------------------------
		-- Hide the combat log
		----------------------------------------------------------------------

		if LeaPlusLC["NoCombatLogTab"] == "On" then
			-- Ensure combat log is docked
			if ChatFrame2.isDocked then
				-- Set combat log attributes when chat windows are updated
				LpEvt:RegisterEvent("UPDATE_CHAT_WINDOWS")
				-- Set combat log tab placement when tabs are assigned by the client
				hooksecurefunc("FCF_SetTabPosition", function()
					ChatFrame2Tab:SetPoint("BOTTOMLEFT", ChatFrame1Tab, "BOTTOMRIGHT", 0, 0)
				end)
			else
				-- If combat log is undocked, do nothing but show warning
				C_Timer.After(1, function()
					LeaPlusLC:Print("Combat log cannot be hidden while undocked.")
				end)
			end
		end

		----------------------------------------------------------------------
		--	Show player chain
		----------------------------------------------------------------------

		if LeaPlusLC["ShowPlayerChain"] == "On" then

			-- Create configuration panel
			local ChainPanel = LeaPlusLC:CreatePanel("Player Chain", "ChainPanel")

			-- Add dropdown menu
			LeaPlusLC:CreateDropDown("PlayerChainMenu", "Chain style", ChainPanel, 146, "TOPLEFT", 16, -112, {L["RARE"], L["ELITE"], L["RARE ELITE"]}, "")

			-- Set chain style
			local function SetChainStyle()
				-- Get dropdown menu value
				local chain = LeaPlusLC["PlayerChainMenu"] -- Numeric value
				-- Set chain style according to value
				if chain == 1 then -- Rare
					PlayerFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare.blp");
				elseif chain == 2 then -- Elite
					PlayerFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite.blp");
				elseif chain == 3 then -- Rare Elite
					PlayerFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite.blp");
				end
			end

			-- Set style on startup
			SetChainStyle()

			-- Set style when a drop menu is selected (procs when the list is hidden)
			LeaPlusCB["ListFramePlayerChainMenu"]:HookScript("OnHide", SetChainStyle)

			-- Help button hidden
			ChainPanel.h:Hide()

			-- Back button handler
			ChainPanel.b:SetScript("OnClick", function() 
				LeaPlusCB["ListFramePlayerChainMenu"]:Hide(); -- Hide the dropdown list
				ChainPanel:Hide();
				LeaPlusLC["PageF"]:Show();
				LeaPlusLC["Page6"]:Show();
				return
			end) 

			-- Reset button handler
			ChainPanel.r:SetScript("OnClick", function()
				LeaPlusCB["ListFramePlayerChainMenu"]:Hide(); -- Hide the dropdown list
				LeaPlusLC["PlayerChainMenu"] = 2
				ChainPanel:Hide(); ChainPanel:Show();
				SetChainStyle()
			end)

			-- Show the panel when the configuration button is clicked
			LeaPlusCB["ModPlayerChain"]:SetScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					LeaPlusLC["PlayerChainMenu"] = 3;
					SetChainStyle();
				else
					LeaPlusLC:HideFrames();
					ChainPanel:Show();
				end
			end)

		end

		----------------------------------------------------------------------
		-- Show raid frame toggle button
		----------------------------------------------------------------------

		if LeaPlusLC["ShowRaidToggle"] == "On" then

			-- Check to make sure raid toggle button exists
			if CompactRaidFrameManagerDisplayFrameHiddenModeToggle then

				-- Create a border for the button
				CompactRaidFrameManagerDisplayFrameHiddenModeToggle:SetBackdrop({ 
					edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
					tile = false, tileSize = 0, edgeSize = 16,
					insets = { left = 0, right = 0, top = 0, bottom = 0 }})

				-- Move the button (function runs after PLAYER_ENTERING_WORLD and PARTY_LEADER_CHANGED)
				hooksecurefunc("CompactRaidFrameManager_UpdateOptionsFlowContainer", function()
					if CompactRaidFrameManager and CompactRaidFrameManagerDisplayFrameHiddenModeToggle then
						local void, void, void, void, y = CompactRaidFrameManager:GetPoint()
						CompactRaidFrameManagerDisplayFrameHiddenModeToggle:SetWidth(40)
						CompactRaidFrameManagerDisplayFrameHiddenModeToggle:ClearAllPoints()
						CompactRaidFrameManagerDisplayFrameHiddenModeToggle:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, y + 22)
						CompactRaidFrameManagerDisplayFrameHiddenModeToggle:SetParent(UIParent)
					end
				end)

			end

		end

		----------------------------------------------------------------------
		-- Hide hit indicators (portrait text)
		----------------------------------------------------------------------

		if LeaPlusLC["NoHitIndicators"] == "On" then
			hooksecurefunc(PlayerHitIndicator, "Show", PlayerHitIndicator.Hide)
			hooksecurefunc(PetHitIndicator, "Show", PetHitIndicator.Hide)
		end

		----------------------------------------------------------------------
		-- Class colored frames
		----------------------------------------------------------------------

		if LeaPlusLC["ClassColFrames"] == "On" then

			-- Create background frame for player frame
			local PlayFN = CreateFrame("FRAME", nil, PlayerFrame)
			PlayFN:SetWidth(TargetFrameNameBackground:GetWidth())
			PlayFN:SetHeight(TargetFrameNameBackground:GetHeight())

			local void, void, void, x, y = TargetFrameNameBackground:GetPoint()
			PlayFN:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", -x, y)

			PlayFN.t = PlayFN:CreateTexture(nil, "BORDER")
			PlayFN.t:SetAllPoints()
			PlayFN.t:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-LevelBackground")

			local c = LeaPlusLC["RaidColors"][select(2, UnitClass("player"))]
			if c then PlayFN.t:SetVertexColor(c.r, c.g, c.b) end

			-- Create color function for target frame
			local function TargetFrameCol()
				if UnitIsPlayer("target") then
					local c = LeaPlusLC["RaidColors"][select(2, UnitClass("target"))]
					if c then TargetFrameNameBackground:SetVertexColor(c.r, c.g, c.b) end
				end
			end

			-- Set target frame on startup and when events fire
			local ColTar = CreateFrame("FRAME")
			ColTar:RegisterEvent("GROUP_ROSTER_UPDATE")
			ColTar:RegisterEvent("PLAYER_TARGET_CHANGED")
			ColTar:RegisterEvent("UNIT_FACTION")
			ColTar:SetScript("OnEvent", TargetFrameCol)
			TargetFrameCol()

		end

		----------------------------------------------------------------------
		-- Minimap customisation
		----------------------------------------------------------------------

		if LeaPlusLC["MinimapMod"] == "On" then

			----------------------------------------------------------------------
			-- Configuration panel
			----------------------------------------------------------------------

			-- Create configuration panel
			local SideMinimap = LeaPlusLC:CreatePanel("Minimap", "SideMinimap")

			-- Hide panel during combat
			SideMinimap:RegisterEvent("PLAYER_REGEN_DISABLED")
			SideMinimap:SetScript("OnEvent", SideMinimap.Hide)

			-- Add checkboxes
			LeaPlusLC:MakeTx(SideMinimap, "Settings", 16, -72)
			LeaPlusLC:MakeCB(SideMinimap, "HideZoneTextBar", "Hide the zone text bar", 16, -92, false, "If checked, the zone text bar will be hidden.  The tracking button tooltip will show zone information.")
			LeaPlusLC:MakeCB(SideMinimap, "HideMiniZoomBtns", "Hide the zoom buttons", 16, -112, false, "If checked, the zoom buttons will be hidden.  You can use the mousewheel to zoom regardless of this setting.")

			-- Add slider control
			LeaPlusLC:MakeTx(SideMinimap, "Scale", 356, -72)
			LeaPlusLC:MakeSL(SideMinimap, "MinimapScale", "Drag to set the minimap scale.|n|nNote that if you are using the default action bars, rescaling the minimap will also rescale the right action bars at startup so you may want to leave this at 100%.", 1, 2, 0.1, 356, -92, "%.2f")

			----------------------------------------------------------------------
			-- Hide the zone text bar
			----------------------------------------------------------------------

			-- Store Blizzard handler
			local zonta, zontp, zontr, zontx, zonty = MinimapZoneTextButton:GetPoint()

			-- Function to show zone tooltip
			local function ShowZoneTip(doNotShow)
				if LeaPlusLC["HideZoneTextBar"] == "On" then
					-- Show zone information in tooltip
					local zoneName = GetZoneText()
					local subzoneName = GetSubZoneText()
					if subzoneName == zoneName then	subzoneName = "" end
					-- Change the owner and position (needed for Minimap_SetTooltip)
					GameTooltip:SetOwner(MinimapZoneTextButton, "ANCHOR_LEFT")
					MinimapZoneTextButton:SetAllPoints(MiniMapTrackingButton)
					-- Show the tooltip
					local pvpType, isSubZonePvP, factionName = GetZonePVPInfo()
					Minimap_SetTooltip(pvpType, factionName)
					GameTooltip:Show()
					if doNotShow == true then GameTooltip:Hide() end
				else
					MinimapZoneTextButton:ClearAllPoints()
					MinimapZoneTextButton:SetPoint(zonta, zontp, zontr, zontx, zonty)
				end
			end

			-- Function to set the zone text bar position
			local function SetTitleBarPos()
				if OrderHallCommandBar then
					if OrderHallCommandBar:IsShown() then
						-- Order hall command bar is showing so move minimap cluster to top
						MinimapCluster:ClearAllPoints()
						MinimapCluster:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 0)
						if LeaPlusLC["HideZoneTextBar"] == "Off" then
							-- Zone text bar is showing so hide it as it will be behind the order hall command bar
							MinimapBorderTop:SetTexture("")
							MinimapZoneTextButton:Hide()
							MiniMapWorldMapButton:Hide()
						end
					else
						-- Order hall command bar is not showing
						if LeaPlusLC["HideZoneTextBar"] == "On" then
							-- Zone text bar is being hidden so move minimap cluster down below the order hall command bar
							MinimapCluster:ClearAllPoints()
							MinimapCluster:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 20)
						else
							-- Zone text bar is not being hidden so move order hall command bar to top
							MinimapCluster:ClearAllPoints()
							MinimapCluster:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 0)
							-- Show zone text bar
							MinimapZoneTextButton:Show()
							MiniMapWorldMapButton:Show()
							MinimapBorderTop:SetTexture("Interface\\Minimap\\UI-Minimap-Border")
						end
					end
				else
					-- Order hall command bar has not been loaded by the game yet
					if LeaPlusLC["HideZoneTextBar"] == "On" then
						MinimapCluster:ClearAllPoints()
						MinimapCluster:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 20)
					else
						MinimapCluster:ClearAllPoints()
						MinimapCluster:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 0)
					end
				end
			end

			-- Function to toggle the zone text bar
			local function SetMiniZoneText()
				if LeaPlusLC["HideZoneTextBar"] == "On" then
					-- Hide the zone text bar
					MinimapZoneTextButton:Hide()
					MiniMapWorldMapButton:Hide()
					MinimapBorderTop:SetTexture("")
					-- Move the minimap up to the top
					SetTitleBarPos()
				else
					-- Show the zone text bar
					MinimapZoneTextButton:Show()
					MiniMapWorldMapButton:Show()
					MinimapBorderTop:SetTexture("Interface\\Minimap\\UI-Minimap-Border")
					-- Move the minimap to its original position
					SetTitleBarPos()
				end
			end

			-- Set the zone text bar layout and tooltip position when option is clicked
			LeaPlusCB["HideZoneTextBar"]:HookScript("OnClick", function()
				SetMiniZoneText()
				ShowZoneTip(true)
			end)

			-- Set the zone text bar layout on startup
			SetMiniZoneText()

			----------------------------------------------------------------------
			-- Hide the zoom buttons
			----------------------------------------------------------------------

			-- Function to toggle the zoom buttons
			local function ToggleZoomButtons()
				if LeaPlusLC["HideMiniZoomBtns"] == "On" then
					MinimapZoomIn:Hide()
					MinimapZoomOut:Hide()
				else
					MinimapZoomIn:Show()
					MinimapZoomOut:Show()
				end
			end

			-- Set the zoom buttons when the option is clicked and on startup
			LeaPlusCB["HideMiniZoomBtns"]:HookScript("OnClick", ToggleZoomButtons)
			ToggleZoomButtons()

			----------------------------------------------------------------------
			-- Enable mousewheel zoom
			----------------------------------------------------------------------

			-- Function to control mousewheel zoom
			local function MiniZoom(self, arg1)
				if arg1 > 0 and self:GetZoom() < 5 then
					-- Zoom in
					MinimapZoomOut:Enable()
					self:SetZoom(self:GetZoom() + 1)
					if(Minimap:GetZoom() == (Minimap:GetZoomLevels() - 1)) then
						MinimapZoomIn:Disable()
					end
				elseif arg1 < 0 and self:GetZoom() > 0 then
					-- Zoom out
					MinimapZoomIn:Enable()
					self:SetZoom(self:GetZoom() - 1)
					if(Minimap:GetZoom() == 0) then
						MinimapZoomOut:Disable()
					end
				end
			end

			-- Enable mousewheel zoom
			Minimap:EnableMouseWheel(true)
			Minimap:SetScript("OnMouseWheel", MiniZoom)

			----------------------------------------------------------------------
			-- Minimap scale
			----------------------------------------------------------------------

			-- Function to set the minimap scale
			local function SetMiniScale()
				MinimapCluster:SetScale(LeaPlusLC["MinimapScale"])
				-- Set slider formatted text
				LeaPlusCB["MinimapScale"].f:SetFormattedText("%.0f%%", LeaPlusLC["MinimapScale"] * 100)
			end

			-- Set minimap scale when slider is changed and on startup
			LeaPlusCB["MinimapScale"]:HookScript("OnValueChanged", SetMiniScale)
			SetMiniScale()

			----------------------------------------------------------------------
			-- Buttons
			----------------------------------------------------------------------

			-- Help button tooltip
			SideMinimap.h.tiptext = L["This panel will close automatically if you enter combat."]

			-- Back button handler
			SideMinimap.b:SetScript("OnClick", function() 
				SideMinimap:Hide(); LeaPlusLC["PageF"]:Show(); LeaPlusLC["Page5"]:Show()
				return
			end) 

			-- Reset button handler
			SideMinimap.r:SetScript("OnClick", function()
				LeaPlusLC["HideZoneTextBar"] = "Off"; SetMiniZoneText(); ShowZoneTip(true)
				LeaPlusLC["HideMiniZoomBtns"] = "Off"; ToggleZoomButtons()
				LeaPlusLC["MinimapScale"] = 1; SetMiniScale()
				SideMinimap:Hide(); SideMinimap:Show()
			end)

			-- Configuration button handler
			LeaPlusCB["ModMinimapBtn"]:SetScript("OnClick", function()
				if LeaPlusLC:PlayerInCombat() then
					return
				else
					if IsShiftKeyDown() and IsControlKeyDown() then
						-- Preset profile
						LeaPlusLC["HideZoneTextBar"] = "On"; SetMiniZoneText(); ShowZoneTip(true)
						LeaPlusLC["HideMiniZoomBtns"] = "Off"; ToggleZoomButtons()
						LeaPlusLC["MinimapScale"] = 1.30; SetMiniScale()
					else
						-- Show configuration panel
						SideMinimap:Show()
						LeaPlusLC:HideFrames()
					end
				end
			end)

		end

		----------------------------------------------------------------------
		--	Quest text size
		----------------------------------------------------------------------

		if LeaPlusLC["QuestFontChange"] == "On" then

			-- Create configuration panel
			local QuestTextPanel = LeaPlusLC:CreatePanel("Quest Text", "QuestTextPanel")

			LeaPlusLC:MakeTx(QuestTextPanel, "Text size", 16, -72)
			LeaPlusLC:MakeSL(QuestTextPanel, "LeaPlusQuestFontSize", "Drag to set the font size of quest text.", 10, 36, 1, 16, -92, "%.0f")

			-- Function to update the font size
			local function QuestSizeUpdate()
				QuestTitleFont:SetFont(QuestFont:GetFont(), LeaPlusLC["LeaPlusQuestFontSize"] + 3, nil)
				QuestFont:SetFont(QuestFont:GetFont(), LeaPlusLC["LeaPlusQuestFontSize"] + 1, nil)
				QuestFontNormalSmall:SetFont(QuestFontNormalSmall:GetFont(), LeaPlusLC["LeaPlusQuestFontSize"], nil)
			end

			-- Set text size when slider changes and on startup
			LeaPlusCB["LeaPlusQuestFontSize"]:HookScript("OnValueChanged", QuestSizeUpdate)
			QuestSizeUpdate()

			-- Help button hidden
			QuestTextPanel.h:Hide()

			-- Back button handler
			QuestTextPanel.b:SetScript("OnClick", function() 
				QuestTextPanel:Hide(); LeaPlusLC["PageF"]:Show(); LeaPlusLC["Page4"]:Show()
				return
			end)

			-- Reset button handler
			QuestTextPanel.r:SetScript("OnClick", function()

				-- Reset slider
				LeaPlusLC["LeaPlusQuestFontSize"] = 12
				QuestSizeUpdate()

				-- Refresh side panel
				QuestTextPanel:Hide(); QuestTextPanel:Show()

			end)

			-- Show configuration panal when options panel button is clicked
			LeaPlusCB["QuestTextBtn"]:SetScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaPlusLC["LeaPlusQuestFontSize"] = 18
					QuestSizeUpdate()
				else
					QuestTextPanel:Show()
					LeaPlusLC:HideFrames()
				end
			end)

		end

		----------------------------------------------------------------------
		--	Resize mail text
		----------------------------------------------------------------------

		if LeaPlusLC["MailFontChange"] == "On" then

			-- Create configuration panel
			local MailTextPanel = LeaPlusLC:CreatePanel("Mail Text", "MailTextPanel")

			LeaPlusLC:MakeTx(MailTextPanel, "Text size", 16, -72)
			LeaPlusLC:MakeSL(MailTextPanel, "LeaPlusMailFontSize", "Drag to set the font size of mail text.", 10, 36, 1, 16, -92, "%.0f")

			-- Function to set the text size
			local function MailSizeUpdate()
				local MailFont = QuestFont:GetFont();
				OpenMailBodyText:SetFont(MailFont, LeaPlusLC["LeaPlusMailFontSize"])
				SendMailBodyEditBox:SetFont(MailFont, LeaPlusLC["LeaPlusMailFontSize"])
			end

			-- Set text size after changing slider and on startup
			LeaPlusCB["LeaPlusMailFontSize"]:HookScript("OnValueChanged", MailSizeUpdate)
			MailSizeUpdate()

			-- Help button hidden
			MailTextPanel.h:Hide()

			-- Back button handler
			MailTextPanel.b:SetScript("OnClick", function() 
				MailTextPanel:Hide(); LeaPlusLC["PageF"]:Show(); LeaPlusLC["Page4"]:Show()
				return
			end)

			-- Reset button handler
			MailTextPanel.r:SetScript("OnClick", function()

				-- Reset slider
				LeaPlusLC["LeaPlusMailFontSize"] = 15

				-- Refresh side panel
				MailTextPanel:Hide(); MailTextPanel:Show()

			end)

			-- Show configuration panal when options panel button is clicked
			LeaPlusCB["MailTextBtn"]:SetScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaPlusLC["LeaPlusMailFontSize"] = 22
					MailSizeUpdate()
				else
					MailTextPanel:Show()
					LeaPlusLC:HideFrames()
				end
			end)

		end

		----------------------------------------------------------------------
		--	Show durability status
		----------------------------------------------------------------------

		if LeaPlusLC["DurabilityStatus"] == "On" then

			-- Create durability button
			local cButton = CreateFrame("BUTTON", nil, PaperDollFrame)
			cButton:ClearAllPoints()
			cButton:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMRIGHT", -40, 80)
			cButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
			cButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
			cButton:SetSize(32, 32)

			-- Create durability tables
			local Slots = {"HeadSlot", "ShoulderSlot", "ChestSlot", "WristSlot", "HandsSlot", "WaistSlot", "LegsSlot", "FeetSlot", "MainHandSlot", "SecondaryHandSlot"}
			local SlotsFriendly = {INVTYPE_HEAD, INVTYPE_SHOULDER, INVTYPE_CHEST, INVTYPE_WRIST, INVTYPE_HAND, INVTYPE_WAIST, INVTYPE_LEGS, INVTYPE_FEET, INVTYPE_WEAPONMAINHAND, INVTYPE_WEAPONOFFHAND}

			-- Show durability status in tooltip or status line (tip or status)
			local function ShowDuraStats(where)

				local duravaltotal, duramaxtotal, durapercent = 0, 0, 0
				local valcol, id, duraval, duramax

				if where == "tip" then
					-- Creare layout
					GameTooltip:AddLine("|cffffffff")
					GameTooltip:AddLine("|cffffffff")
					GameTooltip:AddLine("|cffffffff")
					_G["GameTooltipTextLeft1"]:SetText("|cffffffff"); _G["GameTooltipTextRight1"]:SetText("|cffffffff")
					_G["GameTooltipTextLeft2"]:SetText("|cffffffff"); _G["GameTooltipTextRight2"]:SetText("|cffffffff")
					_G["GameTooltipTextLeft3"]:SetText("|cffffffff"); _G["GameTooltipTextRight3"]:SetText("|cffffffff")
				end

				local validItems = false

				-- Traverse equipment slots
				for k, slotName in ipairs(Slots) do
					if GetInventorySlotInfo(slotName) then
						id = GetInventorySlotInfo(slotName)
						duraval, duramax = GetInventoryItemDurability(id)
						if duraval ~= nil then

							-- At least one item has durability stat
							validItems = true

							-- Add to tooltip
							if where == "tip" then
								durapercent = tonumber(format("%.0f", duraval / duramax * 100))
								valcol = (durapercent >= 80 and "|cff00FF00") or (durapercent >= 60 and "|cff99FF00") or (durapercent >= 40 and "|cffFFFF00") or (durapercent >= 20 and "|cffFF9900") or (durapercent >= 0 and "|cffFF2000") or ("|cffFFFFFF")
								_G["GameTooltipTextLeft1"]:SetText(L["Durability"])
								_G["GameTooltipTextLeft2"]:SetText(_G["GameTooltipTextLeft2"]:GetText() .. SlotsFriendly[k] .. "|n")
								_G["GameTooltipTextRight2"]:SetText(_G["GameTooltipTextRight2"]:GetText() ..  valcol .. durapercent .. "%" .. "|n")
							end

							duravaltotal = duravaltotal + duraval
							duramaxtotal = duramaxtotal + duramax
						end
					end
				end
				if duravaltotal > 0 and duramaxtotal > 0 then
					durapercent = duravaltotal / duramaxtotal * 100
				else
					durapercent = 0
				end

				if where == "tip" then

					if validItems == true then
						-- Show overall durability in the tooltip
						if durapercent >= 80 then valcol = "|cff00FF00"	elseif durapercent >= 60 then valcol = "|cff99FF00"	elseif durapercent >= 40 then valcol = "|cffFFFF00"	elseif durapercent >= 20 then valcol = "|cffFF9900"	elseif durapercent >= 0 then valcol = "|cffFF2000" else return end
						_G["GameTooltipTextLeft3"]:SetText(L["Overall"] .. " " .. valcol)
						_G["GameTooltipTextRight3"]:SetText(valcol .. string.format("%.0f", durapercent) .. "%")

						-- Show lines of the tooltip
						GameTooltipTextLeft1:Show(); GameTooltipTextRight1:Show()
						GameTooltipTextLeft2:Show(); GameTooltipTextRight2:Show()
						GameTooltipTextLeft3:Show(); GameTooltipTextRight3:Show()
						GameTooltipTextRight2:SetJustifyH"RIGHT";
						GameTooltipTextRight3:SetJustifyH"RIGHT";
						GameTooltip:Show()
					else
						-- No items have durability stat
						GameTooltip:ClearLines()
						GameTooltip:AddLine("" .. L["Durability"],1.0, 0.85, 0.0)
						GameTooltip:AddLine("" .. L["No items with durability equipped."], 1, 1, 1)
						GameTooltip:Show()
					end

				elseif where == "status" then
					if validItems == true then
						-- Show simple status line instead
						if tonumber(durapercent) >= 0 then -- Ensure character has some durability items equipped
							LeaPlusLC:Print(L["You have"] .. " " .. string.format("%.0f", durapercent) .. "%" .. " " .. L["durability"] .. ".")
						end
					end

				end
			end

			-- Hover over the durability button to show the durability tooltip
			cButton:SetScript("OnEnter", function()
				GameTooltip:SetOwner(cButton, "ANCHOR_RIGHT");
				ShowDuraStats("tip");
			end)
			cButton:SetScript("OnLeave", GameTooltip_Hide)

			-- Create frame to watch events
			local DeathDura = CreateFrame("FRAME")
			DeathDura:RegisterEvent("PLAYER_DEAD")
			DeathDura:SetScript("OnEvent", function(self, event)
				ShowDuraStats("status")
				DeathDura:UnregisterEvent("PLAYER_DEAD")
				C_Timer.After(2, function()
					DeathDura:RegisterEvent("PLAYER_DEAD")
				end)
			end)

			hooksecurefunc("AcceptResurrect", function()
				-- Player has ressed without releasing
				ShowDuraStats("status")
			end)
			
		end

		----------------------------------------------------------------------
		--	Hide zone text
		----------------------------------------------------------------------

		if LeaPlusLC["HideZoneText"] == "On" then
			ZoneTextFrame:SetScript("OnShow", ZoneTextFrame.Hide);
			SubZoneTextFrame:SetScript("OnShow", SubZoneTextFrame.Hide);
		end

		----------------------------------------------------------------------
		--	Disable sticky chat
		----------------------------------------------------------------------

		if LeaPlusLC["NoStickyChat"] == "On" then
			-- These taint if set to anything other than nil
			ChatTypeInfo.WHISPER.sticky = nil
			ChatTypeInfo.BN_WHISPER.sticky = nil
			ChatTypeInfo.CHANNEL.sticky = nil
		end

		----------------------------------------------------------------------
		--	Hide stance bar
		----------------------------------------------------------------------

		if LeaPlusLC["NoClassBar"] == "On" then
			local stancebar = CreateFrame("FRAME")
			stancebar:Hide();
			UIPARENT_MANAGED_FRAME_POSITIONS["StanceBarFrame"] = nil;
			StanceBarFrame:SetParent(stancebar)
		end

		----------------------------------------------------------------------
		--	Hide gryphons
		----------------------------------------------------------------------

		if LeaPlusLC["NoGryphons"] == "On" then
			MainMenuBarLeftEndCap:Hide();
			MainMenuBarRightEndCap:Hide();
		end

		----------------------------------------------------------------------
		--	Disable chat fade
		----------------------------------------------------------------------

		if LeaPlusLC["NoChatFade"] == "On" then
			-- Process normal and existing chat frames
			for i = 1, 50 do
				if _G["ChatFrame" .. i] then
					_G["ChatFrame" .. i]:SetFading(false)
				end
			end
			-- Process temporary frames
			hooksecurefunc("FCF_OpenTemporaryWindow", function()
				local cf = FCF_GetCurrentChatFrame():GetName() or nil
				if cf then
					_G[cf]:SetFading(false)
				end
			end)
		end

		----------------------------------------------------------------------
		--	Use easy chat frame resizing
		----------------------------------------------------------------------

		if LeaPlusLC["UseEasyChatResizing"] == "On" then
			ChatFrame1Tab:HookScript("OnMouseDown", function(self,arg1)
				if arg1 == "LeftButton" then
					if select(8, GetChatWindowInfo(1)) then
						ChatFrame1:StartSizing("TOP")
					end
				end
			end)
			ChatFrame1Tab:SetScript("OnMouseUp", function(self,arg1)
				if arg1 == "LeftButton" then
					ChatFrame1:StopMovingOrSizing()
					FCF_SavePositionAndDimensions(ChatFrame1)
				end
			end)
		end

		----------------------------------------------------------------------
		--	Increase chat history
		----------------------------------------------------------------------

		if LeaPlusLC["MaxChatHstory"] == "On" then
			-- Process normal and existing chat frames
			for i = 1, 50 do
				if _G["ChatFrame" .. i] and _G["ChatFrame" .. i]:GetMaxLines() ~= 4096 then
					_G["ChatFrame" .. i]:SetMaxLines(4096);
				end
			end
			-- Process temporary chat frames
			hooksecurefunc("FCF_OpenTemporaryWindow", function()
				local cf = FCF_GetCurrentChatFrame():GetName() or nil
				if cf then
					if (_G[cf]:GetMaxLines() ~= 4096) then
						_G[cf]:SetMaxLines(4096);
					end
				end
			end)
		end

		----------------------------------------------------------------------
		--	Hide error messages
		----------------------------------------------------------------------

		if LeaPlusLC["HideErrorMessages"] == "On" then

			--	Error message events
			local OrigErrHandler = UIErrorsFrame:GetScript('OnEvent')
			UIErrorsFrame:SetScript('OnEvent', function (self, event, id, err, ...)
				if event == "UI_ERROR_MESSAGE" then
					-- Hide error messages
					if LeaPlusLC["ShowErrorsFlag"] == 1 then
						if 	err == ERR_INV_FULL or
							err == ERR_QUEST_LOG_FULL or
							err == ERR_RAID_GROUP_ONLY or
							err == ERR_PET_SPELL_DEAD or
							err == ERR_PLAYER_DEAD then
							return OrigErrHandler(self, event, id, err, ...)
						end
					else
						return OrigErrHandler(self, event, id, err, ...) 
					end
				elseif event == 'UI_INFO_MESSAGE'  then
					-- Show information messages
					return OrigErrHandler(self, event, id, err, ...)
				end
			end)

		end

		-- Release memory
		LeaPlusLC.Isolated = nil

	end

----------------------------------------------------------------------
--	L40: Player
----------------------------------------------------------------------

	function LeaPlusLC:Player()

		----------------------------------------------------------------------
		--	Show vendor price
		----------------------------------------------------------------------

		if LeaPlusLC["ShowVendorPrice"] == "On" then

			-- Function to add vendor price to tooltips
			local function ShowVendorPrice(tooltip)
				-- Do nothing if money frame is already showing
				if tooltip.shownMoneyFrames then return end
				-- Get item sell price
				local void, link = tooltip:GetItem()
				if not link then return end
				local void, void, void, void, void, void, void, void, void, void, itemSellPrice = GetItemInfo(link)
				if not itemSellPrice or itemSellPrice <= 0 then return end
				local container = GetMouseFocus()
				if not container then return end
				-- Get item quantity
				local buttonName = container:GetName() and (container:GetName() .. "Count")
				local count = container.count or (container.Count and container.Count:GetText()) or (container.Quantity and container.Quantity:GetText()) or (buttonName and _G[buttonName] and _G[buttonName]:GetText())
				count = tonumber(count) or 1
				if count <= 1 then count = 1 end
				-- Show sell price in tooltip
				SetTooltipMoney(tooltip, count * itemSellPrice, "STATIC", SELL_PRICE .. ":")
			end

			-- Run function for regular tooltips and chat link tooltips
			GameTooltip:HookScript("OnTooltipSetItem", ShowVendorPrice)
			ItemRefTooltip:HookScript("OnTooltipSetItem", ShowVendorPrice)

		end

		----------------------------------------------------------------------
		--	Stand and dismount
		----------------------------------------------------------------------

		if LeaPlusLC["StandAndDismount"] == "On" then

			local eFrame = CreateFrame("FRAME")
			eFrame:RegisterEvent("UI_ERROR_MESSAGE")
			eFrame:SetScript("OnEvent", function(self, event, messageType, msg)
				-- Auto stand
				if msg == SPELL_FAILED_NOT_STANDING
				or msg == ERR_CANTATTACK_NOTSTANDING
				or msg == ERR_LOOT_NOTSTANDING
				or msg == ERR_TAXINOTSTANDING
				then
					DoEmote("stand")
					UIErrorsFrame:Clear()
				-- Auto dismount
				elseif msg == ERR_ATTACK_MOUNTED
				or msg == ERR_MOUNT_ALREADYMOUNTED
				or msg == ERR_NOT_WHILE_MOUNTED
				or msg == ERR_TAXIPLAYERALREADYMOUNTED
				or msg == SPELL_FAILED_NOT_MOUNTED
				then
					if IsMounted() then
						Dismount()
						UIErrorsFrame:Clear()
					end
				end
			end)

		end

		----------------------------------------------------------------------
		--	Show vanity controls
		----------------------------------------------------------------------

		if LeaPlusLC["ShowVanityControls"] == "On" then

			-- Create checkboxes
			LeaPlusLC:MakeCB(CharacterModelFrame, "ShowHelm", L["Helm"], 2, -192, false, "");
			LeaPlusLC:MakeCB(CharacterModelFrame, "ShowCloak", L["Cloak"], 281, -192, false, "");
			LeaPlusCB["ShowHelm"]:SetFrameStrata("HIGH")
			LeaPlusCB["ShowHelm"]:SetHitRectInsets(0, -LeaPlusCB["ShowHelm"].f:GetStringWidth() + 4, 0, 0)

			LeaPlusCB["ShowCloak"]:SetFrameStrata("HIGH")
			LeaPlusCB["ShowCloak"]:SetHitRectInsets(0, -LeaPlusCB["ShowCloak"].f:GetStringWidth() + 4, 0, 0)
			LeaPlusCB["ShowCloak"]:ClearAllPoints()
			LeaPlusCB["ShowCloak"]:SetPoint("TOPLEFT", 210 - LeaPlusCB["ShowCloak"].f:GetStringWidth(), -192) -- 240

			-- Toggle helm with click
			LeaPlusCB["ShowHelm"]:HookScript("OnClick", function()
				LeaPlusCB["ShowHelm"]:Disable()
				C_Timer.After(0.5, function()
					if ShowingHelm() then
						ShowHelm(false)
					else
						ShowHelm(true)
					end
					LeaPlusCB["ShowHelm"]:Enable()
				end)
			end)

			-- Toggle cloak with click
			LeaPlusCB["ShowCloak"]:HookScript("OnClick", function()
				LeaPlusCB["ShowCloak"]:Disable()
				C_Timer.After(0.5, function()
					if ShowingCloak() then
						ShowCloak(false)
					else
						ShowCloak(true)
					end
					LeaPlusCB["ShowCloak"]:Enable()
				end)
			end)

			-- Set checkbox state when checkboxes are shown
			LeaPlusCB["ShowCloak"]:HookScript("OnShow", function()
				if ShowingHelm() then
					LeaPlusCB["ShowHelm"]:SetChecked(true)
				else
					LeaPlusCB["ShowHelm"]:SetChecked(false)
				end
				if ShowingCloak() then
					LeaPlusCB["ShowCloak"]:SetChecked(true)
				else
					LeaPlusCB["ShowCloak"]:SetChecked(false)
				end
			end)

		end

		----------------------------------------------------------------------
		--	Use class colors in chat
		----------------------------------------------------------------------

		do

			-- Function to set class colors
			local function SetClassCol()
				if LeaPlusLC["ClassColorsInChat"] == "On" then
					SetCVar("chatClassColorOverride", "0")
				else
					SetCVar("chatClassColorOverride", "1")
				end
			end

			-- Set class colors on startup and when option is clicked (if enabled)
			LeaPlusCB["ClassColorsInChat"]:HookScript("OnClick", SetClassCol)
			if LeaPlusLC["ClassColorsInChat"] == "On" then SetClassCol() end

		end

		----------------------------------------------------------------------
		-- Disable screen glow (no reload required)
		----------------------------------------------------------------------

		do

			-- Function to set screen glow
			local function SetGlow()
				if LeaPlusLC["NoScreenGlow"] == "On" then
					SetCVar("ffxGlow", "0")
				else
					SetCVar("ffxGlow", "1")
				end
			end

			-- Set screen glow on startup and when option is clicked (if enabled)
			LeaPlusCB["NoScreenGlow"]:HookScript("OnClick", SetGlow)
			if LeaPlusLC["NoScreenGlow"] == "On" then SetGlow() end

		end

		----------------------------------------------------------------------
		-- Disable screen effects (no reload required)
		----------------------------------------------------------------------

		do

			-- Function to set screen effects
			local function SetEffects()
				if LeaPlusLC["NoScreenEffects"] == "On" then
					SetCVar("ffxDeath", "0")
					SetCVar("ffxNether", "0")
				else
					SetCVar("ffxDeath", "1")
					SetCVar("ffxNether", "1")
				end
			end

			-- Set screen effects when option is clicked and on startup (if enabled)
			LeaPlusCB["NoScreenEffects"]:HookScript("OnClick", SetEffects)
			if LeaPlusLC["NoScreenEffects"] == "On" then SetEffects() end

		end

		----------------------------------------------------------------------
		-- Universal group chat color (no reload required)
		----------------------------------------------------------------------

		do

			-- Function to set chat colors
			local function SetCol()
				if LeaPlusLC["UnivGroupColor"] == "On" then
					ChangeChatColor("RAID", 0.67, 0.67, 1)
					ChangeChatColor("RAID_LEADER", 0.46, 0.78, 1)
					ChangeChatColor("INSTANCE_CHAT", 0.67, 0.67, 1)
					ChangeChatColor("INSTANCE_CHAT_LEADER", 0.46, 0.78, 1)
				else
					ChangeChatColor("RAID", 1, 0.50, 0)
					ChangeChatColor("RAID_LEADER", 1, 0.28, 0.04)
					ChangeChatColor("INSTANCE_CHAT", 1, 0.50, 0)
					ChangeChatColor("INSTANCE_CHAT_LEADER", 1, 0.28, 0.04)
				end
			end

			-- Set chat colors when option is clicked and on startup (if enabled)
			LeaPlusCB["UnivGroupColor"]:HookScript("OnClick", SetCol)
			if LeaPlusLC["UnivGroupColor"] == "On" then	SetCol() end

		end

		----------------------------------------------------------------------
		-- Minimap button (no reload required)
		----------------------------------------------------------------------

		do

			-- Minimap button click function
			local function MiniBtnClickFunc(arg1)

				-- Prevent options panel from showing if Blizzard options panel is showing
				if InterfaceOptionsFrame:IsShown() or VideoOptionsFrame:IsShown() or ChatConfigFrame:IsShown() then return end
				-- Prevent options panel from showing if Blizzard Store is showing
				if StoreFrame and StoreFrame:GetAttribute("isshown") then return end
				-- Left button down
				if arg1 == "LeftButton" then

					-- Control key does nothing
					if IsControlKeyDown() and not IsShiftKeyDown() then
						return
					end

					-- Shift key toggles music
					if IsShiftKeyDown() and not IsControlKeyDown() then
						Sound_ToggleMusic();
						return
					end

					-- Shift key and control key toggles Zygor addon
					if IsShiftKeyDown() and IsControlKeyDown() then
						LeaPlusLC:ZygorToggle();
						return
					end

					-- No modifier key toggles the options panel
					if LeaPlusLC:IsPlusShowing() then
						LeaPlusLC:HideFrames()
						LeaPlusLC:HideConfigPanels()
					else
						LeaPlusLC:HideFrames()
						LeaPlusLC["PageF"]:Show()
					end
					LeaPlusLC["Page"..LeaPlusLC["LeaStartPage"]]:Show()
				end

				-- Right button down
				if arg1 == "RightButton" then

					-- Control key toggles error messages
					if IsControlKeyDown() and not IsShiftKeyDown() then
						if LeaPlusDB["HideErrorMessages"] == "On" then -- Checks global
							if LeaPlusLC["ShowErrorsFlag"] == 1 then 
								LeaPlusLC["ShowErrorsFlag"] = 0
								ActionStatus_DisplayMessage(L["Error messages will be shown"], true);
							else
								LeaPlusLC["ShowErrorsFlag"] = 1
								ActionStatus_DisplayMessage(L["Error messages will be hidden"], true);
							end
							return
						end
						return
					end

					-- Shift key does nothing
					if IsShiftKeyDown() and not IsControlKeyDown() then
						return
					end

					-- Shift key and control key toggles maximised window mode
					if IsShiftKeyDown() and IsControlKeyDown() then
						if LeaPlusLC:PlayerInCombat() then
							return
						else
							SetCVar("gxMaximize", tostring(1 - GetCVar("gxMaximize")));
							RestartGx();
						end
						return
					end

					-- No modifier key toggles the options panel
					if LeaPlusLC:IsPlusShowing() then
						LeaPlusLC:HideFrames()
						LeaPlusLC:HideConfigPanels()
					else
						LeaPlusLC:HideFrames()
						LeaPlusLC["PageF"]:Show()
					end
					LeaPlusLC["Page" .. LeaPlusLC["LeaStartPage"]]:Show()

				end

			end

			-- Create minimap button using LibDBIcon
			local ldb = LibStub("LibDataBroker-1.1", true)
			local miniButton = ldb:NewDataObject("Leatrix_Plus", {
				type = "launcher",
				icon = "Interface\\HELPFRAME\\ReportLagIcon-Movement",
				OnClick = function(self, btn)
					MiniBtnClickFunc(btn)
				end,
				OnTooltipShow = function(tooltip)
					if not tooltip or not tooltip.AddLine then return end
					tooltip:AddLine("Leatrix Plus")
				end,
			})
			local icon = LibStub("LibDBIcon-1.0", true)
			icon:Register("Leatrix_Plus", miniButton, LeaPlusDB)

			-- Function to toggle LibDBIcon
			local function SetLibDBIconFunc()
				if LeaPlusLC["ShowMinimapIcon"] == "On" then
					icon:Show("Leatrix_Plus")
				else
					icon:Hide("Leatrix_Plus")
				end
			end

			-- Set LibDBIcon when option is clicked and on startup
			LeaPlusCB["ShowMinimapIcon"]:HookScript("OnClick", SetLibDBIconFunc)
			SetLibDBIconFunc()

		end

		----------------------------------------------------------------------
		-- Auction House Extras
		----------------------------------------------------------------------

		if LeaPlusLC["AhExtras"] == "On" then

			local function AuctionFunc()

				-- Set default auction duration value to saved settings or default settings
				AuctionFrameAuctions.duration = LeaPlusDB["AHDuration"] or 3

				-- Update duration radio button
				AuctionsShortAuctionButton:SetChecked(false)
				AuctionsMediumAuctionButton:SetChecked(false)
				AuctionsLongAuctionButton:SetChecked(false)
				if AuctionFrameAuctions.duration == 1 then
					AuctionsShortAuctionButton:SetChecked(true)
				elseif AuctionFrameAuctions.duration == 2 then
					AuctionsMediumAuctionButton:SetChecked(true)
				elseif AuctionFrameAuctions.duration == 3 then
					AuctionsLongAuctionButton:SetChecked(true)
				end

				-- Functions
				local function CreateAuctionCB(name, anchor, x, y, text)
					LeaPlusCB[name] = CreateFrame("CheckButton", nil, AuctionFrameAuctions, "OptionsCheckButtonTemplate")
					LeaPlusCB[name]:SetFrameStrata("HIGH")
					LeaPlusCB[name]:SetSize(20, 20)
					LeaPlusCB[name]:SetPoint(anchor, x, y)
					LeaPlusCB[name].f = LeaPlusCB[name]:CreateFontString(nil, 'OVERLAY', "GameFontNormal")
					LeaPlusCB[name].f:SetPoint("LEFT", 20, 0)
					LeaPlusCB[name].f:SetText(L[text])
					LeaPlusCB[name].f:Show();
					LeaPlusCB[name]:SetScript('OnClick', function()
						if LeaPlusCB[name]:GetChecked() then
							LeaPlusLC[name] = "On"
						else
							LeaPlusLC[name] = "Off"
						end
					end)
					LeaPlusCB[name]:SetScript('OnShow', function(self)
						if LeaPlusLC[name] == "On" then
							self:SetChecked(true)
						else
							self:SetChecked(false)
						end
					end)
				end

				-- Show the correct fields in the AH frame and match prices
				local function SetupAh()
					if LeaPlusLC["AhBuyoutOnly"] == "On" then
						-- Hide the start price
						StartPrice:SetAlpha(0);
						-- Set start price to buyout price 
						StartPriceGold:SetText(BuyoutPriceGold:GetText());
						StartPriceSilver:SetText(BuyoutPriceSilver:GetText());
						StartPriceCopper:SetText(BuyoutPriceCopper:GetText());
					else
						-- Show the start price
						StartPrice:SetAlpha(1);
					end
					-- If gold only is on, set copper and silver to 99
					if LeaPlusLC["AhGoldOnly"] == "On" then
						StartPriceCopper:SetText("99"); StartPriceCopper:Disable();
						StartPriceSilver:SetText("99"); StartPriceSilver:Disable();
						BuyoutPriceCopper:SetText("99"); BuyoutPriceCopper:Disable();
						BuyoutPriceSilver:SetText("99"); BuyoutPriceSilver:Disable();
					else
						StartPriceCopper:Enable();
						StartPriceSilver:Enable();
						BuyoutPriceCopper:Enable();
						BuyoutPriceSilver:Enable();
					end
					-- Validate the auction (mainly for the create auction button status)
					AuctionsFrameAuctions_ValidateAuction()
				end

				-- Create checkboxes
				CreateAuctionCB("AhBuyoutOnly", "BOTTOMLEFT", 200, 16, "Buyout Only")
				CreateAuctionCB("AhGoldOnly", "BOTTOMLEFT", 320, 16, "Gold Only")

				-- Reposition Gold Only checkbox so it does not overlap Buyout Only checkbox label
				LeaPlusCB["AhGoldOnly"]:ClearAllPoints()
				LeaPlusCB["AhGoldOnly"]:SetPoint("LEFT", LeaPlusCB["AhBuyoutOnly"].f, "RIGHT", 20, 0)

				-- Set click boundaries
				LeaPlusCB["AhBuyoutOnly"]:SetHitRectInsets(0, -LeaPlusCB["AhBuyoutOnly"].f:GetStringWidth() + 6, 0, 0);
				LeaPlusCB["AhGoldOnly"]:SetHitRectInsets(0, -LeaPlusCB["AhGoldOnly"].f:GetStringWidth() + 6, 0, 0);

				LeaPlusCB["AhBuyoutOnly"]:HookScript('OnClick', SetupAh);
				LeaPlusCB["AhBuyoutOnly"]:HookScript('OnShow', SetupAh);
	
				AuctionFrameAuctions:HookScript("OnShow", SetupAh)
				BuyoutPriceGold:HookScript("OnTextChanged", SetupAh)
				BuyoutPriceSilver:HookScript("OnTextChanged", SetupAh)
				BuyoutPriceCopper:HookScript("OnTextChanged", SetupAh)
				StartPriceGold:HookScript("OnTextChanged", SetupAh)
				StartPriceSilver:HookScript("OnTextChanged", SetupAh)
				StartPriceCopper:HookScript("OnTextChanged", SetupAh)
	
				-- Lock the create auction button if buyout gold box is empty (when using buyout only and gold only)
				AuctionsCreateAuctionButton:HookScript("OnEnable", function()
					-- Do nothing if wow token frame is showing
					if AuctionsWowTokenAuctionFrame:IsShown() then return end
					-- Lock the create auction button if both checkboxes are enabled and buyout gold price is empty
					if LeaPlusLC["AhGoldOnly"] == "On" and LeaPlusLC["AhBuyoutOnly"] == "On" then
						if BuyoutPriceGold:GetText() == "" then
							AuctionsCreateAuctionButton:Disable()
						end
					end
				end)
				
				-- Clear copper and silver prices if gold only box is unchecked
				LeaPlusCB["AhGoldOnly"]:HookScript('OnClick', function()
					if LeaPlusCB["AhGoldOnly"]:GetChecked() == false then
						BuyoutPriceCopper:SetText("")
						BuyoutPriceSilver:SetText("")
						StartPriceCopper:SetText("")
						StartPriceSilver:SetText("")
					end
					SetupAh();
				end)

				-- Create find button
				AuctionsItemText:Hide()
				LeaPlusLC:CreateButton("FindAuctionButton", AuctionsStackSizeMaxButton, "Find Item", "CENTER", 0, 68, 0, 21, false, "")
				LeaPlusCB["FindAuctionButton"]:SetParent(AuctionFrameAuctions)

				-- Show find button when the auctions tab is shown
				AuctionFrameAuctions:HookScript("OnShow", function() 
					LeaPlusCB["FindAuctionButton"]:SetEnabled(GetAuctionSellItemInfo() and true or false)
				end)

				-- Show find button when a new item is added
				AuctionsItemButton:HookScript("OnEvent", function(self, event)
					if event == "NEW_AUCTION_UPDATE" then
						LeaPlusCB["FindAuctionButton"]:SetEnabled(GetAuctionSellItemInfo() and true or false)
					end
				end)

				LeaPlusCB["FindAuctionButton"]:SetScript("OnClick", function()
					if GetAuctionSellItemInfo() then
						if BrowseWowTokenResults:IsShown() then
							-- Stop if Game Time filter is currently shown
							AuctionFrameTab1:Click()
							LeaPlusLC:Print("To use the Find Item button, you need to deselect the WoW Token category.")
						else
							-- Otherwise, search for the required item
							local name = GetAuctionSellItemInfo()
							BrowseName:SetText(name)
							QueryAuctionItems(name, 0, 0, 0, false, 0, false, true)
							AuctionFrameTab1:Click()
						end
					end
				end)

				-- Clear the cursor and reset editboxes when a new item replaces an existing one
				hooksecurefunc("AuctionsFrameAuctions_ValidateAuction", function()
					if GetAuctionSellItemInfo() then
						-- Return anything you might be holding
						ClearCursor();
						-- Set copper and silver prices to 99 if gold mode is on
						if LeaPlusLC["AhGoldOnly"] == "On" then
							StartPriceCopper:SetText("99")
							StartPriceSilver:SetText("99")
							BuyoutPriceCopper:SetText("99")
							BuyoutPriceSilver:SetText("99")
						end
					end
				end)
      
				-- Clear gold editbox after an auction has been created (to force user to enter something)
				AuctionsCreateAuctionButton:HookScript("OnClick", function()
					StartPriceGold:SetText("")
					BuyoutPriceGold:SetText("")
				end)

				-- Set tab key actions (if different from defaults)
				StartPriceGold:HookScript("OnTabPressed", function()
					if not IsShiftKeyDown() then
						if LeaPlusLC["AhBuyoutOnly"] == "Off" and LeaPlusLC["AhGoldOnly"] == "On" then
							BuyoutPriceGold:SetFocus()
						end
					end
				end)

				BuyoutPriceGold:HookScript("OnTabPressed", function()
					if IsShiftKeyDown() then
						if LeaPlusLC["AhBuyoutOnly"] == "Off" and LeaPlusLC["AhGoldOnly"] == "On" then
							StartPriceGold:SetFocus()
						end
					end
				end)
			end

			-- Run function when Blizzard addon is loaded
			if IsAddOnLoaded("Blizzard_AuctionUI") then
				AuctionFunc()
			else
				local waitFrame = CreateFrame("FRAME")
				waitFrame:RegisterEvent("ADDON_LOADED")
				waitFrame:SetScript("OnEvent", function(self, event, arg1)
					if arg1 == "Blizzard_AuctionUI" then
						AuctionFunc()
						waitFrame:UnregisterAllEvents()
					end
				end)
			end

		end

		----------------------------------------------------------------------
		-- Show volume control on character sheet
		----------------------------------------------------------------------

		if LeaPlusLC["ShowVolume"] == "On" then

			-- Function to update master volume
			local function MasterVolUpdate()
				if LeaPlusLC["ShowVolume"] == "On" then
					-- Set the volume
					SetCVar("Sound_MasterVolume", LeaPlusLC["LeaPlusMaxVol"]);
					-- Format the slider text
					LeaPlusCB["LeaPlusMaxVol"].f:SetFormattedText("%.0f", LeaPlusLC["LeaPlusMaxVol"] * 20)
				end
			end

			-- Create slider control
			LeaPlusLC["LeaPlusMaxVol"] = tonumber(GetCVar("Sound_MasterVolume"));
			LeaPlusLC:MakeSL(CharacterModelFrame, "LeaPlusMaxVol", "",	0, 1, 0.05, -42, -328, "%.2f")
			LeaPlusCB["LeaPlusMaxVol"]:SetWidth(64)
			LeaPlusCB["LeaPlusMaxVol"].f:ClearAllPoints()
			LeaPlusCB["LeaPlusMaxVol"].f:SetPoint("LEFT", LeaPlusCB["LeaPlusMaxVol"], "RIGHT", 6, 0)

			-- Set slider control value when shown
			LeaPlusCB["LeaPlusMaxVol"]:SetScript("OnShow", function()
				LeaPlusCB["LeaPlusMaxVol"]:SetValue(GetCVar("Sound_MasterVolume"))
			end)

			-- Update volume when slider control is changed
			LeaPlusCB["LeaPlusMaxVol"]:HookScript("OnValueChanged", function()
				if IsMouseButtonDown("RightButton") and IsShiftKeyDown() then 
					-- Dual layout is active so don't adjust slider
					LeaPlusCB["LeaPlusMaxVol"].f:SetFormattedText("%.0f", LeaPlusLC["LeaPlusMaxVol"] * 20)
					LeaPlusCB["LeaPlusMaxVol"]:Hide()
					LeaPlusCB["LeaPlusMaxVol"]:Show()
					return
				else
					-- Set sound level and refresh slider
					MasterVolUpdate()
				end
			end)

		end

		----------------------------------------------------------------------
		--	Use arrow keys in chat
		----------------------------------------------------------------------

		if LeaPlusLC["UseArrowKeysInChat"] == "On" then
			-- Enable arrow keys for normal and existing chat frames
			for i = 1, 50 do
				if _G["ChatFrame" .. i] then
					_G["ChatFrame" .. i .. "EditBox"]:SetAltArrowKeyMode(false)
				end
			end
			-- Enable arrow keys for temporary chat frames
			hooksecurefunc("FCF_OpenTemporaryWindow", function()
				local cf = FCF_GetCurrentChatFrame():GetName() or nil
				if cf then
					_G[cf .. "EditBox"]:SetAltArrowKeyMode(false)
				end
			end)
		end

		----------------------------------------------------------------------
		-- L42: Manage frames
		----------------------------------------------------------------------

		-- Frame Movement
		if LeaPlusLC["FrmEnabled"] == "On" then

			-- Lock the player and target frames
			PlayerFrame_SetLocked(true)
			TargetFrame_SetLocked(true)

			-- Remove integrated movement functions to avoid conflicts
			_G.PlayerFrame_ResetUserPlacedPosition = function() end
			_G.TargetFrame_ResetUserPlacedPosition = function() end
			_G.PlayerFrame_SetLocked = function() end
			_G.TargetFrame_SetLocked = function() end

			-- Replace buff frame movement function
			local buffSetPos = BuffFrame.SetPoint

			-- Create and manage container for UIWidgetTopCenterContainerFrame
			local topCenterHolder = CreateFrame("Frame", "LeaPlusTopCenterContainerHolder", UIParent)
			topCenterHolder:SetPoint("TOP", UIParent, "TOP", 0, -30)
			topCenterHolder:SetSize(10, 58)

			local topCenterContainer = _G.UIWidgetTopCenterContainerFrame
			topCenterContainer:ClearAllPoints()
			topCenterContainer:SetPoint('CENTER', topCenterHolder)

			hooksecurefunc(topCenterContainer, 'SetPoint', function(self, void, b)
				local holder = _G.LeaPlusTopCenterContainerHolder
				if b and (b ~= holder) then
					self:ClearAllPoints()
					self:SetPoint('CENTER', holder)
					self:SetParent(holder)
				end
			end)

			-- Create frame table (used for local traversal)
			local FrameTable = {DragPlayerFrame = PlayerFrame, DragTargetFrame = TargetFrame, DragMirrorTimer1 = MirrorTimer1, DragLeaPlusTopCenterContainerHolder = LeaPlusTopCenterContainerHolder, DragBuffFrame = BuffFrame}

			-- Create main table structure in saved variables if it doesn't exist
			if (LeaPlusDB["Frames"]) == nil then
				LeaPlusDB["Frames"] = {}
			end

			-- Create frame based table structure in saved variables if it doesn't exist and set initial scales
			for k,v in pairs(FrameTable) do
				local vf = v:GetName()
				-- Create frame table structure if it doesn't exist
				if not LeaPlusDB["Frames"][vf] then
					LeaPlusDB["Frames"][vf] = {}
				end
				-- Set saved scale value to default if it doesn't exist
				if not LeaPlusDB["Frames"][vf]["Scale"] then
					LeaPlusDB["Frames"][vf]["Scale"] = 1.00
				end
				-- Set frame scale to saved value
				_G[vf]:SetScale(LeaPlusDB["Frames"][vf]["Scale"])
			end

			-- Set cached status
			local function LeaPlusFramesSaveCache(frame)
				_G[frame]:SetMovable(true)
				if frame == "PlayerFrame" or frame == "TargetFrame" then
					_G[frame]:SetUserPlaced(true)
				else
					_G[frame]:SetUserPlaced(false)
				end
			end

			-- Set frames to manual values
			local function LeaFramesSetPos(frame, point, parent, relative, xoff, yoff)
				frame:SetMovable(true)
				frame:ClearAllPoints()
				if frame:GetName() == "BuffFrame" then
					buffSetPos(BuffFrame, point, parent, relative, xoff, yoff)
				else
					frame:SetPoint(point, parent, relative, xoff, yoff)
				end
			end

			-- Set frames to default values
			local function LeaPlusFramesDefaults()
				LeaFramesSetPos(PlayerFrame						, "TOPLEFT"	, UIParent, "TOPLEFT"	, -19, -4)
				LeaFramesSetPos(TargetFrame						, "TOPLEFT"	, UIParent, "TOPLEFT"	, 250, -4)
				LeaFramesSetPos(MirrorTimer1					, "TOP"		, UIParent, "TOP"		, -5, -96)
				LeaFramesSetPos(LeaPlusTopCenterContainerHolder	, "TOP"		, UIParent, "TOP"		, 0, -15)
				LeaFramesSetPos(BuffFrame						, "TOPRIGHT", UIParent, "TOPRIGHT"	, -205, -13)
			end

			-- Create configuration panel
			local SideFrames = LeaPlusLC:CreatePanel("Frames", "SideFrames")

			-- Variable used to store currently selected frame
			local currentframe

			-- Create scale title
			LeaPlusLC:MakeTx(SideFrames, "Scale", 16, -72)
			
			-- Set initial slider value (will be changed when drag frames are selected)
			LeaPlusLC["FrameScale"] = 1.00

			-- Create scale slider
			LeaPlusLC:MakeSL(SideFrames, "FrameScale", "Drag to set the scale of the selected frame.", 0.5, 3.0, 0.05, 16, -92, "%.2f")
			LeaPlusCB["FrameScale"]:HookScript("OnValueChanged", function(self, value)
				if currentframe then -- If a frame is selected
					-- Set real and drag frame scale
					LeaPlusDB["Frames"][currentframe]["Scale"] = value
					_G[currentframe]:SetScale(LeaPlusDB["Frames"][currentframe]["Scale"])
					LeaPlusLC["Drag" .. currentframe]:SetScale(LeaPlusDB["Frames"][currentframe]["Scale"])
					-- If target frame scale is changed, also change combo point frame
					if currentframe == "TargetFrame" then
						ComboFrame:SetScale(LeaPlusDB["Frames"]["TargetFrame"]["Scale"])
					end
					-- If buff frame scale is changed, also change temporary enchant frame
					if currentframe == "BuffFrame" then
						TemporaryEnchantFrame:SetScale(LeaPlusDB["Frames"]["BuffFrame"]["Scale"])
					end
					-- If widget top holder scale is changed, also change real widget top center frame
					if currentframe == "LeaPlusTopCenterContainerHolder" then
						UIWidgetTopCenterContainerFrame:SetScale(LeaPlusDB["Frames"]["LeaPlusTopCenterContainerHolder"]["Scale"])
					end
					-- Set slider formatted text
					LeaPlusCB["FrameScale"].f:SetFormattedText("%.0f%%", LeaPlusLC["FrameScale"] * 100)
				end
			end)

			-- Set initial scale slider state and value
			LeaPlusCB["FrameScale"]:HookScript("OnShow", function()
				if not currentframe then
					-- No frame selected so select the player frame
					currentframe = PlayerFrame:GetName()
					LeaPlusLC["DragPlayerFrame"].t:SetColorTexture(0.0, 1.0, 0.0,0.5)
				end
				-- Set the scale slider value to the selected frame
				LeaPlusCB["FrameScale"]:SetValue(LeaPlusDB["Frames"][currentframe]["Scale"])
				-- Set slider formatted text
				LeaPlusCB["FrameScale"].f:SetFormattedText("%.0f%%", LeaPlusLC["FrameScale"] * 100)
			end)

			-- Help button tooltip
			SideFrames.h.tiptext = L["Drag the frame overlays to position the frames.|n|nTo change the scale of a frame, click it to select it then adjust the scale slider.|n|nThis panel will close automatically if you enter combat."]

			-- Back button handler
			SideFrames.b:SetScript("OnClick", function()
				-- Hide outer control frame
				SideFrames:Hide()
				-- Hide drag frames
				for k, void in pairs(FrameTable) do
					LeaPlusLC[k]:Hide()
				end
				-- Show options panel at frame section
				LeaPlusLC["PageF"]:Show()
				LeaPlusLC["Page6"]:Show()
			end) 

			-- Reset button handler
			SideFrames.r:SetScript("OnClick", function()
				if LeaPlusLC:PlayerInCombat() then
					-- If player is in combat, print error and stop
					return
				else
					-- Set frames to default positions (presets)
					LeaPlusFramesDefaults()
					for k,v in pairs(FrameTable) do
						local vf = v:GetName()
						-- Store frame locations
						LeaPlusDB["Frames"][vf]["Point"], void, LeaPlusDB["Frames"][vf]["Relative"], LeaPlusDB["Frames"][vf]["XOffset"], LeaPlusDB["Frames"][vf]["YOffset"] = _G[vf]:GetPoint()
						-- Reset real frame scales and save them
						LeaPlusDB["Frames"][vf]["Scale"] = 1.00
						_G[vf]:SetScale(LeaPlusDB["Frames"][vf]["Scale"])
						-- Reset drag frame scales
						LeaPlusLC[k]:SetScale(LeaPlusDB["Frames"][vf]["Scale"])
					end
					-- Set combo frame scale to match target frame scale
					ComboFrame:SetScale(LeaPlusDB["Frames"]["TargetFrame"]["Scale"])
					-- Set temporary enchant frame scale to match buff frame scale
					TemporaryEnchantFrame:SetScale(LeaPlusDB["Frames"]["BuffFrame"]["Scale"])
					-- Set real widget top center frame scale to match holder frame
					UIWidgetTopCenterContainerFrame:SetScale(LeaPlusDB["Frames"]["LeaPlusTopCenterContainerHolder"]["Scale"])
					LeaPlusTopCenterContainerHolder:SetScale(LeaPlusDB["Frames"]["LeaPlusTopCenterContainerHolder"]["Scale"])
					-- Set the scale slider value to the selected frame scale
					LeaPlusCB["FrameScale"]:SetValue(LeaPlusDB["Frames"][currentframe]["Scale"])
					-- Refresh the panel
					SideFrames:Hide(); SideFrames:Show()
				end
			end)

			-- Show drag frames with configuration panel
			SideFrames:HookScript("OnShow", function()
				for k, void in pairs(FrameTable) do
					LeaPlusLC[k]:Show()
				end
			end)
			SideFrames:HookScript("OnHide", function()
				for k, void in pairs(FrameTable) do
					LeaPlusLC[k]:Hide()
				end
			end)

			-- Save frame positions
			local function SaveAllFrames()
				for k, v in pairs(FrameTable) do
					local vf = v:GetName()
					-- Stop real frames from moving
					v:StopMovingOrSizing()
					-- Save frame positions
					LeaPlusDB["Frames"][vf]["Point"], void, LeaPlusDB["Frames"][vf]["Relative"], LeaPlusDB["Frames"][vf]["XOffset"], LeaPlusDB["Frames"][vf]["YOffset"] = v:GetPoint()
					v:SetMovable(true)
					v:ClearAllPoints()
					v:SetPoint(LeaPlusDB["Frames"][vf]["Point"], UIParent, LeaPlusDB["Frames"][vf]["Relative"], LeaPlusDB["Frames"][vf]["XOffset"], LeaPlusDB["Frames"][vf]["YOffset"])
					LeaPlusFramesSaveCache(vf)
				end
			end

			-- Prevent changes during combat
			SideFrames:RegisterEvent("PLAYER_REGEN_DISABLED")
			SideFrames:SetScript("OnEvent", function()
				-- Hide controls frame
				SideFrames:Hide()
				-- Hide drag frames
				for k,void in pairs(FrameTable) do
					LeaPlusLC[k]:Hide()
				end
				-- Save frame positions
				SaveAllFrames()
			end)

			-- Create drag frames
			local function LeaPlusMakeDrag(dragframe,realframe)

				local dragframe = CreateFrame("Frame", nil)
				LeaPlusLC[dragframe] = dragframe
				dragframe:SetSize(realframe:GetSize())
				if realframe:GetName() == "BuffFrame" then
					dragframe:SetPoint("TOPRIGHT", realframe, "TOPRIGHT", 0, 2.5)
				else
					dragframe:SetPoint("TOP", realframe, "TOP", 0, 2.5)
				end
				dragframe:SetBackdropColor(0.0, 0.5, 1.0);
				dragframe:SetBackdrop({ 
					edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
					tile = false, tileSize = 0, edgeSize = 16,
					insets = { left = 0, right = 0, top = 0, bottom = 0 }})
				dragframe:SetToplevel(true)
				dragframe:SetFrameStrata("HIGH")

				-- Set frame clamps
				if realframe:GetName() == "BuffFrame" then
					realframe:SetClampedToScreen(true)
				else
					realframe:SetClampedToScreen(false)
				end

				-- Hide the drag frame and make real frame movable
				dragframe:Hide()
				realframe:SetMovable(true)

				-- Click handler
				dragframe:SetScript("OnMouseDown", function(self, btn)

					-- Start dragging if left clicked
					if btn == "LeftButton" then
						realframe:SetMovable(true)
						realframe:StartMoving()
					end

					-- Set all drag frames to blue then tint the selected frame to green
					for k,v in pairs(FrameTable) do
						LeaPlusLC[k].t:SetColorTexture(0.0, 0.5, 1.0, 0.5)
					end
					dragframe.t:SetColorTexture(0.0, 1.0, 0.0, 0.5)

					-- Set currentframe variable to selected frame and set the scale slider value
					currentframe = realframe:GetName()
					LeaPlusCB["FrameScale"]:SetValue(LeaPlusDB["Frames"][currentframe]["Scale"])

				end)

				dragframe:SetScript("OnMouseUp", function()
					-- Save frame positions
					SaveAllFrames()
				end)
	
				dragframe.t = dragframe:CreateTexture()
				dragframe.t:SetAllPoints()
				dragframe.t:SetColorTexture(0.0, 0.5, 1.0, 0.5)
				dragframe.t:SetAlpha(0.5)

				dragframe.f = dragframe:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
				dragframe.f:SetPoint('CENTER', 0, 0)

				-- Add titles
				if realframe:GetName() == "PlayerFrame" 					then dragframe.f:SetText(L["Player"]) end
				if realframe:GetName() == "TargetFrame" 					then dragframe.f:SetText(L["Target"]) end
				if realframe:GetName() == "MirrorTimer1" 					then dragframe.f:SetText(L["Timer"]) end
				if realframe:GetName() == "LeaPlusTopCenterContainerHolder" then dragframe.f:SetText(L["Widget"] .. "|n" .. L["Top Center"]) end
				if realframe:GetName() == "BuffFrame" 						then dragframe.f:SetText(L["Buffs"]) end
				return LeaPlusLC[dragframe]

			end
			
			for k,v in pairs(FrameTable) do
				LeaPlusLC[k] = LeaPlusMakeDrag(k,v)
			end

			-- Set frame scales
			for k,v in pairs(FrameTable) do
				local vf = v:GetName()
				_G[vf]:SetScale(LeaPlusDB["Frames"][vf]["Scale"])
				LeaPlusLC[k]:SetScale(LeaPlusDB["Frames"][vf]["Scale"])
			end
			ComboFrame:SetScale(LeaPlusDB["Frames"]["TargetFrame"]["Scale"])
			TemporaryEnchantFrame:SetScale(LeaPlusDB["Frames"]["BuffFrame"]["Scale"])
			UIWidgetTopCenterContainerFrame:SetScale(LeaPlusDB["Frames"]["LeaPlusTopCenterContainerHolder"]["Scale"])
			LeaPlusTopCenterContainerHolder:SetScale(LeaPlusDB["Frames"]["LeaPlusTopCenterContainerHolder"]["Scale"])

			-- Load defaults first then overwrite with saved values if they exist
			LeaPlusFramesDefaults()
			if LeaPlusDB["Frames"] then
				for k,v in pairs(FrameTable) do
					local vf = v:GetName()
					if LeaPlusDB["Frames"][vf] then
						if LeaPlusDB["Frames"][vf]["Point"] and LeaPlusDB["Frames"][vf]["Relative"] and LeaPlusDB["Frames"][vf]["XOffset"] and LeaPlusDB["Frames"][vf]["YOffset"] then
							LeaPlusFramesSaveCache(vf)
							_G[vf]:SetMovable(true)
							_G[vf]:ClearAllPoints()
							_G[vf]:SetPoint(LeaPlusDB["Frames"][vf]["Point"], UIParent, LeaPlusDB["Frames"][vf]["Relative"], LeaPlusDB["Frames"][vf]["XOffset"], LeaPlusDB["Frames"][vf]["YOffset"])
						end
					end
				end
			end

			-- Prevent changes to buff frame position
			hooksecurefunc(BuffFrame, "SetPoint", function()
				if LeaPlusDB["Frames"]["BuffFrame"]["Point"] and LeaPlusDB["Frames"]["BuffFrame"]["Relative"] and LeaPlusDB["Frames"]["BuffFrame"]["XOffset"] and LeaPlusDB["Frames"]["BuffFrame"]["YOffset"] then
					BuffFrame:SetMovable(true)
					BuffFrame:ClearAllPoints()
					buffSetPos(BuffFrame, LeaPlusDB["Frames"]["BuffFrame"]["Point"], UIParent, LeaPlusDB["Frames"]["BuffFrame"]["Relative"], LeaPlusDB["Frames"]["BuffFrame"]["XOffset"], LeaPlusDB["Frames"]["BuffFrame"]["YOffset"])
				end
			end)

			-- Add move button
			LeaPlusCB["MoveFramesButton"]:SetScript("OnClick", function()
				if LeaPlusLC:PlayerInCombat() then
					return
				else
					if IsShiftKeyDown() and IsControlKeyDown() then
						-- Preset profile
						LeaFramesSetPos(PlayerFrame						, "TOPLEFT"	, UIParent, "TOPLEFT"	,	"-35"	, "-14")
						LeaFramesSetPos(TargetFrame						, "TOPLEFT"	, UIParent, "TOPLEFT"	,	"190"	, "-14")
						LeaFramesSetPos(MirrorTimer1					, "TOP"		, UIParent, "TOP"		,	"0"		, "-120")
						LeaFramesSetPos(LeaPlusTopCenterContainerHolder	, "TOP"		, UIParent, "TOP"		,	"0"		, "-432")
						LeaFramesSetPos(BuffFrame						, "TOPRIGHT", UIParent, "TOPRIGHT"	,	"-271"	, "0")
						-- Player
						LeaPlusDB["Frames"]["PlayerFrame"]["Scale"] = 1.20
						PlayerFrame:SetScale(LeaPlusDB["Frames"]["PlayerFrame"]["Scale"])
						LeaPlusLC["DragPlayerFrame"]:SetScale(LeaPlusDB["Frames"]["PlayerFrame"]["Scale"])
						-- Target
						LeaPlusDB["Frames"]["TargetFrame"]["Scale"] = 1.20
						TargetFrame:SetScale(LeaPlusDB["Frames"]["TargetFrame"]["Scale"])
						LeaPlusLC["DragTargetFrame"]:SetScale(LeaPlusDB["Frames"]["TargetFrame"]["Scale"])
						-- LeaPlusTopCenterContainerHolder
						LeaPlusDB["Frames"]["LeaPlusTopCenterContainerHolder"]["Scale"] = 1.25
						UIWidgetTopCenterContainerFrame:SetScale(LeaPlusDB["Frames"]["LeaPlusTopCenterContainerHolder"]["Scale"])
						LeaPlusTopCenterContainerHolder:SetScale(LeaPlusDB["Frames"]["LeaPlusTopCenterContainerHolder"]["Scale"])
						LeaPlusLC["DragLeaPlusTopCenterContainerHolder"]:SetScale(LeaPlusDB["Frames"]["LeaPlusTopCenterContainerHolder"]["Scale"])
						-- Buff
						LeaPlusDB["Frames"]["BuffFrame"]["Scale"] = 0.80
						BuffFrame:SetScale(LeaPlusDB["Frames"]["BuffFrame"]["Scale"])
						LeaPlusLC["DragBuffFrame"]:SetScale(LeaPlusDB["Frames"]["BuffFrame"]["Scale"])
						-- Set the slider to the selected frame (if there is one)
						if currentframe then LeaPlusCB["FrameScale"]:SetValue(LeaPlusDB["Frames"][currentframe]["Scale"]); end
						-- Save locations
						for k,v in pairs(FrameTable) do
							local vf = v:GetName()
							LeaPlusDB["Frames"][vf]["Point"], void, LeaPlusDB["Frames"][vf]["Relative"], LeaPlusDB["Frames"][vf]["XOffset"], LeaPlusDB["Frames"][vf]["YOffset"] = _G[vf]:GetPoint()
							LeaPlusFramesSaveCache(vf)
						end
					else
						-- Show mover frame
						SideFrames:Show()
						LeaPlusLC:HideFrames()

						-- Find out if the UI has a non-standard scale
						if GetCVar("useuiscale") == "1" then
							LeaPlusLC["gscale"] = GetCVar("uiscale")
						else
							LeaPlusLC["gscale"] = 1
						end

						-- Set all scaled sizes
						for k,v in pairs(FrameTable) do
							LeaPlusLC[k]:SetWidth(v:GetWidth() * LeaPlusLC["gscale"])
							LeaPlusLC[k]:SetHeight(v:GetHeight() * LeaPlusLC["gscale"])
						end

						-- Set specific scaled sizes for stubborn frames
						LeaPlusLC["DragMirrorTimer1"]:SetSize(206 * LeaPlusLC["gscale"], 50 * LeaPlusLC["gscale"]);
						LeaPlusLC["DragLeaPlusTopCenterContainerHolder"]:SetSize(160 * LeaPlusLC["gscale"], 79 * LeaPlusLC["gscale"]);
						LeaPlusLC["DragBuffFrame"]:SetSize(280 * LeaPlusLC["gscale"], 225 * LeaPlusLC["gscale"]);
					end
				end
			end)

		end

		----------------------------------------------------------------------
		-- Hide chat buttons
		----------------------------------------------------------------------

		if LeaPlusLC["NoChatButtons"] == "On" then

			-- Create hidden frame to store unwanted frames (more efficient than creating functions)
			local tframe = CreateFrame("FRAME")
			tframe:Hide()

			-- Function to enable mouse scrolling with CTRL and SHIFT key modifiers
			local function AddMouseScroll(chtfrm)
				if _G[chtfrm] then
					_G[chtfrm]:SetScript("OnMouseWheel", function(self, direction)
						if direction == 1 then
							if IsControlKeyDown() then
								self:ScrollToTop()
							elseif IsShiftKeyDown() then
								self:PageUp()
							else
								self:ScrollUp()
							end
						else
							if IsControlKeyDown() then
								self:ScrollToBottom()
							elseif IsShiftKeyDown() then
								self:PageDown()
							else
								self:ScrollDown()
							end
						end
					end)
					_G[chtfrm]:EnableMouseWheel(true)
				end
			end

			-- Function to hide chat buttons
			local function HideButtons(chtfrm)
				_G[chtfrm .. "ButtonFrameUpButton"]:SetParent(tframe)
				_G[chtfrm .. "ButtonFrameDownButton"]:SetParent(tframe)
				_G[chtfrm .. "ButtonFrameMinimizeButton"]:SetParent(tframe)
				_G[chtfrm .. "ButtonFrameUpButton"]:Hide();
				_G[chtfrm .. "ButtonFrameDownButton"]:Hide();
				_G[chtfrm .. "ButtonFrameMinimizeButton"]:Hide();
				_G[chtfrm .. "ButtonFrame"]:SetSize(0.1,0.1)
			end

			-- Function to highlight chat tabs and click to scroll to bottom
			local function HighlightTabs(chtfrm)
				-- Set position of bottom button
				_G[chtfrm .. "ButtonFrameBottomButtonFlash"]:SetTexture("Interface/BUTTONS/GRADBLUE.png")
				_G[chtfrm .. "ButtonFrameBottomButton"]:ClearAllPoints()
				_G[chtfrm .. "ButtonFrameBottomButton"]:SetPoint("BOTTOM",_G[chtfrm .. "Tab"],0,-6)
				_G[chtfrm .. "ButtonFrameBottomButton"]:Show()
				_G[chtfrm .. "ButtonFrameBottomButtonFlash"]:SetAlpha(0.5)
				_G[chtfrm .. "ButtonFrameBottomButton"]:SetWidth(_G[chtfrm .. "Tab"]:GetWidth()-10)
				_G[chtfrm .. "ButtonFrameBottomButton"]:SetHeight(24)

				-- Resize bottom button according to tab size
				_G[chtfrm .. "Tab"]:SetScript("OnSizeChanged", function()
					for j = 1, 50 do
						-- Resize bottom button to tab width
						if _G["ChatFrame" .. j .. "ButtonFrameBottomButton"] then
							_G["ChatFrame" .. j .. "ButtonFrameBottomButton"]:SetWidth(_G["ChatFrame" .. j .. "Tab"]:GetWidth()-10)
						end
					end
					-- If combat log is hidden, resize it's bottom button
					if LeaPlusLC["NoCombatLogTab"] == "On" then
						if _G["ChatFrame2ButtonFrameBottomButton"] then
							-- Resize combat log bottom button
							_G["ChatFrame2ButtonFrameBottomButton"]:SetWidth(0.1);
						end
					end
				end)

				-- Remove click from the bottom button
				_G[chtfrm .. "ButtonFrameBottomButton"]:SetScript("OnClick", nil)

				-- Remove textures
				_G[chtfrm .. "ButtonFrameBottomButton"]:SetNormalTexture("")
				_G[chtfrm .. "ButtonFrameBottomButton"]:SetHighlightTexture("")
				_G[chtfrm .. "ButtonFrameBottomButton"]:SetPushedTexture("")

				-- Always scroll to bottom when clicking a tab
				_G[chtfrm .. "Tab"]:HookScript("OnClick", function(self,arg1)
					if arg1 == "LeftButton" then
						_G[chtfrm]:ScrollToBottom();
					end
				end)

			end

			-- Hide chat menu buttons
			ChatFrameMenuButton:SetParent(tframe)
			ChatFrameChannelButton:SetParent(tframe)

			-- Set options for normal and existing chat frames
			for i = 1, 50 do
				if _G["ChatFrame" .. i] then
					AddMouseScroll("ChatFrame" .. i);
					HideButtons("ChatFrame" .. i);
					HighlightTabs("ChatFrame" .. i)
				end
			end

			-- Do the functions above for temporary chat frames
			hooksecurefunc("FCF_OpenTemporaryWindow", function(chatType)
				local cf = FCF_GetCurrentChatFrame():GetName() or nil
				if cf then
					-- Set options for temporary frame
					AddMouseScroll(cf)
					HideButtons(cf)
					HighlightTabs(cf)
					-- Resize flashing alert to match tab width
					_G[cf .. "Tab"]:SetScript("OnSizeChanged", function()
						_G[cf .. "ButtonFrameBottomButton"]:SetWidth(_G[cf .. "Tab"]:GetWidth()-10)
					end)
				end
			end)

		end

		----------------------------------------------------------------------
		-- Recent chat window
		----------------------------------------------------------------------

		if LeaPlusLC["RecentChatWindow"] == "On" then

			-- Create recent chat frame (not parenting to UIParent due to editbox scaling issue)
			local editFrame = CreateFrame("ScrollFrame", nil, nil, "InputScrollFrameTemplate")

			-- Toggle frame with UIParent
			local hideUI = false
			local function HideRecentChatFrame() if editFrame:IsShown() then hideUI = true editFrame:Hide() end	end
			local function ShowRecentChatFrame() if hideUI and not PetBattleFrame:IsShown() then editFrame:Show() hideUI = false end end
			hooksecurefunc(UIParent, "Hide", HideRecentChatFrame)
			hooksecurefunc(UIParent, "Show", ShowRecentChatFrame)

			-- Set frame parameters
			editFrame:ClearAllPoints()
			editFrame:SetPoint("BOTTOM", 0, 130)
			editFrame:SetSize(470, 170)
			editFrame:SetFrameStrata("MEDIUM")
			editFrame:SetToplevel(true)
			editFrame:Hide()
			editFrame.CharCount:Hide()

			-- Add background color
			editFrame.t = editFrame:CreateTexture(nil, "BACKGROUND")
			editFrame.t:SetAllPoints()
			editFrame.t:SetColorTexture(0.00, 0.00, 0.0, 0.6)

			-- Set textures
			editFrame.LeftTex:SetTexture(editFrame.RightTex:GetTexture()); editFrame.LeftTex:SetTexCoord(1, 0, 0, 1)
			editFrame.BottomTex:SetTexture(editFrame.TopTex:GetTexture()); editFrame.BottomTex:SetTexCoord(0, 1, 1, 0)
			editFrame.BottomRightTex:SetTexture(editFrame.TopRightTex:GetTexture()); editFrame.BottomRightTex:SetTexCoord(0, 1, 1, 0)
			editFrame.BottomLeftTex:SetTexture(editFrame.TopRightTex:GetTexture()); editFrame.BottomLeftTex:SetTexCoord(1, 0, 1, 0)
			editFrame.TopLeftTex:SetTexture(editFrame.TopRightTex:GetTexture()); editFrame.TopLeftTex:SetTexCoord(1, 0, 0, 1)

			-- Create editbox
			local editBox = editFrame.EditBox
			editBox:SetAltArrowKeyMode(false)
			editBox:SetTextInsets(4, 4, 4, 4)
			editBox:SetWidth(editFrame:GetWidth() - 30)

			-- Close frame with right-click of editframe or editbox
			local function CloseRecentChatWindow()
				editBox:SetText("")
				editBox:ClearFocus()
				editFrame:Hide()
			end

			editFrame:SetScript("OnMouseDown", function(self, btn)
				if btn == "RightButton" then CloseRecentChatWindow() end
			end)

			editBox:SetScript("OnMouseDown", function(self, btn)
				if btn == "RightButton" then CloseRecentChatWindow() end
			end)

			-- Disable text changes while still allowing editing controls to work
			editBox:EnableKeyboard(false)
			editBox:SetScript("OnKeyDown", function() end)

			--- Clear highlighted text if escape key is pressed
			editBox:HookScript("OnEscapePressed", function()
				editBox:HighlightText(0, 0)
				editBox:ClearFocus()
			end)

			-- Clear highlighted text and clear focus if enter key is pressed
			editBox:SetScript("OnEnterPressed", function() 
				editBox:HighlightText(0, 0)
				editBox:ClearFocus()
			end)

			-- Populate recent chat frame with chat messages
			local function ShowChatbox(chtfrm)
				editBox:SetText("")
				local NumMsg = chtfrm:GetNumMessages()
				local StartMsg = 1
				if NumMsg > 128 then StartMsg = NumMsg - 127 end
				local totalMsgCount = 0
				for iMsg = StartMsg, NumMsg do
					local chatMessage = chtfrm:GetMessageInfo(iMsg)
					if chatMessage then
						--chatMessage = gsub(chatMessage, "|T.-|t", "") -- Remove textures
						--chatMessage = gsub(chatMessage, "{.-}", "") -- Remove ellipsis
						editBox:Insert(chatMessage .. "|n")
					end
					totalMsgCount = totalMsgCount + 1
				end
				if totalMsgCount == 1 then
					editBox:Insert("|cff88aabb" .. totalMsgCount .. " " .. L["message shown."] .. "  ")
				else
					editBox:Insert("|cff88aabb" .. totalMsgCount .. " " .. L["messages shown."] .. "  ")
				end
				editBox:Insert(L["Right-click to close."])
				editFrame:SetVerticalScroll(0)
				C_Timer.After(0.1, function() editFrame.ScrollBar.ScrollDownButton:Click() end)
				editFrame:Show()
				editBox:ClearFocus()
			end

			-- Hook normal chat frame tab clicks
			for i = 1, 50 do
				if _G["ChatFrame" .. i] then
					_G["ChatFrame" .. i .. "Tab"]:HookScript("OnClick", function()
						if IsControlKeyDown() then
							ShowChatbox(_G["ChatFrame" .. i])
						end
					end)
				end
			end

			-- Hook temporary chat frame tab clicks
			hooksecurefunc("FCF_OpenTemporaryWindow", function()
				local cf = FCF_GetCurrentChatFrame():GetName() or nil
				if cf then
					_G[cf .. "Tab"]:HookScript("OnClick", function()
						if IsControlKeyDown() then
							ShowChatbox(_G[cf])
						end
					end)
				end
			end)

		end

		----------------------------------------------------------------------
		-- Show cooldowns
		----------------------------------------------------------------------

		if LeaPlusLC["ShowCooldowns"] == "On" then

			-- Create main table structure in saved variables if it doesn't exist
			if LeaPlusDB["Cooldowns"] == nil then
				LeaPlusDB["Cooldowns"] = {}
			end

			-- Create class tables if they don't exist
			local classList = {"WARRIOR", "PALADIN", "HUNTER", "SHAMAN", "ROGUE", "DRUID", "MAGE", "WARLOCK", "PRIEST"}
			for index = 1, #classList do
				if LeaPlusDB["Cooldowns"][classList[index]] == nil then
					LeaPlusDB["Cooldowns"][classList[index]] = {}
				end
			end

			-- Get current class
			local PlayerClass = select(2, UnitClass("player"))
			local activeSpec = 1 -- Fixed to 1 for Classic

			-- Create local tables to store cooldown frames and editboxes
			local icon = {} -- Used to store cooldown frames
			local SpellEB = {} -- Used to store editbox values
			local iCount = 5 -- Number of cooldowns

			-- Create cooldown frames
			for i = 1, iCount do

				-- Create cooldown frame
				icon[i] = CreateFrame("Frame", nil, UIParent)
				icon[i]:SetFrameStrata("BACKGROUND")
				icon[i]:SetWidth(20)
				icon[i]:SetHeight(20)

				-- Create cooldown icon
				icon[i].c = CreateFrame("Cooldown", nil, icon[i], "CooldownFrameTemplate")
				icon[i].c:SetAllPoints()
				icon[i].c:SetReverse(true)

				-- Create blank texture (will be assigned a cooldown texture later)
				icon[i].t = icon[i]:CreateTexture(nil,"BACKGROUND")
				icon[i].t:SetAllPoints()

				-- Show icon above target frame and set initial scale
				icon[i]:ClearAllPoints()
				icon[i]:SetPoint("TOPLEFT", TargetFrame, "TOPLEFT", 6 + (22 * (i - 1)), 5)
				icon[i]:SetScale(TargetFrame:GetScale())

				-- Show tooltip
				icon[i]:SetScript("OnEnter", function(self)
					GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 15, -25)
					GameTooltip:SetText(GetSpellInfo(LeaPlusCB["Spell" .. i]:GetText()))
				end)

				-- Hide tooltip
				icon[i]:SetScript("OnLeave", GameTooltip_Hide)

			end

			-- Change cooldown icon scale when target frame scale changes
			TargetFrame:HookScript("OnSizeChanged", function()
				for i = 1, iCount do
					icon[i]:SetScale(TargetFrame:GetScale())
				end
			end)

			-- Function to show cooldown textures in the cooldown frames (run when icons are loaded or changed)
			local function ShowIcon(i, id, owner)

				local void

				-- Get spell information
				local spell, void, path = GetSpellInfo(id)
				if spell and path then

					-- Set icon texture to the spell texture
					icon[i].t:SetTexture(path)

					-- Set top level and raise frame strata (ensures tooltips show properly)
					icon[i]:SetToplevel(true)
					icon[i]:SetFrameStrata("LOW")

					-- Handle events
					icon[i]:RegisterUnitEvent("UNIT_AURA", owner)
					icon[i]:RegisterUnitEvent("UNIT_PET", "player")
					icon[i]:SetScript("OnEvent", function(self, event, arg1)

						-- If pet was dismissed (or otherwise disappears such as when flying), hide pet cooldowns
						if event == "UNIT_PET" then
							if not UnitExists("pet") then
								if LeaPlusDB["Cooldowns"][PlayerClass]["S" .. activeSpec .. "R" .. i .. "Pet"] then
									icon[i]:Hide()
								end
							end

						-- Ensure cooldown belongs to the owner we are watching (player or pet)
						elseif arg1 == owner then

							-- Hide the cooldown frame (required for cooldowns to disappear after the duration)
							icon[i]:Hide()

							-- If buff matches cooldown we want, start the cooldown
							for q = 1, 40 do
								local void, void, void, void, length, expire, void, void, void, spellID = UnitBuff(owner, q)
								if spellID and id == spellID then
									icon[i]:Show()
									local start = expire - length
									CooldownFrame_Set(icon[i].c, start, length, 1)
								end
							end

						end
					end)

				else

					-- Spell does not exist so stop watching it
					icon[i]:SetScript("OnEvent", nil)
					icon[i]:Hide()

				end

			end

			-- Create configuration panel
			local CooldownPanel = LeaPlusLC:CreatePanel("Cooldowns", "CooldownPanel")

			-- Function to refresh the editbox tooltip with the spell name
			local function RefSpellTip(self,elapsed)
				local spellinfo, void, icon = GetSpellInfo(self:GetText())
				if spellinfo and spellinfo ~= "" and icon ~= "" then
					GameTooltip:SetOwner(self, "ANCHOR_NONE")
					GameTooltip:ClearAllPoints()
					GameTooltip:SetPoint("RIGHT", self, "LEFT", -10, 0)
					GameTooltip:SetText("|T" .. icon .. ":0|t " .. spellinfo, nil, nil, nil, nil, true)
				else
					GameTooltip:Hide()
				end
			end

			-- Function to create spell ID editboxes and pet checkboxes
			local function MakeSpellEB(num, x, y, tab, shifttab)

				-- Create editbox for spell ID
                SpellEB[num] = LeaPlusLC:CreateEditBox("Spell" .. num, CooldownPanel, 70, 6, "TOPLEFT", x, y - 20, "Spell" .. tab, "Spell" .. shifttab)
				SpellEB[num]:SetNumeric(true)

				-- Set initial value (for current spec)
				SpellEB[num]:SetText(LeaPlusDB["Cooldowns"][PlayerClass]["S" .. activeSpec .. "R" .. num .. "Idn"] or "")

				-- Refresh tooltip when mouse is hovering over the editbox
				SpellEB[num]:SetScript("OnEnter", function()
					SpellEB[num]:SetScript("OnUpdate", RefSpellTip)
				end)
				SpellEB[num]:SetScript("OnLeave", function()
					SpellEB[num]:SetScript("OnUpdate", nil)
					GameTooltip:Hide()
				end)

				-- Create checkbox for pet cooldown
				LeaPlusLC:MakeCB(CooldownPanel, "Spell" .. num .."Pet", "", 462, y - 20, false, "")
				LeaPlusCB["Spell" .. num .."Pet"]:SetHitRectInsets(0, 0, 0, 0)

			end

			-- Add titles
			LeaPlusLC:MakeTx(CooldownPanel, "Spell ID", 384, -92)
			LeaPlusLC:MakeTx(CooldownPanel, "Pet", 462, -92)

			-- Add editboxes and checkboxes
			MakeSpellEB(1, 386, -92, "2", "5")
			MakeSpellEB(2, 386, -122, "3", "1")
			MakeSpellEB(3, 386, -152, "4", "2")
			MakeSpellEB(4, 386, -182, "5", "3")
			MakeSpellEB(5, 386, -212, "1", "4")

			-- Add checkboxes
			LeaPlusLC:MakeTx(CooldownPanel, "Settings", 16, -72)
			LeaPlusLC:MakeCB(CooldownPanel, "ShowCooldownID", "Show the spell ID in buff icon tooltips", 16, -92, false, "If checked, spell IDs will be shown in buff icon tooltips located in the buff frame and under the target frame.");
			LeaPlusLC:MakeCB(CooldownPanel, "NoCooldownDuration", "Hide cooldown duration numbers (if enabled)", 16, -112, false, "If checked, cooldown duration numbers will not be shown over the cooldowns.|n|nIf unchecked, cooldown duration numbers will be shown over the cooldowns if they are enabled in the game options panel ('ActionBars' menu).")

			-- Function to save the panel control settings and refresh the cooldown icons
			local function SavePanelControls()
				for i = 1, iCount do

					-- Refresh the cooldown texture
					icon[i].c:SetCooldown(0,0)

					-- Save control states to globals
					LeaPlusDB["Cooldowns"][PlayerClass]["S" .. activeSpec .. "R" .. i .. "Idn"] = SpellEB[i]:GetText()
					LeaPlusDB["Cooldowns"][PlayerClass]["S" .. activeSpec .. "R" .. i .. "Pet"] = LeaPlusCB["Spell" .. i .."Pet"]:GetChecked()

					-- Set cooldowns
					if LeaPlusCB["Spell" .. i .."Pet"]:GetChecked() then
						ShowIcon(i, tonumber(SpellEB[i]:GetText()), "pet")
					else
						ShowIcon(i, tonumber(SpellEB[i]:GetText()), "player")
					end

					-- Show or hide cooldown duration
					if LeaPlusLC["NoCooldownDuration"] == "On" then
						icon[i].c:SetHideCountdownNumbers(true)
					else
						icon[i].c:SetHideCountdownNumbers(false)
					end

					-- Show or hide cooldown icons depending on current buffs
					local newowner
					local newspell = tonumber(SpellEB[i]:GetText())

					if newspell then
						if LeaPlusDB["Cooldowns"][PlayerClass]["S" .. activeSpec .. "R" .. i .. "Pet"] then 
							newowner = "pet" 
						else
							newowner = "player"
						end
						-- Hide cooldown icon
						icon[i]:Hide()

						-- If buff matches spell we want, show cooldown icon
						for q = 1, 40 do
							local void, void, void, void, length, expire, void, void, void, spellID = UnitBuff(newowner, q)
							if spellID and newspell == spellID then
								icon[i]:Show()
								-- Set the cooldown to the buff cooldown
								CooldownFrame_Set(icon[i].c, expire - length, length, 1)
							end
						end
					end

				end

			end

			-- Update cooldown icons when checkboxes are clicked
			LeaPlusCB["NoCooldownDuration"]:HookScript("OnClick", SavePanelControls)

			-- Help button tooltip
			CooldownPanel.h.tiptext = L["Enter the spell IDs for the cooldown icons that you want to see.|n|nIf a cooldown icon normally appears under the pet frame, check the pet checkbox.|n|nCooldown icons are saved to your class."]

			-- Back button handler
			CooldownPanel.b:SetScript("OnClick", function()
				CooldownPanel:Hide(); LeaPlusLC["PageF"]:Show(); LeaPlusLC["Page5"]:Show()
				return
			end)

			-- Reset button handler
			CooldownPanel.r:SetScript("OnClick", function()
				-- Reset the checkboxes
				LeaPlusLC["ShowCooldownID"] = "On"
				LeaPlusLC["NoCooldownDuration"] = "On"
				for i = 1, iCount do
					-- Reset the panel controls
					SpellEB[i]:SetText("");
					LeaPlusDB["Cooldowns"][PlayerClass]["S" .. activeSpec .. "R" .. i .. "Pet"] = false
					-- Hide cooldowns and clear scripts
					icon[i]:Hide()
					icon[i]:SetScript("OnEvent", nil)
				end
				CooldownPanel:Hide(); CooldownPanel:Show()
			end)

			-- Save settings when changed
			for i = 1, iCount do
				-- Set initial checkbox states
				LeaPlusCB["Spell" .. i .."Pet"]:SetChecked(LeaPlusDB["Cooldowns"][PlayerClass]["S" .. activeSpec .. "R" .. i .. "Pet"])
				-- Set checkbox states when shown
				LeaPlusCB["Spell" .. i .."Pet"]:SetScript("OnShow", function()
					LeaPlusCB["Spell" .. i .."Pet"]:SetChecked(LeaPlusDB["Cooldowns"][PlayerClass]["S" .. activeSpec .. "R" .. i .. "Pet"])
				end)
				-- Set states when changed
				SpellEB[i]:SetScript("OnTextChanged", SavePanelControls)
				LeaPlusCB["Spell" .. i .."Pet"]:SetScript("OnClick", SavePanelControls)
			end

			-- Show cooldowns on startup
			SavePanelControls()

			-- Show panel when configuration button is clicked
			LeaPlusCB["CooldownsButton"]:SetScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- No preset profile
				else
					-- Show panel
					CooldownPanel:Show()
					LeaPlusLC:HideFrames()
				end
			end)

			-- Create class tag banner fontstring
			local classTagBanner = CooldownPanel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
			local myClassName = UnitClass("player")
			classTagBanner:SetPoint("TOPLEFT", 384, -72)
			classTagBanner:SetText(myClassName)

			-- Function to show spell ID in tooltips
			local function CooldownIDFunc(unit, target, index)
				if LeaPlusLC["ShowCooldownID"] == "On" then
					local spellid = select(10, UnitAura(target, index))
					if spellid then
						GameTooltip:AddLine(L["Spell ID"] .. ": " .. spellid)
						GameTooltip:Show()
					end
				end
			end

			-- Add spell ID to tooltip when buff frame buffs are hovered
			hooksecurefunc(GameTooltip, 'SetUnitAura', CooldownIDFunc)   

			-- Add spell ID to tooltip when target frame buffs are hovered
			hooksecurefunc(GameTooltip, 'SetUnitBuff', CooldownIDFunc)

		end

		----------------------------------------------------------------------
		-- Combat plates
		----------------------------------------------------------------------

		if LeaPlusLC["CombatPlates"] == "On" then

			-- Toggle nameplates with combat
			local f = CreateFrame("Frame")
			f:RegisterEvent("PLAYER_REGEN_DISABLED")
			f:RegisterEvent("PLAYER_REGEN_ENABLED")
			f:SetScript("OnEvent", function(self, event)
				SetCVar("nameplateShowEnemies", event == "PLAYER_REGEN_DISABLED" and 1 or 0)
			end)

			-- Run combat check on startup
			SetCVar("nameplateShowEnemies", UnitAffectingCombat("player") and 1 or 0)

		end

		----------------------------------------------------------------------
		-- Manage tooltip
		----------------------------------------------------------------------

		if LeaPlusLC["TipModEnable"] == "On" then

			----------------------------------------------------------------------
			--	Position the tooltip
			----------------------------------------------------------------------

			-- Position general tooltip
			hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
				if LeaPlusLC["TipMoveTip"] == "On" then
					if (not tooltip or not parent) then
						return
					end
					local a,b,c,d,e = tooltip:GetPoint()
					if a ~= "BOTTOMRIGHT" or c ~= "BOTTOMRIGHT" then
						tooltip:ClearAllPoints()
					end
					tooltip:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", LeaPlusLC["TipOffsetX"], LeaPlusLC["TipOffsetY"]);
				end
			end)

			----------------------------------------------------------------------
			--	Tooltip Configuration
			----------------------------------------------------------------------

			local LT = {}

			-- Create locale specific level string
			LT["LevelLocale"] = strtrim(strtrim(string.gsub(TOOLTIP_UNIT_LEVEL, "%%s", "")))

			-- Tooltip
			LT["ColorBlind"] = GetCVar("colorblindMode")

			-- 	Create drag frame
			local TipDrag = CreateFrame("Frame", nil, UIParent)
			TipDrag:SetToplevel(true);
			TipDrag:SetClampedToScreen(false);
			TipDrag:SetSize(130, 64);
			TipDrag:Hide();
			TipDrag:SetFrameStrata("TOOLTIP")
			TipDrag:SetMovable(true)
			TipDrag:SetBackdropColor(0.0, 0.5, 1.0);
			TipDrag:SetBackdrop({ 
				edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
				tile = false, tileSize = 0, edgeSize = 16,
				insets = { left = 0, right = 0, top = 0, bottom = 0 }});

			-- Show text in drag frame
			TipDrag.f = TipDrag:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
			TipDrag.f:SetPoint("CENTER", 0, 0)
			TipDrag.f:SetText(L["Tooltip"])

			-- Create texture
			TipDrag.t = TipDrag:CreateTexture();
			TipDrag.t:SetAllPoints();
			TipDrag.t:SetColorTexture(0.0, 0.5, 1.0, 0.5);
			TipDrag.t:SetAlpha(0.5);

			---------------------------------------------------------------------------------------------------------
			-- Tooltip movement settings
			---------------------------------------------------------------------------------------------------------

			-- Create tooltip customisation side panel
			local SideTip = LeaPlusLC:CreatePanel("Tooltip", "SideTip")

			-- Add controls
			LeaPlusLC:MakeTx(SideTip, "Settings", 16, -72)
			LeaPlusLC:MakeCB(SideTip, "TipMoveTip", "Reposition the tooltip", 16, -92, false, "If checked, you will be able to reposition the tooltip.")
			LeaPlusLC:MakeCB(SideTip, "TipShowGuild", "Show guild names", 16, -112, false, "If checked, guild names will be shown.  Guild ranks will also be shown for players in your guild.")
			LeaPlusLC:MakeCB(SideTip, "TipShowTarget", "Show the unit's target", 16, -132, false, "If checked, unit targets will be shown.")
			LeaPlusLC:MakeCB(SideTip, "TipBackSimple", "Color the backdrops based on faction", 16, -152, false, "If checked, backdrops will be tinted blue (friendly) or red (hostile).")
			LeaPlusLC:MakeCB(SideTip, "TipHideInCombat", "Hide tooltips for world units during combat", 16, -172, false, "If checked, tooltips for world units will be hidden during combat.|n|nYou can hold the shift key down to override this setting.")

			LeaPlusLC:MakeTx(SideTip, "Scale", 356, -72)
			LeaPlusLC:MakeSL(SideTip, "LeaPlusTipSize", "Drag to set the tooltip scale.", 0.50, 2.00, 0.05, 356, -92, "%.2f")

			-- Help button hidden
			SideTip.h:Hide()

			-- Back button handler
			SideTip.b:SetScript("OnClick", function() 
				SideTip:Hide();
				if TipDrag:IsShown() then
					TipDrag:Hide();
				end
				LeaPlusLC["PageF"]:Show();
				LeaPlusLC["Page5"]:Show();
				return
			end) 

			-- Reset button handler
			SideTip.r:SetScript("OnClick", function()
				LeaPlusLC["TipMoveTip"] = "On";
				LeaPlusLC["TipShowGuild"] = "On";
				LeaPlusLC["TipShowTarget"] = "On";
				LeaPlusLC["TipBackSimple"] = "Off";
				LeaPlusLC["TipHideInCombat"] = "Off";
				LeaPlusLC["LeaPlusTipSize"] = 1.00
				LeaPlusLC["TipOffsetX"] = -13
				LeaPlusLC["TipOffsetY"] = 94
				TipDrag:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", LeaPlusLC["TipOffsetX"], LeaPlusLC["TipOffsetY"]);
				LeaPlusLC:SetTipScale()
				SideTip:Hide(); SideTip:Show();
			end)

			-- Show tooltip overlay only if reposition checkbox is checked
			LeaPlusCB["TipMoveTip"]:HookScript("OnClick", function()
				if LeaPlusLC["TipMoveTip"] == "On" then
					TipDrag:Show()
				else
					TipDrag:Hide()
				end
			end)

			-- Show drag frame with configuration panel
			SideTip:HookScript("OnShow", function()
				if LeaPlusLC["TipMoveTip"] == "On" then
					TipDrag:Show()
				end
			end)
			SideTip:HookScript("OnHide", function() TipDrag:Hide() end)

			-- Control movement functions
			local void, LTax, LTay, LTbx, LTby, LTcx, LTcy
			TipDrag:SetScript("OnMouseDown", function(self, btn)
				if btn == "LeftButton" then
					void, void, void, LTax, LTay = TipDrag:GetPoint()
					TipDrag:StartMoving()
					void, void, void, LTbx, LTby = TipDrag:GetPoint()
				end
			end)
			TipDrag:SetScript("OnMouseUp", function(self, btn)
				if btn == "LeftButton" then
					void, void, void, LTcx, LTcy = TipDrag:GetPoint()
					TipDrag:StopMovingOrSizing();
					LeaPlusLC["TipOffsetX"], LeaPlusLC["TipOffsetY"] = LTcx - LTbx + LTax, LTcy - LTby + LTay
					TipDrag:ClearAllPoints()
					TipDrag:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", LeaPlusLC["TipOffsetX"], LeaPlusLC["TipOffsetY"])
				end
			end)

			--	Move the tooltip
			LeaPlusCB["MoveTooltipButton"]:SetScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaPlusLC["TipMoveTip"] = "On";
					LeaPlusLC["TipShowGuild"] = "On";
					LeaPlusLC["TipShowTarget"] = "On";
					LeaPlusLC["TipBackSimple"] = "On";
					LeaPlusLC["TipHideInCombat"] = "Off";
					LeaPlusLC["LeaPlusTipSize"] = 1.25
					LeaPlusLC["TipOffsetX"] = -13
					LeaPlusLC["TipOffsetY"] = 94
					TipDrag:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", LeaPlusLC["TipOffsetX"], LeaPlusLC["TipOffsetY"]);
					LeaPlusLC:SetTipScale()
					LeaPlusLC:SetDim();
					LeaPlusLC:ReloadCheck();
					SideTip:Show(); SideTip:Hide(); -- Needed to update tooltip scale
					LeaPlusLC["PageF"]:Hide(); LeaPlusLC["PageF"]:Show();
				else
					-- Show tooltip configuration panel
					LeaPlusLC:HideFrames();
					SideTip:Show();

					-- Set scale
					TipDrag:SetScale(LeaPlusLC["LeaPlusTipSize"])

					-- Set position of the drag frame
					TipDrag:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", LeaPlusLC["TipOffsetX"], LeaPlusLC["TipOffsetY"])
				end			

			end)
					
			---------------------------------------------------------------------------------------------------------
			-- Tooltip scale settings
			---------------------------------------------------------------------------------------------------------

			-- Function to set the tooltip scale
			local function SetTipScale()
				if LeaPlusLC["TipModEnable"] == "On" then

					-- General tooltip
					if GameTooltip then GameTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"]) end

					-- Friends
					if FriendsTooltip then FriendsTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"]) end

					-- AutoCompleteBox
					if AutoCompleteBox then AutoCompleteBox:SetScale(LeaPlusLC["LeaPlusTipSize"]) end

					-- Items (links, comparisons)
					if ItemRefTooltip then ItemRefTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"]) end
					if ItemRefShoppingTooltip1 then ItemRefShoppingTooltip1:SetScale(LeaPlusLC["LeaPlusTipSize"]) end
					if ItemRefShoppingTooltip2 then ItemRefShoppingTooltip2:SetScale(LeaPlusLC["LeaPlusTipSize"]) end
					if ShoppingTooltip1 then ShoppingTooltip1:SetScale(LeaPlusLC["LeaPlusTipSize"]) end
					if ShoppingTooltip2 then ShoppingTooltip2:SetScale(LeaPlusLC["LeaPlusTipSize"]) end

					-- Embedded item tooltip (as used in PVP UI)
					if EmbeddedItemTooltip then EmbeddedItemTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"]) end

					-- Nameplate tooltip
					if NamePlateTooltip then NamePlateTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"]) end

					-- Leatrix Plus
					TipDrag:SetScale(LeaPlusLC["LeaPlusTipSize"])

					-- Set slider formatted text
					LeaPlusCB["LeaPlusTipSize"].f:SetFormattedText("%.0f%%", LeaPlusLC["LeaPlusTipSize"] * 100)

				end
				return
			end

			-- Give function a file level scope
			LeaPlusLC.SetTipScale = SetTipScale

			-- Set tooltip scale when slider or checkbox changes and on startup
			LeaPlusCB["LeaPlusTipSize"]:HookScript("OnValueChanged", SetTipScale)
			SetTipScale()

			---------------------------------------------------------------------------------------------------------
			-- Other tooltip code
			---------------------------------------------------------------------------------------------------------

			-- Colorblind setting change
			TipDrag:RegisterEvent("CVAR_UPDATE");
			TipDrag:SetScript("OnEvent", function(self, event, arg1, arg2)
				if (arg1 == "USE_COLORBLIND_MODE") then
					LT["ColorBlind"] = arg2;
				end
			end)

			-- Store locals
			local TipMClass = LOCALIZED_CLASS_NAMES_MALE
			local TipFClass = LOCALIZED_CLASS_NAMES_FEMALE

			-- Level string
			local LevelString, LevelString2
			if GameLocale == "ruRU" then
				-- Level string for ruRU
				LevelString = "уровня"
				LevelString2 = "уровень"
			else
				-- Level string for all other locales
				LevelString = string.lower(TOOLTIP_UNIT_LEVEL:gsub("%%s",".+"))
				LevelString2 = ""
			end

			-- Tag locale (code construction from tiplang)
			local ttYou, ttLevel, ttBoss, ttElite, ttRare, ttRareElite, ttRareBoss, ttTarget
			if 		GameLocale == "zhCN" then 	ttYou = "您"		; ttLevel = "等级"		; ttBoss = "首领"	; ttElite = "精英"	; ttRare = "精良"	; ttRareElite = "精良 精英"		; ttRareBoss = "精良 首领"		; ttTarget = "目标"
			elseif 	GameLocale == "zhTW" then 	ttYou = "您"		; ttLevel = "等級"		; ttBoss = "首領"	; ttElite = "精英"	; ttRare = "精良"	; ttRareElite = "精良 精英"		; ttRareBoss = "精良 首領"		; ttTarget = "目標"
			elseif 	GameLocale == "ruRU" then 	ttYou = "ВЫ"	; ttLevel = "Уровень"	; ttBoss = "босс"	; ttElite = "элита"	; ttRare = "Редкое"	; ttRareElite = "Редкое элита"	; ttRareBoss = "Редкое босс"	; ttTarget = "Цель"
			elseif 	GameLocale == "koKR" then 	ttYou = "당신"	; ttLevel = "레벨"		; ttBoss = "우두머리"	; ttElite = "정예"	; ttRare = "희귀"	; ttRareElite = "희귀 정예"		; ttRareBoss = "희귀 우두머리"		; ttTarget = "대상"
			elseif 	GameLocale == "esMX" then 	ttYou = "TÚ"	; ttLevel = "Nivel"		; ttBoss = "Jefe"	; ttElite = "Élite"	; ttRare = "Raro"	; ttRareElite = "Raro Élite"	; ttRareBoss = "Raro Jefe"		; ttTarget = "Objetivo"
			elseif 	GameLocale == "ptBR" then 	ttYou = "VOCÊ"	; ttLevel = "Nível"		; ttBoss = "Chefe"	; ttElite = "Elite"	; ttRare = "Raro"	; ttRareElite = "Raro Elite"	; ttRareBoss = "Raro Chefe"		; ttTarget = "Alvo"
			elseif 	GameLocale == "deDE" then 	ttYou = "SIE"	; ttLevel = "Stufe"		; ttBoss = "Boss"	; ttElite = "Elite"	; ttRare = "Selten"	; ttRareElite = "Selten Elite"	; ttRareBoss = "Selten Boss"	; ttTarget = "Ziel"
			elseif 	GameLocale == "esES" then	ttYou = "TÚ"	; ttLevel = "Nivel"		; ttBoss = "Jefe"	; ttElite = "Élite"	; ttRare = "Raro"	; ttRareElite = "Raro Élite"	; ttRareBoss = "Raro Jefe"		; ttTarget = "Objetivo"
			elseif 	GameLocale == "frFR" then 	ttYou = "TOI"	; ttLevel = "Niveau"	; ttBoss = "Boss"	; ttElite = "Élite"	; ttRare = "Rare"	; ttRareElite = "Rare Élite"	; ttRareBoss = "Rare Boss"		; ttTarget = "Cible"
			elseif 	GameLocale == "itIT" then 	ttYou = "TU"	; ttLevel = "Livello"	; ttBoss = "Boss"	; ttElite = "Élite"	; ttRare = "Raro"	; ttRareElite = "Raro Élite"	; ttRareBoss = "Raro Boss"		; ttTarget = "Bersaglio"
			else 								ttYou = "YOU"	; ttLevel = "Level"		; ttBoss = "Boss"	; ttElite = "Elite"	; ttRare = "Rare"	; ttRareElite = "Rare Elite"	; ttRareBoss = "Rare Boss"		; ttTarget = "Target"
			end

			-- Show tooltip
			local function ShowTip()

				-- Do nothing if CTRL, SHIFT and ALT are being held
				if IsControlKeyDown() and IsAltKeyDown() and IsShiftKeyDown() then 
					return
				end

				-- Get unit information
				if GetMouseFocus() == WorldFrame then
					LT["Unit"] = "mouseover"
					-- Hide and quit if tips should be hidden during combat 
					if LeaPlusLC["TipHideInCombat"] == "On" and UnitAffectingCombat("player") and not IsShiftKeyDown() then
						GameTooltip:Hide()
						return
					end
				else
					LT["Unit"] = select(2, GameTooltip:GetUnit())
					if not (LT["Unit"]) then return end
				end

				-- Quit if unit has no reaction to player
				LT["Reaction"] = UnitReaction(LT["Unit"], "player") or nil
				if not LT["Reaction"] then 
					return
				end

				-- Setup variables
				LT["TipUnitName"], LT["TipUnitRealm"] = UnitName(LT["Unit"])
				LT["TipIsPlayer"] = UnitIsPlayer(LT["Unit"])
				LT["UnitLevel"] = UnitLevel(LT["Unit"])
				LT["UnitClass"] = UnitClassBase(LT["Unit"])
				LT["PlayerControl"] = UnitPlayerControlled(LT["Unit"])
				LT["PlayerRace"] = UnitRace(LT["Unit"])

				-- Get colorblind information
				if LT["TipIsPlayer"] then
					if LT["ColorBlind"] == "1" then
						LT["InfoLine"] = 3
					else
						LT["InfoLine"] = 2
					end
					-- Lower information line if unit is charmed
					if UnitIsCharmed(LT["Unit"]) then
						LT["InfoLine"] = LT["InfoLine"] + 1
					end
				end

				-- Determine class color
				if LT["UnitClass"] then
					-- Define male or female (for certain locales)
					LT["Sex"] = UnitSex(LT["Unit"])
					if LT["Sex"] == 2 then
						LT["Class"] = TipMClass[LT["UnitClass"]]
					else
						LT["Class"] = TipFClass[LT["UnitClass"]]
					end
					-- Define class color
					LT["ClassCol"] = LeaPlusLC["RaidColors"][LT["UnitClass"]]
					LT["LpTipClassColor"] = "|cff" .. string.format("%02x%02x%02x", LT["ClassCol"].r * 255, LT["ClassCol"].g * 255, LT["ClassCol"].b * 255)
				end

				----------------------------------------------------------------------
				-- Name line
				----------------------------------------------------------------------

				if ((LT["TipIsPlayer"]) or (LT["PlayerControl"])) or LT["Reaction"] > 4 then

					-- If it's a player show name in class color
					if LT["TipIsPlayer"] then
						LT["NameColor"] = LT["LpTipClassColor"]
					else
						-- If not, set to green or blue depending on PvP status
						if UnitIsPVP(LT["Unit"]) then
							LT["NameColor"] = "|cff00ff00"
						else
							LT["NameColor"] = "|cff00aaff"
						end
					end

					-- Show name
					LT["NameText"] = UnitPVPName(LT["Unit"]) or LT["TipUnitName"]

					-- Show realm
					if LT["TipUnitRealm"] then
						LT["NameText"] = LT["NameText"] .. " - " .. LT["TipUnitRealm"]
					end

					-- Show dead units in grey
					if UnitIsDeadOrGhost(LT["Unit"]) then
						LT["NameColor"] = "|c88888888"
					end

					-- Show name line
					_G["GameTooltipTextLeft1"]:SetText(LT["NameColor"] .. LT["NameText"] .. "|cffffffff|r")
					
				elseif UnitIsDeadOrGhost(LT["Unit"]) then

					-- Show grey name for other dead units
					_G["GameTooltipTextLeft1"]:SetText("|c88888888" .. (_G["GameTooltipTextLeft1"]:GetText() or "") .. "|cffffffff|r")
					return

				end

				----------------------------------------------------------------------
				-- Information line (level, class, race)
				----------------------------------------------------------------------

				if LT["TipIsPlayer"] then

					-- Show level
					if LT["Reaction"] < 5 then
						if LT["UnitLevel"] == -1 then
							LT["InfoText"] = ("|cffff3333" .. ttLevel .. " ??|cffffffff")
						else
							LT["LevelColor"] = GetCreatureDifficultyColor(LT["UnitLevel"])
							LT["LevelColor"] = string.format('%02x%02x%02x', LT["LevelColor"].r * 255, LT["LevelColor"].g * 255, LT["LevelColor"].b * 255)
							LT["InfoText"] = ("|cff" .. LT["LevelColor"] .. LT["LevelLocale"] .. " " .. LT["UnitLevel"] .. "|cffffffff")
						end
					else
						LT["InfoText"] = LT["LevelLocale"] .. " " .. LT["UnitLevel"]
					end

					-- Show race
					if LT["PlayerRace"] then
						LT["InfoText"] = LT["InfoText"] .. " " .. LT["PlayerRace"]
					end

					-- Show class
					LT["InfoText"] = LT["InfoText"] .. " " .. LT["LpTipClassColor"] .. LT["Class"] or LT["InfoText"]

					-- Show information line
					_G["GameTooltipTextLeft" .. LT["InfoLine"]]:SetText(LT["InfoText"] .. "|cffffffff|r")

				end

				----------------------------------------------------------------------
				-- Mob name in brighter red (alive) and steel blue (tap denied)
				----------------------------------------------------------------------

				if not (LT["TipIsPlayer"]) and LT["Reaction"] < 4 and not (LT["PlayerControl"]) then
					if UnitIsTapDenied(LT["Unit"]) then
						LT["NameText"] = "|c8888bbbb" .. LT["TipUnitName"] .. "|r"
					else
						LT["NameText"] = "|cffff3333" .. LT["TipUnitName"] .. "|r"
					end
					_G["GameTooltipTextLeft1"]:SetText(LT["NameText"])
				end

				----------------------------------------------------------------------
				-- Mob level in color (neutral or lower)
				----------------------------------------------------------------------

				if UnitCanAttack(LT["Unit"], "player") and not (LT["TipIsPlayer"]) and LT["Reaction"] < 5 and not (LT["PlayerControl"]) then

					-- Find the level line
					LT["MobInfoLine"] = 0
					local line2, line3, line4
					if _G["GameTooltipTextLeft2"] then line2 = _G["GameTooltipTextLeft2"]:GetText() end
					if _G["GameTooltipTextLeft3"] then line3 = _G["GameTooltipTextLeft3"]:GetText() end
					if _G["GameTooltipTextLeft4"] then line4 = _G["GameTooltipTextLeft4"]:GetText() end
					if GameLocale == "ruRU" then -- Additional check for ruRU
						if line2 and string.lower(line2):find(LevelString2) then LT["MobInfoLine"] = 2 end
						if line3 and string.lower(line3):find(LevelString2) then LT["MobInfoLine"] = 3 end
						if line4 and string.lower(line4):find(LevelString2) then LT["MobInfoLine"] = 4 end
					end
					if line2 and string.lower(line2):find(LevelString) then LT["MobInfoLine"] = 2 end
					if line3 and string.lower(line3):find(LevelString) then LT["MobInfoLine"] = 3 end
					if line4 and string.lower(line4):find(LevelString) then LT["MobInfoLine"] = 4 end

					-- Show level line
					if LT["MobInfoLine"] > 1 then

						-- Level ?? mob
						if LT["UnitLevel"] == -1 then
							LT["InfoText"] = "|cffff3333" .. ttLevel .. " ??|cffffffff "

						-- Mobs within level range
						else
							LT["MobColor"] = GetCreatureDifficultyColor(LT["UnitLevel"])
							LT["MobColor"] = string.format('%02x%02x%02x', LT["MobColor"].r * 255, LT["MobColor"].g * 255, LT["MobColor"].b * 255)
							LT["InfoText"] = "|cff" .. LT["MobColor"] .. LT["LevelLocale"] .. " " .. LT["UnitLevel"] .. "|cffffffff "
						end

						-- Show creature type and classification
						LT["CreatureType"] = UnitCreatureType(LT["Unit"])
						if (LT["CreatureType"]) and not (LT["CreatureType"] == "Not specified") then
							LT["InfoText"] = LT["InfoText"] .. "|cffffffff" .. LT["CreatureType"] .. "|cffffffff "
						end

						-- Rare, elite and boss mobs
						LT["Special"] = UnitClassification(LT["Unit"])
						if LT["Special"] then
							if LT["Special"] == "elite" then
								if strfind(_G["GameTooltipTextLeft" .. LT["MobInfoLine"]]:GetText(), "(" .. ttBoss .. ")") then
									LT["Special"] = "(" .. ttBoss .. ")"
								else
									LT["Special"] = "(" .. ttElite .. ")"
								end
							elseif LT["Special"] == "rare" then
								LT["Special"] = "|c00e066ff(" .. ttRare .. ")"
							elseif LT["Special"] == "rareelite" then
								if strfind(_G["GameTooltipTextLeft" .. LT["MobInfoLine"]]:GetText(), "(" .. ttBoss .. ")") then
									LT["Special"] = "|c00e066ff(" .. ttRareBoss .. ")"
								else
									LT["Special"] = "|c00e066ff(" .. ttRareElite .. ")"
								end
							elseif LT["Special"] == "worldboss" then
								LT["Special"] = "(" .. ttBoss .. ")"
							elseif LT["UnitLevel"] == -1 and LT["Special"] == "normal" and strfind(_G["GameTooltipTextLeft" .. LT["MobInfoLine"]]:GetText(), "(" .. ttBoss .. ")") then
								LT["Special"] = "(" .. ttBoss .. ")"
							else
								LT["Special"] = nil 
							end

							if (LT["Special"]) then
								LT["InfoText"] = LT["InfoText"] .. LT["Special"]
							end
						end

						-- Show mob info line
						_G["GameTooltipTextLeft" .. LT["MobInfoLine"]]:SetText(LT["InfoText"])

					end

				end

				----------------------------------------------------------------------
				-- Backdrop color
				----------------------------------------------------------------------

				LT["TipFaction"] = UnitFactionGroup(LT["Unit"])

				if UnitCanAttack("player", LT["Unit"]) and not (UnitIsDeadOrGhost(LT["Unit"])) and not (LT["TipFaction"] == nil) and not (LT["TipFaction"] == UnitFactionGroup("player")) then
					-- Hostile faction
					if LeaPlusLC["TipBackSimple"] == "On" then
						GameTooltip:SetBackdropColor(0.5, 0.0, 0.0);
					else
						GameTooltip:SetBackdropColor(0.0, 0.0, 0.0);
					end
				else
					-- Friendly faction
					if LeaPlusLC["TipBackSimple"] == "On" then
						GameTooltip:SetBackdropColor(0.0, 0.0, 0.5);
					else
						GameTooltip:SetBackdropColor(0.0, 0.0, 0.0);
					end
				end

				----------------------------------------------------------------------
				-- Show guild
				----------------------------------------------------------------------

				if LeaPlusLC["TipShowGuild"] == "On" and LT["TipIsPlayer"] then
					local unitGuild, unitRank = GetGuildInfo(LT["Unit"])
					if unitGuild and unitRank then
						if UnitIsInMyGuild(LT["Unit"]) then
							GameTooltip:AddLine("|c00aaaaff" .. unitGuild .. " - " .. unitRank .. "|r")
						else
							GameTooltip:AddLine("|c00aaaaff" .. unitGuild .. "|cffffffff|r")
						end
					end
				end

				----------------------------------------------------------------------
				--	Show target
				----------------------------------------------------------------------

				if LeaPlusLC["TipShowTarget"] == "On" then

					-- Get target
					LT["Target"] = UnitName(LT["Unit"] .. "target");

					-- If target doesn't exist, quit
					if LT["Target"] == nil or LT["Target"] == "" then return end

					-- If target is you, set target to YOU
					if (UnitIsUnit(LT["Target"], "player")) then 
						LT["Target"] = ("|c12ff4400" .. ttYou)

					-- If it's not you, but it's a player, show target in class color
					elseif UnitIsPlayer(LT["Unit"] .. "target") then
						LT["TargetBase"] = UnitClassBase(LT["Unit"] .. "target")
						LT["TargetCol"] = LeaPlusLC["RaidColors"][LT["TargetBase"]]
						LT["TargetCol"] = "|cff" .. string.format('%02x%02x%02x', LT["TargetCol"].r * 255, LT["TargetCol"].g * 255, LT["TargetCol"].b * 255)
						LT["Target"] = (LT["TargetCol"] .. LT["Target"])

					end
					
					-- Add target line
					GameTooltip:AddLine(ttTarget .. ": " .. LT["Target"])

				end

			end

			GameTooltip:HookScript("OnTooltipSetUnit", ShowTip)
			
		end

		----------------------------------------------------------------------
		--	Move chat editbox to top
		----------------------------------------------------------------------

		if LeaPlusLC["MoveChatEditBoxToTop"] == "On" then

			-- Set options for normal chat frames
			for i = 1, 50 do
				if _G["ChatFrame" .. i] then
					-- Position the editbox
					_G["ChatFrame" .. i .. "EditBox"]:ClearAllPoints();
					_G["ChatFrame" .. i .. "EditBox"]:SetPoint("TOPLEFT", _G["ChatFrame" .. i], 0, 0);
					_G["ChatFrame" .. i .. "EditBox"]:SetWidth(_G["ChatFrame" .. i]:GetWidth());
					-- Ensure editbox width matches chatframe width
					_G["ChatFrame" .. i]:HookScript("OnSizeChanged", function()
						_G["ChatFrame" .. i .. "EditBox"]:SetWidth(_G["ChatFrame" .. i]:GetWidth())
					end)
				end
			end

			-- Do the functions above for other chat frames (pet battles, whispers, etc)
			hooksecurefunc("FCF_OpenTemporaryWindow", function()

				local cf = FCF_GetCurrentChatFrame():GetName() or nil
				if cf then

					-- Position the editbox
					_G[cf .. "EditBox"]:ClearAllPoints();
					_G[cf .. "EditBox"]:SetPoint("TOPLEFT", cf, "TOPLEFT", 0, 0);
					_G[cf .. "EditBox"]:SetWidth(_G[cf]:GetWidth());

					-- Ensure editbox width matches chatframe width
					_G[cf]:HookScript("OnSizeChanged", function()
						_G[cf .. "EditBox"]:SetWidth(_G[cf]:GetWidth())
					end)

				end
			end)

		end

		----------------------------------------------------------------------
		-- Viewport
		----------------------------------------------------------------------

		if LeaPlusLC["ViewPortEnable"] == "On" then

			-- Create border textures
			local BordTop = WorldFrame:CreateTexture(nil, "ARTWORK"); BordTop:SetColorTexture(0, 0, 0, 1); BordTop:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0); BordTop:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 0)
			local BordBot = WorldFrame:CreateTexture(nil, "ARTWORK"); BordBot:SetColorTexture(0, 0, 0, 1); BordBot:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0); BordBot:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
			local BordLeft = WorldFrame:CreateTexture(nil, "ARTWORK"); BordLeft:SetColorTexture(0, 0, 0, 1); BordLeft:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0); BordLeft:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
			local BordRight = WorldFrame:CreateTexture(nil, "ARTWORK"); BordRight:SetColorTexture(0, 0, 0, 1); BordRight:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 0); BordRight:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)

			-- Create viewport configuration panel
			local SideViewport = LeaPlusLC:CreatePanel("Viewport", "SideViewport")

			-- Create resize screen button
			local resizeScreenBtn = LeaPlusLC:CreateButton("resizeScreenBtn", SideViewport, "Resize Screen", "BOTTOMRIGHT", -16, 10, 0, 25, true, "Click to resize the screen to fit between the top and bottom borders.")
			resizeScreenBtn:ClearAllPoints()
			resizeScreenBtn:SetPoint("LEFT", SideViewport.h, "RIGHT", 10, 0)
			resizeScreenBtn:SetScript("OnClick", function()
				LeaPlusLC["ViewPortResizeTop"] = LeaPlusLC["ViewPortTop"]
				LeaPlusLC["ViewPortResizeBottom"] = LeaPlusLC["ViewPortBottom"]
				WorldFrame:SetPoint("TOPLEFT", 0, -LeaPlusLC["ViewPortResizeTop"])
				WorldFrame:SetPoint("BOTTOMRIGHT", 0, LeaPlusLC["ViewPortResizeBottom"])
				-- Disable lock button if borders match viewport size
				if LeaPlusLC["ViewPortTop"] == LeaPlusLC["ViewPortResizeTop"] and LeaPlusLC["ViewPortBottom"] == LeaPlusLC["ViewPortResizeBottom"] then
					LeaPlusLC:LockItem(resizeScreenBtn, true)
				else
					LeaPlusLC:LockItem(resizeScreenBtn, false)
				end
			end)

			-- Function to set viewport parameters
			local function RefreshViewport()

				-- Set border size and transparency
				BordTop:SetHeight(LeaPlusLC["ViewPortTop"]); BordTop:SetAlpha(1 - LeaPlusLC["ViewPortAlpha"])
				BordBot:SetHeight(LeaPlusLC["ViewPortBottom"]); BordBot:SetAlpha(1 - LeaPlusLC["ViewPortAlpha"])
				BordLeft:SetWidth(LeaPlusLC["ViewPortLeft"]); BordLeft:SetAlpha(1 - LeaPlusLC["ViewPortAlpha"])
				BordRight:SetWidth(LeaPlusLC["ViewPortRight"]); BordRight:SetAlpha(1 - LeaPlusLC["ViewPortAlpha"])

				-- Show formatted slider value
				LeaPlusCB["ViewPortAlpha"].f:SetFormattedText("%.0f%%", LeaPlusLC["ViewPortAlpha"] * 100)

				-- Disable lock button if borders match viewport size
				if LeaPlusLC["ViewPortTop"] == LeaPlusLC["ViewPortResizeTop"] and LeaPlusLC["ViewPortBottom"] == LeaPlusLC["ViewPortResizeBottom"] then
					LeaPlusLC:LockItem(resizeScreenBtn, true)
				else
					LeaPlusLC:LockItem(resizeScreenBtn, false)
				end

			end

			-- Create slider controls
			LeaPlusLC:MakeTx(SideViewport, "Top", 16, -72)
			LeaPlusLC:MakeSL(SideViewport, "ViewPortTop", "Drag to set the size of the top border.", 0, 300, 5, 16, -92, "%.0f")
			LeaPlusCB["ViewPortTop"]:HookScript("OnValueChanged", RefreshViewport)

			LeaPlusLC:MakeTx(SideViewport, "Bottom", 16, -132)
			LeaPlusLC:MakeSL(SideViewport, "ViewPortBottom", "Drag to set the size of the bottom border.", 0, 300, 5, 16, -152, "%.0f")
			LeaPlusCB["ViewPortBottom"]:HookScript("OnValueChanged", RefreshViewport)

			LeaPlusLC:MakeTx(SideViewport, "Left", 186, -72)
			LeaPlusLC:MakeSL(SideViewport, "ViewPortLeft", "Drag to set the size of the left border.", 0, 300, 5, 186, -92, "%.0f")
			LeaPlusCB["ViewPortLeft"]:HookScript("OnValueChanged", RefreshViewport)

			LeaPlusLC:MakeTx(SideViewport, "Right", 186, -132)
			LeaPlusLC:MakeSL(SideViewport, "ViewPortRight", "Drag to set the size of the right border.", 0, 300, 5, 186, -152, "%.0f")
			LeaPlusCB["ViewPortRight"]:HookScript("OnValueChanged", RefreshViewport)

			LeaPlusLC:MakeTx(SideViewport, "Transparency", 356, -132)
			LeaPlusLC:MakeSL(SideViewport, "ViewPortAlpha", "Drag to set the transparency of the borders.", 0, 0.9, 0.1, 356, -152, "%.1f")
			LeaPlusCB["ViewPortAlpha"]:HookScript("OnValueChanged", RefreshViewport)

			-- Help button tooltip
			SideViewport.h.tiptext = L["This panel will close automatically if you enter combat."]

			-- Back button handler
			SideViewport.b:SetScript("OnClick", function() 
				SideViewport:Hide()
				LeaPlusLC["PageF"]:Show()
				LeaPlusLC["Page7"]:Show()
				return
			end) 

			-- Reset button handler
			SideViewport.r:SetScript("OnClick", function()
				LeaPlusLC["ViewPortTop"] = 0 
				LeaPlusLC["ViewPortBottom"] = 0
				LeaPlusLC["ViewPortLeft"] = 0
				LeaPlusLC["ViewPortRight"] = 0
				LeaPlusLC["ViewPortResizeTop"] = 0
				LeaPlusLC["ViewPortResizeBottom"] = 0
				LeaPlusLC["ViewPortAlpha"] = 0
				SideViewport:Hide(); SideViewport:Show()
				RefreshViewport()
				WorldFrame:SetPoint("TOPLEFT", 0, -LeaPlusLC["ViewPortResizeTop"])
				WorldFrame:SetPoint("BOTTOMRIGHT", 0, LeaPlusLC["ViewPortResizeBottom"])
			end)

			-- Configuration button handler
			LeaPlusCB["ModViewportBtn"]:SetScript("OnClick", function()
				if LeaPlusLC:PlayerInCombat() then
					return
				else
					if IsShiftKeyDown() and IsControlKeyDown() then
						-- Preset profile
						LeaPlusLC["ViewPortTop"] = 0 
						LeaPlusLC["ViewPortBottom"] = 0
						LeaPlusLC["ViewPortLeft"] = 0
						LeaPlusLC["ViewPortRight"] = 0
						LeaPlusLC["ViewPortResizeTop"] = 0
						LeaPlusLC["ViewPortResizeBottom"] = 0
						LeaPlusLC["ViewPortAlpha"] = 0.7
						RefreshViewport()
						WorldFrame:SetPoint("TOPLEFT", 0, -LeaPlusLC["ViewPortResizeTop"])
						WorldFrame:SetPoint("BOTTOMRIGHT", 0, LeaPlusLC["ViewPortResizeBottom"])
					else
						SideViewport:Show()
						LeaPlusLC:HideFrames()
					end
				end
			end)

			-- Set viewport on startup
			RefreshViewport()
			WorldFrame:SetPoint("TOPLEFT", 0, -LeaPlusLC["ViewPortResizeTop"])
			WorldFrame:SetPoint("BOTTOMRIGHT", 0, LeaPlusLC["ViewPortResizeBottom"])

			-- Hide the configuration panel if combat starts
			SideViewport:RegisterEvent("PLAYER_REGEN_DISABLED")
			SideViewport:SetScript("OnEvent", SideViewport.Hide)

			-- Hide borders when cinematic is shown
			hooksecurefunc(CinematicFrame, "Hide", function()
				BordTop:Show(); BordBot:Show(); BordLeft:Show(); BordRight:Show()
			end)
			hooksecurefunc(CinematicFrame, "Show", function()
				BordTop:Hide(); BordBot:Hide(); BordLeft:Hide(); BordRight:Hide()
			end)

		end

		----------------------------------------------------------------------
		-- Silence rested emotes
		----------------------------------------------------------------------

		-- Manage emotes
		if LeaPlusLC["NoRestedEmotes"] == "On" then

			-- Zone table 		English					, French					, German					, Italian						, Russian					, S Chinese	, Spanish					, T Chinese	,
			local zonetable = {	"The Grim Guzzler"		, "Le Sinistre écluseur"	, "Zum Grimmigen Säufer"	, "Torvo Beone"					, "Трактир Угрюмый обжора"	, "黑铁酒吧"	, "Tragapenas"				, "黑鐵酒吧"	,}

			-- Function to set rested state
			local function UpdateEmoteSound()

				-- Find character's current zone
				local szone = GetSubZoneText() or "None"

				-- Find out if emote sounds are disabled or enabled
				local emoset = GetCVar("Sound_EnableEmoteSounds")

				if IsResting() then
					-- Character is resting so silence emotes
					if emoset ~= "0" then
						SetCVar("Sound_EnableEmoteSounds", "0")
					end
					return
				end

				-- Traverse zone table and silence emotes if character is in a designated zone
				for k, v in next, zonetable do
					if szone == zonetable[k] then
						if emoset ~= "0" then
							SetCVar("Sound_EnableEmoteSounds", "0")
						end
						return
					end
				end

				-- If the above didn't return, emote sounds should be enabled
				if emoset ~= "1" then
					SetCVar("Sound_EnableEmoteSounds", "1")
				end
				return
			
			end

			-- Set emote sound when rest state or zone changes
			local RestEvent = CreateFrame("FRAME")
			RestEvent:RegisterEvent("PLAYER_UPDATE_RESTING")
            RestEvent:RegisterEvent("ZONE_CHANGED_NEW_AREA")
			RestEvent:RegisterEvent("ZONE_CHANGED")
			RestEvent:RegisterEvent("ZONE_CHANGED_INDOORS")
			RestEvent:SetScript("OnEvent", UpdateEmoteSound)

			-- Set sound setting at startup
			UpdateEmoteSound()

		end

		----------------------------------------------------------------------
		-- Final code for Player
		----------------------------------------------------------------------

		-- Register logout event to save settings
		LpEvt:RegisterEvent("PLAYER_LOGOUT")

		-- Release memory
		LeaPlusLC.Player = nil

	end

----------------------------------------------------------------------
--	L45: World
----------------------------------------------------------------------

	function LeaPlusLC:World()

		----------------------------------------------------------------------
		--	Max camera zoom (no reload required)
		----------------------------------------------------------------------

		do

			-- Function to set camera zoom
			local function SetZoom()
				if LeaPlusLC["MaxCameraZoom"] == "On" then
					SetCVar("cameraDistanceMaxZoomFactor", 4.0)
				else
					SetCVar("cameraDistanceMaxZoomFactor", 1.9)
				end
			end

			-- Set camera zoom when option is clicked and on startup (if enabled)
			LeaPlusCB["MaxCameraZoom"]:HookScript("OnClick", SetZoom)
			if LeaPlusLC["MaxCameraZoom"] == "On" then SetZoom() end

		end

	end

----------------------------------------------------------------------
-- 	L50: RunOnce
----------------------------------------------------------------------

	function LeaPlusLC:RunOnce()

		----------------------------------------------------------------------
		-- Media player
		----------------------------------------------------------------------

		function LeaPlusLC:MediaFunc()

			-- Create tables for list data and zone listing
			local ListData, playlist = {}, {}, {}
			local scrollFrame, willPlay, musicHandle, ZonePage, LastPlayed, LastFolder, TempFolder, HeadingOfClickedTrack, LastMusicHandle
			local numButtons = 15
			local uframe = CreateFrame("FRAME")

			-- Create a table for each heading
			local ZoneList = {L["Music"], L["Random"], L["Search"], L["Movies"]}
			for k, v in ipairs(ZoneList) do
				ZoneList[v] = {}
			end

			-- Music table
			ZoneList[L["Music"]] = Leatrix_Plus["Music"]
			tinsert(ZoneList[L["Music"]], 1, "|cffffd800" .. L["Music"])
			tinsert(ZoneList[L["Music"]], 2, "|cffffd800")
			tinsert(ZoneList[L["Music"]], 3, "|cffffd800")

			-- Movies table
			ZoneList[L["Movies"]] = {L["Ten Years of Warcraft"] .. " |r(1)", L["World of Warcraft"] .. " |r(2)"}
			tinsert(ZoneList[L["Movies"]], 1, "|cffffd800" .. L["Movies"])
			tinsert(ZoneList[L["Movies"]], 2, "|cffffd800")
			tinsert(ZoneList[L["Movies"]], 3, "|cffffd800")

			-- Debug
			-- ZoneList[L["Music"]] = {"|cffffd800" .. L["Music"], "|cffffd800", "|cffffd800", "citymusic/darnassus/darnassus intro.mp3#53183#3", "citymusic/darnassus/darnassus walking 1.mp3#53184#3", "citymusic/darnassus/darnassus walking 2.mp3#53185#3"}

			-- Give zone table a file level scope so slash command function can access it
			LeaPlusLC["ZoneList"] = ZoneList

			-- Show relevant list items
			local function UpdateList()
				FauxScrollFrame_Update(scrollFrame, #ListData, numButtons, 16)
				for index = 1, numButtons do
					local offset = index + FauxScrollFrame_GetOffset(scrollFrame)
					local button = scrollFrame.buttons[index]
					button.index = offset
					if offset <= #ListData then
						-- Show track listing
						button:SetText(ListData[offset])
						-- Set width of highlight texture
						if button:GetTextWidth() > 290 then
							button.t:SetSize(290, 16)
						else
							button.t:SetSize(button:GetTextWidth(), 16)
						end
						-- Show the button
						button:Show()
						-- Hide highlight bar texture by default
						button.s:Hide()
						-- Hide highlight bar if the button is a heading
						if strfind(button:GetText(), "|c") then button.t:Hide() end
						-- Show last played track highlight bar texture 
						if LastPlayed == button:GetText() then
							local HeadingOfCurrentFolder = ListData[1]
							if HeadingOfCurrentFolder == HeadingOfClickedTrack then
								button.s:Show()
							end
						end
						-- Set width of highlight bar
						if button:GetTextWidth() > 290 then
							button.s:SetSize(290, 16)
						else
							button.s:SetSize(button:GetTextWidth(), 16)
						end
						-- Limit click to label width
						local bWidth = button:GetFontString():GetStringWidth() or 0
						if bWidth > 290 then bWidth = 290 end
						button:SetHitRectInsets(0, 454 - bWidth, 0, 0)
						-- Disable label click movement
						button:SetPushedTextOffset(0, 0)
						-- Disable word wrap and set width
						button:GetFontString():SetWidth(290)
						button:GetFontString():SetWordWrap(false)
					else
						button:Hide()
					end
				end
			end

			-- Give function file level scope (it's used in SetPlusScale to set the highlight bar scale)
			LeaPlusLC.UpdateList = UpdateList

			-- Function to make navigation menu buttons
			local function MakeButton(where, y)
				local mbtn = CreateFrame("Button", nil, LeaPlusLC["Page9"])
				mbtn:Show()
				mbtn:SetAlpha(1.0)
				mbtn:SetPoint("TOPLEFT", 146, y)

				-- Create hover texture
				mbtn.t = mbtn:CreateTexture(nil, "BACKGROUND")
				mbtn.t:SetColorTexture(0.3, 0.3, 0.00, 0.8)
				mbtn.t:SetAlpha(0.7)
				mbtn.t:SetAllPoints()
				mbtn.t:Hide()

				-- Create highlight texture
				mbtn.s = mbtn:CreateTexture(nil, "BACKGROUND")
				mbtn.s:SetColorTexture(0.3, 0.3, 0.00, 0.8)
				mbtn.s:SetAlpha(1.0)
				mbtn.s:SetAllPoints()
				mbtn.s:Hide()

				-- Create fontstring
				mbtn.f = mbtn:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
				mbtn.f:SetPoint('LEFT', 1, 0)
				mbtn.f:SetText(L[where])

				mbtn:SetScript("OnEnter", function()
					mbtn.t:Show()
				end)

				mbtn:SetScript("OnLeave", function()
					mbtn.t:Hide()
				end)

				-- Set button size when shown
				mbtn:SetScript("OnShow", function()
					mbtn:SetSize(mbtn.f:GetStringWidth() + 1, 16)
				end)

				mbtn:SetScript("OnClick", function()
					-- Show zone listing for clicked item
					ListData = ZoneList[where]
					-- Show results count for Music and Movies
					if where == L["Music"] or where == L["Movies"] then
						ListData[2] = "|cffffffaa{" .. #ZoneList[where] - 3 .. " " .. L["results"] .. "}"
					end
					UpdateList()
				end)

				return mbtn, mbtn.s

			end

			-- Create a table for each button
			local conbtn = {}
			for q, w in pairs(ZoneList) do
				conbtn[q] = {}
			end

			-- Create buttons
			local function MakeButtonNow(title, anchor)
				conbtn[title], conbtn[title].s = MakeButton(title, height)
				conbtn[title]:ClearAllPoints()
				if title == L["Music"] then
					-- Set first button position
					conbtn[title]:SetPoint("TOPLEFT", LeaPlusLC["Page9"], "TOPLEFT", 145, -70)
				elseif anchor then
					-- Set subsequent button positions
					conbtn[title]:SetPoint("TOPLEFT", conbtn[anchor], "BOTTOMLEFT", 0, 0)
					conbtn[title].f:SetText(L[title])
				end
			end

			MakeButtonNow(L["Music"])
			MakeButtonNow(L["Movies"], L["Music"])
			MakeButtonNow(L["Random"], L["Movies"])
			MakeButtonNow(L["Search"]) -- Positioned when search editbox is created

			-- Show button highlight for clicked button
			for q, w in pairs(ZoneList) do
				if type(w) == "string" and conbtn[w] then
					conbtn[w]:HookScript("OnClick", function()
						-- Hide all button highlights
						for k, v in pairs(ZoneList) do
							if type(v) == "string" and conbtn[v] then
								conbtn[v].s:Hide()
							end
						end
						-- Show clicked button highlight
						conbtn[w].s:Show()
						LeaPlusDB["MusicContinent"] = w
						scrollFrame:SetVerticalScroll(0)
						-- Set TempFolder to clicked button
						TempFolder = L[w]
					end)
				end
			end

			-- Create scroll bar
			scrollFrame = CreateFrame("ScrollFrame", "LeaPlusScrollFrame", LeaPlusLC["Page9"], "FauxScrollFrameTemplate")
			scrollFrame:SetPoint("TOPLEFT", 0, -32)
			scrollFrame:SetPoint("BOTTOMRIGHT", -30, 50)
			scrollFrame:SetFrameLevel(10)
			scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
				FauxScrollFrame_OnVerticalScroll(self, offset, 16, UpdateList)
			end)

			-- Add stop button
			local stopBtn = LeaPlusLC:CreateButton("StopMusicBtn", LeaPlusLC["Page9"], "Stop", "TOPLEFT", 146, -292, 0, 25, true, "")
			stopBtn:Hide(); stopBtn:Show()
			LeaPlusLC:LockItem(stopBtn, true)
			stopBtn:SetScript("OnClick", function()
				if musicHandle then
					StopSound(musicHandle)
					musicHandle = nil
					-- Hide highlight bars
					LastPlayed = ""
					LastFolder = ""
					UpdateList()
				end
				-- Cancel sound file music timer
				if LeaPlusLC.TrackTimer then LeaPlusLC.TrackTimer:Cancel() end
				-- Lock button and unregister next track events
				LeaPlusLC:LockItem(stopBtn, true)
				uframe:UnregisterEvent("SOUNDKIT_FINISHED")
				uframe:UnregisterEvent("LOADING_SCREEN_DISABLED")
			end)

			-- Store currently playing track number
			local tracknumber = 1

			-- Function to play a track and show the static highlight bar
			local function PlayTrack()
				-- Play tracks
				if musicHandle then StopSound(musicHandle) end
				local file, soundID, trackTime
				if playlist[tracknumber]:match("([^,]+)%#([^,]+)%#([^,]+)") then
					-- Music file with track time
					file, soundID, trackTime = playlist[tracknumber]:match("([^,]+)%#([^,]+)%#([^,]+)")
					--willPlay, musicHandle = PlaySoundFile(soundID, "Master", false, true)
					-- Play the track (adds the sound/music/ prefix removed in sounds file)
					willPlay, musicHandle = PlaySoundFile(gsub("sound/music/" .. file, "|C.-|r", ""), "Master", false, true)
				else
					-- Sound kit without track time
					file, soundID = playlist[tracknumber]:match("([^,]+)%#([^,]+)")
					willPlay, musicHandle = PlaySound(soundID, "Master", false, true)
				end
				-- Cancel existing music timer for a sound file
				if LeaPlusLC.TrackTimer then LeaPlusLC.TrackTimer:Cancel() end
				if playlist[tracknumber]:match("([^,]+)%#([^,]+)%#([^,]+)") then
					-- Track is a sound file with track time so create track timer
					LeaPlusLC.TrackTimer = C_Timer.NewTimer(trackTime + 1, function()
						if musicHandle then StopSound(musicHandle) end
						if tracknumber == #playlist then
							-- Playlist is at the end, restart from first track
							tracknumber = 1
						end
						PlayTrack()
					end)
				end
				-- Store its handle for later use
				LastMusicHandle = musicHandle
				LastPlayed = playlist[tracknumber]
				tracknumber = tracknumber + 1
				-- Show static highlight bar
				for index = 1, numButtons do
					local button = scrollFrame.buttons[index]
					local item = button:GetText()
					if item then
						if item:match("([^,]+)%#([^,]+)%#([^,]+)") then
							-- Music file with track time
							local item, void, void = item:match("([^,]+)%#([^,]+)%#([^,]+)")
							if item then
								if item == file and LastFolder == TempFolder then
									button.s:Show()
								else
									button.s:Hide()
								end
							end
						else
							-- Sound kit without track time
							local item, void = item:match("([^,]+)%#([^,]+)")
							if item then
								if item == file and LastFolder == TempFolder then
									button.s:Show()
								else
									button.s:Hide()
								end
							end
						end
					end
				end
			end

			-- Create editbox for search
			local sBox = LeaPlusLC:CreateEditBox("MusicSearchBox", LeaPlusLC["Page9"], 78, 10, "TOPLEFT", 150, -260, "MusicSearchBox", "MusicSearchBox")
			sBox:SetMaxLetters(50)

			-- Position search button above editbox
			conbtn[L["Search"]]:ClearAllPoints()
			conbtn[L["Search"]]:SetPoint("BOTTOMLEFT", sBox, "TOPLEFT", -4, 0)

			-- Set initial search data
			for q, w in pairs(ZoneList) do
				if conbtn[w] then
					conbtn[w]:HookScript("OnClick", function()
						if w == L["Search"] then
							ListData[1] = "|cffffd800" .. L["Search"]
							if #ListData == 1 then 
								ListData[2] = "|cffffffaa{" .. L["enter music or movie name"] .. "}"
							end
							UpdateList()
						else
							sBox:ClearFocus()
						end
					end)
				end
			end

			-- Function to show search results
			local function ShowSearchResults()
				-- Get unescaped editbox text
				local searchText = gsub(strlower(sBox:GetText()), '(['..("%^$().[]*+-?"):gsub("(.)", "%%%1")..'])', "%%%1")
				-- Wipe the track listing
				wipe(ListData)
				-- Set the track list heading
				ListData[1] = "|cffffd800" .. L["Search"]
				-- Show the subheading only if no search results are being shown
				if searchText == "" then
					ListData[2] = "|cffffffaa{" .. L["enter music or movie name"] .. "}"
				else
					ListData[2] = ""
				end
				-- Traverse music listing and populate ListData
				if searchText ~= "" then
					local word1, word2, word3, word4, word5 = strsplit(" ", (strtrim(searchText):gsub("%s+", " ")))
					RunScript('LeaPlusGlobalHash = {}')
					local hash = LeaPlusGlobalHash
					local trackCount = 0
					for a, b in pairs({L["Music"], L["Movies"]}) do
						for k, v in pairs(ZoneList[b]) do
							if (strfind(v, "#") or strfind(v, "|r")) and (strfind(strlower(v), word1) or strfind(strlower(b), word1)) then
								if not word2 or word2 ~= "" and (strfind(strlower(v), word2) or strfind(strlower(b), word2)) then
									if not word3 or word3 ~= "" and (strfind(strlower(v), word3) or strfind(strlower(b), word3)) then
										if not word4 or word4 ~= "" and (strfind(strlower(v), word4) or strfind(strlower(b), word4)) then
											if not word5 or word5 ~= "" and (strfind(strlower(v), word5) or strfind(strlower(b), word5)) then
												-- Show category
												if not hash[b] then
													tinsert(ListData, "|cffffffff")
													tinsert(ListData, "|cffffd800" .. b)
													hash[b] = true
												end
												-- Show track
												tinsert(ListData, v)
												trackCount = trackCount + 1
												hash[v] = true
											end
										end
									end
								end
							end
						end
					end

					-- Set results tag
					if trackCount == 1 then
						ListData[2] = "|cffffffaa{" .. trackCount .. " " .. L["result"] .. "}"
					else
						ListData[2] = "|cffffffaa{" .. trackCount .. " " .. L["results"] .. "}"
					end
				end
				-- Refresh the track listing
				UpdateList()
				-- Set track listing to top
				scrollFrame:SetVerticalScroll(0)
			end

			-- Populate ListData when editbox is changed by user
			sBox:HookScript("OnTextChanged", function(self, userInput)
				if userInput then
					-- Show search page
					conbtn[L["Search"]]:Click()
					-- If search results are currently playing, stop playback since search results will be changed
					if LastFolder == L["Search"] then stopBtn:Click() end
					-- Show search results
					ShowSearchResults()
				end
			end)

			-- Populate ListData when editbox enter key is pressed
			sBox:HookScript("OnEnterPressed", function()
				-- Show search page
				conbtn[L["Search"]]:Click()
				-- If search results are currently playing, stop playback since search results will be changed
				if LastFolder == L["Search"] then stopBtn:Click() end
				-- Show search results
				ShowSearchResults()
			end)

			-- Function to show random track listing
			local function ShowRandomList()
				-- If random track is currently playing, stop playback since random track list will be changed
				if LastFolder == L["Random"] then 
					stopBtn:Click()
				end
				-- Wipe the track listing for random
				wipe(ListData)
				-- Set the track list heading
				ListData[1] = "|cffffd800" .. L["Random"]
				ListData[2] = "|Cffffffaa{" .. L["click here to shuffle music"] .. "}" -- Must be capital |C
				ListData[3] = "|cffffd800"
				ListData[4] = "|cffffd800" .. L["Music"] -- Must be lower case |c
				-- Populate list data until it contains desired number of tracks
				while #ListData < #ZoneList[L["Music"]] do
					-- Get random category
					local rCategory = GetRandomArgument(L["Music"])
					-- Get random track within zone
					local rTrack = ZoneList[rCategory][random(1, #ZoneList[L["Music"]])]
					-- Insert track into ListData if it's not a duplicate
					if rTrack and rTrack ~= "" and strfind(rTrack, "#") and not tContains(ListData, rTrack) then
						tinsert(ListData, rTrack)
					end
				end
				-- Refresh the track listing
				UpdateList()
				-- Set track listing to top
				scrollFrame:SetVerticalScroll(0)
			end

			-- Show random track listing on startup when random button is clicked
			for q, w in pairs(ZoneList) do
				if conbtn[w] then
					conbtn[w]:HookScript("OnClick", function()
						if w == L["Random"] then
							-- Generate initial playlist for first run
							if #ListData == 0 then
								ShowRandomList()
							end
						end
					end)
				end
			end

			-- Create list items
			scrollFrame.buttons = {}
			for i = 1, numButtons do
				scrollFrame.buttons[i] = CreateFrame("Button", nil, LeaPlusLC["Page9"])
				local button = scrollFrame.buttons[i]

				button:SetSize(470 - 14, 16)
				button:SetNormalFontObject("GameFontHighlightLeft")
				button:SetPoint("TOPLEFT", 246, -62+ -(i - 1) * 16 - 8)

				-- Create highlight bar texture
				button.t = button:CreateTexture(nil, "BACKGROUND")
				button.t:SetPoint("TOPLEFT", button, 0, 0)
				button.t:SetSize(516, 16)

				button.t:SetColorTexture(0.3, 0.3, 0.0, 0.8)
				button.t:SetAlpha(0.7)
				button.t:Hide()

				-- Create last playing highlight bar texture
				button.s = button:CreateTexture(nil, "BACKGROUND")
				button.s:SetPoint("TOPLEFT", button, 0, 0)
				button.s:SetSize(516, 16)

				button.s:SetColorTexture(0.3, 0.4, 0.00, 0.6)
				button.s:Hide()

				button:SetScript("OnEnter", function()
					-- Highlight links only
					if not string.match(button:GetText() or "", "|c") then
						button.t:Show()
					end
				end)

				button:SetScript("OnLeave", function()
					button.t:Hide()
				end)

				button:RegisterForClicks("LeftButtonUp", "RightButtonUp")

				-- Handler for playing next SoundKit track in playlist
				uframe:SetScript("OnEvent", function(self, event, stoppedHandle)
					if event == "SOUNDKIT_FINISHED" then
						-- Do nothing if stopped sound kit handle doesnt match last played track handle
						if LastMusicHandle and LastMusicHandle ~= stoppedHandle then return end
						-- Reset track number if playlist has reached the end
						if tracknumber == #playlist then tracknumber = 1 end
						-- Play next track
						PlayTrack()
					elseif event == "LOADING_SCREEN_DISABLED" then
						-- Restart player if it stopped between tracks during loading screen
						if playlist and tracknumber and playlist[tracknumber] and not willPlay and not musicHandle then
							tracknumber = tracknumber - 1
							C_Timer.After(0.1, PlayTrack)
						end
					end
				end)

				-- Click handler for track, zone and back button
				button:SetScript("OnClick", function(self, btn)
					if btn == "LeftButton" then
						-- Remove focus from search box
						sBox:ClearFocus()
						-- Get clicked track text
						local item = self:GetText()
						-- Do nothing if its a blank line or informational heading
						if not item or strfind(item, "|c") then return end
						if item == "|Cffffffaa{" .. L["click here to shuffle music"] .. "}" then -- must be capital |C
							-- Create new random track listing
							ShowRandomList()
							return
						elseif strfind(item, "#") then
							-- Enable sound if required
							if GetCVar("Sound_EnableAllSound") == "0" then SetCVar("Sound_EnableAllSound", "1") end
							-- Disable music if it's currently enabled
							if GetCVar("Sound_EnableMusic") == "1" then	SetCVar("Sound_EnableMusic", "0") end
							-- Add all tracks to playlist
							wipe(playlist)
							local StartItem = 0
							-- Get item clicked row number
							for index = 1, #ListData do
								local item = ListData[index]
								if self:GetText() == item then StartItem = index end
							end
							-- Add all items from clicked item onwards to playlist
							for index = StartItem, #ListData do
								local item = ListData[index]
								if item then
									if strfind(item, "#") then 
										tinsert(playlist, item)
									end
								end
							end
							-- Add all items up to clicked item to playlist
							for index = 1, StartItem do
								local item = ListData[index]
								if item then
									if strfind(item, "#") then 
										tinsert(playlist, item)
									end
								end
							end
							-- Enable the stop button
							LeaPlusLC:LockItem(stopBtn, false)
							-- Set Temp Folder to currently playing folder
							TempFolder = L[gsub(ListData[1], "|cffffd800", "")]
							-- Store information about the track we are about to play
							tracknumber = 1
							LastPlayed = item
							LastFolder = TempFolder
							HeadingOfClickedTrack = ListData[1]
							-- Play first track
							PlayTrack()
							-- Play subsequent tracks (commented out for now because sound kits are not used)
							-- uframe:RegisterEvent("SOUNDKIT_FINISHED")
							-- uframe:RegisterEvent("LOADING_SCREEN_DISABLED")
							return
						elseif strfind(item, "|r") then
							-- A movie was clicked
							local movieName, movieID = item:match("([^,]+)%|r([^,]+)")
							movieID = strtrim(movieID, "()")
							if IsMoviePlayable(movieID) then
								stopBtn:Click()
								MovieFrame_PlayMovie(MovieFrame, movieID)
							else
								LeaPlusLC:Print("Movie not playable.")
							end
							return
						end
					end
				end)

			end

			-- Delete the global scroll frame pointer
			_G.LeaPlusScrollFrame = nil

			-- Set zone listing on startup
			if LeaPlusDB["MusicContinent"] and LeaPlusDB["MusicContinent"] ~= "" then
				-- Saved music continent exists
				if conbtn[LeaPlusDB["MusicContinent"]] then
					-- Saved continent is valid button so click it
					conbtn[LeaPlusDB["MusicContinent"]]:Click()
				else
					-- Saved continent is not valid button so click default button
					conbtn[L["Music"]]:Click()
				end
			else
				-- Saved music continent does not exist so click default button
				conbtn[L["Music"]]:Click()
			end
			UpdateList()

			-- Manage events
			LeaPlusLC["Page9"]:RegisterEvent("PLAYER_LOGOUT")
			LeaPlusLC["Page9"]:RegisterEvent("UI_SCALE_CHANGED")
			LeaPlusLC["Page9"]:SetScript("OnEvent", function(self, event)
				if event == "PLAYER_LOGOUT" then
					-- Stop playing at reload or logout
					if musicHandle then
						StopSound(musicHandle)
					end
				elseif event == "UI_SCALE_CHANGED" then
					-- Refresh list
					UpdateList()
				end
			end)

		end

		-- Run on startup
		LeaPlusLC:MediaFunc()

		-- Release memory
		LeaPlusLC.MediaFunc = nil

		----------------------------------------------------------------------
		-- Panel alpha
		----------------------------------------------------------------------

		-- Function to set panel alpha
		local function SetPlusAlpha()
			-- Set panel alpha
			LeaPlusLC["PageF"].t:SetAlpha(1 - LeaPlusLC["PlusPanelAlpha"])
			-- Show formatted value
			LeaPlusCB["PlusPanelAlpha"].f:SetFormattedText("%.0f%%", LeaPlusLC["PlusPanelAlpha"] * 100)
		end

		-- Set alpha on startup
		SetPlusAlpha()

		-- Set alpha after changing slider
		LeaPlusCB["PlusPanelAlpha"]:HookScript("OnValueChanged", SetPlusAlpha)

		----------------------------------------------------------------------
		-- Panel scale
		----------------------------------------------------------------------

		-- Function to set panel scale
		local function SetPlusScale()
			-- Reset panel position
			LeaPlusLC["MainPanelA"], LeaPlusLC["MainPanelR"], LeaPlusLC["MainPanelX"], LeaPlusLC["MainPanelY"] = "CENTER", "CENTER", 0, 0
			if LeaPlusLC["PageF"]:IsShown() then 
				LeaPlusLC["PageF"]:Hide()
				LeaPlusLC["PageF"]:Show()
			end
			-- Set panel scale
			LeaPlusLC["PageF"]:SetScale(LeaPlusLC["PlusPanelScale"])
			-- Update music player highlight bar scale
			LeaPlusLC:UpdateList()
		end

		-- Set scale on startup
		LeaPlusLC["PageF"]:SetScale(LeaPlusLC["PlusPanelScale"])

		-- Set scale and reset panel position after changing slider
		LeaPlusCB["PlusPanelScale"]:HookScript("OnMouseUp", SetPlusScale)
		LeaPlusCB["PlusPanelScale"]:HookScript("OnMouseWheel", SetPlusScale)

		-- Show formatted slider value
		LeaPlusCB["PlusPanelScale"]:HookScript("OnValueChanged", function()
			LeaPlusCB["PlusPanelScale"].f:SetFormattedText("%.0f%%", LeaPlusLC["PlusPanelScale"] * 100)
		end)

		----------------------------------------------------------------------
		-- Options panel
		----------------------------------------------------------------------

		-- Hide Leatrix Plus if game options panel is shown
		InterfaceOptionsFrame:HookScript("OnShow", LeaPlusLC.HideFrames);
		VideoOptionsFrame:HookScript("OnShow", LeaPlusLC.HideFrames);

		----------------------------------------------------------------------
		-- Block friend requests
		----------------------------------------------------------------------

		-- Function to decline friend requests
		local function DeclineReqs()
			if LeaPlusLC["NoFriendRequests"] == "On" then
				for i = BNGetNumFriendInvites(), 1, -1 do
					local id, player = BNGetFriendInviteInfo(i)
					if id and player then
						BNDeclineFriendInvite(id)
						C_Timer.After(0.1, function()
							LeaPlusLC:Print(L["A friend request from"] .. " " .. player .. " " .. L["was automatically declined."])
						end)
					end
				end
			end
		end

		-- Event frame for incoming friend requests
		local DecEvt = CreateFrame("FRAME")
		DecEvt:SetScript("OnEvent", DeclineReqs)

		-- Function to register or unregister the event
		local function ControlEvent()
			if LeaPlusLC["NoFriendRequests"] == "On" then
				DecEvt:RegisterEvent("BN_FRIEND_INVITE_ADDED")
				DeclineReqs()
			else
				DecEvt:UnregisterEvent("BN_FRIEND_INVITE_ADDED")
			end
		end

		-- Set event status when option is enabled
		LeaPlusCB["NoFriendRequests"]:HookScript("OnClick", ControlEvent)

		-- Set event status on startup
		ControlEvent()

		----------------------------------------------------------------------
		-- Final code for RunOnce
		----------------------------------------------------------------------

		-- Update addon memory usage (speeds up initial value)
		UpdateAddOnMemoryUsage();

		-- Release memory
		LeaPlusLC.RunOnce = nil

	end

----------------------------------------------------------------------
-- 	L60: Default events
----------------------------------------------------------------------

	local function eventHandler(self, event, arg1, arg2, ...)

		----------------------------------------------------------------------
		-- Invite from whisper
		----------------------------------------------------------------------

		if event == "CHAT_MSG_WHISPER" or event == "CHAT_MSG_BN_WHISPER" then
			if (not UnitExists("party1") or UnitIsGroupLeader("player")) and strlower(arg1) == "inv" then
				if event == "CHAT_MSG_WHISPER" then
					InviteUnit(arg2)
				elseif event == "CHAT_MSG_BN_WHISPER" then
					local presenceID = select(11, ...)
					if presenceID and BNIsFriend(presenceID) then
						local index = BNGetFriendIndex(presenceID);
						if index then
							local presenceID, presenceName, battleTag, isBattleTagPresence, toonName, toonID = BNGetFriendInfo(index);
							if toonID then
								BNInviteFriend(toonID);
							end
						end
					end
				end
			end
			return
		end

		----------------------------------------------------------------------
		-- Block duel requests
		----------------------------------------------------------------------

		if event == "DUEL_REQUESTED" and not LeaPlusLC:FriendCheck(arg1) then
			CancelDuel();
			StaticPopup_Hide("DUEL_REQUESTED");
			return
		end

		----------------------------------------------------------------------
		-- Automatically accept resurrection requests
		----------------------------------------------------------------------

		if event == "RESURRECT_REQUEST" then

			-- Resurrect automatically if not in combat
			if not UnitAffectingCombat(arg1) then
				AcceptResurrect()
				StaticPopup_Hide("RESURRECT_NO_TIMER")
			end
			return

		end

		----------------------------------------------------------------------
		-- Accept summon
		----------------------------------------------------------------------

		if event == "CONFIRM_SUMMON" then
			if not UnitAffectingCombat("player") then
				ConfirmSummon()
				StaticPopup_Hide("CONFIRM_SUMMON")
			end
			return
		end

		----------------------------------------------------------------------
		-- Block party invites
		----------------------------------------------------------------------

		if event == "PARTY_INVITE_REQUEST" then

			-- If a friend, accept if you're accepting friends
			if (LeaPlusLC["AcceptPartyFriends"] == "On" and LeaPlusLC:FriendCheck(arg1)) then
				AcceptGroup();
				for i=1, STATICPOPUP_NUMDIALOGS do
					if _G["StaticPopup"..i].which == "PARTY_INVITE" then
						_G["StaticPopup"..i].inviteAccepted = 1
						StaticPopup_Hide("PARTY_INVITE");
						break
					elseif _G["StaticPopup"..i].which == "PARTY_INVITE_XREALM" then
						_G["StaticPopup"..i].inviteAccepted = 1
						StaticPopup_Hide("PARTY_INVITE_XREALM");
						break
					end
				end
				return
			end

			-- If not a friend and you're blocking invites, decline
			if LeaPlusLC["NoPartyInvites"] == "On" then
				if LeaPlusLC:FriendCheck(arg1) then
					return
				else
					DeclineGroup();
					StaticPopup_Hide("PARTY_INVITE");
					StaticPopup_Hide("PARTY_INVITE_XREALM");
					return
				end
			end

			return
		end

		----------------------------------------------------------------------
		-- Disable loot warnings
		----------------------------------------------------------------------

		-- Disable warnings for attempting to roll Need on loot
		if event == "CONFIRM_LOOT_ROLL" then
			ConfirmLootRoll(arg1, arg2)
			StaticPopup_Hide("CONFIRM_LOOT_ROLL")
			return
		end

		-- Disable warning for attempting to loot a Bind on Pickup item
		if event == "LOOT_BIND_CONFIRM" then
			ConfirmLootSlot(arg1, arg2)
			StaticPopup_Hide("LOOT_BIND",...)
			return
		end

		-- Disable warning for attempting to vendor an item within its refund window
		if event == "MERCHANT_CONFIRM_TRADE_TIMER_REMOVAL" then
			SellCursorItem()
			return
		end

		-- Disable warning for attempting to mail an item within its refund window
		if event == "MAIL_LOCK_SEND_ITEMS" then
			RespondMailLockSendItem(arg1, true)
			return
		end

		----------------------------------------------------------------------
		-- Automatically release in battlegrounds
		----------------------------------------------------------------------

		if event == "PLAYER_DEAD" then

			-- If player has ability to self-resurrect (soulstone, reincarnation, etc), do nothing and quit
			if C_DeathInfo.GetSelfResurrectOptions() and #C_DeathInfo.GetSelfResurrectOptions() > 0 then return end

			-- Resurrect if player is in a battleground
			local InstStat, InstType = IsInInstance()
			if InstStat and InstType == "pvp" then
				RepopMe()
				return
			end

			return

		end

		----------------------------------------------------------------------
		-- Hide the combat log
		----------------------------------------------------------------------

		if event == "UPDATE_CHAT_WINDOWS" then
			ChatFrame2Tab:EnableMouse(false)
			ChatFrame2Tab:SetText(" ") -- Needs to be something for chat settings to function
			ChatFrame2Tab:SetScale(0.01)
			ChatFrame2Tab:SetWidth(0.01)
			ChatFrame2Tab:SetHeight(0.01)
		end

		----------------------------------------------------------------------
		-- L62: Profile events
		----------------------------------------------------------------------

		if event == "ADDON_LOADED" then
			if arg1 == "Leatrix_Plus" then

				-- Automation
				LeaPlusLC:LoadVarChk("AutomateQuests", "Off")				-- Automate quests
				LeaPlusLC:LoadVarChk("AutomateGossip", "Off")				-- Automate gossip
				LeaPlusLC:LoadVarChk("AutoAcceptSummon", "Off")				-- Accept summon
				LeaPlusLC:LoadVarChk("AutoAcceptRes", "Off")				-- Accept resurrection
				LeaPlusLC:LoadVarChk("AutoReleasePvP", "Off")				-- Release in PvP

				LeaPlusLC:LoadVarChk("AutoSellJunk", "Off")					-- Sell junk automatically
				LeaPlusLC:LoadVarChk("AutoRepairGear", "Off")				-- Repair automatically

				-- Social
				LeaPlusLC:LoadVarChk("NoDuelRequests", "Off")				-- Block duels
				LeaPlusLC:LoadVarChk("NoPartyInvites", "Off")				-- Block party invites
				LeaPlusLC:LoadVarChk("NoFriendRequests", "Off")				-- Block friend requests

				LeaPlusLC:LoadVarChk("AcceptPartyFriends", "Off")			-- Party from friends
				LeaPlusLC:LoadVarChk("InviteFromWhisper", "Off")			-- Invite from whispers

				-- Chat
				LeaPlusLC:LoadVarChk("UseEasyChatResizing", "Off")			-- Use easy resizing
				LeaPlusLC:LoadVarChk("NoCombatLogTab", "Off")				-- Hide the combat log
				LeaPlusLC:LoadVarChk("NoChatButtons", "Off")				-- Hide chat buttons
				LeaPlusLC:LoadVarChk("UnclampChat", "Off")					-- Unclamp chat frame
				LeaPlusLC:LoadVarChk("MoveChatEditBoxToTop", "Off")			-- Move editbox to top

				LeaPlusLC:LoadVarChk("NoStickyChat", "Off")					-- Disable sticky chat
				LeaPlusLC:LoadVarChk("UseArrowKeysInChat", "Off")			-- Use arrow keys in chat
				LeaPlusLC:LoadVarChk("NoChatFade", "Off")					-- Disable chat fade
				LeaPlusLC:LoadVarChk("UnivGroupColor", "Off")				-- Universal group color
				LeaPlusLC:LoadVarChk("ClassColorsInChat", "Off")			-- Use class colors in chat
				LeaPlusLC:LoadVarChk("RecentChatWindow", "Off")				-- Recent chat window
				LeaPlusLC:LoadVarChk("MaxChatHstory", "Off")				-- Increase chat history

				-- Text
				LeaPlusLC:LoadVarChk("HideErrorMessages", "Off")			-- Hide error messages
				LeaPlusLC:LoadVarChk("NoHitIndicators", "Off")				-- Hide portrait text
				LeaPlusLC:LoadVarChk("HideZoneText", "Off")					-- Hide zone text

				LeaPlusLC:LoadVarChk("MailFontChange", "Off")				-- Resize mail text
				LeaPlusLC:LoadVarNum("LeaPlusMailFontSize", 15, 10, 36)		-- Mail text slider

				LeaPlusLC:LoadVarChk("QuestFontChange", "Off")				-- Resize quest text
				LeaPlusLC:LoadVarNum("LeaPlusQuestFontSize", 12, 10, 36)	-- Quest text slider

				-- Interface
				LeaPlusLC:LoadVarChk("MinimapMod", "Off")					-- Customise minimap
				LeaPlusLC:LoadVarChk("HideZoneTextBar", "Off")				-- Hide zone text bar
				LeaPlusLC:LoadVarChk("HideMiniZoomBtns", "Off")				-- Hide zoom buttons
				LeaPlusLC:LoadVarNum("MinimapScale", 1, 1, 2)				-- Minimap scale slider

				LeaPlusLC:LoadVarChk("TipModEnable", "Off")					-- Manage tooltip
				LeaPlusLC:LoadVarChk("TipMoveTip", "On")					-- Reposition the tooltip
				LeaPlusLC:LoadVarChk("TipShowGuild", "On")					-- Show guild
				LeaPlusLC:LoadVarChk("TipShowTarget", "On")					-- Show target
				LeaPlusLC:LoadVarChk("TipBackSimple", "Off")				-- Color backdrops
				LeaPlusLC:LoadVarChk("TipHideInCombat", "Off")				-- Hide tooltips during combat
				LeaPlusLC:LoadVarNum("LeaPlusTipSize", 1.00, 0.50, 2.00)	-- Tooltip scale slider
				LeaPlusLC:LoadVarNum("TipOffsetX", -13, -5000, 5000)		-- Tooltip X offset
				LeaPlusLC:LoadVarNum("TipOffsetY", 94, -5000, 5000)			-- Tooltip Y offset

				LeaPlusLC:LoadVarChk("EnhanceDressup", "Off")				-- Enhance dressup
				LeaPlusLC:LoadVarChk("ShowVolume", "Off")					-- Show volume slider
				LeaPlusLC:LoadVarChk("AhExtras", "Off")						-- Show auction controls
				LeaPlusLC:LoadVarChk("AhBuyoutOnly", "Off")					-- Auction buyout only
				LeaPlusLC:LoadVarChk("AhGoldOnly", "Off")					-- Auction gold only

				LeaPlusLC:LoadVarChk("ShowCooldowns", "Off")				-- Show cooldowns
				LeaPlusLC:LoadVarChk("ShowCooldownID", "On")				-- Show cooldown ID in tips
				LeaPlusLC:LoadVarChk("NoCooldownDuration", "On")			-- Hide cooldown duration
				LeaPlusLC:LoadVarChk("DurabilityStatus", "Off")				-- Show durability status
				LeaPlusLC:LoadVarChk("ShowVanityControls", "Off")			-- Show vanity controls
				LeaPlusLC:LoadVarChk("ShowWowheadLinks", "Off")				-- Show Wowhead links

				-- Frames
				LeaPlusLC:LoadVarChk("FrmEnabled", "Off")					-- Manage frames
				LeaPlusLC:LoadVarChk("ClassColFrames", "Off")				-- Class colored frames
				LeaPlusLC:LoadVarChk("ShowPlayerChain", "Off")				-- Show player chain
				LeaPlusLC:LoadVarNum("PlayerChainMenu", 2, 1, 3)			-- Player chain dropdown value
				LeaPlusLC:LoadVarChk("ShowRaidToggle", "Off")				-- Show raid toggle button
				LeaPlusLC:LoadVarChk("CombatPlates", "Off")					-- Combat plates

				LeaPlusLC:LoadVarChk("NoGryphons", "Off")					-- Hide gryphons
				LeaPlusLC:LoadVarChk("NoClassBar", "Off")					-- Hide stance bar

				-- System
				LeaPlusLC:LoadVarChk("NoScreenGlow", "Off")					-- Disable screen glow
				LeaPlusLC:LoadVarChk("NoScreenEffects", "Off")				-- Disable screen effects
				LeaPlusLC:LoadVarChk("MaxCameraZoom", "Off")				-- Max camera zoom
				LeaPlusLC:LoadVarChk("ViewPortEnable", "Off")				-- Enable viewport
				LeaPlusLC:LoadVarNum("ViewPortTop", 0, 0, 300)				-- Top border
				LeaPlusLC:LoadVarNum("ViewPortBottom", 0, 0, 300)			-- Bottom border
				LeaPlusLC:LoadVarNum("ViewPortLeft", 0, 0, 300)				-- Left border
				LeaPlusLC:LoadVarNum("ViewPortRight", 0, 0, 300)			-- Right border
				LeaPlusLC:LoadVarNum("ViewPortResizeTop", 0, 0, 300)		-- Resize top border
				LeaPlusLC:LoadVarNum("ViewPortResizeBottom", 0, 0, 300)		-- Resize bottom border
				LeaPlusLC:LoadVarNum("ViewPortAlpha", 0, 0, 0.9)			-- Border alpha

				LeaPlusLC:LoadVarChk("NoRestedEmotes", "Off")				-- Silence rested emotes

				LeaPlusLC:LoadVarChk("NoBagAutomation", "Off")				-- Disable bag automation
				LeaPlusLC:LoadVarChk("CharAddonList", "Off")				-- Show character addons
				LeaPlusLC:LoadVarChk("NoConfirmLoot", "Off")				-- Disable loot warnings
				LeaPlusLC:LoadVarChk("FasterLooting", "Off")				-- Faster auto loot
				LeaPlusLC:LoadVarChk("FasterMovieSkip", "Off")				-- Faster movie skip
				LeaPlusLC:LoadVarChk("StandAndDismount", "Off")				-- Stand and dismount
				LeaPlusLC:LoadVarChk("ShowVendorPrice", "Off")				-- Show vendor price

				-- Settings
				LeaPlusLC:LoadVarChk("ShowMinimapIcon", "On")				-- Show minimap button
				LeaPlusLC:LoadVarChk("EnableHotkey", "Off")					-- Enable hotkey

				LeaPlusLC:LoadVarNum("PlusPanelScale", 1, 1, 2)				-- Panel scale
				LeaPlusLC:LoadVarNum("PlusPanelAlpha", 0, 0, 1)				-- Panel alpha

				-- Panel position
				LeaPlusLC:LoadVarAnc("MainPanelA", "CENTER")				-- Panel anchor
				LeaPlusLC:LoadVarAnc("MainPanelR", "CENTER")				-- Panel relative
				LeaPlusLC:LoadVarNum("MainPanelX", 0, -5000, 5000)			-- Panel X axis
				LeaPlusLC:LoadVarNum("MainPanelY", 0, -5000, 5000)			-- Panel Y axis

				-- Start page
				LeaPlusLC:LoadVarNum("LeaStartPage", 0, 0, LeaPlusLC["NumberOfPages"])

				-- Run other startup items
				LeaPlusLC:Live()
				LeaPlusLC:Isolated()
				LeaPlusLC:RunOnce()
				LeaPlusLC:SetDim()

			end
			return
		end

		if event == "PLAYER_LOGIN" then
			LeaPlusLC:Player()
			collectgarbage()
			return
		end

		if event == "PLAYER_ENTERING_WORLD" then
			LeaPlusLC:World()
			LpEvt:UnregisterEvent("PLAYER_ENTERING_WORLD")
			return
		end

		-- Save locals back to globals on logout
		if event == "PLAYER_LOGOUT" then

			-- Run the logout function without wipe flag
			LeaPlusLC:PlayerLogout(false)

			-- Automation
			LeaPlusDB["AutomateQuests"]			= LeaPlusLC["AutomateQuests"]
			LeaPlusDB["AutomateGossip"]			= LeaPlusLC["AutomateGossip"]
			LeaPlusDB["AutoAcceptSummon"] 		= LeaPlusLC["AutoAcceptSummon"]
			LeaPlusDB["AutoAcceptRes"] 			= LeaPlusLC["AutoAcceptRes"]
			LeaPlusDB["AutoReleasePvP"] 		= LeaPlusLC["AutoReleasePvP"]

			LeaPlusDB["AutoSellJunk"] 			= LeaPlusLC["AutoSellJunk"]
			LeaPlusDB["AutoRepairGear"] 		= LeaPlusLC["AutoRepairGear"]

			-- Social
			LeaPlusDB["NoDuelRequests"] 		= LeaPlusLC["NoDuelRequests"]
			LeaPlusDB["NoPartyInvites"]			= LeaPlusLC["NoPartyInvites"]
			LeaPlusDB["NoFriendRequests"]		= LeaPlusLC["NoFriendRequests"]

			LeaPlusDB["AcceptPartyFriends"]		= LeaPlusLC["AcceptPartyFriends"]
			LeaPlusDB["InviteFromWhisper"]		= LeaPlusLC["InviteFromWhisper"]

			-- Chat
			LeaPlusDB["UseEasyChatResizing"]	= LeaPlusLC["UseEasyChatResizing"]
			LeaPlusDB["NoCombatLogTab"]			= LeaPlusLC["NoCombatLogTab"]
			LeaPlusDB["NoChatButtons"]			= LeaPlusLC["NoChatButtons"]
			LeaPlusDB["UnclampChat"]			= LeaPlusLC["UnclampChat"]
			LeaPlusDB["MoveChatEditBoxToTop"]	= LeaPlusLC["MoveChatEditBoxToTop"]

			LeaPlusDB["NoStickyChat"] 			= LeaPlusLC["NoStickyChat"]
			LeaPlusDB["UseArrowKeysInChat"]		= LeaPlusLC["UseArrowKeysInChat"]
			LeaPlusDB["NoChatFade"]				= LeaPlusLC["NoChatFade"]
			LeaPlusDB["UnivGroupColor"]			= LeaPlusLC["UnivGroupColor"]
			LeaPlusDB["ClassColorsInChat"]		= LeaPlusLC["ClassColorsInChat"]
			LeaPlusDB["RecentChatWindow"]		= LeaPlusLC["RecentChatWindow"]
			LeaPlusDB["MaxChatHstory"]			= LeaPlusLC["MaxChatHstory"]

			-- Text
			LeaPlusDB["HideErrorMessages"]		= LeaPlusLC["HideErrorMessages"]
			LeaPlusDB["NoHitIndicators"]		= LeaPlusLC["NoHitIndicators"]
			LeaPlusDB["HideZoneText"] 			= LeaPlusLC["HideZoneText"]

			LeaPlusDB["MailFontChange"] 		= LeaPlusLC["MailFontChange"]
			LeaPlusDB["LeaPlusMailFontSize"] 	= LeaPlusLC["LeaPlusMailFontSize"]

			LeaPlusDB["QuestFontChange"] 		= LeaPlusLC["QuestFontChange"]
			LeaPlusDB["LeaPlusQuestFontSize"]	= LeaPlusLC["LeaPlusQuestFontSize"]

			-- Interface
			LeaPlusDB["MinimapMod"]				= LeaPlusLC["MinimapMod"]
			LeaPlusDB["HideZoneTextBar"]		= LeaPlusLC["HideZoneTextBar"]
			LeaPlusDB["HideMiniZoomBtns"]		= LeaPlusLC["HideMiniZoomBtns"]
			LeaPlusDB["MinimapScale"]			= LeaPlusLC["MinimapScale"]

			LeaPlusDB["TipModEnable"]			= LeaPlusLC["TipModEnable"]
			LeaPlusDB["TipMoveTip"]				= LeaPlusLC["TipMoveTip"]
			LeaPlusDB["TipShowGuild"]			= LeaPlusLC["TipShowGuild"]
			LeaPlusDB["TipShowTarget"]			= LeaPlusLC["TipShowTarget"]
			LeaPlusDB["TipBackSimple"]			= LeaPlusLC["TipBackSimple"]
			LeaPlusDB["TipHideInCombat"]		= LeaPlusLC["TipHideInCombat"]
			LeaPlusDB["LeaPlusTipSize"]			= LeaPlusLC["LeaPlusTipSize"]
			LeaPlusDB["TipOffsetX"]				= LeaPlusLC["TipOffsetX"]
			LeaPlusDB["TipOffsetY"]				= LeaPlusLC["TipOffsetY"]

			LeaPlusDB["EnhanceDressup"]			= LeaPlusLC["EnhanceDressup"]
			LeaPlusDB["ShowVolume"] 			= LeaPlusLC["ShowVolume"]
			LeaPlusDB["AhExtras"]				= LeaPlusLC["AhExtras"]
			LeaPlusDB["AhBuyoutOnly"]			= LeaPlusLC["AhBuyoutOnly"]
			LeaPlusDB["AhGoldOnly"]				= LeaPlusLC["AhGoldOnly"]

			LeaPlusDB["ShowCooldowns"]			= LeaPlusLC["ShowCooldowns"]
			LeaPlusDB["ShowCooldownID"]			= LeaPlusLC["ShowCooldownID"]
			LeaPlusDB["NoCooldownDuration"]		= LeaPlusLC["NoCooldownDuration"]
			LeaPlusDB["DurabilityStatus"]		= LeaPlusLC["DurabilityStatus"]
			LeaPlusDB["ShowVanityControls"]		= LeaPlusLC["ShowVanityControls"]
			LeaPlusDB["ShowWowheadLinks"]		= LeaPlusLC["ShowWowheadLinks"]

			-- Frames
			LeaPlusDB["FrmEnabled"]				= LeaPlusLC["FrmEnabled"]
			LeaPlusDB["ClassColFrames"]			= LeaPlusLC["ClassColFrames"]
			LeaPlusDB["ShowPlayerChain"]		= LeaPlusLC["ShowPlayerChain"]
			LeaPlusDB["PlayerChainMenu"]		= LeaPlusLC["PlayerChainMenu"]
			LeaPlusDB["ShowRaidToggle"]			= LeaPlusLC["ShowRaidToggle"]
			LeaPlusDB["CombatPlates"]			= LeaPlusLC["CombatPlates"]

			LeaPlusDB["NoGryphons"]				= LeaPlusLC["NoGryphons"]
			LeaPlusDB["NoClassBar"]				= LeaPlusLC["NoClassBar"]

			-- System
			LeaPlusDB["NoScreenGlow"] 			= LeaPlusLC["NoScreenGlow"]
			LeaPlusDB["NoScreenEffects"] 		= LeaPlusLC["NoScreenEffects"]
			LeaPlusDB["MaxCameraZoom"] 			= LeaPlusLC["MaxCameraZoom"]
			LeaPlusDB["ViewPortEnable"]			= LeaPlusLC["ViewPortEnable"]
			LeaPlusDB["ViewPortTop"]			= LeaPlusLC["ViewPortTop"]
			LeaPlusDB["ViewPortBottom"]			= LeaPlusLC["ViewPortBottom"]
			LeaPlusDB["ViewPortLeft"]			= LeaPlusLC["ViewPortLeft"]
			LeaPlusDB["ViewPortRight"]			= LeaPlusLC["ViewPortRight"]
			LeaPlusDB["ViewPortResizeTop"]		= LeaPlusLC["ViewPortResizeTop"]
			LeaPlusDB["ViewPortResizeBottom"]	= LeaPlusLC["ViewPortResizeBottom"]
			LeaPlusDB["ViewPortAlpha"]			= LeaPlusLC["ViewPortAlpha"]

			LeaPlusDB["NoRestedEmotes"]			= LeaPlusLC["NoRestedEmotes"]

			LeaPlusDB["NoBagAutomation"]		= LeaPlusLC["NoBagAutomation"]
			LeaPlusDB["CharAddonList"]			= LeaPlusLC["CharAddonList"]
			LeaPlusDB["NoConfirmLoot"] 			= LeaPlusLC["NoConfirmLoot"]
			LeaPlusDB["FasterLooting"] 			= LeaPlusLC["FasterLooting"]
			LeaPlusDB["FasterMovieSkip"] 		= LeaPlusLC["FasterMovieSkip"]
			LeaPlusDB["StandAndDismount"] 		= LeaPlusLC["StandAndDismount"]
			LeaPlusDB["ShowVendorPrice"] 		= LeaPlusLC["ShowVendorPrice"]

			-- Settings
			LeaPlusDB["ShowMinimapIcon"] 		= LeaPlusLC["ShowMinimapIcon"]
			LeaPlusDB["EnableHotkey"] 			= LeaPlusLC["EnableHotkey"]

			LeaPlusDB["PlusPanelScale"] 		= LeaPlusLC["PlusPanelScale"]
			LeaPlusDB["PlusPanelAlpha"] 		= LeaPlusLC["PlusPanelAlpha"]

			-- Panel position
			LeaPlusDB["MainPanelA"]				= LeaPlusLC["MainPanelA"]
			LeaPlusDB["MainPanelR"]				= LeaPlusLC["MainPanelR"]
			LeaPlusDB["MainPanelX"]				= LeaPlusLC["MainPanelX"]
			LeaPlusDB["MainPanelY"]				= LeaPlusLC["MainPanelY"]

			-- Start page
			LeaPlusDB["LeaStartPage"]			= LeaPlusLC["LeaStartPage"]

		end

	end

--	Register event handler
	LpEvt:SetScript("OnEvent", eventHandler);

----------------------------------------------------------------------
--	L70: Player logout
----------------------------------------------------------------------

	-- Player Logout
	function LeaPlusLC:PlayerLogout(wipe)

		----------------------------------------------------------------------
		-- Restore default values for options that do not require reloads
		----------------------------------------------------------------------

		-- Disable screen glow (LeaPlusLC["NoScreenGlow"])
		if wipe then

			-- Disable screen glow (LeaPlusLC["NoScreenGlow"])
			SetCVar("ffxGlow", "1")

			-- Disable screen effects (LeaPlusLC["NoScreenEffects"])
			SetCVar("ffxDeath", "1")
			SetCVar("ffxNether", "1")

			-- Max camera zoom (LeaPlusLC["MaxCameraZoom"])
			SetCVar("cameraDistanceMaxZoomFactor", 1.9)

			-- Universal group color (LeaPlusLC["UnivGroupColor"])
			ChangeChatColor("RAID", 1, 0.50, 0)
			ChangeChatColor("RAID_LEADER", 1, 0.28, 0.04)
			ChangeChatColor("INSTANCE_CHAT", 1, 0.50, 0)
			ChangeChatColor("INSTANCE_CHAT_LEADER", 1, 0.28, 0.04)

			-- Use class colors in chat (LeaPlusLC["ClassColorsInChat"])
			SetCVar("chatClassColorOverride", "1")

		end

		----------------------------------------------------------------------
		-- Restore default values for options that require reloads
		----------------------------------------------------------------------

		-- Silence rested emotes
		if LeaPlusDB["NoRestedEmotes"] == "On" then
			if wipe or (not wipe and LeaPlusLC["NoRestedEmotes"] == "Off") then
				SetCVar("Sound_EnableEmoteSounds", "1")
			end
		end

		----------------------------------------------------------------------
		-- Do other stuff during logout
		----------------------------------------------------------------------

		-- Prevent frame caching if frame customisation is enabled
		if LeaPlusDB["FrmEnabled"] == "On" then
			PlayerFrame:SetMovable(true)
			PlayerFrame:SetUserPlaced(false)
			TargetFrame:SetMovable(true)
			TargetFrame:SetUserPlaced(false)
		end

		-- Store the auction house duration and price type values if auction house option is enabled
		if LeaPlusDB["AhExtras"] == "On" then
			if AuctionFrameAuctions then
				if AuctionFrameAuctions.duration then
					LeaPlusDB["AHDuration"] = AuctionFrameAuctions.duration
				end
			end
		end

	end

----------------------------------------------------------------------
-- 	Options panel functions
----------------------------------------------------------------------

	-- Function to add textures to panels
	function LeaPlusLC:CreateBar(name, parent, width, height, anchor, r, g, b, alp, tex)
		local ft = parent:CreateTexture(nil, "BORDER")
		ft:SetTexture(tex)
		ft:SetSize(width, height)  
		ft:SetPoint(anchor)
		ft:SetVertexColor(r ,g, b, alp)
		if name == "MainTexture" then
			ft:SetTexCoord(0.09, 1, 0, 1);
		end
	end

	-- Create a configuration panel
	function LeaPlusLC:CreatePanel(title, globref)

		-- Create the panel
		local Side = CreateFrame("Frame", nil, UIParent)

		-- Make it a system frame
		_G["LeaPlusGlobalPanel_" .. globref] = Side
		table.insert(UISpecialFrames, "LeaPlusGlobalPanel_" .. globref)

		-- Store it in the configuration panel table
		tinsert(LeaConfigList, Side)

		-- Set frame parameters
		Side:Hide();
		Side:SetSize(570, 370); 
		Side:SetClampedToScreen(true)
		Side:SetClampRectInsets(500, -500, -300, 300)
		Side:SetFrameStrata("FULLSCREEN_DIALOG")

		-- Set the background color
		Side.t = Side:CreateTexture(nil, "BACKGROUND")
		Side.t:SetAllPoints()
		Side.t:SetColorTexture(0.05, 0.05, 0.05, 0.9)

		-- Add a close Button
		Side.c = CreateFrame("Button", nil, Side, "UIPanelCloseButton") 
		Side.c:SetSize(30, 30)
		Side.c:SetPoint("TOPRIGHT", 0, 0)
		Side.c:SetScript("OnClick", function() Side:Hide() end)

		-- Add reset, help and back buttons
		Side.r = LeaPlusLC:CreateButton("ResetButton", Side, "Reset", "TOPLEFT", 16, -292, 0, 25, true, "Click to reset the settings on this page.")
		Side.h = LeaPlusLC:CreateButton("HelpButton", Side, "Help", "TOPLEFT", 76, -292, 0, 25, true, "No help is available for this page.")
		Side.b = LeaPlusLC:CreateButton("BackButton", Side, "Back to Main Menu", "TOPRIGHT", -16, -292, 0, 25, true, "Click to return to the main menu.")

		-- Reposition help button so it doesn't overlap reset button
		Side.h:ClearAllPoints()
		Side.h:SetPoint("LEFT", Side.r, "RIGHT", 10, 0)

		-- Remove the click texture from the help button
		Side.h:SetPushedTextOffset(0, 0)

		-- Add a reload button and syncronise it with the main panel reload button
		local reloadb = LeaPlusLC:CreateButton("ConfigReload", Side, "Reload", "BOTTOMRIGHT", -16, 10, 0, 25, true, LeaPlusCB["ReloadUIButton"].tiptext)
		LeaPlusLC:LockItem(reloadb,true)
		reloadb:SetScript("OnClick", ReloadUI)

		reloadb.f = reloadb:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
		reloadb.f:SetHeight(32);
		reloadb.f:SetPoint('RIGHT', reloadb, 'LEFT', -10, 0)
		reloadb.f:SetText(LeaPlusCB["ReloadUIButton"].f:GetText())
		reloadb.f:Hide()

		LeaPlusCB["ReloadUIButton"]:HookScript("OnEnable", function()
			LeaPlusLC:LockItem(reloadb, false)
			reloadb.f:Show()
		end)

		LeaPlusCB["ReloadUIButton"]:HookScript("OnDisable", function()
			LeaPlusLC:LockItem(reloadb, true)
			reloadb.f:Hide()
		end)

		-- Set textures
		LeaPlusLC:CreateBar("FootTexture", Side, 570, 48, "BOTTOM", 0.5, 0.5, 0.5, 1.0, "Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")
		LeaPlusLC:CreateBar("MainTexture", Side, 570, 323, "TOPRIGHT", 0.7, 0.7, 0.7, 0.7,  "Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")

		-- Allow movement
		Side:EnableMouse(true)
		Side:SetMovable(true)
		Side:RegisterForDrag("LeftButton")
		Side:SetScript("OnDragStart", Side.StartMoving)
		Side:SetScript("OnDragStop", function ()
			Side:StopMovingOrSizing();
			Side:SetUserPlaced(false);
			-- Save panel position
			LeaPlusLC["MainPanelA"], void, LeaPlusLC["MainPanelR"], LeaPlusLC["MainPanelX"], LeaPlusLC["MainPanelY"] = Side:GetPoint()
		end)

		-- Set panel attributes when shown
		Side:SetScript("OnShow", function()
			Side:ClearAllPoints()
			Side:SetPoint(LeaPlusLC["MainPanelA"], UIParent, LeaPlusLC["MainPanelR"], LeaPlusLC["MainPanelX"], LeaPlusLC["MainPanelY"])
			Side:SetScale(LeaPlusLC["PlusPanelScale"])
			Side.t:SetAlpha(1 - LeaPlusLC["PlusPanelAlpha"])
		end)

		-- Add title
		Side.f = Side:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
		Side.f:SetPoint('TOPLEFT', 16, -16);
		Side.f:SetText(L[title])

		-- Add description
		Side.v = Side:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
		Side.v:SetHeight(32);
		Side.v:SetPoint('TOPLEFT', Side.f, 'BOTTOMLEFT', 0, -8); 
		Side.v:SetPoint('RIGHT', Side, -32, 0)
		Side.v:SetJustifyH('LEFT'); Side.v:SetJustifyV('TOP');
		Side.v:SetText(L["Configuration Panel"])
	
		-- Prevent options panel from showing while side panel is showing
		LeaPlusLC["PageF"]:HookScript("OnShow", function()
			if Side:IsShown() then LeaPlusLC["PageF"]:Hide(); end
		end)

		-- Return the frame
		return Side

	end

	-- Define subheadings
	function LeaPlusLC:MakeTx(frame, title, x, y)
		local text = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		text:SetPoint("TOPLEFT", x, y)
		text:SetText(L[title])
	end

	-- Define text
	function LeaPlusLC:MakeWD(frame, title, x, y)
		local text = frame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
		text:SetPoint("TOPLEFT", x, y)
		text:SetText(L[title])
		text:SetJustifyH"LEFT";
	end

	-- Create a slider control (uses standard template)
	function LeaPlusLC:MakeSL(frame, field, caption, low, high, step, x, y, form)

		-- Create slider control
		local Slider = CreateFrame("Slider", "LeaPlusGlobalSlider" .. field, frame, "OptionssliderTemplate")
		LeaPlusCB[field] = Slider;
		Slider:SetMinMaxValues(low, high)
		Slider:SetValueStep(step)
		Slider:EnableMouseWheel(true)
		Slider:SetPoint('TOPLEFT', x,y)
		Slider:SetWidth(100)
		Slider:SetHeight(20)
		Slider:SetHitRectInsets(0, 0, 0, 0);
		Slider.tiptext = L[caption]
		Slider:SetScript("OnEnter", LeaPlusLC.TipSee)
		Slider:SetScript("OnLeave", GameTooltip_Hide)

		-- Remove slider text
		_G[Slider:GetName().."Low"]:SetText('');
		_G[Slider:GetName().."High"]:SetText('');

		-- Create slider label
		Slider.f = Slider:CreateFontString(nil, 'BACKGROUND')
		Slider.f:SetFontObject('GameFontHighlight')
		Slider.f:SetPoint('LEFT', Slider, 'RIGHT', 12, 0)
		Slider.f:SetFormattedText("%.2f", Slider:GetValue())

		-- Process mousewheel scrolling
		Slider:SetScript("OnMouseWheel", function(self, arg1)
			if Slider:IsEnabled() then
				local step = step * arg1
				local value = self:GetValue()
				if step > 0 then
					self:SetValue(min(value + step, high))
				else
					self:SetValue(max(value + step, low))
				end
			end
		end)

		-- Process value changed
		Slider:SetScript("OnValueChanged", function(self, value)
			local value = floor((value - low) / step + 0.5) * step + low
			Slider.f:SetFormattedText(form, value)
			LeaPlusLC[field] = value
		end)

		-- Set slider value when shown
		Slider:SetScript("OnShow", function(self)
			self:SetValue(LeaPlusLC[field])
		end)

	end

	-- Create a checkbox control (uses standard template)
	function LeaPlusLC:MakeCB(parent, field, caption, x, y, reload, tip, tipstyle)

		-- Create the checkbox
		local Cbox = CreateFrame('CheckButton', nil, parent, "ChatConfigCheckButtonTemplate")
		LeaPlusCB[field] = Cbox
		Cbox:SetPoint("TOPLEFT",x, y)
		Cbox:SetScript("OnEnter", LeaPlusLC.TipSee)
		Cbox:SetScript("OnLeave", GameTooltip_Hide)

		-- Add label and tooltip
		Cbox.f = Cbox:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
		Cbox.f:SetPoint('LEFT', 20, 0)
		if reload then
			-- Checkbox requires UI reload
			Cbox.f:SetText(L[caption] .. "*")
			Cbox.tiptext = L[tip] .. "|n|n* " .. L["Requires UI reload."]
		else
			-- Checkbox does not require UI reload
			Cbox.f:SetText(L[caption])
			Cbox.tiptext = L[tip]
		end

		-- Set label parameters
		Cbox.f:SetJustifyH("LEFT")
		Cbox.f:SetWordWrap(false)

		-- Set maximum label width
		if parent:GetParent() == LeaPlusLC["PageF"] then
			-- Main panel checkbox labels
			if Cbox.f:GetWidth() > 152 then
				Cbox.f:SetWidth(152)
				LeaPlusLC["TruncatedLabelsList"] = LeaPlusLC["TruncatedLabelsList"] or {}
				LeaPlusLC["TruncatedLabelsList"][Cbox.f] = L[caption]
			end
			-- Set checkbox click width
			if Cbox.f:GetStringWidth() > 152 then
				Cbox:SetHitRectInsets(0, -142, 0, 0)
			else
				Cbox:SetHitRectInsets(0, -Cbox.f:GetStringWidth() + 4, 0, 0)
			end
		else
			-- Configuration panel checkbox labels (other checkboxes either have custom functions or blank labels)
			if Cbox.f:GetWidth() > 302 then
				Cbox.f:SetWidth(302)
				LeaPlusLC["TruncatedLabelsList"] = LeaPlusLC["TruncatedLabelsList"] or {}
				LeaPlusLC["TruncatedLabelsList"][Cbox.f] = L[caption]
			end
			-- Set checkbox click width
			if Cbox.f:GetStringWidth() > 302 then
				Cbox:SetHitRectInsets(0, -292, 0, 0)
			else
				Cbox:SetHitRectInsets(0, -Cbox.f:GetStringWidth() + 4, 0, 0)
			end
		end

		-- Set default checkbox state and click area
		Cbox:SetScript('OnShow', function(self)
			if LeaPlusLC[field] == "On" then
				self:SetChecked(true)
			else
				self:SetChecked(false)
			end
		end)

		-- Process clicks
		Cbox:SetScript('OnClick', function()
			if Cbox:GetChecked() then
				LeaPlusLC[field] = "On"
			else
				LeaPlusLC[field] = "Off"
			end
			LeaPlusLC:SetDim(); -- Lock invalid options
			LeaPlusLC:ReloadCheck(); -- Show reload button if needed
			LeaPlusLC:Live(); -- Run live code
		end)
	end

	-- Create an editbox (uses standard template)
	function LeaPlusLC:CreateEditBox(frame, parent, width, maxchars, anchor, x, y, tab, shifttab)

		-- Create editbox
        local eb = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
		LeaPlusCB[frame] = eb
		eb:SetPoint(anchor, x, y)
		eb:SetWidth(width)
		eb:SetHeight(24)
		eb:SetFontObject("GameFontNormal")
		eb:SetTextColor(1.0, 1.0, 1.0)
		eb:SetAutoFocus(false) 
		eb:SetMaxLetters(maxchars) 
		eb:SetScript("OnEscapePressed", eb.ClearFocus)
		eb:SetScript("OnEnterPressed", eb.ClearFocus)

		-- Add editbox border and backdrop
		eb.f = CreateFrame("FRAME", nil, eb)
		eb.f:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = false, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }})
		eb.f:SetPoint("LEFT", -6, 0)
		eb.f:SetWidth(eb:GetWidth()+6)
		eb.f:SetHeight(eb:GetHeight())
		eb.f:SetBackdropColor(1.0, 1.0, 1.0, 0.3)

		-- Move onto next editbox when tab key is pressed
		eb:SetScript("OnTabPressed", function(self)
			self:ClearFocus()
			if IsShiftKeyDown() then
				LeaPlusCB[shifttab]:SetFocus()
			else
				LeaPlusCB[tab]:SetFocus()
			end
		end)

		return eb

	end

	-- Create a standard button (using standard button template)
	function LeaPlusLC:CreateButton(name, frame, label, anchor, x, y, width, height, reskin, tip)
		local mbtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
		LeaPlusCB[name] = mbtn
		mbtn:SetSize(width, height)
		mbtn:SetPoint(anchor, x, y)
		mbtn:SetHitRectInsets(0, 0, 0, 0)
		mbtn:SetText(L[label])

		-- Create fontstring so the button can be sized correctly
		mbtn.f = mbtn:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		mbtn.f:SetText(L[label])
		if width > 0 then
			-- Button should have static width
			mbtn:SetWidth(width)
		else
			-- Button should have variable width
			mbtn:SetWidth(mbtn.f:GetStringWidth() + 20)
		end

		-- Tooltip handler
		mbtn.tiptext = L[tip]
		mbtn:SetScript("OnEnter", LeaPlusLC.TipSee)
		mbtn:SetScript("OnLeave", GameTooltip_Hide)

		-- Texture the button
		if reskin then

			-- Set skinned button textures
			mbtn:SetNormalTexture("Interface\\AddOns\\Leatrix_Plus\\Leatrix_Plus.blp")
			mbtn:GetNormalTexture():SetTexCoord(0.5, 1, 0, 1)
			mbtn:SetHighlightTexture("Interface\\AddOns\\Leatrix_Plus\\Leatrix_Plus.blp")
			mbtn:GetHighlightTexture():SetTexCoord(0, 0.5, 0, 1)

			-- Hide the default textures
			mbtn:HookScript("OnShow", function() mbtn.Left:Hide(); mbtn.Middle:Hide(); mbtn.Right:Hide() end)
			mbtn:HookScript("OnEnable", function() mbtn.Left:Hide(); mbtn.Middle:Hide(); mbtn.Right:Hide() end)
			mbtn:HookScript("OnDisable", function() mbtn.Left:Hide(); mbtn.Middle:Hide(); mbtn.Right:Hide() end)
			mbtn:HookScript("OnMouseDown", function() mbtn.Left:Hide(); mbtn.Middle:Hide(); mbtn.Right:Hide() end)
			mbtn:HookScript("OnMouseUp", function() mbtn.Left:Hide(); mbtn.Middle:Hide(); mbtn.Right:Hide() end)

		end

		return mbtn
	end

	-- Create a dropdown menu (using custom function to avoid taint)
	function LeaPlusLC:CreateDropDown(ddname, label, parent, width, anchor, x, y, items, tip)

		-- Add the dropdown name to a table
		tinsert(LeaDropList, ddname)

		-- Populate variable with item list
		LeaPlusLC[ddname.."Table"] = items

		-- Create outer frame
		local frame = CreateFrame("FRAME", nil, parent); frame:SetWidth(width); frame:SetHeight(42); frame:SetPoint("BOTTOMLEFT", parent, anchor, x, y);

		-- Create dropdown inside outer frame
		local dd = CreateFrame("Frame", nil, frame); dd:SetPoint("BOTTOMLEFT", -16, -8); dd:SetPoint("BOTTOMRIGHT", 15, -4); dd:SetHeight(32);

		-- Create dropdown textures
		local lt = dd:CreateTexture(nil, "ARTWORK"); lt:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame"); lt:SetTexCoord(0, 0.1953125, 0, 1); lt:SetPoint("TOPLEFT", dd, 0, 17); lt:SetWidth(25); lt:SetHeight(64); 
		local rt = dd:CreateTexture(nil, "BORDER"); rt:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame"); rt:SetTexCoord(0.8046875, 1, 0, 1); rt:SetPoint("TOPRIGHT", dd, 0, 17); rt:SetWidth(25); rt:SetHeight(64); 
		local mt = dd:CreateTexture(nil, "BORDER"); mt:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame"); mt:SetTexCoord(0.1953125, 0.8046875, 0, 1); mt:SetPoint("LEFT", lt, "RIGHT"); mt:SetPoint("RIGHT", rt, "LEFT"); mt:SetHeight(64);

		-- Create dropdown label
		local lf = dd:CreateFontString(nil, "OVERLAY", "GameFontNormal"); lf:SetPoint("TOPLEFT", frame, 0, 0); lf:SetPoint("TOPRIGHT", frame, -5, 0); lf:SetJustifyH("LEFT"); lf:SetText(L[label])
	
		-- Create dropdown placeholder for value (set it using OnShow)
		local value = dd:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		value:SetPoint("LEFT", lt, 26, 2); value:SetPoint("RIGHT", rt, -43, 0); value:SetJustifyH("LEFT")
		dd:SetScript("OnShow", function() value:SetText(LeaPlusLC[ddname.."Table"][LeaPlusLC[ddname]]) end)

		-- Create dropdown button (clicking it opens the dropdown list)
		local dbtn = CreateFrame("Button", nil, dd)
		dbtn:SetPoint("TOPRIGHT", rt, -16, -18); dbtn:SetWidth(24); dbtn:SetHeight(24)
		dbtn:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up"); dbtn:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down"); dbtn:SetDisabledTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Disabled"); dbtn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight"); dbtn:GetHighlightTexture():SetBlendMode("ADD")
		dbtn.tiptext = tip; dbtn:SetScript("OnEnter", LeaPlusLC.ShowTooltip); 
		dbtn:SetScript("OnLeave", GameTooltip_Hide)

		-- Create dropdown list
		local ddlist =  CreateFrame("Frame",nil,frame);
		LeaPlusCB["ListFrame"..ddname] = ddlist;
		ddlist:SetPoint("TOP",0,-42);
		ddlist:SetWidth(frame:GetWidth());
		ddlist:SetHeight((#items * 17) + 17 + 17);
		ddlist:SetFrameStrata("FULLSCREEN_DIALOG");
		ddlist:SetFrameLevel(12);
		ddlist:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = false, tileSize = 0, edgeSize = 32, insets = { left = 4, right = 4, top = 4, bottom = 4 }});
		ddlist:Hide();

		-- Hide list if parent is closed
		parent:HookScript("OnHide", function() ddlist:Hide() end)

		-- Create checkmark (it marks the currently selected item)
		local ddlistchk = CreateFrame("FRAME", nil, ddlist)
		ddlistchk:SetHeight(16); ddlistchk:SetWidth(16);
		ddlistchk.t = ddlistchk:CreateTexture(nil, "ARTWORK"); ddlistchk.t:SetAllPoints(); ddlistchk.t:SetTexture("Interface\\Common\\UI-DropDownRadioChecks"); ddlistchk.t:SetTexCoord(0, 0.5, 0.5, 1.0);

		-- Create dropdown list items
		for k, v in pairs(items) do

			local dditem = CreateFrame("Button", nil, LeaPlusCB["ListFrame"..ddname])
			LeaPlusCB["Drop"..ddname..k] = dditem;
			dditem:Show();
			dditem:SetWidth(ddlist:GetWidth()-22)
			dditem:SetHeight(20)
			dditem:SetPoint("TOPLEFT", 12, -k*16)

			dditem.f = dditem:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight'); 
			dditem.f:SetPoint('LEFT', 16, 0)
			dditem.f:SetText(items[k])

			dditem.t = dditem:CreateTexture(nil, "BACKGROUND")
			dditem.t:SetAllPoints()
			dditem.t:SetColorTexture(0.3, 0.3, 0.00, 0.8)
			dditem.t:Hide();

			dditem:SetScript("OnEnter", function() dditem.t:Show() end)
			dditem:SetScript("OnLeave", function() dditem.t:Hide() end)
			dditem:SetScript("OnClick", function()
				LeaPlusLC[ddname] = k
				value:SetText(LeaPlusLC[ddname.."Table"][k])
				ddlist:Hide(); -- Must be last in click handler as other functions hook it
			end)

			-- Show list when button is clicked
			dbtn:SetScript("OnClick", function()
				-- Show the dropdown
				if ddlist:IsShown() then ddlist:Hide() else 
					ddlist:Show();
					ddlistchk:SetPoint("TOPLEFT",10,select(5,LeaPlusCB["Drop"..ddname..LeaPlusLC[ddname]]:GetPoint()))
					ddlistchk:Show();
				end;
				-- Hide all other dropdowns except the one we're dealing with
				for void,v in pairs(LeaDropList) do
					if v ~= ddname then
						LeaPlusCB["ListFrame"..v]:Hide();
					end
				end
			end)

			-- Expand the clickable area of the button to include the entire menu width
			dbtn:SetHitRectInsets(-width+28, 0, 0, 0);

		end

		return frame
		
	end
	
----------------------------------------------------------------------
-- 	Create main options panel frame
----------------------------------------------------------------------

	function LeaPlusLC:CreateMainPanel()

		-- Create the panel
		local PageF = CreateFrame("Frame", nil, UIParent);

		-- Make it a system frame
		_G["LeaPlusGlobalPanel"] = PageF
		table.insert(UISpecialFrames, "LeaPlusGlobalPanel")

		-- Set frame parameters
		LeaPlusLC["PageF"] = PageF
		PageF:SetSize(570,370)
		PageF:Hide();
		PageF:SetFrameStrata("FULLSCREEN_DIALOG")
		PageF:SetClampedToScreen(true)
		PageF:SetClampRectInsets(500, -500, -300, 300)
		PageF:EnableMouse(true)
		PageF:SetMovable(true)
		PageF:RegisterForDrag("LeftButton")
		PageF:SetScript("OnDragStart", PageF.StartMoving)
		PageF:SetScript("OnDragStop", function ()
			PageF:StopMovingOrSizing();
			PageF:SetUserPlaced(false);
			-- Save panel position
			LeaPlusLC["MainPanelA"], void, LeaPlusLC["MainPanelR"], LeaPlusLC["MainPanelX"], LeaPlusLC["MainPanelY"] = PageF:GetPoint()
		end)

		-- Add background color
		PageF.t = PageF:CreateTexture(nil, "BACKGROUND")
		PageF.t:SetAllPoints()
		PageF.t:SetColorTexture(0.05, 0.05, 0.05, 0.9)

		-- Add textures
		LeaPlusLC:CreateBar("FootTexture", PageF, 570, 48, "BOTTOM", 0.5, 0.5, 0.5, 1.0, "Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")
		LeaPlusLC:CreateBar("MainTexture", PageF, 440, 323, "TOPRIGHT", 0.7, 0.7, 0.7, 0.7,  "Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")
		LeaPlusLC:CreateBar("MenuTexture", PageF, 130, 323, "TOPLEFT", 0.7, 0.7, 0.7, 0.7, "Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")

		-- Set panel position when shown
		PageF:SetScript("OnShow", function()
			PageF:ClearAllPoints()
			PageF:SetPoint(LeaPlusLC["MainPanelA"], UIParent, LeaPlusLC["MainPanelR"], LeaPlusLC["MainPanelX"], LeaPlusLC["MainPanelY"])
		end)

		-- Add main title (shown above menu in the corner)
		PageF.mt = PageF:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
		PageF.mt:SetPoint('TOPLEFT', 16, -16)
		PageF.mt:SetText("Leatrix Plus")

		-- Add version text (shown underneath main title)
		PageF.v = PageF:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
		PageF.v:SetHeight(32);
		PageF.v:SetPoint('TOPLEFT', PageF.mt, 'BOTTOMLEFT', 0, -8); 
		PageF.v:SetPoint('RIGHT', PageF, -32, 0)
		PageF.v:SetJustifyH('LEFT'); PageF.v:SetJustifyV('TOP');
		PageF.v:SetNonSpaceWrap(true); PageF.v:SetText(L["Classic"] .. " " .. LeaPlusLC["AddonVer"])

		-- Add reload UI Button
		local reloadb = LeaPlusLC:CreateButton("ReloadUIButton", PageF, "Reload", "BOTTOMRIGHT", -16, 10, 0, 25, true, "Your UI needs to be reloaded for some of the changes to take effect.|n|nYou don't have to click the reload button immediately but you do need to click it when you are done making changes and you want the changes to take effect.")
		LeaPlusLC:LockItem(reloadb,true)
		reloadb:SetScript("OnClick", ReloadUI)

		reloadb.f = reloadb:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
		reloadb.f:SetHeight(32);
		reloadb.f:SetPoint('RIGHT', reloadb, 'LEFT', -10, 0)
		reloadb.f:SetText(L["Your UI needs to be reloaded."])
		reloadb.f:Hide()

		-- Add close Button
		local CloseB = CreateFrame("Button", nil, PageF, "UIPanelCloseButton") 
		CloseB:SetSize(30, 30)
		CloseB:SetPoint("TOPRIGHT", 0, 0)
		CloseB:SetScript("OnClick", LeaPlusLC.HideFrames) 

		-- Release memory
		LeaPlusLC.CreateMainPanel = nil

	end

	LeaPlusLC:CreateMainPanel();

----------------------------------------------------------------------
-- 	L80: Commands 
----------------------------------------------------------------------

	-- Slash command function
	function LeaPlusLC:SlashFunc(str)
		if str and str ~= "" then
			-- Get parameters in lower case with duplicate spaces removed
			local str, arg1, arg2, arg3 = strsplit(" ", string.lower(str:gsub("%s+", " ")))
			-- Traverse parameters
			if str == "wipe" then
				-- Wipe settings
				LeaPlusLC:PlayerLogout(true) -- Run logout function with wipe parameter
				wipe(LeaPlusDB)
				LpEvt:UnregisterAllEvents(); -- Don't save any settings
				ReloadUI();
			elseif str == "nosave" then
				-- Prevent Leatrix Plus from overwriting LeaPlusDB at next logout
				LpEvt:UnregisterEvent("PLAYER_LOGOUT")
				LeaPlusLC:Print("Leatrix Plus will not overwrite LeaPlusDB at next logout.")
				return
			elseif str == "reset" then
				-- Reset panel positions
				LeaPlusLC["MainPanelA"], LeaPlusLC["MainPanelR"], LeaPlusLC["MainPanelX"], LeaPlusLC["MainPanelY"] = "CENTER", "CENTER", 0, 0
				LeaPlusLC["PlusPanelScale"] = 1
				LeaPlusLC["PlusPanelAlpha"] = 0
				LeaPlusLC["PageF"]:SetScale(1)
				LeaPlusLC["PageF"].t:SetAlpha(1 - LeaPlusLC["PlusPanelAlpha"])
				-- Refresh panels
				LeaPlusLC["PageF"]:ClearAllPoints()
				LeaPlusLC["PageF"]:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
				-- Reset currently showing configuration panel
				for k, v in pairs(LeaConfigList) do 
					if v:IsShown() then
						v:ClearAllPoints()
						v:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
						v:SetScale(1)
						v.t:SetAlpha(1 - LeaPlusLC["PlusPanelAlpha"])
					end
				end
				-- Refresh Leatrix Plus settings menu only
				if LeaPlusLC["Page8"]:IsShown() then
					LeaPlusLC["Page8"]:Hide()
					LeaPlusLC["Page8"]:Show()
				end
				return
			elseif str == "taint" then
				-- Set taint log level
				if arg1 and arg1 ~= "" then
					arg1 = tonumber(arg1)
					if arg1 and arg1 >= 0 and arg1 <= 2 then
						if arg1 == 0 then
							-- Disable taint log
							ConsoleExec("taintLog 0")
							LeaPlusLC:Print("Taint level: Disabled (0).")
						elseif arg1 == 1 then
							-- Basic taint log
							ConsoleExec("taintLog 1")
							LeaPlusLC:Print("Taint level: Basic (1).")
						elseif arg1 == 2 then
							-- Full taint log
							ConsoleExec("taintLog 2")
							LeaPlusLC:Print("Taint level: Full (2).")
						end
					else
 						LeaPlusLC:Print("Invalid taint level.")
					end
				else
					-- Show current taint level
					local taintCurrent = GetCVar("taintLog")
					if taintCurrent == "0" then
						LeaPlusLC:Print("Taint level: Disabled (0).")
					elseif taintCurrent == "1" then
						LeaPlusLC:Print("Taint level: Basic (1).")
					elseif taintCurrent == "2" then
						LeaPlusLC:Print("Taint level: Full (2).")
					end
				end
				return
			elseif str == "quest" then
				-- Show quest completed status
				if arg1 and arg1 ~= "" then
					if tonumber(arg1) then
						local questCompleted = IsQuestFlaggedCompleted(arg1)
						if questCompleted then
							LeaPlusLC:Print(arg1 .. ": " .. L["Quest completed."])
						else
							LeaPlusLC:Print(arg1 .. ": " .. L["Quest not completed."])
						end
					else
						LeaPlusLC:Print("Invalid quest ID.")
					end
				else
					LeaPlusLC:Print("Missing quest ID.")
				end
				return
			elseif str == "rest" then
				-- Show rested bubbles
				LeaPlusLC:Print(L["Rested bubbles"] .. ": |cffffffff" .. (math.floor(20 * (GetXPExhaustion() or 0) / UnitXPMax("player") + 0.5)))
				return
			elseif str == "zygor" then
				-- Toggle Zygor addon
				LeaPlusLC:ZygorToggle()
				return
			elseif str == "id" then
				-- Print NPC ID
				local npcName = UnitName("target")
				local npcGuid = UnitGUID("target") or nil
				if npcName and npcGuid then
					local void, void, void, void, void, npcID = strsplit("-", npcGuid)
					if npcID then
						LeaPlusLC:Print(npcName .. ": |cffffffff" .. npcID)
					end
				end
				return
			elseif str == "tooltip" then
				-- Print tooltip frame name
				local enumf = EnumerateFrames()
				while enumf do
					if (enumf:GetObjectType() == "GameTooltip" or strfind((enumf:GetName() or ""):lower(),"tip")) and enumf:IsVisible() and enumf:GetPoint() then
						print(enumf:GetName())
					end 
					enumf = EnumerateFrames(enumf)
				end
				collectgarbage()
				return
			elseif str == "rsnd" then
				-- Restart sound system
				if LeaPlusCB["StopMusicBtn"] then LeaPlusCB["StopMusicBtn"]:Click() end 
				Sound_GameSystem_RestartSoundSystem()
				LeaPlusLC:Print("Sound system restarted.")
				return
			elseif str == "event" then
				-- List events (used for debug)
				LeaPlusLC["DbF"] = LeaPlusLC["DbF"] or CreateFrame("FRAME")
				if not LeaPlusLC["DbF"]:GetScript("OnEvent") then
					LeaPlusLC:Print("Tracing started.")
					LeaPlusLC["DbF"]:RegisterAllEvents()
					LeaPlusLC["DbF"]:SetScript("OnEvent", function(self, event)
						if event == "ACTIONBAR_UPDATE_COOLDOWN"
						or event == "BAG_UPDATE_COOLDOWN"
						or event == "CHAT_MSG_TRADESKILLS"
						or event == "COMBAT_LOG_EVENT_UNFILTERED"
						or event == "SPELL_UPDATE_COOLDOWN"
						or event == "SPELL_UPDATE_USABLE"
						or event == "UNIT_POWER_FREQUENT"
						or event == "UPDATE_INVENTORY_DURABILITY"
						then return
						else
							print(event)
						end
					end)
				else
					LeaPlusLC["DbF"]:UnregisterAllEvents()
					LeaPlusLC["DbF"]:SetScript("OnEvent", nil)
					LeaPlusLC:Print("Tracing stopped.")
				end
				return
			elseif str == "config" then
				-- Show maximum camera distance
				LeaPlusLC:Print(L["Camera distance"] .. ": |cffffffff" .. GetCVar("cameraDistanceMaxZoomFactor"))
				-- Show screen effects
				LeaPlusLC:Print(L["Shaders"] .. ": |cffffffff" .. GetCVar("ffxGlow") .. ", " .. GetCVar("ffxDeath") .. ", " .. GetCVar("ffxNether"))
				-- Show particle density
				LeaPlusLC:Print(L["Particle density"] .. ": |cffffffff" .. GetCVar("particleDensity"))
				LeaPlusLC:Print(L["Weather density"] .. ": |cffffffff" .. GetCVar("weatherDensity"))
				-- Show config
				LeaPlusLC:Print("SynchroniseConfig: |cffffffff" .. GetCVar("synchronizeConfig"))
				-- Show raid restrictions
				local unRaid = GetAllowLowLevelRaid()
				if unRaid and unRaid == true then
					LeaPlusLC:Print("GetAllowLowLevelRaid: |cffffffff" .. "True")
				else
					LeaPlusLC:Print("GetAllowLowLevelRaid: |cffffffff" .. "False")
				end
				return
			elseif str == "move" then
				-- Move minimap
				MinimapZoneTextButton:Hide()
				MinimapBorderTop:SetTexture("")
				MiniMapWorldMapButton:Hide()
				MinimapBackdrop:ClearAllPoints()
				MinimapBackdrop:SetPoint("CENTER", UIParent, "CENTER", -330, -75)
				Minimap:SetPoint("CENTER", UIParent, "CENTER", -320, -50)
				return
			elseif str == "tipcol" then
				-- Show default tooltip title color
				if GameTooltipTextLeft1:IsShown() then
					local r, g, b, a = GameTooltipTextLeft1:GetTextColor()
					r = r <= 1 and r >= 0 and r or 0
					g = g <= 1 and g >= 0 and g or 0
					b = b <= 1 and b >= 0 and b or 0
					LeaPlusLC:Print(L["Tooltip title color"] .. ": " .. strupper(string.format("%02x%02x%02x", r * 255, g * 255, b * 255) .. "."))
				else
					LeaPlusLC:Print("No tooltip showing.")
				end
				return
			elseif str == "list" then
				-- Enumerate frames
				local frame = EnumerateFrames()
				while frame do 
					if (frame:IsVisible() and MouseIsOver(frame)) then 
						LeaPlusLC:Print(frame:GetName() or string.format("[Unnamed Frame: %s]", tostring(frame)))
					end 
					frame = EnumerateFrames(frame) 
				end
				return
			elseif str == "grid" then
				-- Create grid for first use
				if not LeaPlusLC.grid then
					LeaPlusLC.grid = CreateFrame('FRAME') 
					LeaPlusLC.grid:Hide()
					LeaPlusLC.grid:SetAllPoints(UIParent)
					local w, h = GetScreenWidth() * UIParent:GetEffectiveScale(), GetScreenHeight() * UIParent:GetEffectiveScale()
					local ratio = w / h
					local sqsize = w / 20
					local wline = floor(sqsize - (sqsize % 2))
					local hline = floor(sqsize / ratio - ((sqsize / ratio) % 2))
					-- Plot vertical lines
					for i = 0, wline do
						local t = LeaPlusLC.grid:CreateTexture(nil, 'BACKGROUND')
						if i == wline / 2 then t:SetColorTexture(1, 0, 0, 0.5) else t:SetColorTexture(0, 0, 0, 0.5) end
						t:SetPoint('TOPLEFT', LeaPlusLC.grid, 'TOPLEFT', i * w / wline - 1, 0)
						t:SetPoint('BOTTOMRIGHT', LeaPlusLC.grid, 'BOTTOMLEFT', i * w / wline + 1, 0)
					end
					-- Plot horizontal lines
					for i = 0, hline do
						local t = LeaPlusLC.grid:CreateTexture(nil, 'BACKGROUND')
						if i == hline / 2 then	t:SetColorTexture(1, 0, 0, 0.5) else t:SetColorTexture(0, 0, 0, 0.5) end
						t:SetPoint('TOPLEFT', LeaPlusLC.grid, 'TOPLEFT', 0, -i * h / hline + 1)
						t:SetPoint('BOTTOMRIGHT', LeaPlusLC.grid, 'TOPRIGHT', 0, -i * h / hline - 1)
					end	
				end
				-- Show or hide grid
				if LeaPlusLC.grid:IsShown() then
					LeaPlusLC.grid:Hide()
				else
					LeaPlusLC.grid:Show()
				end
				return
			elseif str == "chk" then
				-- List truncated checkbox labels
				if LeaPlusLC["TruncatedLabelsList"] then
					for i, v in pairs(LeaPlusLC["TruncatedLabelsList"]) do
						LeaPlusLC:Print(LeaPlusLC["TruncatedLabelsList"][i])
					end
				else
					LeaPlusLC:Print("Checkbox labels are Ok.")
				end
				return
			elseif str == "cv" then
				-- Print and set console variable setting
				if arg1 and arg1 ~= "" then
					if GetCVar(arg1) then
						if arg2 and arg2 ~= ""  then
							if tonumber(arg2) then
								SetCVar(arg1, arg2)
							else
								LeaPlusLC:Print("Value must be a number.")
								return
							end
						end
						LeaPlusLC:Print(arg1 .. ": |cffffffff" .. GetCVar(arg1))
					else
						LeaPlusLC:Print("Invalid console variable.")
					end
				else
					LeaPlusLC:Print("Missing console variable.")
				end
				return
			elseif str == "play" then
				-- Play sound ID
				if arg1 and arg1 ~= "" then
					if tonumber(arg1) then
						-- Stop last played sound ID
						if LeaPlusLC.SNDcanitHandle then
							StopSound(LeaPlusLC.SNDcanitHandle)
						end
						-- Play sound ID
						LeaPlusLC.SNDcanitPlay, LeaPlusLC.SNDcanitHandle = PlaySound(arg1, "Master", false, false)
						if not LeaPlusLC.SNDcanitPlay then LeaPlusLC:Print(L["Invalid sound ID"] .. ": |cffffffff" .. arg1) end
					else
						LeaPlusLC:Print(L["Invalid sound ID"] .. ": |cffffffff" .. arg1)
					end
				else
					LeaPlusLC:Print("Missing sound ID.")
				end
				return
			elseif str == "stop" then
				-- Stop last played sound ID
				if LeaPlusLC.SNDcanitHandle then
					StopSound(LeaPlusLC.SNDcanitHandle)
				end
				return
			elseif str == "wipecds" then
				-- Wipe cooldowns
				LeaPlusDB["Cooldowns"] = nil
				ReloadUI()
				return
			elseif str == "tipchat" then
				-- Print tooltip contents in chat
				local numLines = GameTooltip:NumLines()
				if numLines then
					for i = 1, numLines do
						print(_G["GameTooltipTextLeft" .. i]:GetText() or "")
					end
				end
				return
			elseif str == "tiplang" then
				-- Tooltip tag locale code constructor
				local msg = ""
				msg = msg .. 'if GameLocale == "' .. GameLocale .. '" then '
				msg = msg .. 'ttLevel = "' .. LEVEL .. '"; '
				msg = msg .. 'ttBoss = "' .. BOSS .. '"; '
				msg = msg .. 'ttElite = "' .. ELITE .. '"; '
				msg = msg .. 'ttRare = "' .. ITEM_QUALITY3_DESC .. '"; '
				msg = msg .. 'ttRareElite = "' .. ITEM_QUALITY3_DESC .. " " .. ELITE .. '"; '
				msg = msg .. 'ttRareBoss = "' .. ITEM_QUALITY3_DESC .. " " .. BOSS .. '"; '
				msg = msg .. 'ttTarget = "' .. TARGET .. '"; '
				msg = msg .. "end"
				print(msg)
				return
			elseif str == "con" then
				-- Show the developer console
				C_Console.SetFontHeight(28)
				DeveloperConsole:Toggle(true)
				return
			elseif str == "movlist" then
				-- List playable movie IDs
				local count = 0
				for i = 1, 1000 do
					if IsMoviePlayable(i) then
						print(i)
						count = count + 1
					end
				end
				LeaPlusLC:Print("Total movies: |cffffffff" .. count)
				return
			elseif str == "movie" then
				-- Playback movie by ID
				arg1 = tonumber(arg1)
				if arg1 and arg1 ~= "" then
					if IsMoviePlayable(arg1) then
						MovieFrame_PlayMovie(MovieFrame, arg1)
					else
						LeaPlusLC:Print("Movie not playable.")
					end
				else
					LeaPlusLC:Print("Missing movie ID.")
				end
				return
			elseif str == "cin" then
				-- Play opening cinematic (only works if character has never gained XP) (used for testing)
				OpeningCinematic()
				return
			elseif str == "skit" then
				-- Play a test sound kit
				PlaySound("1020", "Master", false, true)
				return
			elseif str == "marker" then
				-- Prevent showing raid target markers on self
				if not LeaPlusLC.MarkerFrame then
					LeaPlusLC.MarkerFrame = CreateFrame("FRAME")
					LeaPlusLC.MarkerFrame:RegisterEvent("RAID_TARGET_UPDATE")
				end
				LeaPlusLC.MarkerFrame.Update = true
				if LeaPlusLC.MarkerFrame.Toggle == false then
					-- Show markers
					LeaPlusLC.MarkerFrame:SetScript("OnEvent", nil)
					ActionStatus_DisplayMessage(L["Self Markers Allowed"], true)
					LeaPlusLC.MarkerFrame.Toggle = true
				else
					-- Hide markers
					SetRaidTarget("player", 0)
					LeaPlusLC.MarkerFrame:SetScript("OnEvent", function()
						if LeaPlusLC.MarkerFrame.Update == true then
							LeaPlusLC.MarkerFrame.Update = false
							SetRaidTarget("player", 0)
						end
						LeaPlusLC.MarkerFrame.Update = true
					end)
					ActionStatus_DisplayMessage(L["Self Markers Blocked"], true)
					LeaPlusLC.MarkerFrame.Toggle = false
				end
				return
			elseif str == "af" then
				-- Automatically follow player target using ticker
				if LeaPlusLC.followTick then
					-- Existing ticker is active so cancel it
					LeaPlusLC.followTick:Cancel()
					LeaPlusLC.followTick = nil
					FollowUnit("player")
					LeaPlusLC:Print("AutoFollow disabled.")
				else
					-- No ticker is active so create one
					local targetName, targetRealm = UnitName("target")
					if not targetName or not UnitIsPlayer("target") or UnitIsUnit("player", "target") then
						LeaPlusLC:Print("Invalid target.")
						return
					end
					if targetRealm then targetName = targetName .. "-" .. targetRealm end
					if LeaPlusLC.followTick then
						LeaPlusLC.followTick:Cancel()
					end
					FollowUnit(targetName, true)
					LeaPlusLC.followTick = C_Timer.NewTicker(0.5, function()
						FollowUnit(targetName, true)
					end)
					LeaPlusLC:Print(L["AutoFollow"] .. ": |cffffffff" .. targetName .. "|r.")
				end
				return
			elseif str == "mapid" then
				-- Print map ID
				if WorldMapFrame:IsShown() then
					-- Show world map ID
					local mapID = WorldMapFrame.mapID or nil
					local artID = C_Map.GetMapArtID(mapID) or nil
					local mapName = C_Map.GetMapInfo(mapID).name or nil
					if mapID and artID and mapName then
						LeaPlusLC:Print(mapID .. " (" .. artID .. "): " .. mapName .. " (map)")
					end
				else
					-- Show character map ID
					local mapID = C_Map.GetBestMapForUnit("player") or nil
					local artID = C_Map.GetMapArtID(mapID) or nil
					local mapName = C_Map.GetMapInfo(mapID).name or nil
					if mapID and artID and mapName then
						LeaPlusLC:Print(mapID .. " (" .. artID .. "): " .. mapName .. " (player)")
					end
				end
				return
			elseif str == "pos" then
				-- Map POI code builder
				local mapID = C_Map.GetBestMapForUnit("player") or nil
				local mapName = C_Map.GetMapInfo(mapID).name or nil
				local mapRects = {}
				local tempVec2D = CreateVector2D(0, 0)
				local void
				-- Get player map position
				tempVec2D.x, tempVec2D.y = UnitPosition("player")
				if not tempVec2D.x then return end
				local mapRect = mapRects[mapID]
				if not mapRect then
					mapRect = {}
					void, mapRect[1] = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(0, 0))
					void, mapRect[2] = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(1, 1))
					mapRect[2]:Subtract(mapRect[1])
					mapRects[mapID] = mapRect
				end
				tempVec2D:Subtract(mapRects[mapID][1])
				local pX, pY = tempVec2D.y/mapRects[mapID][2].y, tempVec2D.x/mapRects[mapID][2].x
				pX = string.format("%0.1f", 100 * pX)
				pY = string.format("%0.1f", 100 * pY)
				if mapID and mapName and pX and pY then
					ChatFrame1:Clear()
					local dnType, dnTex = "Dungeon", "dnTex"
					if arg1 == "raid" then dnType, dnTex = "Raid", "rdTex" end
					if arg1 == "portal" then dnType = "Portal" end
					print('[' .. mapID .. '] =  --[[' .. mapName .. ']] {{' .. pX .. ', ' .. pY .. ', L[' .. '"Name"' .. '], L[' .. '"' .. dnType .. '"' .. '], ' .. dnTex .. '},},')
				end
				return
			elseif str == "mapref" then
				-- Print map reveal structure code
				if not WorldMapFrame:IsShown() then
					LeaPlusLC:Print("Open the map first!")
					return
				end
				ChatFrame1:Clear()
				local msg = ""
				local mapID = WorldMapFrame.mapID
				local mapName = C_Map.GetMapInfo(mapID).name
				local mapArt = C_Map.GetMapArtID(mapID)
				msg = msg .. "--[[" .. mapName .. "]] [" .. mapArt .. "] = {"
				local exploredMapTextures = C_MapExplorationInfo.GetExploredMapTextures(mapID);
				if exploredMapTextures then
					for i, exploredTextureInfo in ipairs(exploredMapTextures) do
						local twidth = exploredTextureInfo.textureWidth or 0
						if twidth > 0 then
							local theight = exploredTextureInfo.textureHeight or 0
							local offsetx = exploredTextureInfo.offsetX
							local offsety = exploredTextureInfo.offsetY
							local filedataIDS = exploredTextureInfo.fileDataIDs
							msg = msg .. "[" .. '"' .. twidth .. ":" .. theight .. ":" .. offsetx .. ":" .. offsety .. '"' .. "] = " .. '"'
							for fileData = 1, #filedataIDS do
								msg = msg .. filedataIDS[fileData]
								if fileData < #filedataIDS then
									msg = msg .. ", "
								else
									msg = msg .. '",'
									if i < #exploredMapTextures then
										msg = msg .. " "
									end
								end
							end
						end
					end
					msg = msg .. "},"
					print(msg)
				end
				return
			elseif str == "mk" then
				-- Print a map key
				if not arg1 then LeaPlusLC:Print("Key missing!") return end
				if not tonumber(arg1) then LeaPlusLC:Print("Must be a number!") return end
				local key = arg1
				ChatFrame1:Clear()
				print('"' .. mod(floor(key / 2^36), 2^12) .. ":" .. mod(floor(key / 2^24), 2^12) .. ":" .. mod(floor(key / 2^12), 2^12) .. ":" .. mod(key, 2^12) .. '"')
				return
			elseif str == "map" then
				-- Set map by ID
				if not arg1 or not tonumber(arg1) or not C_Map.GetMapInfo(arg1) then
					LeaPlusLC:Print("Invalid map ID.")
				else
					WorldMapFrame:SetMapID(arg1)
				end
				return
			elseif str == "cls" then
				-- Clear chat frame
				ChatFrame1:Clear()
				return
			elseif str == "al" then
				-- Enable auto loot
				SetCVar("autoLootDefault", "1")
				LeaPlusLC:Print("Auto loot is now enabled.")
				return
			elseif str == "realm" then
				-- Show list of connected realms
				local titleRealm = GetRealmName()
				local userRealm = GetNormalizedRealmName()
				local connectedServers = GetAutoCompleteRealms()
				if titleRealm and userRealm and connectedServers then
					LeaPlusLC:Print(L["Connections for"] .. "|cffffffff " .. titleRealm)
					if #connectedServers > 0 then
						local count = 1
						for i = 1, #connectedServers do
							if userRealm ~= connectedServers[i] then
								LeaPlusLC:Print(count .. ".  " .. connectedServers[i])
								count = count + 1
							end
						end
					else
						LeaPlusLC:Print("None")
					end
				end
				return
			elseif str == "admin" then
				-- Preset profile (used for testing)
				LpEvt:UnregisterAllEvents()						-- Prevent changes
				wipe(LeaPlusDB)									-- Wipe settings
				LeaPlusLC:PlayerLogout(true)					-- Reset permanent settings
				-- Automation
				LeaPlusDB["AutomateQuests"] = "On"				-- Automate quests
				LeaPlusDB["AutomateGossip"] = "On"				-- Automate gossip
				LeaPlusDB["AutoAcceptSummon"] = "On"			-- Accept summon
				LeaPlusDB["AutoAcceptRes"] = "On"				-- Accept resurrection
				LeaPlusDB["AutoReleasePvP"] = "On"				-- Release in PvP
				LeaPlusDB["AutoSellJunk"] = "On"				-- Sell junk automatically
				LeaPlusDB["AutoRepairGear"] = "On"				-- Repair automatically

				-- Social
				LeaPlusDB["NoDuelRequests"] = "On"				-- Block duels
				LeaPlusDB["NoPartyInvites"] = "Off"				-- Block party invites
				LeaPlusDB["NoFriendRequests"] = "Off"			-- Block friend requests			
				LeaPlusDB["AcceptPartyFriends"] = "On"			-- Party from friends
				LeaPlusDB["InviteFromWhisper"] = "On"			-- Invite from whispers

				-- Chat
				LeaPlusDB["UseEasyChatResizing"] = "On"			-- Use easy resizing
				LeaPlusDB["NoCombatLogTab"] = "On"				-- Hide the combat log
				LeaPlusDB["NoChatButtons"] = "On"				-- Hide chat buttons
				LeaPlusDB["UnclampChat"] = "On"					-- Unclamp chat frame
				LeaPlusDB["MoveChatEditBoxToTop"] = "On"		-- Move editbox to top
				LeaPlusDB["NoStickyChat"] = "On"				-- Disable sticky chat
				LeaPlusDB["UseArrowKeysInChat"] = "On"			-- Use arrow keys in chat
				LeaPlusDB["NoChatFade"] = "On"					-- Disable chat fade
				LeaPlusDB["UnivGroupColor"] = "On"				-- Universal group color
				LeaPlusDB["ClassColorsInChat"] = "On"			-- Use class colors in chat
				LeaPlusDB["RecentChatWindow"] = "On"			-- Recent chat window
				LeaPlusDB["MaxChatHstory"] = "Off"				-- Increase chat history

				-- Text
				LeaPlusDB["HideErrorMessages"] = "On"			-- Hide error messages
				LeaPlusDB["NoHitIndicators"] = "On"				-- Hide portrait text
				LeaPlusDB["MailFontChange"] = "On"				-- Resize mail text
				LeaPlusDB["LeaPlusMailFontSize"] = 22			-- Mail font size
				LeaPlusDB["QuestFontChange"] = "On"				-- Resize quest text
				LeaPlusDB["LeaPlusQuestFontSize"] = 18			-- Quest font size

				-- Interface
				LeaPlusDB["MinimapMod"] = "On"					-- Customise minimap
				LeaPlusDB["HideZoneTextBar"] = "On"				-- Hide zone text bar
				LeaPlusDB["MinimapScale"] = 1.30				-- Minimap scale slider
				LeaPlusDB["TipModEnable"] = "On"				-- Manage tooltip
				LeaPlusDB["TipBackSimple"] = "On"				-- Color backdrops
				LeaPlusDB["LeaPlusTipSize"] = 1.25				-- Tooltip scale slider
				LeaPlusDB["EnhanceDressup"] = "On"				-- Enhance dressup
				LeaPlusDB["ShowVolume"] = "On"					-- Show volume slider
				LeaPlusDB["AhExtras"] = "On"					-- Show auction controls
				LeaPlusDB["ShowCooldowns"] = "On"				-- Show cooldowns
				LeaPlusDB["DurabilityStatus"] = "On"			-- Show durability status
				LeaPlusDB["ShowVanityControls"] = "On"			-- Show vanity controls
				LeaPlusDB["ShowWowheadLinks"] = "On"			-- Show Wowhead links

				-- Interface: Manage frames
				LeaPlusDB["FrmEnabled"] = "On"

				LeaPlusDB["Frames"] = {}
				LeaPlusDB["Frames"]["PlayerFrame"] = {}
				LeaPlusDB["Frames"]["PlayerFrame"]["Point"] = "TOPLEFT"
				LeaPlusDB["Frames"]["PlayerFrame"]["Relative"] = "TOPLEFT"
				LeaPlusDB["Frames"]["PlayerFrame"]["XOffset"] = -35
				LeaPlusDB["Frames"]["PlayerFrame"]["YOffset"] = -14
				LeaPlusDB["Frames"]["PlayerFrame"]["Scale"] = 1.20

				LeaPlusDB["Frames"]["TargetFrame"] = {}
				LeaPlusDB["Frames"]["TargetFrame"]["Point"] = "TOPLEFT"
				LeaPlusDB["Frames"]["TargetFrame"]["Relative"] = "TOPLEFT"
				LeaPlusDB["Frames"]["TargetFrame"]["XOffset"] = 190
				LeaPlusDB["Frames"]["TargetFrame"]["YOffset"] = -14
				LeaPlusDB["Frames"]["TargetFrame"]["Scale"] = 1.20

				LeaPlusDB["Frames"]["MirrorTimer1"] = {}
				LeaPlusDB["Frames"]["MirrorTimer1"]["Point"] = "TOP"
				LeaPlusDB["Frames"]["MirrorTimer1"]["Relative"] = "TOP"
				LeaPlusDB["Frames"]["MirrorTimer1"]["XOffset"] = 0
				LeaPlusDB["Frames"]["MirrorTimer1"]["YOffset"] = -120

				LeaPlusDB["Frames"]["LeaPlusTopCenterContainerHolder"] = {}
				LeaPlusDB["Frames"]["LeaPlusTopCenterContainerHolder"]["Point"] = "TOP"
				LeaPlusDB["Frames"]["LeaPlusTopCenterContainerHolder"]["Relative"] = "TOP"
				LeaPlusDB["Frames"]["LeaPlusTopCenterContainerHolder"]["XOffset"] = 0
				LeaPlusDB["Frames"]["LeaPlusTopCenterContainerHolder"]["YOffset"] = -432
				LeaPlusDB["Frames"]["LeaPlusTopCenterContainerHolder"]["Scale"] = 1.25

				LeaPlusDB["Frames"]["BuffFrame"] = {}
				LeaPlusDB["Frames"]["BuffFrame"]["Point"] = "TOPRIGHT"
				LeaPlusDB["Frames"]["BuffFrame"]["Relative"] = "TOPRIGHT"
				LeaPlusDB["Frames"]["BuffFrame"]["XOffset"] = -271
				LeaPlusDB["Frames"]["BuffFrame"]["YOffset"] = 0
				LeaPlusDB["Frames"]["BuffFrame"]["Scale"] = 0.80

				LeaPlusDB["ClassColFrames"] = "On"				-- Class colored frames
				LeaPlusDB["ShowPlayerChain"] = "On"				-- Show player chain
				LeaPlusDB["PlayerChainMenu"] = 3				-- Player chain style
				LeaPlusDB["ShowRaidToggle"] = "On"				-- Show raid toggle button
				LeaPlusDB["CombatPlates"] = "On"				-- Combat plates

				LeaPlusDB["NoGryphons"] = "On"					-- Hide gryphons
				LeaPlusDB["NoClassBar"] = "On"					-- Hide stance bar

				-- System
				LeaPlusDB["NoScreenGlow"] = "On"				-- Disable screen glow
				LeaPlusDB["NoScreenEffects"] = "On"				-- Disable screen effects
				LeaPlusDB["MaxCameraZoom"] = "On"				-- Max camera zoom
				LeaPlusDB["ViewPortEnable"] = "On"				-- Enable viewport
				LeaPlusDB["NoRestedEmotes"] = "On"				-- Silence rested emotes

				LeaPlusDB["NoBagAutomation"] = "On"				-- Disable bag automation
				LeaPlusDB["CharAddonList"] = "On"				-- Show character addons
				LeaPlusDB["NoConfirmLoot"] = "On"				-- Disable loot warnings
				LeaPlusDB["FasterLooting"] = "On"				-- Faster auto loot
				LeaPlusDB["FasterMovieSkip"] = "On"				-- Faster movie skip
				LeaPlusDB["StandAndDismount"] = "On"			-- Stand and dismount
				LeaPlusDB["ShowVendorPrice"] = "On"				-- Show vendor price

				-- Settings
				LeaPlusDB["EnableHotkey"] = "On"				-- Enable hotkey

				-- Function to assign cooldowns
				local function setIcon(pclass, pspec, sp1, pt1, sp2, pt2, sp3, pt3, sp4, pt4, sp5, pt5)
					-- Set spell ID
					if sp1 == 0 then LeaPlusDB["Cooldowns"][pclass]["S" .. pspec .. "R1Idn"] = "" else LeaPlusDB["Cooldowns"][pclass]["S" .. pspec .. "R1Idn"] = sp1 end
					if sp2 == 0 then LeaPlusDB["Cooldowns"][pclass]["S" .. pspec .. "R2Idn"] = "" else LeaPlusDB["Cooldowns"][pclass]["S" .. pspec .. "R2Idn"] = sp2 end
					if sp3 == 0 then LeaPlusDB["Cooldowns"][pclass]["S" .. pspec .. "R3Idn"] = "" else LeaPlusDB["Cooldowns"][pclass]["S" .. pspec .. "R3Idn"] = sp3 end
					if sp4 == 0 then LeaPlusDB["Cooldowns"][pclass]["S" .. pspec .. "R4Idn"] = "" else LeaPlusDB["Cooldowns"][pclass]["S" .. pspec .. "R4Idn"] = sp4 end
					if sp5 == 0 then LeaPlusDB["Cooldowns"][pclass]["S" .. pspec .. "R5Idn"] = "" else LeaPlusDB["Cooldowns"][pclass]["S" .. pspec .. "R5Idn"] = sp5 end
					-- Set pet checkbox
					if pt1 == 0 then LeaPlusDB["Cooldowns"][pclass]["S" .. pspec .. "R1Pet"] = false else LeaPlusDB["Cooldowns"][pclass]["S" .. pspec .. "R1Pet"] = true end
					if pt2 == 0 then LeaPlusDB["Cooldowns"][pclass]["S" .. pspec .. "R2Pet"] = false else LeaPlusDB["Cooldowns"][pclass]["S" .. pspec .. "R2Pet"] = true end
					if pt3 == 0 then LeaPlusDB["Cooldowns"][pclass]["S" .. pspec .. "R3Pet"] = false else LeaPlusDB["Cooldowns"][pclass]["S" .. pspec .. "R3Pet"] = true end
					if pt4 == 0 then LeaPlusDB["Cooldowns"][pclass]["S" .. pspec .. "R4Pet"] = false else LeaPlusDB["Cooldowns"][pclass]["S" .. pspec .. "R4Pet"] = true end
					if pt5 == 0 then LeaPlusDB["Cooldowns"][pclass]["S" .. pspec .. "R5Pet"] = false else LeaPlusDB["Cooldowns"][pclass]["S" .. pspec .. "R5Pet"] = true end
				end

				-- Create main table
				LeaPlusDB["Cooldowns"] = {}

				-- Create class tables
				local classList = {"WARRIOR", "PALADIN", "HUNTER", "SHAMAN", "ROGUE", "DRUID", "MAGE", "WARLOCK", "PRIEST"}
				for index = 1, #classList do
					if LeaPlusDB["Cooldowns"][classList[index]] == nil then
						LeaPlusDB["Cooldowns"][classList[index]] = {}
					end
				end

				-- Assign cooldowns
				setIcon("WARRIOR", 		1, --[[1]] 0, 0, 		--[[2]] 0, 0, 		--[[3]] 0, 0, 		--[[4]] 0, 0, 		--[[5]] 0, 0)
				setIcon("PALADIN", 		1, --[[1]] 0, 0, 		--[[2]] 0, 0, 		--[[3]] 0, 0, 		--[[4]] 0, 0, 		--[[5]] 19740, 0) -- nil, nil, nil, nil, Might
				setIcon("HUNTER", 		1, --[[1]] 136, 1, 		--[[2]] 118455, 1, 	--[[3]] 0, 0, 		--[[4]] 0, 0, 		--[[5]] 5384, 0) -- Mend Pet, nil, nil, nil, Feign Death
				setIcon("SHAMAN", 		1, --[[1]] 0, 0, 		--[[2]] 0, 0, 		--[[3]] 0, 0, 		--[[4]] 215864, 0, 	--[[5]] 546, 0) -- nil, nil, nil, Rainfall, Water Walking
				setIcon("ROGUE", 		1, --[[1]] 1784, 0, 	--[[2]] 0, 0, 		--[[3]] 0, 0, 		--[[4]] 2823, 0, 	--[[5]] 3408, 0) -- Stealth, nil, nil, Deadly Poison, Crippling Poison
				setIcon("DRUID", 		1, --[[1]] 0, 0, 		--[[2]] 0, 0, 		--[[3]] 0, 0, 		--[[4]] 0, 0, 		--[[5]] 0, 0)
				setIcon("MAGE", 		1, --[[1]] 235450, 0, 	--[[2]] 0, 0, 		--[[3]] 0, 0, 		--[[4]] 0, 0, 		--[[5]] 0, 0) -- Prismatic Barrier
				setIcon("WARLOCK", 		1, --[[1]] 0, 0, 		--[[2]] 0, 0, 		--[[3]] 0, 0, 		--[[4]] 0, 0, 		--[[5]] 0, 0)
				setIcon("PRIEST", 		1, --[[1]] 17, 0, 		--[[2]] 0, 0, 		--[[3]] 0, 0, 		--[[4]] 0, 0, 		--[[5]] 0, 0) -- Power Word: Shield

				-- Reload
				ReloadUI()
			else
				LeaPlusLC:Print("Invalid parameter.")
			end
			return
		else
			-- Prevent options panel from showing if a game options panel is showing
			if InterfaceOptionsFrame:IsShown() or VideoOptionsFrame:IsShown() or ChatConfigFrame:IsShown() then return end
			-- Prevent options panel from showing if Blizzard Store is showing
			if StoreFrame and StoreFrame:GetAttribute("isshown") then return end
			-- Toggle the options panel if game options panel is not showing
			if LeaPlusLC:IsPlusShowing() then
				LeaPlusLC:HideFrames()
				LeaPlusLC:HideConfigPanels()
			else
				LeaPlusLC:HideFrames()
				LeaPlusLC["PageF"]:Show()
			end
			LeaPlusLC["Page"..LeaPlusLC["LeaStartPage"]]:Show()
		end
	end

	-- Slash command for global function
	_G.SLASH_Leatrix_Plus1 = "/ltp"
	_G.SLASH_Leatrix_Plus2 = "/leaplus" 
	SlashCmdList["Leatrix_Plus"] = function(self)
		-- Run slash command function
		LeaPlusLC:SlashFunc(self)
		-- Redirect tainted variables
		RunScript('ACTIVE_CHAT_EDIT_BOX = ACTIVE_CHAT_EDIT_BOX')
		RunScript('LAST_ACTIVE_CHAT_EDIT_BOX = LAST_ACTIVE_CHAT_EDIT_BOX')
	end

	-- Slash command for UI reload
	_G.SLASH_LEATRIX_PLUS_RL1 = "/rl"
	SlashCmdList["LEATRIX_PLUS_RL"] = function()
		ReloadUI()
	end

----------------------------------------------------------------------
-- 	L90: Create options panel pages (no content yet)
----------------------------------------------------------------------

	-- Function to add menu button
	function LeaPlusLC:MakeMN(name, text, parent, anchor, x, y, width, height)

		local mbtn = CreateFrame("Button", nil, parent)
		LeaPlusLC[name] = mbtn
		mbtn:Show();
		mbtn:SetSize(width, height)
		mbtn:SetAlpha(1.0)
		mbtn:SetPoint(anchor, x, y)

		mbtn.t = mbtn:CreateTexture(nil, "BACKGROUND")
		mbtn.t:SetAllPoints()
		mbtn.t:SetColorTexture(0.3, 0.3, 0.00, 0.8)
		mbtn.t:SetAlpha(0.7)
		mbtn.t:Hide()

		mbtn.s = mbtn:CreateTexture(nil, "BACKGROUND")
		mbtn.s:SetAllPoints()
		mbtn.s:SetColorTexture(0.3, 0.3, 0.00, 0.8)
		mbtn.s:Hide()

		mbtn.f = mbtn:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		mbtn.f:SetPoint('LEFT', 16, 0)
		mbtn.f:SetText(L[text])
	
		mbtn:SetScript("OnEnter", function()
			mbtn.t:Show()
		end)

		mbtn:SetScript("OnLeave", function()
			mbtn.t:Hide()
		end)

		return mbtn, mbtn.s

	end

	-- Function to create individual options panel pages
	function LeaPlusLC:MakePage(name, title, menu, menuname, menuparent, menuanchor, menux, menuy, menuwidth, menuheight)

		-- Create frame
		local oPage = CreateFrame("Frame", nil, LeaPlusLC["PageF"]); 
		LeaPlusLC[name] = oPage
		oPage:SetAllPoints(LeaPlusLC["PageF"])
		oPage:Hide();

		-- Add page title
		oPage.s = oPage:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
		oPage.s:SetPoint('TOPLEFT', 146, -16)
		oPage.s:SetText(L[title])

		-- Add menu item if needed
		if menu then
			LeaPlusLC[menu], LeaPlusLC[menu .. ".s"] = LeaPlusLC:MakeMN(menu, menuname, menuparent, menuanchor, menux, menuy, menuwidth, menuheight)
			LeaPlusLC[name]:SetScript("OnShow", function() LeaPlusLC[menu .. ".s"]:Show(); end)
			LeaPlusLC[name]:SetScript("OnHide", function() LeaPlusLC[menu .. ".s"]:Hide(); end)
		end

		return oPage;
	
	end

	-- Create options pages
	LeaPlusLC["Page0"] = LeaPlusLC:MakePage("Page0", "Home"			, "LeaPlusNav0", "Home"			, LeaPlusLC["PageF"], "TOPLEFT", 16, -72, 112, 20)
	LeaPlusLC["Page1"] = LeaPlusLC:MakePage("Page1", "Automation"	, "LeaPlusNav1", "Automation"	, LeaPlusLC["PageF"], "TOPLEFT", 16, -112, 112, 20)
	LeaPlusLC["Page2"] = LeaPlusLC:MakePage("Page2", "Social"		, "LeaPlusNav2", "Social"		, LeaPlusLC["PageF"], "TOPLEFT", 16, -132, 112, 20)
	LeaPlusLC["Page3"] = LeaPlusLC:MakePage("Page3", "Chat"			, "LeaPlusNav3", "Chat"			, LeaPlusLC["PageF"], "TOPLEFT", 16, -152, 112, 20)
	LeaPlusLC["Page4"] = LeaPlusLC:MakePage("Page4", "Text"			, "LeaPlusNav4", "Text"			, LeaPlusLC["PageF"], "TOPLEFT", 16, -172, 112, 20)
	LeaPlusLC["Page5"] = LeaPlusLC:MakePage("Page5", "Interface"	, "LeaPlusNav5", "Interface"	, LeaPlusLC["PageF"], "TOPLEFT", 16, -192, 112, 20)
	LeaPlusLC["Page6"] = LeaPlusLC:MakePage("Page6", "Frames"		, "LeaPlusNav6", "Frames"		, LeaPlusLC["PageF"], "TOPLEFT", 16, -212, 112, 20)
	LeaPlusLC["Page7"] = LeaPlusLC:MakePage("Page7", "System"		, "LeaPlusNav7", "System"		, LeaPlusLC["PageF"], "TOPLEFT", 16, -232, 112, 20)
	LeaPlusLC["Page8"] = LeaPlusLC:MakePage("Page8", "Settings"		, "LeaPlusNav8", "Settings"		, LeaPlusLC["PageF"], "TOPLEFT", 16, -272, 112, 20)
	LeaPlusLC["Page9"] = LeaPlusLC:MakePage("Page9", "Media"		, "LeaPlusNav9", "Media"		, LeaPlusLC["PageF"], "TOPLEFT", 16, -292, 112, 20)

	-- Page navigation mechanism
	for i = 0, LeaPlusLC["NumberOfPages"] do
		LeaPlusLC["LeaPlusNav"..i]:SetScript("OnClick", function()
			LeaPlusLC:HideFrames()
			LeaPlusLC["PageF"]:Show();
			LeaPlusLC["Page"..i]:Show();
			LeaPlusLC["LeaStartPage"] = i
		end)
	end

	-- Use a variable to contain the page number (makes it easier to move options around)
	local pg;

----------------------------------------------------------------------
-- 	LC0: Welcome
----------------------------------------------------------------------

	pg = "Page0";

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Welcome to Leatrix Plus.", 146, -72);
	LeaPlusLC:MakeWD(LeaPlusLC[pg], "To begin, choose an options page.", 146, -92);

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Support", 146, -132);
	LeaPlusLC:MakeWD(LeaPlusLC[pg], "www.curseforge.com/wow/addons/leatrix-plus-classic", 146, -152);

----------------------------------------------------------------------
-- 	LC1: Automation
----------------------------------------------------------------------

	pg = "Page1";

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Character"					, 	146, -72);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "AutomateQuests"			,	"Automate quests"				,	146, -92, 	false,	"If checked, quests will be selected, accepted and turned-in automatically.|n|nQuests which have a gold requirement will not be turned-in automatically.|n|nYou can hold the shift key down when you talk to a quest giver to override this setting.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "AutomateGossip"			,	"Automate gossip"				,	146, -112, 	false,	"If checked, you can hold down the alt key while opening a gossip window to automatically select a single gossip item.|n|nIf the gossip item type is banker, taxi, trainer or vendor, gossip will be skipped without needing to hold the alt key.  You can hold the shift key down to prevent this.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "AutoAcceptSummon"			,	"Accept summon"					, 	146, -132, 	false,	"If checked, summon requests will be accepted automatically unless you are in combat.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "AutoAcceptRes"				,	"Accept resurrection"			, 	146, -152, 	false,	"If checked, resurrection requests will be accepted automatically as long as the player resurrecting you is not in combat.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "AutoReleasePvP"			,	"Release in PvP"				, 	146, -172, 	false,	"If checked, you will release automatically after you die in a battleground.|n|nYou will not release automatically if you have the ability to self-resurrect.")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Vendors"					, 	340, -72);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "AutoSellJunk"				,	"Sell junk automatically"		,	340, -92, 	false,	"If checked, all grey items in your bags will be sold automatically when you visit a merchant.|n|nYou can hold the shift key down when you talk to a merchant to override this setting.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "AutoRepairGear"			, 	"Repair automatically"			,	340, -112, 	false,	"If checked, your gear will be repaired automatically when you visit a suitable merchant.|n|nYou can hold the shift key down when you talk to a merchant to override this setting.")

----------------------------------------------------------------------
-- 	LC2: Social
----------------------------------------------------------------------

	pg = "Page2";

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Blocks"					, 	146, -72);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoDuelRequests"			, 	"Block duels"					,	146, -92, 	false,	"If checked, duel requests will be blocked unless the player requesting the duel is in your friends list or guild.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoPartyInvites"			, 	"Block party invites"			, 	146, -112, 	false,	"If checked, party invitations will be blocked unless the player inviting you is in your friends list or guild.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoFriendRequests"			, 	"Block friend requests"			, 	146, -132, 	false,	"If checked, BattleTag and Real ID friend requests will be automatically declined.|n|nEnabling this option will automatically decline any pending requests.")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Groups"					, 	340, -72);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "AcceptPartyFriends"		, 	"Party from friends"			, 	340, -92, 	false,	"If checked, party invitations from friends or guild members will be automatically accepted.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "InviteFromWhisper"			,   "Invite from whispers"			,	340, -112,	false,	"If checked, a group invite will be sent to anyone who whispers you with the keyword INV.|n|nYou need to be either ungrouped or party leader in your own group for this to work.")

----------------------------------------------------------------------
-- 	LC3: Chat
----------------------------------------------------------------------

	pg = "Page3";

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Chat Frame"				, 	146, -72);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "UseEasyChatResizing"		,	"Use easy resizing"				,	146, -92,	true,	"If checked, dragging the General chat tab while the chat frame is locked will expand the chat frame upwards.|n|n\If the chat frame is unlocked, dragging the General chat tab will move the chat frame.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoCombatLogTab" 			, 	"Hide the combat log"			, 	146, -112, 	true,	"If checked, the combat log will be hidden.|n|nThe combat log must be docked in order for this option to work.|n|nIf the combat log is undocked, you can dock it by dragging the tab (and reloading your UI) or by resetting the chat windows (from the chat menu).")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoChatButtons"				,	"Hide chat buttons"				,	146, -132,	true,	"If checked, chat frame buttons will be hidden.|n|nClicking chat tabs will automatically show the latest messages.|n|nUse the mouse wheel to scroll through the chat history.  Hold down SHIFT for page jump or CTRL to jump to the top or bottom of the chat history.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "UnclampChat"				,	"Unclamp chat frame"			,	146, -152,	true,	"If checked, you will be able to drag the chat frame to the edge of the screen.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "MoveChatEditBoxToTop" 		, 	"Move editbox to top"			,	146, -172, 	true,	"If checked, the editbox will be moved to the top of the chat frame.")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Mechanics"					, 	340, -72);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoStickyChat"				, 	"Disable sticky chat"			,	340, -92,	true,	"If checked, sticky chat will be disabled.|n|nNote that this does not apply to temporary chat windows.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "UseArrowKeysInChat"		, 	"Use arrow keys in chat"		, 	340, -112, 	true,	"If checked, you can press the arrow keys to move the insertion point left and right in the chat frame.|n|nIf unchecked, the arrow keys will use the default keybind setting.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoChatFade"				, 	"Disable chat fade"				, 	340, -132, 	true,	"If checked, chat text will not fade out after a time period.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "UnivGroupColor"			,	"Universal group color"			,	340, -152,	false,	"If checked, raid chat and instance chat will both be colored blue (to match the default party chat color).")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ClassColorsInChat"			,	"Use class colors in chat"		,	340, -172,	false,	"If checked, class colors will be used in the chat frame.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "RecentChatWindow"			,	"Recent chat window"			, 	340, -192, 	true,	"If checked, you can hold down the control key and click a chat tab to view recent chat in a copy-friendly window.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "MaxChatHstory"				,	"Increase chat history"			, 	340, -212, 	true,	"If checked, your chat history will increase to 4096 lines.  If unchecked, the default will be used (128 lines).|n|nEnabling this option may prevent some chat text from showing during login.")

----------------------------------------------------------------------
-- 	LC4: Text
----------------------------------------------------------------------

	pg = "Page4";

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Visibility"				, 	146, -72);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "HideErrorMessages"			, 	"Hide error messages"			,	146, -92, 	true,	"If checked, most error messages (such as 'Not enough rage') will not be shown.  Some important errors are excluded.|n|nIf you have the minimap button enabled, you can hold down the control key and right-click it to toggle error messages without affecting this setting.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoHitIndicators"			, 	"Hide portrait numbers"			,	146, -112, 	true,	"If checked, damage and healing numbers in the player and pet portrait frames will be hidden.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "HideZoneText"				,	"Hide zone text"				,	146, -132, 	true,	"If checked, zone text will not be shown (eg. 'Ironforge').")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Text Size"					, 	340, -72);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "MailFontChange"			,	"Resize mail text"				, 	340, -92, 	true,	"If checked, you will be able to change the font size of standard mail text.|n|nThis does not affect mail created using templates (such as auction house invoices).")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "QuestFontChange"			,	"Resize quest text"				, 	340, -112, 	true,	"If checked, you will be able to change the font size of quest text.")

	LeaPlusLC:CfgBtn("MailTextBtn", LeaPlusCB["MailFontChange"])
	LeaPlusLC:CfgBtn("QuestTextBtn", LeaPlusCB["QuestFontChange"])

----------------------------------------------------------------------
-- 	LC5: Interface
----------------------------------------------------------------------

	pg = "Page5";

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Enhancements"				, 	146, -72);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "MinimapMod"				,	"Customise minimap"				, 	146, -92, 	true,	"If checked, you will be able to customise the minimap.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "TipModEnable"				,	"Manage tooltip"				,	146, -112, 	true,	"If checked, the tooltip will be color coded and you will be able to modify the tooltip layout and scale.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "EnhanceDressup"			, 	"Enhance dressup"				,	146, -132, 	true,	"If checked, nude and tabard toggle buttons will be added to the dressup frame and model rotation controls will be removed.")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Extras"					, 	340, -72);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ShowVolume"				, 	"Show volume slider"			, 	340, -92, 	true,	"If checked, a master volume slider will be shown in the character sheet.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "AhExtras"					, 	"Show auction controls"			, 	340, -112, 	true,	"If checked, additional functionality will be added to the auction house.|n|nBuyout only - create buyout auctions without filling in the starting price.|n|nGold only - set the copper and silver prices at 99 to speed up new auctions.|n|nFind item - search the auction house for the item you are selling.|n|nIn addition, the auction duration setting will be saved account-wide.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ShowCooldowns"				, 	"Show cooldowns"				, 	340, -132, 	true,	"If checked, you will be able to place up to five beneficial cooldown icons above the target frame.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "DurabilityStatus"			, 	"Show durability status"		, 	340, -152, 	true,	"If checked, a button will be added to the character sheet which will show your equipped item durability when you hover the pointer over it.|n|nIn addition, an overall percentage will be shown in the chat frame when you die.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ShowVanityControls"		, 	"Show vanity controls"			, 	340, -172, 	true,	"If checked, helm and cloak toggle checkboxes will be shown in the character sheet.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ShowWowheadLinks"			, 	"Show Wowhead links"			, 	340, -192, 	true,	"If checked, Wowhead links will be shown above the quest log frame.")

	LeaPlusLC:CfgBtn("ModMinimapBtn", LeaPlusCB["MinimapMod"])
	LeaPlusLC:CfgBtn("MoveTooltipButton", LeaPlusCB["TipModEnable"])
	LeaPlusLC:CfgBtn("CooldownsButton", LeaPlusCB["ShowCooldowns"])

----------------------------------------------------------------------
-- 	LC6: Frames
----------------------------------------------------------------------

	pg = "Page6";

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Features"					, 	146, -72);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "FrmEnabled"				,	"Manage frames"					, 	146, -92, 	true,	"If checked, you will be able to change the position and scale of the following frames:|n|n- Player frame|n- Target frame|n- Buffs frame|n- Widget top center frame|n- Timer bar")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ClassColFrames"			, 	"Class colored frames"			,	146, -112, 	true,	"If checked, class coloring will be used in the player frame and target frame.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ShowPlayerChain"			, 	"Show player chain"				,	146, -132, 	true,	"If checked, you will be able to show a rare, elite or rare elite chain around the player frame.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ShowRaidToggle"			, 	"Raid frame toggle"				,	146, -152, 	true,	"If checked, the button to toggle the raid container frame will be shown just above the raid management frame (left side of the screen) instead of in the raid management frame itself.|n|nThis allows you to toggle the raid container frame without needing to open the raid management frame.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "CombatPlates"				, 	"Combat plates"					,	146, -172, 	true,	"If checked, enemy nameplates will be shown during combat and hidden when combat ends.")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Visibility"				, 	340, -72);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoGryphons"				,	"Hide gryphons"					, 	340, -92, 	true,	"If checked, the main bar gryphons will not be shown.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoClassBar"				,	"Hide stance bar"				, 	340, -112, 	true,	"If checked, the stance bar will not be shown.")

	LeaPlusLC:CfgBtn("MoveFramesButton", LeaPlusCB["FrmEnabled"])
	LeaPlusLC:CfgBtn("ModPlayerChain", LeaPlusCB["ShowPlayerChain"])

----------------------------------------------------------------------
-- 	LC7: System
----------------------------------------------------------------------

	pg = "Page7";

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Graphics and Sound"		, 	146, -72);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoScreenGlow"				, 	"Disable screen glow"			, 	146, -92, 	false,	"If checked, the screen glow will be disabled.|n|nEnabling this option will also disable the drunken haze effect.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoScreenEffects"			, 	"Disable screen effects"		, 	146, -112, 	false,	"If checked, the grey screen of death and the netherworld effect will be disabled.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "MaxCameraZoom"				, 	"Max camera zoom"				, 	146, -132, 	false,	"If checked, you will be able to zoom out to a greater distance.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ViewPortEnable"			,	"Enable viewport"				,	146, -152, 	true,	"If checked, you will be able to create a viewport.  A viewport adds adjustable black borders around the game world.|n|nThe borders are placed on top of the game world but under the UI so you can place UI elements over them.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoRestedEmotes"			, 	"Silence rested emotes"			,	146, -172, 	true,	"If checked, emote sounds will be silenced while your character is resting or at the Grim Guzzler.|n|nEmote sounds will be enabled at all other times.")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Game Options"				, 	340, -72);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoBagAutomation"			, 	"Disable bag automation"		, 	340, -92, 	true,	"If checked, your bags will not be opened or closed automatically when you interact with a merchant, bank or mailbox.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "CharAddonList"				, 	"Show character addons"			, 	340, -112, 	true,	"If checked, the addon list (accessible from the game menu) will show character based addons by default.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoConfirmLoot"				, 	"Disable loot warnings"			,	340, -132, 	false,	"If checked, confirmations will no longer appear when you choose a loot roll option or attempt to sell or mail a tradable item.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "FasterLooting"				, 	"Faster auto loot"				,	340, -152, 	true,	"If checked, the amount of time it takes to auto loot creatures will be significantly reduced.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "FasterMovieSkip"			, 	"Faster movie skip"				,	340, -172, 	true,	"If checked, you will be able to cancel cinematics without being prompted for confirmation.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "StandAndDismount"			, 	"Stand and dismount"			,	340, -192, 	true,	"If checked, your character will automatically stand or dismount when an action is prevented because you are either seated or mounted.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ShowVendorPrice"			, 	"Show vendor price"				,	340, -212, 	true,	"If checked, the vendor price will be shown in item tooltips.")

	LeaPlusLC:CfgBtn("ModViewportBtn", LeaPlusCB["ViewPortEnable"])

----------------------------------------------------------------------
-- 	LC8: Settings
----------------------------------------------------------------------

	pg = "Page8";

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Addon"						, 146, -72);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ShowMinimapIcon"			, "Show minimap button"				, 146, -92,		false,	"If checked, a minimap button will be available.|n|nClick - Toggle options panel.|n|nSHIFT/Left-click - Toggle music.|n|nCTRL/Right-click - Toggle errors (if enabled).|n|nCTRL/SHIFT/Left-click - Toggle Zygor (if installed).|n|nCTRL/SHIFT/Right-click - Toggle windowed mode.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "EnableHotkey"				, "Enable hotkey"					, 146, -112,	true,	"If checked, you can open Leatrix Plus by pressing CTRL/Z.")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Scale", 340, -72);
	LeaPlusLC:MakeSL(LeaPlusLC[pg], "PlusPanelScale", "Drag to set the scale of the Leatrix Plus panel.", 1, 2, 0.1, 340, -92, "%.1f")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Transparency", 340, -132);
	LeaPlusLC:MakeSL(LeaPlusLC[pg], "PlusPanelAlpha", "Drag to set the transparency of the Leatrix Plus panel.", 0, 1, 0.1, 340, -152, "%.1f")

	LeaPlusLC:ShowMemoryUsage(LeaPlusLC[pg], "TOPLEFT", 146, -262)
