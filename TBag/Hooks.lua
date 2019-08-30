local _G = getfenv(0)
local TBag = _G.TBag
TBag.Hooks = {}
local Hooks = TBag.Hooks


Hooks.UNREGISTER = 0
Hooks.REGISTER = 1
Hooks.CHECK = 2

Hooks.funcs = {
  "OpenBag",
  "CloseBag",
  "ToggleBag",
  "OpenBackpack",
  "CloseBackpack",
  "ToggleBackpack",
  "ToggleAllBags",
  "ContainerFrameItemButton_OnModifiedClick",
}

Hooks.scripts = {
  ["MerchantFrame"] = "OnHide"
}

Hooks.savedfuncs = {}

local inMerchantFrameOnHide = false

function Hooks.Register(reg)
  local funcs = Hooks.funcs
  local scripts = Hooks.scripts
  local savedfuncs = Hooks.savedfuncs

  if (reg == Hooks.REGISTER) then
    for _,funcname in ipairs(funcs) do
      local ourfunc = Hooks[funcname]

      if ourfunc then
        savedfuncs[funcname] = _G[funcname]
        setglobal(funcname, ourfunc)
        TBag:PrintDEBUG("Hook function for '"..funcname.." installed.")
      else
        TBag:PrintDEBUG("** Hook function for '"..funcname.." SKIPPED **")
      end
    end
    for framename,script in pairs(scripts) do
      local funcname = framename..'_'..script
      local ourfunc = Hooks[funcname]

      if ourfunc then
        local frame = _G[framename]
        savedfuncs[funcname] = frame:GetScript(script)
        frame:SetScript(script, ourfunc)
        TBag:PrintDEBUG("Hook script for '"..funcname.." installed.")
      else
        TBag:PrintDEBUG("** Hook script for '"..funcname.." SKIPPED **")
      end
    end
  elseif (reg == Hooks.UNREGISTER) then
    -- unregister hooks
    for _,funcname in ipairs(funcs) do
      local ourfunc = Hooks[funcname]

      if ourfunc and savedfuncs[funcname] then
        setglobal(funcname, savedfuncs[funcname])
        savedfuncs[funcname] = nil
        TBag:PrintDEBUG("Hook function for '"..funcname.." removed.")
      end
    end
    for framename,script in pairs(scripts) do
      local funcname = framename..'_'..script
      local ourfunc = Hooks[funcname]

      if ourfunc and savedfuncs[funcname] then
        local frame = _G[framename]
        frame:SetScript(script, savedfuncs[funcname])
        savedfuncs[funcname] = nil
        TBag:PrintDEBUG("Hook script for '"..funcname.." removed.")
      end
    end
  elseif (reg == Hooks.CHECK) then
    -- check if hooks are registered
    TBag:Print( "Hooks:" ,1,1,0.2 )
    for _,funcname in ipairs(funcs) do
      local ourfunc = Hooks[funcname]
      local curfunc = _G[funcname]

      if ourfunc == curfunc then
        TBag:Print("  "..funcname.." is hooked properly.", 0, 1, 0.25)
      else
        TBag:Print("  "..funcname.." is NOT hooked.", 1, 0.2, 0.2)
      end
    end
    for framename,script in pairs(scripts) do
      local funcname = framename..'_'..script
      local ourfunc = Hooks[funcname]
      local frame = _G[framename]
      local curfunc = frame:GetScript(script)

      if ourfunc == curfunc then
        TBag:Print("  "..funcname.." is hooked properly.", 0, 1, 0.25)
      else
        TBag:Print("  "..funcname.." is NOT hooked.", 1, 0.2, 0.2)
      end
    end
  end
end

local function CloseAllWindows()
  TBag:PrintDEBUG("event: CloseAllWindows()")

  TInvFrame:Hide()
  TBnkFrame:Hide()
end
hooksecurefunc('CloseAllWindows', CloseAllWindows)

