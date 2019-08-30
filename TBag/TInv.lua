local _G = getfenv(0)
local TBag = _G.TBag
TBag.Inv = {}
local Inv = TBag.Inv

-- Localization Support
local L = TBag.LOCALE;

BINDING_NAME_TINV_TOGGLE = L["Toggle Inventory Window"];

-- Constants
TINV_DEBUGMESSAGES = 0;   -- 0 = off, 1 = on
TINV_SHOWITEMDEBUGINFO = 0;
local TINV_WIPECONFIGONLOAD = 0;  -- for debugging, test it out on a new config every load


------------------------

function Inv:CalcButtonSize(newsize, pad)
  -- constants
  self.BF_X_PAD = pad;
  self.BF_Y_PAD = pad;
  self.BF_WIDTH = newsize;
  self.BF_HEIGHT = newsize;
  self.BF_PADWIDTH = self.BF_WIDTH + (self.BF_X_PAD*2);
  self.BF_PADHEIGHT = self.BF_HEIGHT + (self.BF_Y_PAD*2);
  self.BGF_WIDTH = self.BF_WIDTH * 1.6 + (self.BF_X_PAD*2);
  self.BGF_HEIGHT = self.BF_HEIGHT * 1.6 + (self.BF_Y_PAD*2);

  -- Always ensure a visually appealing fit
  self.BGF_WIDTH = TBag:MakeEven(self.BGF_WIDTH, self.BF_WIDTH);
  self.BGF_HEIGHT = TBag:MakeEven(self.BGF_HEIGHT, self.BF_HEIGHT);
end

function Inv:SetDefPos(cfg, reset)
  TBag:SetDef(cfg, "frameLEFT", UIParent:GetRight() * UIParent:GetScale() * 0.73, reset, TBag.NumFunc);
  TBag:SetDef(cfg, "frameRIGHT", UIParent:GetRight() * UIParent:GetScale() * 0.92, reset, TBag.NumFunc);
  TBag:SetDef(cfg, "frameTOP", UIParent:GetTop() * UIParent:GetScale() * 0.83, reset, TBag.NumFunc);
  TBag:SetDef(cfg, "frameBOTTOM", UIParent:GetTop() * UIParent:GetScale() * 0.232, reset, TBag.NumFunc);
  TBag:SetDef(cfg, "frameXRelativeTo", "LEFT", reset, TBag.StrFunc, {"RIGHT","LEFT"} );
  TBag:SetDef(cfg, "frameYRelativeTo", "BOTTOM", reset, TBag.StrFunc, {"TOP","BOTTOM"} );
end

-- set reset to 1 to restore all default values
function Inv:InitDefVals(reset)
  local i, key, value;
  local cfg = self.cfg;

  TBag:InitDefVals(cfg, self.bags, 0, reset);

  TBag:SetDef(cfg, "maxColumns", 11, reset, TBag.NumFunc, TBag.NUMCOL_MIN,TBag.NUMCOL_MAX);

  TBag:SetDef(cfg, "alt_pickup", 1, reset, TBag.NumFunc, 0, 1);
  TBag:SetDef(cfg, "alt_panel", 1, reset, TBag.NumFunc, 0, 1);

  TBag:SetDef(cfg, "show_keyring_empty_slots", 0, reset, TBag.NumFunc, 0, 1);

  -- Colors
  TBag:SetColor(cfg, "bkgr_"..TBag.MAIN_BAR, 0.0, 0.2, 0.4, 0.4, reset);
  TBag:SetColor(cfg, "brdr_"..TBag.MAIN_BAR, 0.2, 0.2, 1.0, 0.3, reset);
  for i = 1, TBag.BAR_MAX do
    TBag:SetColor(cfg, "bkgr_"..i, 0.0, 0.2, 0.4, 0.4, reset);
    TBag:SetColor(cfg, "brdr_"..i, 0.2, 0.2, 1.0, 0.3, reset);
  end
  TBag:SetDefColors(cfg, reset);

  self:SetDefPos(cfg, reset);

  TBag:SetDef(cfg, "show_searchbox", 1, reset, TBag.NumFunc, 0, 1);
  TBag:SetDef(cfg, "show_bankbutton", 1, reset, TBag.NumFunc, 0, 1);

end

function Inv:SetPlayer(playerid)
   -- An ugly hack to get around the fact that we can't hook the
   -- OnClick for the ContainerFrameItemButton.  The Blizzard
   -- code uses the id of the frame to figure out what to pickup.
   -- When we are showing another character's inventory we set
   -- our bag frames id's to 100 to stop Blizzard's code from
   -- actually doing anything.
   if (playerid ~= TBag.PLAYERID) then
     for _, bag in ipairs(self.bags) do
       _G[TBag:GetDummyBagFrameName(bag)]:SetID(100);
     end
   else
     for _, bag in ipairs(self.bags) do
       _G[TBag:GetDummyBagFrameName(bag)]:SetID(bag);
     end
   end
   if self.playerid ~=  playerid then
     self.CACHE_REQ = TBag.REQ_MUST
   end
   self.playerid = playerid;
end



