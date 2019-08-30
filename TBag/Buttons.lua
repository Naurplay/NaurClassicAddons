-- Implementation of the base templates for various buttons.

local _G = getfenv(0)
local TBag = _G.TBag
local L = TBag.LOCALE

-- Generic itembutton implementation
TBag.ItemButton = {}
local ItemButton = TBag.ItemButton

function ItemButton:OnEnter()
  local itm = TBag:GetItmFromFrame(TBag.BUTTONS, self)
  if not itm or not next(itm) then return end
  local mainFrame = self:GetParent():GetParent()
  if self:GetName():match('_EditButton') then
    mainFrame = self:GetParent():GetParent():GetParent()
  end
  local bar, bag, slot = itm[TBag.I_BAR], itm[TBag.I_BAG], itm[TBag.I_SLOT]
  local cat, link = itm[TBag.I_CAT], itm[TBag.I_ITEMLINK]
  local charges = itm[TBag.I_CHARGES]
  local suffix = itm[TBag.I_LINKSUFFIX]
  local pet = link and link:sub(1,10) == "battlepet:"
  local isLive = TBag:IsLive(mainFrame)

  if mainFrame.edit_selected == "" then
    mainFrame.edit_hilight = cat
  end

  -- Tool Tip Anchor
  if self:GetLeft() < GetScreenWidth()/2 then
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
  else
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
  end

  local hasCooldown, repairCost
  if not link then
    if mainFrame.edit_mode == 1 then
      GameTooltip:ClearLines()
      GameTooltip:AddLine(L["Empty Slot"], 1,1,1)
    else
      GameTooltip:Hide()
      return
    end
  else
    hasCooldown, repairCost = TBag:SetInventoryItem(GameTooltip, mainFrame.playerid,
                                                    link, bag, slot, suffix)
  end

  -- Set charges if remote viewing, Blizzard's code does it otherwise.
  if charges and not isLive then
    GameTooltip:AddLine(string.format(L["%d |4Charge:Charges;"], tonumber(charges)),
                        255,255,255,1)
    GameTooltip:Show()
  end

  if isLive then
    if InRepairMode() and (repairCost and repairCost > 0) then
      GameTooltip:AddLine(TEXT(REPAIR_COST), 1, 1, 1)
      SetTooltipMoney(GameTooltip, repairCost)
      GameTooltip:Show()
    elseif MerchantFrame:IsVisible() then
      ShowContainerSellCursor(bag, slot)
    elseif itm[TBag.I_READABLE] then
      ShowInspectCursor()
    end
  end

  if IsModifiedClick("COMPAREITEMS") then
    GameTooltip_ShowCompareItem()
  end

  if pet then
    GameTooltip:SetOwner(BattlePetTooltip, "ANCHOR_BOTTOM")
  end

  if mainFrame.edit_mode == 1 then
    if cat then
      if mainFrame.edit_selected ~= "" then
        GameTooltip:AddLine(" ", 0,0,0)
        GameTooltip:AddLine(string.format(L["|c%sLeft click to move category |r|c%s%s|r|c%s to bar |r|c%s%s|r"],TBag.C_INST,TBag.C_CAT,mainFrame.edit_selected,TBag.C_INST,TBag.C_BAR,bar))
      else
        GameTooltip:AddLine(" ", 0,0,0)
        GameTooltip:AddLine(string.format(L["|c%sLeft click to select category to move:|r |c%s%s|r"],TBag.C_INST,TBag.C_CAT,cat))
        if link then
          GameTooltip:AddLine(L["Right click to assign this item to a different category"], 1,0,0)
        end
      end
    else
      GameTooltip:AddLine(" ", 0,0,0)
      GameTooltip:AddLine(L["Item has no category"], 1,0,0 )
    end
  end

  if mainFrame.cfg.spotlight_hover == 1 then
    local r, g, b, a = TBag:GetColor(mainFrame.cfg, "bag_"..bag)
    local bagFrameSpot = TBag:GetBagFrameSpotlight(bag)
    bagFrameSpot:SetVertexColor(r, g, b, a)
    bagFrameSpot:Show()
  end

  if mainFrame.edit_mode == 1 then
    GameTooltip:Show()
    mainFrame:UpdateWindow()
  end