function Hooks.OpenBag(bag)
  TBag:PrintDEBUG("event: OpenBag("..bag..")")
  local mainFrame
  if TBag:Member(TInvFrame.bags,bag) then
    mainFrame = TInvFrame
  else
    mainFrame = TBnkFrame
  end

  if mainFrame.cfg["show_Bag"..bag] ~= 1 then
    TBag:GetBagFrame(bag):SetChecked(true)
  end
  mainFrame:Show()
  TBag:UpdateButtonHighlights()
end

function Hooks.CloseBag(bag)
  TBag:PrintDEBUG("event: CloseBag("..bag..")")
  if TBag:Member(TInvFrame.bags,bag) then
    TInvFrame:Hide()
  else
    TBnkFrame:Hide()
  end
end

function Hooks.ToggleBag(bag)
  TBag:PrintDEBUG("event: ToggleBag("..bag..")")
  local mainFrame
  if TBag:Member(TInvFrame.bags,bag) then
    mainFrame = TInvFrame
  else
    mainFrame = TBnkFrame
  end
  local isBagShown = mainFrame.cfg["show_Bag"..bag] == 1
  local isVisible = mainFrame:IsVisible()

  -- If the frame is already visible and the bag is set to
  -- always be shown just hide the frame.
  if isVisible and isBagShown then
    mainFrame:Hide()
    return
  end

  -- Toggle the checked state of the bag frame if the
  -- bag isn't  permanetly set to be shown, this will
  -- toggle the shown state of the Bag.
  if not isBagShown then
    local bagFrame = TBag:GetBagFrame(bag)
    bagFrame:SetChecked(not bagFrame:GetChecked())
  end

  -- If the frame was already visible when we started
  -- force an update, otherwise show it which will
  -- force an update for us.
  if isVisible then
    TInvFrame:UpdateWindow(TBag.REQ_MUST)
  else
    TInvFrame:Show()
  end
  TBag:UpdateButtonHighlights()
end

function Hooks.OpenBackpack()
  TBag:PrintDEBUG("event: OpenBackpack()")
  Hooks.OpenBag(BACKPACK_CONTAINER)
end

function Hooks.CloseBackpack()
  TBag:PrintDEBUG("event: CloseBackpack()")
  if not inMerchantFrameOnHide then
    TInvFrame:Hide()
  end
end

function Hooks.ToggleBackpack()
  TBag:PrintDEBUG("event: ToggleBackpack()")
  Hooks.ToggleBag(BACKPACK_CONTAINER)
end

function Hooks.ToggleAllBags()
  TBag:PrintDEBUG("event: OpenAllBags()")
  local inv_bag_toggled  = false
  local inv_shown = false
  local bnk_bag_toggled = false

  for _,bag in ipairs(TInvFrame.bags) do
    if TInvFrame.cfg["show_Bag"..bag] ~= 1 then
      local bagframe = TBag:GetBagFrame(bag)
      if not bagframe:GetChecked() then
        bagframe:SetChecked(true)
        TInvFrame.CACHE_REQ = TBag.REQ_MUST
        inv_bag_toggled = true
      end
    end
  end

  if inv_bag_toggled then
    inv_shown = true
    TInvFrame:Show()
    if TInvFrame.CACHE_REQ > TBag.REQ_NONE then
      TInvFrame:UpdateWindow(TBag.REQ_PART)
    end
  else
    inv_shown = not TInvFrame:Toggle()
  end

  -- Toggle the normally hidden bank bags based on
  -- if the inventory is hidden or shown
  if TBnkFrame:IsVisible() then
    for _, bag in ipairs(TBnkFrame.bags) do
      if TBnkFrame.cfg["show_Bag"..bag] ~= 1 then
        local bagframe = TBag:GetBagFrame(bag)
        if bagframe:GetChecked() ~= inv_shown then
          bagframe:SetChecked(inv_shown)
          TBnkFrame.CACHE_REQ = TBag.REQ_MUST
          bnk_bag_toggled = true
        end
      end
    end
  end

  if bnk_bag_toggled then
    TBnkFrame:UpdateWindow(TBag.REQ_PART)
  end

  TBag:UpdateButtonHighlights()