-- Set reset = 1 to restore default values
function Inv:init(reset)
  if not Inv.metatabledone then
    setmetatable(TBag.MainFrame,getmetatable(TInvFrame))
    setmetatable(TBag.Inv,{__index=TBag.MainFrame})
    setmetatable(TInvFrame,{__index=TBag.Inv})
    Inv.metatabledone = true
  end
  self = TInvFrame
  self:SetUserPlaced(false) -- remove us from layout-cache

  -- View switching
  self.playerid  = "";
  self.bags = TBag.Inv_Bags

  self.CACHE_REQ = TBag.REQ_NONE;

  self.cfg  = nil;
  self.BARITM = {};
  self.hilight_new = 0;
  self.edit_mode = 0;
  self.edit_hilight = "";   -- when editmode is 1, which items do you want to hilight
  self.edit_selected = "";  -- when editmode is 1, this is the class of item you clicked on
  self.RightClickMenu_mode = "";
  self.RightClickMenu_opts = {};
  self.RightClickMenu = TInvFrame_RightClickMenu

  self.BC_LIST = {};  -- Bar to Class conversion

  self.BF_X_PAD = 1;
  self.BF_Y_PAD = 1;
  self.BF_WIDTH = 34;
  self.BF_HEIGHT = 34;
  self.BF_PADWIDTH = 36;
  self.BF_PADHEIGHT = 36;
  self.BGF_WIDTH = 38;
  self.BGF_HEIGHT = 38;


  TBag:Init();
  self.cfg = TBagCfg["Inv"];
  local cfg = self.cfg

  if ( TINV_WIPECONFIGONLOAD == 1 ) then
    cfg = {};
  end

  self:SetPlayer(TBag.PLAYERID);

  -- Make all the frames
  for _, bag in ipairs(self.bags) do
    TBag:CreateDummyBag(bag, "TBag_ItemButtonTemplate");
  end

  TBag:CreateFrame("Frame", "TInvFrame_bar_", TInvFrame,
    "TBag_BarFrameTemplate", TBag.BAR_MAX, "");
  TBag:CreateFrame("Button", "TInvFrame_BarButton_", TInvFrame,
    "TBag_BarButtonTemplate", TBag.BAR_MAX, "");

  -- register slash command
  SlashCmdList["TINV"] = TInv_cmd;
  SLASH_TINV1 = "/tinv";
  SLASH_TINV2 = "/tbag";

  -- load default values
  self:InitDefVals(reset);

  self:CalcButtonSize(cfg["frameButtonSize"], cfg["framePad"]);

  for _, bag in ipairs(self.bags) do
    TBag:GetBagFrame(bag):SetScale(0.7);
  end

  TInv_SearchBox:SetMaxLetters(25);

  -- setup hooks
  TBag.Hooks.Register(TBag.Hooks.UNREGISTER);
  TBag.Hooks.Register(TBag.Hooks.REGISTER);

  if (cfg["moveLock"] == 0) then
    TInvLockNorm:SetTexture("Interface\\AddOns\\TBag\\images\\LockButton-Locked-Up");
    TInvLockPush:SetTexture("Interface\\AddOns\\TBag\\images\\LockButton-Locked-Down");
  else
    TInvLockNorm:SetTexture("Interface\\AddOns\\TBag\\images\\LockButton-Unlocked-Up");
    TInvLockPush:SetTexture("Interface\\AddOns\\TBag\\images\\LockButton-Unlocked-Down");
  end


  if (cfg["show_bagbuttons"] == 0) then
    TInvacterBag0Slot:Hide();
    TInvacterBag1Slot:Hide();
    TInvacterBag2Slot:Hide();
    TInvacterBag3Slot:Hide();
    TInvMenuBarBackpackButton:Hide();
    TInvingButton:Hide();
  end
  if (cfg["show_searchbox"] == 0) then
    TInv_SearchBox:Hide();
  end
  if (cfg["show_userdropdown"] == 0) then
    TInv_UserDropdown:Hide();
  end
  if (cfg["show_reloadbutton"] == 0) then
    TInv_Button_Reload:Hide();
  end
  if (cfg["show_bankbutton"] == 0) then
    TInv_Button_ShowBank:Hide();
  end
  if (cfg["show_editbutton"] == 0) then
    TInv_Button_ChangeEditMode:Hide();
  end
  if (cfg["show_editbutton"] == 0) then
    TInv_Button_ChangeEditMode:Hide();
  end
  if (cfg["show_hilightbutton"] == 0) then
    TInv_Button_HighlightToggle:Hide();
  end
  if (cfg["show_lockbutton"] == 0) then
    TInv_Button_MoveLockToggle:Hide();
  end
  if (cfg["show_closebutton"] == 0) then
    TInv_Button_Close:Hide();
  end
  if (cfg["show_total"] == 0) then
    TInvFrame_Total:Hide();
  end
  if (cfg["show_money"] == 0) then
    TInvFrame_MoneyFrame:Hide();
  end
  if (cfg["show_tokens"] == 0) then
    TInvFrame_TokenFrame:Hide();
  end

  TBag:BuildBarClassList(self.BC_LIST, cfg);

  if TInvItm[self.playerid] then
    TBag.CurInvItm = TBag:CopyTable(TInvItm[self.playerid])
  end
  if TBnkItm[self.playerid] then
    TBag.CurBnkItm = TBag:CopyTable(TBnkItm[self.playerid])
  end

  -- Force update item cache.
  TBag:ClearItmCache(TInvItm[self.playerid], self.bags);
  TBag:UpdateItmCache(cfg, self.playerid, TInvItm[self.playerid], self.bags);

  self.BARITM = TBag:SortItmCache(cfg,
    self.playerid, TInvItm[self.playerid], self.BARITM, self.bags);
  TBag:LayoutWindow(self)
end

function Inv:UpdateBagGfx()
  local bag;
  local totalfree = 0;
  local totalsize = 0;
  local cfg = self.cfg
  for _, bag in ipairs(self.bags) do
    local free, size = TBag:UpdateSlots(self.playerid, bag, cfg["show_bag_sizes"]);
    totalfree = totalfree + free;
    totalsize = totalsize + size;

    -- Update the textures as well
    TBag:GetBagFrameTexture(bag):SetTexture(
        TBag:GetBagTexture(self.playerid, bag));

    TBag:UpdateBagColors(bag);
  end
  TBag:SetFreeStr(TInvFrame_TotalText, totalfree, totalsize, cfg["show_bag_sizes"]);
end

function Inv.Button_HighlightToggle_OnClick(self)
  PlaySound(856);
  if (TBag.SrchText) then
    TBag:ClearSearch();
    if (GameTooltip:GetOwner() == TInv_Button_HighlightToggle) then
      if (TInvFrame.highlight_new == 1) then
        GameTooltip_AddNewbieTip(self, L["Normal"], 1.0, 1.0, 1.0,
                                 L["Stop highlighting new items."]);
      else
        GameTooltip_AddNewbieTip(self, L["Highlight New"], 1.0, 1.0, 1.0,
                                 L["Highlight items marked as new."]);
      end
    end
    return;
  elseif (TInvFrame.hilight_new == 0) then
    TInvFrame.hilight_new = 1;
    if (GameTooltip:GetOwner() == TInv_Button_HighlightToggle) then
      GameTooltip_AddNewbieTip(self, L["Normal"], 1.0, 1.0, 1.0,
                               L["Stop highlighting new items."]);
    end
  else
    TInvFrame.hilight_new = 0;
    if (GameTooltip:GetOwner() == TInv_Button_HighlightToggle) then
      GameTooltip_AddNewbieTip(self, L["Highlight New"], 1.0, 1.0, 1.0,
                               L["Highlight items marked as new."]);
    end
  end
  TInvFrame:UpdateWindow();
end

function Inv.Button_ChangeEditMode_OnClick()
  PlaySound(856);
  if (TInvFrame.edit_mode == 0) then
    TInvFrame.edit_mode = 1;
  else
    TInvFrame.edit_mode = 0;
  end
  -- resort will force a window redraw
  TInvFrame:UpdateWindow(TBag.REQ_MUST);
end