end

function ItemButton:OnLeave()
  local itm = TBag:GetItmFromFrame(TBag.BUTTONS, self)
  local mainFrame = self:GetParent():GetParent()
  if self:GetName():match('_EditButton') then
    mainFrame = self:GetParent():GetParent():GetParent()
  end

  if mainFrame.edit_selected == "" then
    mainFrame.edit_hilight = ""
  end

  if GameTooltip:IsOwned(self) then
    GameTooltip:Hide()
    ResetCursor()
  end

  if itm then
    local bag = itm[TBag.I_BAG]
    TBag:GetBagFrameSpotlight(bag):Hide()
  end

  if mainFrame.edit_mode == 1 then
    mainFrame:UpdateWindow()
  end
end

function ItemButton:OnClick(button)
  local itm = TBag:GetItmFromFrame(TBag.BUTTONS, self)
  if not itm or not next(itm) then return end
  local mainFrame = self:GetParent():GetParent()
  if self:GetName():match('_EditButton') then
    mainFrame = self:GetParent():GetParent():GetParent()
  end
  if mainFrame.edit_mode ~= 1 then return end

  local bar, bag, slot = itm[TBag.I_BAR], itm[TBag.I_BAG], itm[TBag.I_SLOT]
  local cat = itm[TBag.I_CAT]

  if button == "LeftButton" then
    if (mainFrame.edit_selected == "") then
      -- you clicked, we selected
      mainFrame.edit_selected = cat
      mainFrame.edit_hilight = cat
    else
      -- we got a click, and we already had one selected.  let's move the items
      TBag:SetCatBar(mainFrame.cfg, mainFrame.edit_selected, bar, 1);

      mainFrame.edit_selected = "";
      mainFrame.edit_hilight = cat

      -- resort will force a window update
      mainFrame:UpdateWindow(TBag.REQ_MUST);
    end
  elseif ( button == "RightButton" ) then
    HideDropDownMenu(1);
    mainFrame.RightClickMenu_mode = "item";
    mainFrame.RightClickMenu_opts = {
      [TBag.I_BAR] = bar,
      [TBag.I_BAG] = bag,
      [TBag.I_SLOT] = slot
    };
    ToggleDropDownMenu(1, nil, mainFrame.RightClickMenu, self:GetName(), -50, 0);
  end
end

-- Handles lock updates.  Takes an itm and mainFrame parameter
-- which allows it to short circuit getting the frames itm and mainFrame
-- such as when it is called from ItemButton.Update.
function ItemButton.UpdateLock(self, itm, mainFrame)
  if not itm then itm = TBag:GetItmFromFrame(TBag.BUTTONS, self) end
  if not itm or not next(itm) then return end
  if not mainFrame then mainFrame = self:GetParent():GetParent() end

  -- Another player's view never appears locked
  if not TBag:IsLive(mainFrame) then return end

  local _,_,locked,_,_ = GetContainerItemInfo(itm[TBag.I_BAG],itm[TBag.I_SLOT])
  SetItemButtonDesaturated(self, locked, 0.5, 0.5, 0.5);
end

-- Handles cooldown updates.  Takes an itm and mainFrame paramenter
-- which allows it to short circuit getting the frames itm and mainFrame
-- such as when it is called from ItemButton.Update.
function ItemButton.UpdateCooldown(self, itm, mainFrame)
  local cooldownFrame = _G[self:GetName().."Cooldown"]
  if not cooldownFrame then return end
  if not itm then itm = TBag:GetItmFromFrame(TBag.BUTTONS, self) end
  if not itm or not next(itm) then return end
  if not mainFrame then mainFrame = self:GetParent():GetParent() end
  local start, duration, enable = 0, 0, false

  if itm[TBag.I_ITEMLINK] and TBag:IsLive(mainFrame) then
    start, duration, enable = GetContainerItemCooldown(itm[TBag.I_BAG], itm[TBag.I_SLOT])
  end
  CooldownFrame_Set(cooldownFrame, start, duration, enable)
  cooldownFrame:SetScale(TBag.COOLDOWN_SCALE)
end