end

function Hooks.ContainerFrameItemButton_OnModifiedClick(self, button, ...)
  TBag:PrintDEBUG("event: ItemButton_OnModifiedClick self="..self:GetName())

  -- Original func
  local func = Hooks.savedfuncs["ContainerFrameItemButton_OnModifiedClick"]

  -- Get the itm and ultimately know if it's one of our buttons
  local itm = TBag:GetItmFromFrame(TBag.BUTTONS, self)
  if not itm then return func(self, button, ...) end
  local mainFrame = self:GetParent():GetParent()

  if TBag:IsLive(mainFrame) then
    -- Manage Alt+Click Auto Trade/Auction
    if IsAltKeyDown() then
      local alt_pickup = TInvFrame.cfg.alt_pickup == 1
      local alt_panel = TInvFrame.cfg.alt_panel == 1

      if TradeFrame and TradeFrame:IsShown() then
        if alt_pickup  then
          local tradeslot = TradeFrame_GetAvailableSlot()
          if tradeslot then
            PickupContainerItem(itm[TBag.I_BAG], itm[TBag.I_SLOT])
            ClickTradeButton(tradeslot)
            ClearCursor()
            return
          end
        end
      elseif AuctionFrame and AuctionFrame:IsShown() then
        if alt_panel then
          this = AuctionFrameTab3 -- Workaround for AucAdvanced Apraiser module
          AuctionFrameTab_OnClick(AuctionFrameTab3)
        end
        -- If we have auctioneer do not auto pickup let auctioneer do it.
        if not AuctionFramePost then
          if alt_pickup and PanelTemplates_GetSelectedTab(AuctionFrame) == 3 then
            PickupContainerItem(itm[TBag.I_BAG], itm[TBag.I_SLOT])
            ClickAuctionSellItemButton()
            ClearCursor()
            return
          end
        end
      elseif MailFrame and MailFrame:IsShown() then
        if alt_panel then
          MailFrameTab_OnClick(MailFrameTab2)
        end
        if alt_pickup and PanelTemplates_GetSelectedTab(MailFrame) == 2 then
          PickupContainerItem(itm[TBag.I_BAG], itm[TBag.I_SLOT])
          ClickSendMailItemButton()
          ClearCursor()
          return
        end
      end
    end
  else
    -- not a live frame
    if itm[TBag.I_ITEMLINK] then
      if IsModifiedClick("CHATLINK") then
        local hl = TBag:MakeHyperlink(itm[TBag.I_ITEMLINK], itm[TBag.I_NAME],
                                      itm[TBag.I_RARITY],
                                      TBag:GetPlayerInfo(mainFrame.playerid,TBag.G_BASIC)[TBag.S_LEVEL] or UnitLevel("player"),
                                      itm[TBag.I_LINKSUFFIX])
        ChatEdit_InsertLink(hl)
        return
      elseif IsModifiedClick("DRESSUP") then
        DressUpItemLink(itm[TBag.I_ITEMLINK])
        return
      elseif IsModifiedClick("SPLITSTACK") then
        -- Can't split something in a non live frame
        return
      end
    end
  end

  -- Fall through to the original code
  return func(self, button, ...)
end

function Hooks.MerchantFrame_OnHide(...)
  inMerchantFrameOnHide = true
  Hooks.savedfuncs.MerchantFrame_OnHide(...)
  inMerchantFrameOnHide = false
end

function Hooks.MerchantFrame_OnShow(...)
  TInvFrame:UpdateWindow()
  TBnkFrame:UpdateWindow()
end
MerchantFrame:HookScript("OnShow", Hooks.MerchantFrame_OnShow)