function Inv.Button_Reload_OnClick()
  -- Never clear another player's cache
  if (TInvFrame.playerid == TBag.PLAYERID) then
    TBag:ClearItmCache(TInvItm[TInvFrame.playerid], TInvFrame.bags);
    TBag:ClearStackSkip(TInvFrame.bags);
    TBag:ClearCompSkip(TInvFrame.bags);

    -- Send a message to restack
    if (TInvFrame.cfg["stack_resort"] == 1) then
      TInvFrame.cfg["stack_once"] = 1;
    end
  end

  TInvFrame:UpdateWindow(TBag.REQ_MUST);
  TBag:PrintDEBUG("TInv reloaded.");
end

function Inv.Button_ShowBank_OnClick()
  TBnkFrame:Toggle()
end

function Inv.Button_MoveLockToggle_OnClick(self)
  PlaySound(856);
  if (TInvFrame.cfg["moveLock"] == 0) then
    TInvFrame.cfg["moveLock"] = 1;
    TInvLockNorm:SetTexture("Interface\\AddOns\\TBag\\images\\LockButton-Unlocked-Up");
    TInvLockPush:SetTexture("Interface\\AddOns\\TBag\\images\\LockButton-Unlocked-Down");
    if (GameTooltip:GetOwner() == TInv_Button_MoveLockToggle) then
      GameTooltip_AddNewbieTip(self, L["Lock Window"], 1.0, 1.0, 1.0,
                               L["Prevent window from being moved by dragging it."]);
    end
  else
    TInvFrame.cfg["moveLock"] = 0;
    TInvLockNorm:SetTexture("Interface\\AddOns\\TBag\\images\\LockButton-Locked-Up");
    TInvLockPush:SetTexture("Interface\\AddOns\\TBag\\images\\LockButton-Locked-Down");
    if (GameTooltip:GetOwner() == TInv_Button_MoveLockToggle) then
      GameTooltip_AddNewbieTip(self, L["Unlock Window"], 1.0, 1.0, 1.0,
                               L["Allow window to be moved by dragging it."]);
    end
  end
end

function Inv.BagSlotButton_OnEnter(self)
  local bag = self:GetID() - 19;
  local itemlink = TBag:GetPlayerBagCfg(TInvFrame.playerid, bag, TBag.I_ITEMLINK);

  GameTooltip:SetOwner(self, "ANCHOR_LEFT");
  GameTooltip:ClearLines();

  if (itemlink and itemlink ~= "") then
    GameTooltip:SetHyperlink(itemlink);
  else
    GameTooltip:AddLine(L["Equip Container"], 1,1,1);
  end

  GameTooltip:Show();
end

function Inv:SetTopLeftButton_Anchors()
  local buttons = {
    "TInv_Button_HighlightToggle",
    "TInv_Button_ChangeEditMode",
    "TInv_Button_ShowBank",
    "TInv_Button_Reload",
  };
  local button_left = nil;

  -- Handle user dropdown list separately...
  local dropdown = TInv_UserDropdown;
  if (dropdown and dropdown:IsVisible()) then
    dropdown:ClearAllPoints();
    dropdown:SetPoint("TOPLEFT",TInvFrame,"TOPLEFT",-10,-5);
    button_left = dropdown;
  end

  for _,button_name in ipairs(buttons) do
    button = _G[button_name];
    if (button) then
      button:ClearAllPoints();
      if (button_left) then
        if (button_left == dropdown) then
          -- First button after dropdown
          button:SetPoint("TOPLEFT",button_left,"TOPRIGHT",15,-3);
        else
          -- button following another button
          button:SetPoint("TOPLEFT",button_left,"TOPRIGHT",2,0);
        end
      else
        -- First button if dropdown is hidden
        button:SetPoint("TOPLEFT",TInvFrame,"TOPLEFT",9,-8);
      end
      if (button:IsVisible()) then
        button_left = button;
      end
    end
  end
end

function Inv:SetTopRightButton_Anchors()
  local buttons = {
    "TInv_Button_Close",
    "TInv_Button_MoveLockToggle",
  }
  local button_right = nil;

  for _,button_name in ipairs(buttons) do
    local button = _G[button_name];
    if (button) then
      if (button_right) then
        button:SetPoint("TOPRIGHT",button_right,"TOPLEFT",10,0);
      else
        button:SetPoint("TOPRIGHT",TInvFrame,"TOPRIGHT",0,0);
      end
      if (button:IsVisible()) then
        button_right = button;
      end
    end
  end
end

function Inv:SetBottomLeftButton_Anchors()
  local buttons = {
    "TInvFrame_Total",
    "TInvacterBag3Slot",
  }
  local button_left = nil;

  -- Handle search box separate.
  local search = TInv_SearchBox;
  if (search and search:IsVisible()) then
    local y = 4;
    if (TInvFrame.edit_mode == 1) then
      y = y + 30;
    end
    search:ClearAllPoints();
    search:SetPoint("BOTTOMLEFT",TInvFrame,"BOTTOMLEFT",10,y);
    button_left = search;
  end

  for _,button_name in ipairs(buttons) do
    button = _G[button_name];
    if (button) then
      button:ClearAllPoints();
      if (button_left) then
        if (button_left == search) then
          -- First button after search
          button:SetPoint("BOTTOMLEFT",button_left,"TOPLEFT",0,4);
        else
          -- button following another button
          button:SetPoint("BOTTOMLEFT",button_left,"BOTTOMRIGHT",3,-1);
        end
      else
        -- First button if dropdown is hidden
        local y = 12;
        if (TInvFrame.edit_mode == 1) then
          y = y + 30;
        end
        button:SetPoint("BOTTOMLEFT",TInvFrame,"BOTTOMLEFT",10,y);
      end
      if (button:IsVisible()) then
        button_left = button;
      end
    end
  end

end

function Inv:SetBottomRightButton_Anchors()
  local buttons = {
    "TInvFrame_MoneyFrame",
    "TInvFrame_TokenFrame",
  }
  local button_right = nil

  for _, button_name in ipairs(buttons) do
    button = _G[button_name]
    if button then
      button:ClearAllPoints()
      if button_right then
        button:SetPoint("BOTTOMRIGHT",button_right,"TOPRIGHT",0,-5);
      else
        local y = 5
        if TInvFrame.edit_mode == 1 then
          y = y + 30
        end
        button:SetPoint("BOTTOMRIGHT",TInvFrame,"BOTTOMRIGHT",5,y)
      end
      if button:IsVisible() then
        button_right = button
      end
    end
  end
end

function Inv:SetButton_Anchors()
  self:SetTopLeftButton_Anchors();
  self:SetTopRightButton_Anchors();
  self:SetBottomLeftButton_Anchors();
  self:SetBottomRightButton_Anchors();
  TBag:LayoutWindow(self)