function ItemButton.Update(self)
  local mainFrame = self:GetParent():GetParent()
  local cfg = mainFrame.cfg
  local playerid = mainFrame.playerid
  local hilight_new = mainFrame.hilight_new
  local itm = TBag:GetItmFromFrame(TBag.BUTTONS, self)
  if not itm or not next(itm) then return end
  local bag, slot = itm[TBag.I_BAG], itm[TBag.I_SLOT]
  local ic_start, ic_duration, ic_enable, texture

  -- Get the various frames.
  local framename = self:GetName()
  local frame_texture = _G[framename.."IconTexture"]
  local frame_font = _G[framename.."Count"]
  local frame_bkgr = _G[framename.."_bkgr"]
  local frame_stock = _G[framename.."Stock"]
  local editFrame = _G[framename.."_EditButton"]
  local questTexture = _G[framename.."IconQuestTexture"]

  -- Hide buttons attached to bars which are marked to be hidden
  -- unless of course it is set to a forced show.
  if TBag:GetGrp(cfg, TBag.G_BAR_HIDE, itm[TBag.I_BAR]) == 1 and
     not TBag.FORCED_SHOW[TBag:BagSlotToString(bag, slot)] then
    self:Hide()
    return
  else
    self:Show()
  end

  -- Set the texture for for the button
  local itemlink = itm[TBag.I_ITEMLINK]
  if itemlink then
    frame_texture:SetAlpha(1)
    if itemlink:sub(1,5) == "item:" then
      texture = GetItemIcon(itm[TBag.I_ITEMLINK])
    elseif itemlink:sub(1,10) == "battlepet:" then
      local _, _, _, speciesID = TBag:GetItemID(itemlink)
      _, texture = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
    elseif string.find(itemlink, "keystone") then
      texture = GetItemIcon(158923)
    end
  else
    if cfg.show_bag_icons == 1 then
      texture = TBag:GetBagTexture(playerid, bag)
    end
    frame_texture:SetAlpha(0.35)
  end
  SetItemButtonTexture(self, texture)

  -- Handle quest overlays
  if itm[TBag.I_QUEST_ID] and not itm[TBag.I_QUEST_ACTIVE] then
    questTexture:SetTexture(TEXTURE_ITEM_QUEST_BANG)
    questTexture:Show()
  elseif itm[TBag.I_QUEST_ID] or itm[TBag.I_QUEST_ITEM] then
    questTexture:SetTexture(TEXTURE_ITEM_QUEST_BORDER)
    questTexture:Show()
  else
    questTexture:Hide()
  end

  if (itm[TBag.I_RARITY] and itm[TBag.I_RARITY] == LE_ITEM_QUALITY_POOR and
      not itm[TBag.I_NOVALUE] and MerchantFrame:IsShown()) then
    self.JunkIcon:Show()
  else
    self.JunkIcon:Hide()
  end

  SetItemButtonCount(self, itm[TBag.I_COUNT])

  if mainFrame.edit_mode == 1 then
    -- we should be hilighting an entire class of item
    if itm[TBag.I_CAT] ~= mainFrame.edit_hilight then
      -- dim this item
        self:SetAlpha(0.25)
    else
      -- hilight this item
      self:SetAlpha(1)
    end
    editFrame:Show()
  else
    -- no hilights, just do your normal work
    local age = time() - itm[TBag.I_TIMESTAMP]
    if TBag:GetGrp(cfg, TBag.G_USE_NEW, itm[TBag.I_BAR]) == 1 and
       itm[TBag.I_ITEMLINK] and itm[TBag.I_TIMESTAMP] > 1 and
       age < 60*cfg.newItemTimeout then
      -- item is still new, display the new text.
      frame_stock:SetText(cfg[itm[TBag.I_NEWSTR]])
      if age < 60*cfg.recentTimeout then
        TBag:ColorFont(cfg, frame_stock, frame_font, "recentitem")
      else
        TBag:ColorFont(cfg, frame_stock, frame_font, "newitem")
      end
      frame_stock:Show()
      self:SetAlpha(1)
    else
      frame_stock:Hide()
      if mainFrame.hilight_new == 1 then
        -- We're hilighting new items and the item isn't new
        -- or we would be in the above if statement not this else.
        self:SetAlpha(0.25)
      else
          self:SetAlpha(1)
      end
    end

    if TBag.SrchText then
      if string.match(string.lower(itm[TBag.I_NAME]), TBag.SrchText) then
        -- Matched to normal alpha
        self:SetAlpha(1)
      else
        -- No match so make it partly transparent
        self:SetAlpha(0.25)
      end
    end

    if cfg.show_rarity_color == 1 then
      TBag:SetRarityColor(itm[TBag.I_RARITY], framename)
    else
      TBag:SetRarityColor(nil, framename)
    end

    editFrame:Hide()
  end

  -- Handle desaturation update for locked status
  TBag.ItemButton.UpdateLock(self, itm, mainFrame)

  -- resize and position fonts
  frame_font:SetTextHeight(math.ceil(cfg.count_font)) -- count, bottomright
  frame_font:ClearAllPoints()
  frame_font:SetPoint("BOTTOMRIGHT", framename, "BOTTOMRIGHT", 0-cfg.count_font_x, cfg.count_font_y)

  frame_stock:SetTextHeight(math.ceil(cfg.new_font)) -- stock, topleft
  frame_stock:ClearAllPoints()
  frame_stock:SetPoint("TOPLEFT", framename, "TOPLEFT", cfg.count_font_x/2,
                       0-cfg.count_font_y)

  -- Update the cooldown
  TBag.ItemButton.UpdateCooldown(self, itm, mainFrame)
end

-- Bar buttons used in edit mode to reference a bar.
TBag.BarButton = {}
local BarButton = TBag.BarButton

function BarButton:OnLoad()
  self:RegisterForClicks("LeftButtonUp", "RightButtonUp")

  -- Stock frame from ItemButtonTemplate is used here for
  -- the bar number.  Adjust it to center the number.
  local stock = _G[self:GetName().."Stock"]
  stock:SetFont("Fonts\\ARIALN.TTF", 18, "OUTLINE")
  stock:SetTextColor(1,0,0.25,1)
  stock:SetJustifyH("CENTER")
  stock:ClearAllPoints()
  stock:SetAllPoints()
  stock:Show()
end


function BarButton:OnEnter()
  local mainFrame = self:GetParent()
  if mainFrame.edit_mode ~= 1 then return end
  local bar = self:GetID()

  GameTooltip:SetOwner(self, "ANCHOR_LEFT")
  GameTooltip:ClearLines()

  if mainFrame.edit_selected ~= "" then
    GameTooltip:AddLine(string.format("|c%sLeft click to move category |r|c%s%s|r|c%s to bar |r|c%s%s|r",TBag.C_INST,TBag.C_CAT,mainFrame.edit_selected,TBag.C_INST,TBag.C_BAR,bar));
  else
    GameTooltip:AddLine(string.format("|c%sBar |r|c%s%s|r",TBag.C_INST,TBag.C_BAR,bar));
    GameTooltip:AddLine(" ");
    for key, value in pairs(mainFrame.BC_LIST[bar]) do
      GameTooltip:AddLine(string.format("|c%s%s|r",TBag.C_CAT,value));
    end
    GameTooltip:AddLine(" ");
    GameTooltip:AddLine(L["Right click for options"], 0.85,0.85,0.85, 1.0);
  end
  GameTooltip:Show();
end

function BarButton:OnLeave()
  if GameTooltip:IsOwned(self) then
    GameTooltip:Hide()
    ResetCursor()
  end
end

function BarButton:OnClick(button)
  local mainFrame = self:GetParent()
  if mainFrame.edit_mode ~= 1 then return end
  local bar = self:GetID()

  if button == "LeftButton" then
    if mainFrame.edit_selected ~= "" then
      TBag:SetCatBar(mainFrame.cfg, mainFrame.edit_selected, bar, 1)

      mainFrame.edit_selected = ""
      mainFrame.edit_hilight = ""

      TBag:BuildBarClassList(mainFrame.BC_LIST, mainFrame.cfg)

      mainFrame:UpdateWindow(TBag.REQ_MUST)
    end
  elseif button =="RightButton" then
    HideDropDownMenu(1)
    mainFrame.RightClickMenu_mode = "bar"
    mainFrame.RightClickMenu_opts = {
      [TBag.I_BAR] = bar
    }
    ToggleDropDownMenu(1, nil, mainFrame.RightClickMenu, self:GetName(), -50, 0)
  end