end

function Inv.Toggle_CloseButton()
  if (TInvFrame.cfg["show_closebutton"] == 1) then
    TInvFrame.cfg["show_closebutton"] = 0;
    TInv_Button_Close:Hide();
    TInvFrame:SetButton_Anchors();
  else
    TInvFrame.cfg["show_closebutton"] = 1;
    TInv_Button_Close:Show();
    TInvFrame:SetButton_Anchors();
  end
end

function Inv.Toggle_LockButton()
  if (TInvFrame.cfg["show_lockbutton"] == 1) then
    TInvFrame.cfg["show_lockbutton"] = 0;
    TInv_Button_MoveLockToggle:Hide();
    TInvFrame:SetButton_Anchors();
  else
    TInvFrame.cfg["show_lockbutton"] = 1;
    TInv_Button_MoveLockToggle:Show();
    TInvFrame:SetButton_Anchors();
  end
end

function Inv.Toggle_HighlightButton()
  if (TInvFrame.cfg["show_hilightbutton"] == 1) then
    TInvFrame.cfg["show_hilightbutton"] = 0;
    TInv_Button_HighlightToggle:Hide();
    TInvFrame:SetButton_Anchors();
  else
    TInvFrame.cfg["show_hilightbutton"] = 1;
    TInv_Button_HighlightToggle:Show();
    TInvFrame:SetButton_Anchors();
  end
end

function Inv.Toggle_EditButton()
  if (TInvFrame.cfg["show_editbutton"] == 1) then
    TInvFrame.cfg["show_editbutton"] = 0;
    TInv_Button_ChangeEditMode:Hide();
    TInvFrame:SetButton_Anchors();
  else
    TInvFrame.cfg["show_editbutton"] = 1;
    TInv_Button_ChangeEditMode:Show();
    TInvFrame:SetButton_Anchors();
  end
end

function Inv.Toggle_BankButton()
  if (TInvFrame.cfg["show_bankbutton"] == 1) then
    TInvFrame.cfg["show_bankbutton"] = 0;
    TInv_Button_ShowBank:Hide();
    TInvFrame:SetButton_Anchors();
  else
    TInvFrame.cfg["show_bankbutton"] = 1;
    TInv_Button_ShowBank:Show();
    TInvFrame:SetButton_Anchors();
  end
end

function Inv.Toggle_ReloadButton()
  if (TInvFrame.cfg["show_reloadbutton"] == 1) then
    TInvFrame.cfg["show_reloadbutton"] = 0;
    TInv_Button_Reload:Hide();
    TInvFrame:SetButton_Anchors();
  else
    TInvFrame.cfg["show_reloadbutton"] = 1;
    TInv_Button_Reload:Show();
    TInvFrame:SetButton_Anchors();
  end
end

function Inv.Toggle_SearchBox()
  if (TInvFrame.cfg["show_searchbox"] == 1) then
    TInvFrame.cfg["show_searchbox"] = 0;
    TInv_SearchBox:Hide();
    TInvFrame:SetButton_Anchors();
  else
    TInvFrame.cfg["show_searchbox"] = 1;
    TInv_SearchBox:Show();
    TInvFrame:SetButton_Anchors();
  end
end

function Inv.Toggle_UserDropdown()
  if (TInvFrame.cfg["show_userdropdown"] == 1) then
    TInvFrame.cfg["show_userdropdown"] = 0;
    TInv_UserDropdown:Hide();
    TInvFrame:SetButton_Anchors();
  else
    TInvFrame.cfg["show_userdropdown"] = 1;
    TInv_UserDropdown:Show();
    TInvFrame:SetButton_Anchors();
  end
end

function Inv.Toggle_Money()
  if (TInvFrame.cfg["show_money"] == 1) then
    TInvFrame.cfg["show_money"] = 0;
    TInvFrame_MoneyFrame:Hide();
    TInvFrame:SetButton_Anchors();
  else
    TInvFrame.cfg["show_money"] = 1;
    TInvFrame_MoneyFrame:Show();
    TInvFrame:SetButton_Anchors();
  end
end

function Inv.Toggle_Token()
  if (TInvFrame.cfg["show_tokens"] == 1) then
    TInvFrame.cfg["show_tokens"] = 0;
    TInvFrame_TokenFrame:Hide();
    TInvFrame:SetButton_Anchors();
  else
    TInvFrame.cfg["show_tokens"] = 1;
    TInvFrame_TokenFrame:Show();
    TInvFrame:SetButton_Anchors();
  end
end

function Inv.Toggle_BagSlotButtons()
  if (TInvFrame.cfg["show_bagbuttons"] == 1) then
    TInvFrame.cfg["show_bagbuttons"] = 0;
    TInvacterBag0Slot:Hide();
    TInvacterBag1Slot:Hide();
    TInvacterBag2Slot:Hide();
    TInvacterBag3Slot:Hide();
    TInvMenuBarBackpackButton:Hide();
    TInvingButton:Hide();
    TInvFrame:SetButton_Anchors();
  else
    TInvFrame.cfg["show_bagbuttons"] = 1;
    TInvacterBag0Slot:Show();
    TInvacterBag1Slot:Show();
    TInvacterBag2Slot:Show();
    TInvacterBag3Slot:Show();
    TInvMenuBarBackpackButton:Show();
    TInvingButton:Show();
    TInvFrame:SetButton_Anchors();
   end
end

function Inv.Toggle_Total()
  if (TInvFrame.cfg["show_total"] == 1) then
    TInvFrame.cfg["show_total"] = 0;
    TInvFrame_Total:Hide();
    TInvFrame:SetButton_Anchors();
  else
    TInvFrame.cfg["show_total"] = 1;
    TInvFrame_Total:Show();
    TInvFrame:SetButton_Anchors();
  end
end

function Inv.RightClick_DeleteItemOverride(self)
  local bag, slot, itm;
  local this = self or _G.this

  bag = this.value[TBag.I_BAG];
  slot = this.value[TBag.I_SLOT];

  if ( (bag ~= nil) and (slot ~= nil) ) then
    itm = TInvItm[TInvFrame.playerid][bag][slot];

    if (itm[TBag.I_ITEMLINK] ~= nil) then
      local id = TBag:GetItemID(itm[TBag.I_ITEMLINK]);
      if TInvFrame.cfg["item_overrides"][id] ~= nil then
        TInvFrame.cfg["item_overrides"][id] = nil;
        HideDropDownMenu(1);

        -- resort will force a window redraw as well
        TInvFrame:UpdateWindow(TBag.REQ_MUST);
      end
    end
  end
end