end

TBag.BagButton = {}
local BagButton = TBag.BagButton

function BagButton:OnLoad()
  self:RegisterForDrag("LeftButton")
  self:RegisterForClicks("LeftButtonUp", "RightButtonUp")

  -- Stock frame from ItemButtonTemplate is used here for
  -- the counts on the bag.  Adjust it to center the numbers.
  local stock = _G[self:GetName().."Stock"]
  stock:SetFont("Fonts\\ARIALN.TTF", 18, "OUTLINE")
  stock:SetJustifyH("CENTER")
  stock:ClearAllPoints()
  stock:SetAllPoints()
  stock:Show()
end

function BagButton:OnEnter()
  local bag = self:GetID()
  local mainFrame = self:GetParent()

  GameTooltip:SetOwner(self, "ANCHOR_LEFT");
  GameTooltip:ClearLines();
  if bag == BANK_CONTAINER then
    GameTooltip:SetText(L["The Bank"], 1.0, 1.0, 1.0)
    GameTooltip:Show()
    return
  elseif bag == BACKPACK_CONTAINER then
    GameTooltip:SetText(BACKPACK_TOOLTIP, 1.0, 1.0, 1.0)
    GameTooltip:Show()
    return
  elseif bag == REAGENTBANK_CONTAINER then
    if TBag:IsReagentBankUnlocked(mainFrame.playerid) then
      GameTooltip:SetText(REAGENT_BANK, 1.0, 1.0, 1.0);
    else
      GameTooltip:SetText(L["Purchasable Reagent Bank"], 1.0, 1.0, 1.0)
      if mainFrame.atbank == 1 then
        SetTooltipMoney(GameTooltip, GetReagentBankCost())
      end
    end
    GameTooltip:Show()
    return
  elseif mainFrame.playerid == TBag.PLAYERID and
    GameTooltip:SetInventoryItem("player", ContainerIDToInventoryID(bag)) then
    GameTooltip:Show()
    return
  else
    local itemlink = TBag:GetPlayerBagCfg(mainFrame.playerid, bag, TBag.I_ITEMLINK)
    if (itemlink and itemlink ~= "") then
      local level = TBag:GetPlayerInfo(mainFrame.playerid,TBag.G_BASIC)[TBag.S_LEVEL] or
                    UnitLevel("player")
      itemlink = itemlink..":"..level
      GameTooltip:SetHyperlink(itemlink)
      GameTooltip:Show()
      return
    end
  end

  -- Empty bag slots
  if TBag:Member(TBag.Bnk_Bags,bag) then
    local numSlots = TBag:GetNumBankSlots(mainFrame.playerid)

    if bag <= numSlots + 4 then
      SetItemButtonTextureVertexColor(self, 1,0, 1.0, 1.0, 1.0)
      GameTooltip:AddLine(BANK_BAG, 1.0, 1.0, 1.0)
    else
      SetItemButtonTextureVertexColor(self, 1,0, 0.1, 0.1, 1.0)
      GameTooltip:AddLine(BANK_BAG_PURCHASE, 1.0, 1.0, 1.0)
      if mainFrame.atbank == 1 then
        SetTooltipMoney(GameTooltip, GetBankSlotCost(numSlots))
      end
    end
  else
    GameTooltip:SetText(EQUIP_CONTAINER, 1.0, 1.0, 1.0)
  end
  GameTooltip:Show()
end

function BagButton:OnLeave()
  if GameTooltip:IsOwned(self) then
    GameTooltip:Hide()
    ResetCursor()
  end
end

function BagButton:OnClick(button,down,drag)
  local bag = self:GetID()
  local mainFrame = self:GetParent()
  local isLive = TBag:IsLive(mainFrame)
  local isBagShown = mainFrame.cfg["show_Bag"..bag] == 1
  local itm = TBag:GetPlayerBag(mainFrame.playerid,bag)

  -- Unpurchased Reagent Bank
  if (bag == REAGENTBANK_CONTAINER and not TBag:IsReagentBankUnlocked(mainFrame.playerid)) then
    self:SetChecked(not self:GetChecked())
    if mainFrame.atbank == 1 then
      PlaySound(852)
      StaticPopup_Show("CONFIRM_BUY_REAGENTBANK_TAB")
      mainFrame:UpdateBagGfx()
    end
    return
  end

  -- Unpurchased bag slot
  local numSlots = TBag:GetNumBankSlots(mainFrame.playerid)
  if bag > numSlots + 4 then
    self:SetChecked(not self:GetChecked())
    -- Needed to make the CONFIRM_BUY_BANK_SLOT popup work right
    BankFrame.nextSlotCost = GetBankSlotCost(numSlots)
    if mainFrame.atbank == 1 then
      PlaySound(852)
      StaticPopup_Show("CONFIRM_BUY_BANK_SLOT")
      mainFrame:UpdateBagGfx()
    end
    return
  end

  -- Handle putting items in the bag
  if isLive and CursorHasItem() then
    TBag:PutItemInBag(bag)
    if not drag then
      -- If this is a drag receive then don't toggle the check.
      self:SetChecked(not self:GetChecked())
    end
    return
  end

  -- Empty bag slot do nothing, has to follow the above to allow equiping
  -- of bags.
  if bag > 0 and (not itm[TBag.I_ITEMLINK] or itm[TBag.I_ITEMLINK] == "") then
    self:SetChecked(not self:GetChecked())
    return
  end

  -- Handle linking of the bags
  if IsModifiedClick("CHATLINK") then
    local hyperlink = TBag:MakeHyperlink(itm[TBag.I_ITEMLINK], itm[TBag.I_NAME],
                                         itm[TBag.I_RARITY],
                                         TBag:GetPlayerInfo(mainFrame.playerid,
                                         TBag.G_BASIC)[TBag.S_LEVEL] or UnitLevel("player"),
                                         itm[TBag.I_LINKSUFFIX])
    if hyperlink and ChatEdit_InsertLink(hyperlink) then
      self:SetChecked(not self:GetChecked())
      return
    end
  end

  if not isBagShown then
    mainFrame:UpdateWindow(TBag.REQ_MUST)
  end
  TBag:UpdateButtonHighlights()
end

function BagButton:OnDrag()
  local bag = self:GetID()
  if bag <= 0 then return end
  local mainFrame = self:GetParent()
  local isLive = TBag:IsLive(mainFrame)

  if not isLive then return end
  PickupBagFromSlot(ContainerIDToInventoryID(bag))
end

-- Used for the ItemAnim subframe to trigger the animation
-- for a received item.  Have to dulicate the Blizzard
-- implementation since we uniformly use bag ids and
-- they mix and match bag ids with inventory ids.
function BagButton:ItemAnimOnEvent(event, invid, texture)
  if event == "ITEM_PUSH" then
    local bag = self:GetParent():GetID()
    local id
    if bag > 0 then
      id = ContainerIDToInventoryID(bag)
    else
      id = bag
    end

    if id == invid then
      self:ReplaceIconTexture(texture)
      self:SetSequence(0)
      self:SetSequenceTime(0,0)
      self:Show()
    end
  end
end

TBag.ColumnsButton = {}
local ColumnsButton = TBag.ColumnsButton

function ColumnsButton:OnLoad()
  local name = self:GetName()
  local offset = 24

  if name:match("ColumnsAdd") then
    self:SetText(L["<++>"])
  else
    self:SetText(L[">--<"])
    offset = offset * -1
  end
  self:SetPoint("CENTER",self:GetParent(),"CENTER",offset,0)
end

function ColumnsButton:OnClick(button, down)
  local mainFrame = self:GetParent()

  PlaySound(856)
  if self:GetText() == L["<++>"] then
    mainFrame:IncreaseColumns()
  else
    mainFrame:DecreaseColumns()
  end
end

function ColumnsButton:OnEnter()
  local normal, newbie

  if self:GetText() == L["<++>"] then
    normal = L["Increase Window Size"]
    newbie = L["Increase the number of columns displayed"]
  else
    normal = L["Decrease Window Size"]
    newbie = L["Decrease the number of columns displayed"]
  end

  GameTooltip:SetOwner(self, "ANCHOR_LEFT")
  GameTooltip_AddNewbieTip(self, normal, 1.0, 1.0, 1.0, newbie)
end

function ColumnsButton:OnLeave()
  GameTooltip:Hide()
  ResetCursor()
end