function Inv.RightClick_SetItemOverride(self)
  local bag, slot, itm, new_barclass;
  local this = self or _G.this

  bag = this.value[TBag.I_BAG];
  slot = this.value[TBag.I_SLOT];
  new_barclass = this.value["barclass"];

  if ( (bag ~= nil) and (slot ~= nil) and (new_barclass ~= nil) ) then
    itm = TInvItm[TInvFrame.playerid][bag][slot];

    TInvFrame.cfg["item_overrides"][TBag:GetItemID(itm[TBag.I_ITEMLINK])] = new_barclass;
    HideDropDownMenu(2);
    HideDropDownMenu(1);
    TInvFrame:UpdateWindow(TBag.REQ_MUST);
  end
end

function Inv.RightClickMenu_populate(self, level)
  local bar, bag, slot;
  local info, itm, id, barclass, tmp, checked, i;
  local key, value, key2, value2;


  -------------------------------------------------------------------------------------------------
  ------------------------------- ITEM CONTEXT MENU -----------------------------------------------
  -------------------------------------------------------------------------------------------------
  if (TInvFrame.RightClickMenu_mode == "item") then
    -- we have a right click on a button

    bar = TInvFrame.RightClickMenu_opts[TBag.I_BAR];
    bag = TInvFrame.RightClickMenu_opts[TBag.I_BAG];
    slot = TInvFrame.RightClickMenu_opts[TBag.I_SLOT];
    itm = TInvItm[TInvFrame.playerid][bag][slot];
    id = TBag:GetItemID(itm[TBag.I_ITEMLINK]);

    if (level == 1) then
      -- top level of menu

      info = { ["text"] = itm[TBag.I_NAME], ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
      UIDropDownMenu_AddButton(info, level);

      info = { ["disabled"] = 1 };
      UIDropDownMenu_AddButton(info, level);

      info = { ["text"] = string.format(L["Current Category: %s"],itm[TBag.I_CAT]), ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
      UIDropDownMenu_AddButton(info, level);

      info = { ["disabled"] = 1 };
      UIDropDownMenu_AddButton(info, level);

      info = { ["text"] = L["Assign item to category:"], ["hasArrow"] = 1, ["value"] = "override_placement" };
      if (TInvFrame.cfg["item_overrides"][id] ~= nil) then
        info["checked"] = 1;
      end
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = L["Use default category assignment"],
        ["value"] = { [TBag.I_BAG]=bag, [TBag.I_SLOT]=slot },
        ["func"] = TInvFrame.RightClick_DeleteItemOverride
        };
      if (TInvFrame.cfg["item_overrides"][id] == nil) then
        info["checked"] = 1;
      end
      UIDropDownMenu_AddButton(info, level);

      if (TINV_SHOWITEMDEBUGINFO==1) then
        info = { ["disabled"] = 1 };
        UIDropDownMenu_AddButton(info, level);

        info = { ["text"] = L["Debug Info: "], ["hasArrow"] = 1, ["value"] = "show_debug" };
        UIDropDownMenu_AddButton(info, level);
      end
    elseif (level == 2) then
      if ( UIDROPDOWNMENU_MENU_VALUE == "override_placement" ) then
        for i = 1, TBag.BAR_MAX do
          info = {
            ["text"] = string.format(L["Categories within bar %d"],i);
            ["value"] = { ["opt"]="override_placement_select", [TBag.I_BAG]=bag, [TBag.I_SLOT]=slot, ["select_bar"]=i },
            ["hasArrow"] = 1
            };
          if (
        (TInvFrame.cfg["item_overrides"][id]
        ~= nil) and (TBag:GetCat(TInvFrame.cfg, TInvFrame.cfg["item_overrides"][id]) == i) ) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
        end
      elseif ( UIDROPDOWNMENU_MENU_VALUE == "show_debug" ) then
        for key, value in pairs(itm) do
          if (value == nil) then
            info = { ["text"] = "|cFFFF7FFF"..key.."|r = |cFF007FFFNil|r", ["notClickable"] = 1 };
            UIDropDownMenu_AddButton(info, level);
          else
            if ( (type(value) == "number") or (type(value) == "string") ) then
              info = { ["text"] = "|cFFFF7FFF"..key.."|r = |cFF007FFF"..value.."|r", ["notClickable"] = 1 };
              UIDropDownMenu_AddButton(info, level);
            else
              info = { ["text"] = "|cFFFF7FFF"..key.."|r|cFF338FFF=>Array()|r", ["notClickable"] = 1 };
              UIDropDownMenu_AddButton(info, level);
              for key2, value2 in pairs(value) do
                info = { ["text"] = "  |cFFFF7FFF["..key2.."]|r = |cFF338FFF"..value2.."|r", ["notClickable"] = 1 };
                UIDropDownMenu_AddButton(info, level);
              end
            end
          end
        end
      end
    elseif (level == 3) then
      if ( UIDROPDOWNMENU_MENU_VALUE ~= nil ) then
        if ( UIDROPDOWNMENU_MENU_VALUE["opt"] == "override_placement_select" ) then
          for key,barclass in pairs(TInvFrame.BC_LIST[UIDROPDOWNMENU_MENU_VALUE["select_bar"]]) do
            info = {
              ["text"] = barclass;
              ["value"] = { [TBag.I_BAG]=bag, [TBag.I_SLOT]=slot, ["barclass"]=barclass },
              ["func"] = TInvFrame.RightClick_SetItemOverride
              };
            if (TInvFrame.cfg["item_overrides"][id] == barclass) then
              info["checked"] = 1;
            end
            UIDropDownMenu_AddButton(info, level);
          end
        end
      end
    end

  -------------------------------------------------------------------------------------------------
  ------------------------ SLOT TARGET CONTEXT MENU -----------------------------------------------
  -------------------------------------------------------------------------------------------------
  elseif (TInvFrame.RightClickMenu_mode == "bar") then
    -- right click on a slot
    bar = TInvFrame.RightClickMenu_opts[TBag.I_BAR];

    info = { ["text"] = string.format(L["|c%sBar |r|c%s%s|r"],TBag.C_INST, TBag.C_BAR, bar),
      ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
    UIDropDownMenu_AddButton(info, level);

    info = { ["disabled"] = 1 };
    UIDropDownMenu_AddButton(info, level);

    for key, value in pairs(TInvFrame.BC_LIST[bar]) do
      info = {
        ["text"] = string.format(L["Move: |c%s%s|r"],TBag.C_CAT,value);
        ["value"] = value;
        ["func"] = function(self)
          local this = self or _G.this
          TInvFrame.edit_selected = (this.value);
          TInvFrame.edit_hilight = (this.value);
          TInvFrame:UpdateWindow();
        end
      };
      UIDropDownMenu_AddButton(info, level);
    end

    info = { ["disabled"] = 1 };
    UIDropDownMenu_AddButton(info, level);

    info = { ["text"] = L["Sort Mode:"], ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
    UIDropDownMenu_AddButton(info, level);

    for key, value in pairs({
      [TBag.SORTBY_NONE] = L["No sort"],
      [TBag.SORTBY_NORM] = L["Sort by name"],
      [TBag.SORTBY_REV] = L["Sort last words first"]
      }) do

      if (TBag:GetGrp(TInvFrame.cfg, TBag.G_BAR_SORT, bar) == key) then
        checked = 1;
      else
        checked = nil;
      end

      info = {
        ["text"] = value;
        ["value"] = { [TBag.I_BAR]=bar, ["sortby"]=key };
        ["func"] = function(self)
            local this = self or _G.this
            TBag:SetGrpDef(TInvFrame.cfg, TBag.G_BAR_SORT, this.value[TBag.I_BAR], this.value["sortby"], 1);
            TInvFrame:UpdateWindow(TBag.REQ_MUST);
          end,
        ["checked"] = checked
        };
      UIDropDownMenu_AddButton(info, level);
    end

    info = { ["disabled"] = 1 };
    UIDropDownMenu_AddButton(info, level);

    info = { ["text"] = L["Hide Bar:"], ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
    UIDropDownMenu_AddButton(info, level);

    for key,value in pairs({
      [0] = L["Show items assigned to this bar"],
      [1] = L["Hide items assigned to this bar"]
      }) do

      if (TBag:GetGrp(TInvFrame.cfg, TBag.G_BAR_HIDE, bar) == key) then
        checked = 1;
      else
        checked = nil;
      end

      info = {
        ["text"] = value;
        ["value"] = { [TBag.I_BAR]=bar, ["value"]=key };
        ["func"] = function(self)
          local this = self or _G.this
          TBag:SetGrpDef(TInvFrame.cfg, TBag.G_BAR_HIDE, this.value[TBag.I_BAR], this.value["value"], 1);
          TBnkFrame:UpdateWindow();
      end,
    ["checked"] = checked
    };
      UIDropDownMenu_AddButton(info, level);
    end


    info = { ["disabled"] = 1 };
    UIDropDownMenu_AddButton(info, level);

    info = { ["text"] = L["Highlight new items:"], ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
    UIDropDownMenu_AddButton(info, level);

    for key,value in pairs({
      [0] = L["Don't tag new items"],
      [1] = L["Tag new items"]
      }) do

      if (TBag:GetGrp(TInvFrame.cfg, TBag.G_USE_NEW, bar) == key) then
        checked = 1;
      else
        checked = nil;
      end

      info = {
        ["text"] = value;
        ["value"] = { [TBag.I_BAR]=bar, ["value"]=key };
        ["func"] = function(self)
            local this = self or _G.this
            TBag:SetGrpDef(TInvFrame.cfg, TBag.G_USE_NEW, this.value[TBag.I_BAR], this.value["value"], 1);
            TInvFrame:UpdateWindow(TBag.REQ_MUST);
          end,
        ["checked"] = checked
        };
      UIDropDownMenu_AddButton(info, level);
    end

    info = { ["disabled"] = 1 };
    UIDropDownMenu_AddButton(info, level);

    info = { ["text"] = "Color:", ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
    UIDropDownMenu_AddButton(info, level);

    info = TBag:MakeColorPickerInfo(TInvFrame.cfg, "bkgr_", bar,
        string.format(L["Background Color for Bar %d"],bar), function() TInvFrame:UpdateWindow() end);
    UIDropDownMenu_AddButton(info, level);

    info = TBag:MakeColorPickerInfo(TInvFrame.cfg, "brdr_", bar,
        string.format(L["Border Color for Bar %d"],bar), function() TInvFrame:UpdateWindow() end);
    UIDropDownMenu_AddButton(info, level);

  -------------------------------------------------------------------------------------------------
  ------------------------ MAIN WINDOW CONTEXT MENU -----------------------------------------------
  -------------------------------------------------------------------------------------------------
  elseif (TInvFrame.RightClickMenu_mode == "mainwindow") then
    if (level == 1) then

      info = { ["text"] = string.format(L["TBag v%s"],TBag.VERSION), ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
      UIDropDownMenu_AddButton(info, level);

      info = { ["disabled"] = 1 };
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = L["Select Character"];
        ["value"] = { ["opt"]="select_character" },
        ["hasArrow"] = 1
        };
      UIDropDownMenu_AddButton(info, level);

      info = { ["disabled"] = 1 };
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = L["Edit Mode"],
        ["value"] = nil,
        ["func"] = TInvFrame.Button_ChangeEditMode_OnClick
        };
      if (TInvFrame.edit_mode == 1) then
        info["checked"] = 1;
      end
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = L["Lock window"],
        ["value"] = nil,
        ["func"] = TInvFrame.Button_MoveLockToggle_OnClick
        };
      if (TInvFrame.cfg["moveLock"] == 0) then
        info["checked"] = 1;
      end
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = L["Reload and Sort"],
        ["value"] = nil,
        ["func"] = TInvFrame.Button_Reload_OnClick
        };
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = L["Toggle Bank"],
        ["value"] = nil,
        ["func"] = TInvFrame.Button_ShowBank_OnClick
        };
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = L["Close Inventory"],
        ["value"] = nil,
        ["func"] = Inv.Close
        };
      UIDropDownMenu_AddButton(info, level);


      info = { ["disabled"] = 1 };
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["value"] = nil,
        ["func"] = TInvFrame.Button_HighlightToggle_OnClick
        };
      if (TBag.SrchText) then
        info["text"] = L["Clear Search"];
      else
        info["text"] = L["Highlight New Items"];
        if (TInvFrame.hilight_new == 1) then
          info["checked"] = 1;
        end
      end
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = L["Reset NEW tag"],
        ["value"] = nil,
        ["func"] = function()
            local bag, slot;

            for index, bag in ipairs(TInvFrame.bags) do
              if (TInvFrame.cfg["show_Bag"..bag] == 1) then
                if (table.getn(TInvItm[TInvFrame.playerid][bag]) > 0) then
                  for slot = 1, table.getn(TInvItm[TInvFrame.playerid][bag]) do
                    TBag:ResetNew(TInvItm[TInvFrame.playerid][bag][slot]);
                  end
                end
              end
            end

            TInvFrame:UpdateWindow();
          end
        };
      UIDropDownMenu_AddButton(info, level);


      info = { ["disabled"] = 1 };
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = L["Advanced Configuration"],
        ["value"] = nil,
        ["func"] = function()
            TInv_OptsFrame:Show();
          end
        };
      UIDropDownMenu_AddButton(info, level);

      info = { ["disabled"] = 1 };
      UIDropDownMenu_AddButton(info, level);


      info = {
        ["text"] = L["Set Size"];
        ["value"] = { ["opt"]="set_scale" },
        ["hasArrow"] = 1
        };
      UIDropDownMenu_AddButton(info, level);

      info = { ["disabled"] = 1 };
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = L["Set Colors"];
        ["value"] = { ["opt"]="set_colors" },
        ["hasArrow"] = 1
        };
      UIDropDownMenu_AddButton(info, level);

      info = { ["disabled"] = 1 };
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = L["Anchor"];
        ["value"] = { ["opt"]="anchor" },
        ["hasArrow"] = 1
        };
      UIDropDownMenu_AddButton(info, level);


      info = { ["disabled"] = 1 };
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = L["Hide"];
        ["value"] = { ["opt"]="hide_frames" },
        ["hasArrow"] = 1
        };
      UIDropDownMenu_AddButton(info, level);

      info = { ["disabled"] = 1 };
      UIDropDownMenu_AddButton(info, level);

    elseif (level == 2) then
      if (UIDROPDOWNMENU_MENU_VALUE ~= nil) then
        if (UIDROPDOWNMENU_MENU_VALUE["opt"] == "set_scale") then
          for _, value in ipairs(TBag.A_BUTTONSIZE) do
            info = {
              ["text"] = value.."x"..value;
              ["value"] = value;
              ["func"] = function(self)
                  local this = self or _G.this
                  if ( (type(this.value) == "number") and (this.value >= TBag.N_BUTTON_MIN) ) then
                    TInvFrame.cfg["frameButtonSize"], TInvFrame.cfg["count_font"],
                      TInvFrame.cfg["count_font_x"], TInvFrame.cfg["count_font_y"],
                      TInvFrame.cfg["scale"] = TBag:NicePlacement(this.value);
                      TInvFrame:CalcButtonSize(TInvFrame.cfg["frameButtonSize"], TInvFrame.cfg["framePad"]);
                      TInvFrame:UpdateWindow(TBag.REQ_MUST);
                  end
                end
              };
            if (tonumber(TInvFrame.cfg["frameButtonSize"]*TInvFrame.cfg["scale"] - value)
      < 1.0) and (tonumber(TInvFrame.cfg["frameButtonSize"]*TInvFrame.cfg["scale"] - value)
      > -1.0) then
              info["checked"] = 1;
            end
            UIDropDownMenu_AddButton(info, level);
          end
        elseif (UIDROPDOWNMENU_MENU_VALUE["opt"] == "set_colors") then
          TBag:MakeColorMenu(TInvFrame.cfg, function () TInvFrame:UpdateWindow() end, level, TInvFrame.bags);
        elseif (UIDROPDOWNMENU_MENU_VALUE["opt"] == "anchor") then
          info = {
            ["text"] = L["TOPLEFT"];
            ["func"] = function ()
                         TBag:SetFrameAnchor (TInvFrame,TInvFrame.cfg,"TOP","LEFT")
                       end;
            };
          if (TInvFrame.cfg["frameXRelativeTo"] == "LEFT" and
              TInvFrame.cfg["frameYRelativeTo"] == "TOP") then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["TOPRIGHT"];
            ["func"] = function ()
                         TBag:SetFrameAnchor (TInvFrame,TInvFrame.cfg,"TOP","RIGHT")
                       end;
            };
          if (TInvFrame.cfg["frameXRelativeTo"] == "RIGHT" and
              TInvFrame.cfg["frameYRelativeTo"] == "TOP") then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["BOTTOMLEFT"];
            ["func"] = function ()
                         TBag:SetFrameAnchor (TInvFrame,TInvFrame.cfg,"BOTTOM","LEFT")
                       end;
            };
          if (TInvFrame.cfg["frameXRelativeTo"] == "LEFT" and
              TInvFrame.cfg["frameYRelativeTo"] == "BOTTOM") then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["BOTTOMRIGHT"];
            ["func"] = function ()
                         TBag:SetFrameAnchor (TInvFrame,TInvFrame.cfg,"BOTTOM","RIGHT")
                       end;
            };
          if (TInvFrame.cfg["frameXRelativeTo"] == "RIGHT" and
              TInvFrame.cfg["frameYRelativeTo"] == "BOTTOM") then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
        elseif (UIDROPDOWNMENU_MENU_VALUE["opt"] == "hide_frames") then
          info = {
            ["text"] = L["Hide Player Dropdown"];
            ["func"] = TInvFrame.Toggle_UserDropdown;
            ["keepShownOnClick"] = 1;
            };
          if (TInvFrame.cfg["show_userdropdown"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Highlight Button"];
            ["func"] = TInvFrame.Toggle_HighlightButton;
            ["keepShownOnClick"] = 1;
            };
          if (TInvFrame.cfg["show_hilightbutton"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Edit Button"];
            ["func"] = TInvFrame.Toggle_EditButton;
            ["keepShownOnClick"] = 1;
            };
          if (TInvFrame.cfg["show_editbutton"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Bank Button"];
            ["func"] = TInvFrame.Toggle_BankButton;
            ["keepShownOnClick"] = 1;
            };
          if (TInvFrame.cfg["show_bankbutton"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Re-sort Button"];
            ["func"] = TInvFrame.Toggle_ReloadButton;
            ["keepShownOnClick"] = 1;
            };
          if (TInvFrame.cfg["show_reloadbutton"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Lock Button"];
            ["func"] = TInvFrame.Toggle_LockButton;
            ["keepShownOnClick"] = 1;
            };
          if (TInvFrame.cfg["show_lockbutton"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Close Button"];
            ["func"] = TInvFrame.Toggle_CloseButton;
            ["keepShownOnClick"] = 1;
            };
          if (TInvFrame.cfg["show_closebutton"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Search Box"];
            ["func"] = TInvFrame.Toggle_SearchBox;
            ["keepShownOnClick"] = 1;
            };
          if (TInvFrame.cfg["show_searchbox"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Total"];
            ["func"] = TInvFrame.Toggle_Total;
            ["keepShownOnClick"] = 1;
            };
          if (TInvFrame.cfg["show_total"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Bag Buttons"];
            ["func"] = TInvFrame.Toggle_BagSlotButtons;
            ["keepShownOnClick"] = 1;
            };
          if (TInvFrame.cfg["show_bagbuttons"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Tokens"];
            ["func"] = TInvFrame.Toggle_Token;
            ["keepShownOnClick"] = 1;
            };
          if (TInvFrame.cfg["show_tokens"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Money"];
            ["func"] = TInvFrame.Toggle_Money;
            ["keepShownOnClick"] = 1;
            };
          if (TInvFrame.cfg["show_money"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
        elseif (UIDROPDOWNMENU_MENU_VALUE["opt"] == "select_character") then
          TInvFrame.UserDropdown_Initialize(self, level);
        end
      end
    end
  end
  TBag:FixMenuFrameLevels()
end


-- Main "right click menu"
function Inv:RightClickMenu_OnLoad()
  UIDropDownMenu_Initialize(self, Inv.RightClickMenu_populate, "MENU");
end


Inv.WindowIsUpdating = 0;

function Inv:UpdateWindow(resort_req)
  local frame = TInvFrame;
  local barnum;

  TBag:PrintDEBUG("TInv_UpdateWindow:  WindowIsUpdating="..Inv.WindowIsUpdating );

  if (Inv.WindowIsUpdating == 1) then
    return;
  end
  Inv.WindowIsUpdating = 1;

  if ( not frame:IsVisible() ) then
    Inv.WindowIsUpdating = 0;
    return;
  end

--  UpdateAddOnMemoryUsage();
--  TBag:PrintDEBUG('TInv_UpdateWindow Start Memory = '..tostring(GetAddOnMemoryUsage("TBag")));

  -- Set the overall scale
  self:SetScale(self.cfg["scale"]);

  -- Consume a message from updated craft info
  if (TBagCfg["trades_changed"] == 1) then
    resort_req = TBag.REQ_MUST;
  end
  TBagCfg["trades_changed"] = nil;

  -- Setup stackarr and comparr
  local stackarr = TBag:CreateStackArr();
  local comparr = TBag:CreateCompArr();

  -- SORTING and ITEMCACHE
  if (resort_req == nil) then resort_req = TBag.REQ_NONE; end
  local cache_req = TBag:UpdateItmCache(self.cfg, self.playerid, TInvItm[self.playerid], self.bags,stackarr,comparr);
  if (resort_req == TBag.REQ_PART) then
    resort_req = resort_req + self.CACHE_REQ;
  end
  resort_req = resort_req + cache_req;

  -- Consume a message for bag stacking
  if (self.cfg["stack_once"] == 1) then
    if (self.playerid == TBag.PLAYERID) then
      if TBag:Stack(TBag.STACK_INV, TInvItm[self.playerid], stackarr, comparr) then
        self.cfg["stack_once"] = nil
      end
    end
  end

  if (resort_req >= TBag.REQ_MUST) then
    self.CACHE_REQ = TBag.REQ_NONE
    self.BARITM = TBag:SortItmCache(self.cfg,
      self.playerid, TInvItm[self.playerid], self.BARITM, self.bags);
    TBag:LayoutWindow(self)
  else if (cache_req > self.CACHE_REQ) then
      self.CACHE_REQ = cache_req
    end
  end

  -- Relink the button map
  for _,bag in ipairs(self.bags) do
    for slot = 1, TBag:GetBagMaxItems(bag) do
      TBag.BUTTONS[TBag:GetBagItemButtonName(bag, slot)] = TInvItm[self.playerid][bag][slot]
    end
  end

  -- BAGS, to get bag sizes below
  self:UpdateBagGfx();

  -- Update all the buttons
  for _, bag in ipairs(self.bags) do
    local size = TBag:GetPlayerBagCfg(self.playerid, bag, TBag.I_BAGSIZE);
    if (not size) then size = 0; end
    if (self.cfg["show_Bag"..bag] ~= 1 and not TBag:GetBagFrame(bag):GetChecked()) then
      size = 0;
    end
    for slot = 1, size do
      TBag.ItemButton.Update(_G[TBag:GetBagItemButtonName(bag, slot)])
    end
    for slot = size+1, TBag:GetBagMaxItems(bag) do
      _G[TBag:GetBagItemButtonName(bag, slot)]:Hide();
    end
  end

  -- MONEY
  if (self.cfg["show_money"] == 1) then
    local type = "STATIC"
    if (self.playerid == TBag.PLAYERID) then
      type = "PLAYER"
    end
    MoneyFrame_SetType(TInvFrame_MoneyFrame,type)
    MoneyFrame_Update("TInvFrame_MoneyFrame", TBag:GetMoney(self.playerid));
  end

    frame:ClearAllPoints();
    frame:SetPoint(self.cfg["frameYRelativeTo"]..self.cfg["frameXRelativeTo"],
      "UIParent", "BOTTOMLEFT",
      self.cfg["frame"..self.cfg["frameXRelativeTo"]] / frame:GetScale(),
      self.cfg["frame"..self.cfg["frameYRelativeTo"]] / frame:GetScale());


    TBag:ColorFrame(self.cfg, frame, TBag.MAIN_BAR);

    if (self.edit_mode == 1) then
      TInvFrame_ColumnsAdd:Show();
      TInvFrame_ColumnsDel:Show();
    else
      TInvFrame_ColumnsAdd:Hide();
      TInvFrame_ColumnsDel:Hide();
    end

  self:SetButton_Anchors();

  Inv.WindowIsUpdating = 0;
--  UpdateAddOnMemoryUsage();
--  TBag:PrintDEBUG('TInv_UpdateWindow End Memory = '..tostring(GetAddOnMemoryUsage("TBag")));

end

function Inv.UserDropdown_OnLoad(self)
  UIDropDownMenu_Initialize(self, Inv.UserDropdown_Initialize);
  UIDropDownMenu_SetSelectedValue(self, TInvFrame.playerid);
  self.tooltip = L["You are viewing the selected player's inventory."];
  UIDropDownMenu_SetWidth(self,TBag.USERDD_WIDTH)
  -- UIDropDownMenu_SetWidth actually adds 50 to our width, we really only want
  -- 25 to avoid the control running into our buttons on the right.
  self:SetWidth(TBag.USERDD_WIDTH+25);
--  OptionsFrame_EnableDropDown(self);
end

function Inv.UserDropdown_OnClick(self)
  local this = self or _G.this
  UIDropDownMenu_SetSelectedValue(TInv_UserDropdown, this.value);
  if ( this.value ) then
    TInvFrame:SetPlayer(this.value);
  end
  if ( not TInvFrame.playerid ) then
    TBag:PrintDEBUG("TInv_UserDropdown_OnClick Failed");
    return;
  end
  TBag:PrintDEBUG("Selected Player "..TInvFrame.playerid);

  TInvFrame:UpdateWindow(TBag.REQ_MUST);
end

function Inv.UserDropdown_Initialize(self, level)
  TBag:UserDropdown_Init(Inv.UserDropdown_OnClick,
    TInvItm, TInvFrame.playerid,TBag.REALM,level);
end

