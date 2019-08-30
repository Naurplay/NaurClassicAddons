local _G = getfenv(0)
local TBag = _G.TBag
TBag.Bank = {}
local Bank = TBag.Bank

local BankFrame_Saved = nil;

-- Localization Support
local L = TBag.LOCALE;

BINDING_NAME_TBNK_TOGGLE = L["Toggle Bank Window"];

-- Constants
TBnk_SHOWITEMDEBUGINFO = 0;
local TBnk_WIPECONFIGONLOAD = 0; -- for debugging, test it out on a new config every load


------------------------

function Bank:CalcButtonSize(newsize, pad)
  local k = "button_size_opts";
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

function Bank:SetDefPos(cfg, reset)
  TBag:SetDef(cfg, "frameLEFT", UIParent:GetRight() * UIParent:GetScale() * 0.294, reset, TBag.NumFunc);
  TBag:SetDef(cfg, "frameRIGHT", UIParent:GetRight() * UIParent:GetScale() * 0.684, reset, TBag.NumFunc);
  TBag:SetDef(cfg, "frameTOP", UIParent:GetTop() * UIParent:GetScale() * 0.83, reset, TBag.NumFunc);
  TBag:SetDef(cfg, "frameBOTTOM", UIParent:GetTop() * UIParent:GetScale() * 0.232, reset, TBag.NumFunc);
  TBag:SetDef(cfg, "frameXRelativeTo", "LEFT", reset, TBag.StrFunc, {"RIGHT","LEFT"} );
  TBag:SetDef(cfg, "frameYRelativeTo", "BOTTOM", reset, TBag.StrFunc, {"TOP","BOTTOM"} );
end

function Bank:InitDefVals(reset)
  local i, key, value;
  local cfg = self.cfg;

  TBag:InitDefVals(cfg, self.bags, 4, reset);

  TBag:SetDef(cfg, "maxColumns", 14, reset, TBag.NumFunc, TBag.NUMCOL_MIN,TBag.NUMCOL_MAX);

  TBag:SetDef(cfg, "show_purchase_button", 0, reset, TBag.NumFunc, 0, 1);
  TBag:SetDef(cfg, "show_purchasetoggle", 1, reset, TBag.NumFunc, 0, 1);

  -- Colors
  TBag:SetColor(cfg, "bkgr_"..TBag.MAIN_BAR, 0.3, 0.1, 0.0, 0.4, reset);
  TBag:SetColor(cfg, "brdr_"..TBag.MAIN_BAR, 0.7, 0.1, 0.1, 0.3, reset);
  for i = 1, TBag.BAR_MAX do
    TBag:SetColor(cfg, "bkgr_"..i, 0.3, 0.1, 0.0, 0.4, reset);
    TBag:SetColor(cfg, "brdr_"..i, 0.7, 0.1, 0.1, 0.3, reset);
  end
  TBag:SetDefColors(cfg, reset);

  self:SetDefPos(cfg, reset);

end

function Bank:SetPlayer(playerid)
  if self.playerid ~= playerid then
    self.CACHE_REQ = TBag.REQ_MUST
  end
  self.playerid = playerid;
end

-- Set reset=1 to restore default values
function Bank:init(reset)
  if not Bank.metatabledone then
    setmetatable(TBag.MainFrame, getmetatable(TBnkFrame))
    setmetatable(TBag.Bank,{__index=TBag.MainFrame})
    setmetatable(TBnkFrame,{__index=TBag.Bank})
    Bank.metatabledone = true
  end
  self = TBnkFrame
  self:SetUserPlaced(false) -- remove us from the layout-cache

  -- Bank switching
  self.playerid = "";
  self.atbank = 0;
  self.bags = TBag.Bnk_Bags

  self.CACHE_REQ = TBag.REQ_NONE

  self.cfg = nil;
  self.BARITM = {};
  self.hilight_new = 0;
  self.edit_mode = 0;
  self.edit_hilight = "";         -- when editmode is 1, which items do you want to hilight
  self.edit_selected = "";        -- when editmode is 1, this is the class of item you clicked on
  self.RightClickMenu_mode = "";
  self.RightClickMenu_opts = {};
  self.RightClickMenu = TBnkFrame_RightClickMenu

  self.BC_LIST = {};  -- Bar to Class list

  self.BF_X_PAD = 1;
  self.BF_Y_PAD = 1;
  self.BF_WIDTH = 34;
  self.BF_HEIGHT = 34;
  self.BF_PADWIDTH = 36;
  self.BF_PADHEIGHT = 36;
  self.BGF_WIDTH = 38;
  self.BGF_HEIGHT = 38;


  TBag:Init();

  self.cfg = TBagCfg["Bnk"]
  local cfg = self.cfg
  self.atbank = 0

  if ( TBnk_WIPECONFIGONLOAD == 1 ) then
    cfg = {};
  end

  self:SetPlayer(TBag.PLAYERID);

  -- Make all the frames
  for _, bag in ipairs(self.bags) do
--    if (bag == BANK_CONTAINER) then
--      TBag:CreateDummyBag(bag, "TBnk_BankItemButtonTemplate");
--    else
      TBag:CreateDummyBag(bag, "TBag_ItemButtonTemplate");
--    end
  end

  TBag:CreateFrame("Frame", "TBnkFrame_bar_", TBnkFrame,
    "TBag_BarFrameTemplate", TBag.BAR_MAX, "");
  TBag:CreateFrame("Button", "TBnkFrame_BarButton_", TBnkFrame,
    "TBag_BarButtonTemplate", TBag.BAR_MAX, "");

  -- register slash command
  SlashCmdList["TBnk"] = TBnk_cmd;
  SLASH_TBnk1 = "/tbnk";

  -- load default values
  self:InitDefVals(reset);

  self:CalcButtonSize(cfg["frameButtonSize"], cfg["framePad"]);

  for _, bag in ipairs(self.bags) do
    TBag:GetBagFrame(bag):SetScale(0.7);
  end
  self:InitBagGfx()

  self:SetReplaceBank();

  if (cfg["moveLock"] == 0) then
    TBnkLockNorm:SetTexture("Interface\\AddOns\\TBag\\images\\LockButton-Locked-Up");
    TBnkLockPush:SetTexture("Interface\\AddOns\\TBag\\images\\LockButton-Locked-Down");
  else
    TBnkLockNorm:SetTexture("Interface\\AddOns\\TBag\\images\\LockButton-Unlocked-Up");
    TBnkLockPush:SetTexture("Interface\\AddOns\\TBag\\images\\LockButton-Unlocked-Down");
  end

  if (cfg["show_bagbuttons"] == 0) then
    TBnkFrameBag1:Hide();
    TBnkFrameBag2:Hide();
    TBnkFrameBag3:Hide();
    TBnkFrameBag4:Hide();
    TBnkFrameBag5:Hide();
    TBnkFrameBag6:Hide();
    TBnkFrameBag7:Hide();
    TBnkFrameBagBank:Hide();
    TBnkFrameBagReagent:Hide();
  end
  if (cfg["show_userdropdown"] == 0) then
    TBnk_UserDropdown:Hide();
  end
  if (cfg["show_reloadbutton"] == 0) then
    TBnk_Button_Reload:Hide();
  end
  if (cfg["show_editbutton"] == 0) then
    TBnk_Button_ChangeEditMode:Hide();
  end
  if (cfg["show_hilightbutton"] == 0) then
    TBnk_Button_HighlightToggle:Hide();
  end
  if (cfg["show_lockbutton"] == 0) then
    TBnk_Button_MoveLockToggle:Hide();
  end
  if (cfg["show_closebutton"] == 0) then
    TBnk_Button_Close:Hide();
  end
  if (cfg["show_total"] == 0) then
    TBnkFrame_Total:Hide();
  end
  if (cfg["show_money"] == 0) then
    TBnkFrame_MoneyFrame:Hide();
  end
  if (cfg["show_tokens"] == 0) then
    TBnkFrame_TokenFrame:Hide();
  end

  TBag:BuildBarClassList(self.BC_LIST, cfg);

  -- Do one sorting to init the baritm array
  self.BARITM = TBag:SortItmCache(cfg,
    self.playerid, TBnkItm[self.playerid], self.BARITM, self.bags, self.atbank);
  TBag:LayoutWindow(self)
end

function Bank:UpdateDepositButton()
  if (self.atbank == 1 and self.cfg["show_depositbutton"] == 1 and TBag:IsReagentBankUnlocked(self.playerid)) then
    TBnk_Button_DepositReagent:Show()
  else
    TBnk_Button_DepositReagent:Hide()
  end
end

function Bank:UpdateBagGfx()
  local i;
  local bag = BANK_CONTAINER;
  local numSlots, _ = TBag:GetNumBankSlots(self.playerid);
  local free, size = TBag:UpdateSlots(self.playerid, bag, self.cfg["show_bag_sizes"]);
  local totalfree = free;
  local totalsize = size;

  TBag:UpdateBagColors(bag);
  TBag:SetPlayerBagCfg(self.playerid, bag, TBag.I_ITEMLINK, nil);

  for i=1, numSlots do
    bag = i + 4;
    local type = TBag:GetBagType(self.playerid, bag); -- needed for cacheing
    TBag:GetBagFrameTexture(bag):SetVertexColor(1.0,1.0,1.0, 1.0);
  end
  for i=numSlots+1, NUM_BANKBAGSLOTS do
    bag = i + 4;
    TBag:SetPlayerBagCfg(self.playerid, bag, TBag.I_BAGTYPE, 0);
    TBag:SetPlayerBagCfg(self.playerid, bag, TBag.I_BAGFREE, 0);
    TBag:SetPlayerBagCfg(self.playerid, bag, TBag.I_BAGSIZE, 0);
    TBag:SetPlayerBagCfg(self.playerid, bag, TBag.I_ITEMLINK, nil);
    TBag:GetBagFrameTexture(bag):SetVertexColor(1.0,0.1,0.1, 1.0);
  end
  for i=1, NUM_BANKBAGSLOTS do
    bag = i + 4;

    TBag:UpdateBagColors(bag);

    TBag:GetBagFrameTexture(bag):SetTexture(
      TBag:GetBagTexture(self.playerid, bag));

    local free, size = TBag:UpdateSlots(self.playerid, bag, self.cfg["show_bag_sizes"]);

    totalfree = totalfree + free;
    totalsize = totalsize + size;
  end
  TBag:SetFreeStr(TBnkFrame_TotalText, totalfree, totalsize, self.cfg["show_bag_sizes"]);
end

function Bank:InitBagGfx()
  local numSlots, _ = TBag:GetNumBankSlots(self.playerid);

  -- Spoof the bank
  local button = TBnkFrameBagBank;
  SetItemButtonTextureVertexColor(button, 1.0,1.0,1.0, 1.0);
  TBag:GetBagFrameTexture(BANK_CONTAINER):SetTexture(
        TBag:GetBagTexture(TBnkFrame.playerid, BANK_CONTAINER));

  for i=1, NUM_BANKBAGSLOTS do
    button = _G["TBnkFrameBag"..i];
    if ( button ) then
      if ( i <= numSlots ) then
        SetItemButtonTextureVertexColor(button, 1.0,1.0,1.0, 1.0);
        button.tooltipText = BANK_BAG;
      else
        SetItemButtonTextureVertexColor(button, 1.0,0.1,0.1, 1.0);
        button.tooltipText = BANK_BAG_PURCHASE;
      end
    end
  end
end


function Bank.Button_HighlightToggle_OnClick(self)
  PlaySound(856);
  if (TBag.SrchText) then
    TBag:ClearSearch();
    if (GameTooltip:GetOwner() == TBnk_Button_HighlightToggle) then
      if (TBnkFrame.highlight_new == 1) then
        GameTooltip_AddNewbieTip(self, L["Normal"], 1.0, 1.0, 1.0,
                                 L["Stop highlighting new items."]);
      else
        GameTooltip_AddNewbieTip(self, L["Highlight New"], 1.0, 1.0, 1.0,
                                 L["Highlight items marked as new."]);
      end
    end
    return;
  elseif (TBnkFrame.hilight_new == 0) then
    TBnkFrame.hilight_new = 1;
    if (GameTooltip:GetOwner() == TBnk_Button_HighlightToggle) then
      GameTooltip_AddNewbieTip(self, L["Normal"], 1.0, 1.0, 1.0,
                               L["Stop highlighting new items."]);
    end
  else
    TBnkFrame.hilight_new = 0;
    if (GameTooltip:GetOwner() == TBnk_Button_HighlightToggle) then
      GameTooltip_AddNewbieTip(self, L["Highlight New"], 1.0, 1.0, 1.0,
                               L["Highlight items marked as new."]);
    end
  end
  TBnkFrame:UpdateWindow();
end

function Bank.Button_ChangeEditMode_OnClick()
  PlaySound(856);
  if (TBnkFrame.edit_mode == 0) then
    TBnkFrame.edit_mode = 1;
  else
    TBnkFrame.edit_mode = 0;
  end

  -- resort will force a window redraw
  TBnkFrame:UpdateWindow(TBag.REQ_MUST);
end

function Bank.Button_Reload_OnClick()
  -- To avoid cleaning the bank cache, you only can reload bags at bank.
  if (TBnkFrame.atbank==1) then
    -- Hell, let's be paranoid
    if (TBnkFrame.playerid == TBag.PLAYERID) then
      TBag:ClearItmCache(TBnkItm[TBnkFrame.playerid], TBnkFrame.bags);
      TBag:ClearStackSkip(TBnkFrame.bags);
      TBag:ClearCompSkip(TBnkFrame.bags);

      -- Send a message to restack
      if (TBnkFrame.cfg["stack_resort"] == 1) then
        TBnkFrame.cfg["stack_once"] = 1;
      end
    end
  end

  TBnkFrame:UpdateWindow(TBag.REQ_MUST);
  TBag:PrintDEBUG("TBnk reloaded.");
end

function Bank.Button_DepositReagent_OnClick()
  DepositReagentBank()
end

function Bank.Button_MoveLockToggle_OnClick(self)
  PlaySound(856);
  if (TBnkFrame.cfg["moveLock"] == 0) then
    TBnkFrame.cfg["moveLock"] = 1;
    TBnkLockNorm:SetTexture("Interface\\AddOns\\TBag\\images\\LockButton-Unlocked-Up");
    TBnkLockPush:SetTexture("Interface\\AddOns\\TBag\\images\\LockButton-Unlocked-Down");
    if (GameTooltip:GetOwner() == TBnk_Button_MoveLockToggle) then
      GameTooltip_AddNewbieTip(self, L["Lock Window"], 1.0, 1.0, 1.0,
                               L["Prevent window from being moved by dragging it."]);
    end
  else
    TBnkFrame.cfg["moveLock"] = 0;
    TBnkLockNorm:SetTexture("Interface\\AddOns\\TBag\\images\\LockButton-Locked-Up");
    TBnkLockPush:SetTexture("Interface\\AddOns\\TBag\\images\\LockButton-Locked-Down");
    if (GameTooltip:GetOwner() == TBnk_Button_MoveLockToggle) then
      GameTooltip_AddNewbieTip(self, L["Unlock Window"], 1.0, 1.0, 1.0,
                               L["Allow window to be moved by dragging it."]);
    end
  end
end

function Bank.SlotTargetButton_OnClick(self, button)
  local bar, tmp;

  if (TBnkFrame.edit_mode == 1) then
  for tmp in string.gmatch(self:GetName(), "TBnkFrame_SlotTarget_(%d+)") do
    bar = tonumber(tmp);
  end

  if ( (bar == nil) or (bar < 1) or (bar > TBag.BAR_MAX) ) then
    return;
  end

  if ( button == "LeftButton" ) then
    if (TBnkFrame.edit_selected ~= "") then
  -- we got a click, and we already had one selected.  let's move the items
  TBag:SetCatBar(TBnkFrame.cfg, TBnkFrame.edit_selected, bar, 1);

  TBnkFrame.edit_selected = "";
  TBnkFrame.edit_hilight = "";

  TBag:BuildBarClassList(TBnkFrame.BC_LIST, TBnkFrame.cfg);

    -- resort will force a window redraw as well
      TBnkFrame:UpdateWindow(TBag.REQ_MUST);
    end

  elseif ( button == "RightButton" ) then
    HideDropDownMenu(1);
    TBnkFrame.RightClickMenu_mode = "bar";
    TBnkFrame.RightClickMenu_opts = {
  [TBag.I_BAR] = bar
  };
    ToggleDropDownMenu(1, nil, TBnkFrame_RightClickMenu, self:GetName(), -50, 0);

  end
  end
end

function Bank.RightClick_DeleteItemOverride(self)
  local bag, slot, itm;
  local this = self or _G.this

  bag = this.value[TBag.I_BAG];
  slot = this.value[TBag.I_SLOT];

  if ( (bag ~= nil) and (slot ~= nil) ) then
  itm = TBnkItm[TBnkFrame.playerid][bag][slot];

  if (itm[TBag.I_ITEMLINK] ~= nil) then
    local id = TBag:GetItemID(itm[TBag.I_ITEMLINK]);
    if TBnkFrame.cfg["item_overrides"][id] ~= nil then
      TBnkFrame.cfg["item_overrides"][id] = nil;
      HideDropDownMenu(1);

      -- resort will force a window redraw as well
      TBnkFrame:UpdateWindow(TBag.REQ_MUST);
    end
  end
  end
end

function Bank.RightClick_SetItemOverride(self)
  local bag, slot, itm, new_barclass;
  local this = self or _G.this

  bag = this.value[TBag.I_BAG];
  slot = this.value[TBag.I_SLOT];
  new_barclass = this.value["barclass"];

  if ( (bag ~= nil) and (slot ~= nil) and (new_barclass ~= nil) ) then
  itm = TBnkItm[TBnkFrame.playerid][bag][slot];

  TBnkFrame.cfg["item_overrides"][TBag:GetItemID(itm[TBag.I_ITEMLINK])] = new_barclass;
  HideDropDownMenu(2);
  HideDropDownMenu(1);

  TBnkFrame:UpdateWindow(TBag.REQ_MUST);
  end
end

function Bank:SetTopLeftButton_Anchors()
  local buttons = {
    "TBnk_Button_HighlightToggle",
    "TBnk_Button_ChangeEditMode",
    "TBnk_Button_Reload",
    "TBnk_Button_DepositReagent",
  };
  local button_left = nil;

  -- Handle user dropdown list separately...
  local dropdown = TBnk_UserDropdown;
  if (dropdown and dropdown:IsVisible()) then
    dropdown:ClearAllPoints();
    dropdown:SetPoint("TOPLEFT",TBnkFrame,"TOPLEFT",-10,-5);
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
        button:SetPoint("TOPLEFT",TBnkFrame,"TOPLEFT",9,-8);
      end
      if (button:IsVisible()) then
        button_left = button;
      end
    end
  end
end

function Bank:SetTopRightButton_Anchors()
  local buttons = {
    "TBnk_Button_Close",
    "TBnk_Button_MoveLockToggle",
  }
  local button_right = nil;

  for _,button_name in ipairs(buttons) do
    local button = _G[button_name];
    if (button) then
      if (button_right) then
        button:SetPoint("TOPRIGHT",button_right,"TOPLEFT",10,0);
      else
        button:SetPoint("TOPRIGHT",TBnkFrame,"TOPRIGHT",0,0);
      end
      if (button:IsVisible()) then
        button_right = button;
      end
    end
  end
end

function Bank:SetBottomLeftButton_Anchors()
  local buttons = {
    "TBnkFrame_Total",
    "TBnkFrameBagBank",
  }
  local button_left = nil;

  for _,button_name in ipairs(buttons) do
    button = _G[button_name];
    if (button) then
      button:ClearAllPoints();
      if (button_left) then
        -- button following another button
        button:SetPoint("BOTTOMLEFT",button_left,"BOTTOMRIGHT",3,-1);
      else
        -- First button
        local y = 12;
        if (self.edit_mode == 1) then
          y = y + 30;
        end
        button:SetPoint("BOTTOMLEFT",TBnkFrame,"BOTTOMLEFT",10,y);
      end
      if (button:IsVisible()) then
        button_left = button;
      end
    end
  end

  -- Figure the number of columns needed to require the bag buttons
  -- to be split into two rows
  local bags_row = 0;
  if (TBnkFrameBagBank:IsVisible()) then
    bags_row = bags_row + 5;
  end
  if (TBnkFrame_Total:IsVisible()) then
    bags_row = bags_row + 1;
  end
  if TBnkFrame_MoneyFrame:IsVisible() or TBnkFrame_TokenFrame:IsVisible() then
    bags_row = bags_row + 4;
  end

  if (self.cfg["maxColumns"] <= bags_row) then
    TBnkFrameBag4:ClearAllPoints()
    TBnkFrameBag4:SetPoint("BOTTOMLEFT",TBnkFrameBagBank,"TOPLEFT",0,3);
  else
    -- Now separate row required
    TBnkFrameBag4:ClearAllPoints()
    TBnkFrameBag4:SetPoint("BOTTOMLEFT",TBnkFrameBag3,"BOTTOMRIGHT",3,0);
  end

end

function Bank:SetBottomRightButton_Anchors()
  local buttons = {
    "TBnkFrame_MoneyFrame",
    "TBnkFrame_TokenFrame",
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
        if self.edit_mode == 1 then
          y = y + 30
        end
        button:SetPoint("BOTTOMRIGHT",TBnkFrame,"BOTTOMRIGHT",5,y)
      end
      if button:IsVisible() then
        button_right = button
      end
    end
  end
end

function Bank:SetButton_Anchors()
  self:SetTopLeftButton_Anchors();
  self:SetTopRightButton_Anchors();
  self:SetBottomLeftButton_Anchors();
  self:SetBottomRightButton_Anchors();
  TBag:LayoutWindow(self)
end


function Bank.Toggle_CloseButton()
  if (TBnkFrame.cfg["show_closebutton"] == 1) then
    TBnkFrame.cfg["show_closebutton"] = 0;
    TBnk_Button_Close:Hide();
    TBnkFrame:SetButton_Anchors();
  else
    TBnkFrame.cfg["show_closebutton"] = 1;
    TBnk_Button_Close:Show();
    TBnkFrame:SetButton_Anchors();
  end
end

function Bank.Toggle_LockButton()
  if (TBnkFrame.cfg["show_lockbutton"] == 1) then
    TBnkFrame.cfg["show_lockbutton"] = 0;
    TBnk_Button_MoveLockToggle:Hide();
    TBnkFrame:SetButton_Anchors();
  else
    TBnkFrame.cfg["show_lockbutton"] = 1;
    TBnk_Button_MoveLockToggle:Show();
    TBnkFrame:SetButton_Anchors();
  end
end

function Bank.Toggle_HighlightButton()
  if (TBnkFrame.cfg["show_hilightbutton"] == 1) then
    TBnkFrame.cfg["show_hilightbutton"] = 0;
    TBnk_Button_HighlightToggle:Hide();
    TBnkFrame:SetButton_Anchors();
  else
    TBnkFrame.cfg["show_hilightbutton"] = 1;
    TBnk_Button_HighlightToggle:Show();
    TBnkFrame:SetButton_Anchors();
  end
end

function Bank.Toggle_EditButton()
  if (TBnkFrame.cfg["show_editbutton"] == 1) then
    TBnkFrame.cfg["show_editbutton"] = 0;
    TBnk_Button_ChangeEditMode:Hide();
    TBnkFrame:SetButton_Anchors();
  else
    TBnkFrame.cfg["show_editbutton"] = 1;
    TBnk_Button_ChangeEditMode:Show();
    TBnkFrame:SetButton_Anchors();
  end
end

function Bank.Toggle_ReloadButton()
  if (TBnkFrame.cfg["show_reloadbutton"] == 1) then
    TBnkFrame.cfg["show_reloadbutton"] = 0;
    TBnk_Button_Reload:Hide();
    TBnkFrame:SetButton_Anchors();
  else
    TBnkFrame.cfg["show_reloadbutton"] = 1;
    TBnk_Button_Reload:Show();
    TBnkFrame:SetButton_Anchors();
  end
end

function Bank.Toggle_DepositReagentButton()
  if (TBnkFrame.cfg["show_depositbutton"] == 1) then
    TBnkFrame.cfg["show_depositbutton"] = 0;
    TBnk_Button_DepositReagent:Hide();
    TBnkFrame:SetButton_Anchors();
  else
    TBnkFrame.cfg["show_depositbutton"] = 1;
    if (TBnkFrame.atbank == 1 and TBag:IsReagentBankUnlocked(TBnkFrame.playerid)) then
      TBnk_Button_DepositReagent:Show();
      TBnkFrame:SetButton_Anchors();
    end
  end
end

function Bank.Toggle_UserDropdown()
  if (TBnkFrame.cfg["show_userdropdown"] == 1) then
    TBnkFrame.cfg["show_userdropdown"] = 0;
    TBnk_UserDropdown:Hide();
    TBnkFrame:SetButton_Anchors();
  else
    TBnkFrame.cfg["show_userdropdown"] = 1;
    TBnk_UserDropdown:Show();
    TBnkFrame:SetButton_Anchors();
  end
end

function Bank.Toggle_Money()
  if (TBnkFrame.cfg["show_money"] == 1) then
    TBnkFrame.cfg["show_money"] = 0;
    TBnkFrame_MoneyFrame:Hide();
    TBnkFrame:SetButton_Anchors();
  else
    TBnkFrame.cfg["show_money"] = 1;
    TBnkFrame_MoneyFrame:Show();
    TBnkFrame:SetButton_Anchors();
  end
end

function Bank.Toggle_Token()
  if (TBnkFrame.cfg["show_tokens"] == 1) then
    TBnkFrame.cfg["show_tokens"] = 0;
    TBnkFrame_TokenFrame:Hide();
    TBnkFrame:SetButton_Anchors();
  else
    TBnkFrame.cfg["show_tokens"] = 1;
    TBnkFrame_TokenFrame:Show();
    TBnkFrame:SetButton_Anchors();
  end
end

function Bank.Toggle_BagSlotButtons()
  if (TBnkFrame.cfg["show_bagbuttons"] == 1) then
    TBnkFrame.cfg["show_bagbuttons"] = 0;
    TBnkFrameBag1:Hide();
    TBnkFrameBag2:Hide();
    TBnkFrameBag3:Hide();
    TBnkFrameBag4:Hide();
    TBnkFrameBag5:Hide();
    TBnkFrameBag6:Hide();
    TBnkFrameBag7:Hide();
    TBnkFrameBagBank:Hide();
    TBnkFrameBagReagent:Hide();
    TBnkFrame:SetButton_Anchors();
  else
    TBnkFrame.cfg["show_bagbuttons"] = 1;
    TBnkFrameBag1:Show();
    TBnkFrameBag2:Show();
    TBnkFrameBag3:Show();
    TBnkFrameBag4:Show();
    TBnkFrameBag5:Show();
    TBnkFrameBag6:Show();
    TBnkFrameBag7:Show();
    TBnkFrameBagBank:Show();
    TBnkFrameBagReagent:Show();
    TBnkFrame:SetButton_Anchors();
   end
end

function Bank.Toggle_Total()
  if (TBnkFrame.cfg["show_total"] == 1) then
    TBnkFrame.cfg["show_total"] = 0;
    TBnkFrame_Total:Hide();
    TBnkFrame:SetButton_Anchors();
  else
    TBnkFrame.cfg["show_total"] = 1;
    TBnkFrame_Total:Show();
    TBnkFrame:SetButton_Anchors();
  end
end


function Bank.RightClickMenu_populate(self, level)
  local bar, bag, slot;
  local info, itm, id, barclass, tmp, checked, i;
  local key, value, key2, value2;


  -------------------------------------------------------------------------------------------------
  ------------------------------- ITEM CONTEXT MENU -----------------------------------------------
  -------------------------------------------------------------------------------------------------
  if (TBnkFrame.RightClickMenu_mode == "item") then
  -- we have a right click on a button

  bar = TBnkFrame.RightClickMenu_opts[TBag.I_BAR];
  bag = TBnkFrame.RightClickMenu_opts[TBag.I_BAG];
  slot = TBnkFrame.RightClickMenu_opts[TBag.I_SLOT];
  itm = TBnkItm[TBnkFrame.playerid][bag][slot];
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
    if (TBnkFrame.cfg["item_overrides"][id] ~= nil) then
  info["checked"] = 1;
    end
    UIDropDownMenu_AddButton(info, level);

    info = {
  ["text"] = L["Use default category assignment"],
  ["value"] = { [TBag.I_BAG]=bag, [TBag.I_SLOT]=slot },
  ["func"] = TBnkFrame.RightClick_DeleteItemOverride
  };
    if (TBnkFrame.cfg["item_overrides"][id] == nil) then
  info["checked"] = 1;
    end
    UIDropDownMenu_AddButton(info, level);

    if (TBnk_SHOWITEMDEBUGINFO==1) then
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
  if ( (TBnkFrame.cfg["item_overrides"][id] ~=
  nil) and (TBag:GetCat(TBnkFrame.cfg, TBnkFrame.cfg["item_overrides"][id]) == i) ) then
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
  for key, barclass in pairs(TBnkFrame.BC_LIST[UIDROPDOWNMENU_MENU_VALUE["select_bar"]]) do
    info = {
  ["text"] = barclass;
  ["value"] = { [TBag.I_BAG]=bag, [TBag.I_SLOT]=slot, ["barclass"]=barclass },
  ["func"] = TBnkFrame.RightClick_SetItemOverride
  };
    if (TBnkFrame.cfg["item_overrides"][id] == barclass) then
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
  elseif (TBnkFrame.RightClickMenu_mode == "bar") then
  -- right click on a slot
  bar = TBnkFrame.RightClickMenu_opts[TBag.I_BAR];

  info = { ["text"] = string.format(L["|c%sBar |r|c%s%s|r"],TBag.C_INST,TBag.C_BAR,bar), ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
  UIDropDownMenu_AddButton(info, level);

  info = { ["disabled"] = 1 };
  UIDropDownMenu_AddButton(info, level);

  for key, value in pairs(TBnkFrame.BC_LIST[bar]) do
    info = {
    ["text"] = string.format(L["Move: |c%s%s|r"],TBag.C_CAT,value);
    ["value"] = value;
    ["func"] = function(self)
  local this = self or _G.this
  TBnkFrame.edit_selected = (this.value);
  TBnkFrame.edit_hilight = (this.value);
  TBnkFrame:UpdateWindow();
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

    if (TBag:GetGrp(TBnkFrame.cfg, TBag.G_BAR_SORT, bar) == key) then
      checked = 1;
    else
      checked = nil;
    end
    info = {
  ["text"] = value;
  ["value"] = { [TBag.I_BAR]=bar, ["sortby"]=key };
  ["func"] = function(self)
    local this = self or _G.this
    TBag:SetGrpDef(TBnkFrame.cfg, TBag.G_BAR_SORT, this.value[TBag.I_BAR], this.value["sortby"], 1);
    TBnkFrame:UpdateWindow(TBag.REQ_MUST);
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

    if (TBag:GetGrp(TBnkFrame.cfg, TBag.G_USE_NEW, bar) == key) then
      checked = 1;
    else
      checked = nil;
    end

    info = {
      ["text"] = value;
      ["value"] = { [TBag.I_BAR]=bar, ["value"]=key };
      ["func"] = function(self)
        local this = self or _G.this
        TBag:SetGrpDef(TBnkFrame.cfg, TBag.G_USE_NEW, this.value[TBag.I_BAR], this.value["value"], 1);
        TBnkFrame:UpdateWindow();
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

    if (TBag:GetGrp(TBnkFrame.cfg, TBag.G_BAR_HIDE, bar) == key) then
      checked = 1;
    else
      checked = nil;
    end

    info = {
      ["text"] = value;
      ["value"] = { [TBag.I_BAR]=bar, ["value"]=key };
      ["func"] = function(self)
        local this = self or _G.this
        TBag:SetGrpDef(TBnkFrame.cfg, TBag.G_BAR_HIDE, this.value[TBag.I_BAR], this.value["value"], 1);
        TBnkFrame:UpdateWindow();
    end,
  ["checked"] = checked
  };
    UIDropDownMenu_AddButton(info, level);
  end

  info = { ["disabled"] = 1 };
  UIDropDownMenu_AddButton(info, level);

  info = { ["text"] = L["Color:"], ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
  UIDropDownMenu_AddButton(info, level);

  info = TBag:MakeColorPickerInfo(TBnkFrame.cfg, "bkgr_", bar,
    string.format(L["Background Color for Bar %d"],bar), function () TBnkFramer:UpdateWindow() end);
  UIDropDownMenu_AddButton(info, level);

  info = TBag:MakeColorPickerInfo(TBnkFrame.cfg, "brdr_", bar,
    string.format(L["Border Color for Bar %d"],bar), function () TBnkFrame:UpdateWindow() end);
  UIDropDownMenu_AddButton(info, level);

  -------------------------------------------------------------------------------------------------
  ------------------------ MAIN WINDOW CONTEXT MENU -----------------------------------------------
  -------------------------------------------------------------------------------------------------
  elseif (TBnkFrame.RightClickMenu_mode == "mainwindow") then
  if (level == 1) then

    info = { ["text"] = string.format(L["TBag v%s"],TBag.VERSION), ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
    UIDropDownMenu_AddButton(info, level);

    if (TBnkFrame.atbank == 0) then
      info = { ["disabled"] = 1 };
      UIDropDownMenu_AddButton(info, level);

      info = {
        ["text"] = L["Select Character"];
        ["value"] = { ["opt"]="select_character" },
        ["hasArrow"] = 1
        };
      UIDropDownMenu_AddButton(info, level);
    end

    info = { ["disabled"] = 1 };
    UIDropDownMenu_AddButton(info, level);

    info = {
  ["text"] = L["Edit Mode"],
  ["value"] = nil,
  ["func"] = TBnkFrame.Button_ChangeEditMode_OnClick
  };
    if (TBnkFrame.edit_mode == 1) then
      info["checked"] = 1;
    end
    UIDropDownMenu_AddButton(info, level);

    info = {
  ["text"] = L["Lock window"],
  ["value"] = nil,
  ["func"] = TBnkFrame.Button_MoveLockToggle_OnClick
  };
    if (TBnkFrame.cfg["moveLock"] == 0) then
  info["checked"] = 1;
    end
    UIDropDownMenu_AddButton(info, level);

  info = {
  ["text"] = L["Reload and Sort"],
  ["value"] = nil,
  ["func"] = TBnkFrame.Button_Reload_OnClick
  };
  UIDropDownMenu_AddButton(info, level);

    info = {
  ["text"] = REAGENTBANK_DEPOSIT,
  ["value"] = nil,
  ["func"] = TBnkFrame.Button_DepositReagent_OnClick
  };
  UIDropDownMenu_AddButton(info, level);

    info = { ["disabled"] = 1 };
    UIDropDownMenu_AddButton(info, level);

    info = {
  ["value"] = nil,
  ["func"] = TBnkFrame.Button_HighlightToggle_OnClick
  };
    if (TBag.SrchText) then
      info["text"] = L["Clear Search"];
    else
      info["text"] = L["Highlight New Items"];
      if (TBnkFrame.hilight_new == 1) then
        info["checked"] = 1;
      end
    end
    UIDropDownMenu_AddButton(info, level);

    info = {
  ["text"] = L["Reset NEW tag"],
  ["value"] = nil,
  ["func"] = function()
    local bag, slot, index;

    for index, bag in ipairs(TBnkFrame.bags) do
      if (TBnkFrame.cfg["show_Bag"..bag] == 1) then
        if (table.getn(TBnkItm[TBnkFrame.playerid][bag]) > 0) then
          for slot = 1, table.getn(TBnkItm[TBnkFrame.playerid][bag]) do
            TBag:ResetNew(TBnkItm[TBnkFrame.playerid][bag][slot]);
          end
        end
      end
    end

    TBnkFrame:UpdateWindow();
  end
  };
    UIDropDownMenu_AddButton(info, level);

  info = { ["disabled"] = 1 };
  UIDropDownMenu_AddButton(info, level);

    info = {
  ["text"] = L["Advanced Configuration"],
  ["value"] = nil,
  ["func"] = function()
    TBnk_OptsFrame:Show();
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
                    TBnkFrame.cfg["frameButtonSize"], TBnkFrame.cfg["count_font"],
                      TBnkFrame.cfg["count_font_x"], TBnkFrame.cfg["count_font_y"],
                      TBnkFrame.cfg["scale"] = TBag:NicePlacement(this.value);
                  TBnkFrame:CalcButtonSize(TBnkFrame.cfg["frameButtonSize"], TBnkFrame.cfg["framePad"]);
                  TBnkFrame:UpdateWindow(TBag.REQ_MUST);
                end
              end
            };
            if (tonumber(TBnkFrame.cfg["frameButtonSize"]*TBnkFrame.cfg["scale"] - value)
      < 1.0) and (tonumber(TBnkFrame.cfg["frameButtonSize"]*TBnkFrame.cfg["scale"] - value)
      > -1.0) then
              info["checked"] = 1;
            end
            UIDropDownMenu_AddButton(info, level);
          end
        elseif (UIDROPDOWNMENU_MENU_VALUE["opt"] == "set_colors") then
          TBag:MakeColorMenu(TBnkFrame.cfg, function () TBnkFrame:UpdateWindow() end, level, TBnkFrame.bags);
        elseif (UIDROPDOWNMENU_MENU_VALUE["opt"] == "anchor") then
          info = {
            ["text"] = L["TOPLEFT"];
            ["func"] = function ()
                         TBag:SetFrameAnchor (TBnkFrame,TBnkFrame.cfg,"TOP","LEFT")
                       end;
            };
          if (TBnkFrame.cfg["frameXRelativeTo"] == "LEFT" and
              TBnkFrame.cfg["frameYRelativeTo"] == "TOP") then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["TOPRIGHT"];
            ["func"] = function ()
                         TBag:SetFrameAnchor (TBnkFrame,TBnkFrame.cfg,"TOP","RIGHT")
                       end;
            };
          if (TBnkFrame.cfg["frameXRelativeTo"] == "RIGHT" and
              TBnkFrame.cfg["frameYRelativeTo"] == "TOP") then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["BOTTOMLEFT"];            ["func"] = function ()
                         TBag:SetFrameAnchor (TBnkFrame,TBnkFrame.cfg,"BOTTOM","LEFT")
                       end;
            };
          if (TBnkFrame.cfg["frameXRelativeTo"] == "LEFT" and
              TBnkFrame.cfg["frameYRelativeTo"] == "BOTTOM") then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["BOTTOMRIGHT"];
            ["func"] = function ()
                         TBag:SetFrameAnchor (TBnkFrame,TBnkFrame.cfg,"BOTTOM","RIGHT")
                       end;
            };
          if (TBnkFrame.cfg["frameXRelativeTo"] == "RIGHT" and
              TBnkFrame.cfg["frameYRelativeTo"] == "BOTTOM") then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
        elseif (UIDROPDOWNMENU_MENU_VALUE["opt"] == "hide_frames") then
          info = {
            ["text"] = L["Hide Player Dropdown"];
            ["func"] = TBnkFrame.Toggle_UserDropdown;
            ["keepShownOnClick"] = 1;
            };
          if (TBnkFrame.cfg["show_userdropdown"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Highlight Button"];
            ["func"] = TBnkFrame.Toggle_HighlightButton;
            ["keepShownOnClick"] = 1;
            };
          if (TBnkFrame.cfg["show_hilightbutton"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Edit Button"];
            ["func"] = TBnkFrame.Toggle_EditButton;
            ["keepShownOnClick"] = 1;
           };
          if (TBnkFrame.cfg["show_editbutton"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Re-sort Button"];
            ["func"] = TBnkFrame.Toggle_ReloadButton;
            ["keepShownOnClick"] = 1;
            };
          if (TBnkFrame.cfg["show_reloadbutton"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Reagent Deposit Button"];
            ["func"] = TBnkFrame.Toggle_DepositReagentButton;
            ["keepShownOnClick"] = 1;
            };
          if (TBnkFrame.cfg["show_depositbutton"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Lock Button"];
            ["func"] = TBnkFrame.Toggle_LockButton;
            ["keepShownOnClick"] = 1;
            };
          if (TBnkFrame.cfg["show_lockbutton"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Close Button"];
            ["func"] = TBnkFrame.Toggle_CloseButton;
            ["keepShownOnClick"] = 1;
            };
          if (TBnkFrame.cfg["show_closebutton"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Total"];
            ["func"] = TBnkFrame.Toggle_Total;
            ["keepShownOnClick"] = 1;
            };
          if (TBnkFrame.cfg["show_total"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Bag Buttons"];
            ["func"] = TBnkFrame.Toggle_BagSlotButtons;
            ["keepShownOnClick"] = 1;
            };
          if (TBnkFrame.cfg["show_bagbuttons"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Tokens"];
            ["func"] = TBnkFrame.Toggle_Token;
            ["keepShownOnClick"] = 1;
            };
          if (TBnkFrame.cfg["show_tokens"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
          info = {
            ["text"] = L["Hide Money"];
            ["func"] = TBnkFrame.Toggle_Money;
            ["keepShownOnClick"] = 1;
            };
          if (TBnkFrame.cfg["show_money"] == 0) then
            info["checked"] = 1;
          end
          UIDropDownMenu_AddButton(info, level);
        elseif (UIDROPDOWNMENU_MENU_VALUE["opt"] == "select_character") then
          Bank.UserDropdown_Initialize(self, level);
        end
      end
    end
  end
  TBag:FixMenuFrameLevels()
end


-- Main "right click menu"
function Bank.RightClickMenu_OnLoad(self)
  UIDropDownMenu_Initialize(self, Bank.RightClickMenu_populate, "MENU");
end

Bank.WindowIsUpdating = 0;

function Bank:UpdateWindow(resort_req)
  local frame = TBnkFrame;
  local barnum;
  local cur_y;

  TBag:PrintDEBUG("Bank:UpdateWindow(): WindowIsUpdating="..Bank.WindowIsUpdating);

  if (Bank.WindowIsUpdating == 1) then
    return;
  end
  Bank.WindowIsUpdating = 1;

  if ( not frame:IsVisible() ) then
    Bank.WindowIsUpdating = 0;
    return;
  end

  -- Set the overall scale
  self:SetScale(self.cfg["scale"]);

  if (resort_req == nil) then resort_req = TBag.REQ_NONE; end

  -- Show some things only when we are at then bank
  if (self.atbank == 1 or self.cfg["show_userdropdown"] == 0) then
    TBnk_UserDropdown:Hide();
  else
    TBnk_UserDropdown:Show();
  end

  -- SORTING

  -- Consume a message from updated craft info
  if (TBagCfg["trades_changed"] == 1) then
    resort_req = TBag.REQ_MUST;
  end
  TBagCfg["trades_changed"] = 0;

  -- Setup stackarr and comparr
  local stackarr = TBag:CreateStackArr();
  local comparr = TBag:CreateCompArr();

  local cache_req = TBag:UpdateItmCache(self.cfg, self.playerid, TBnkItm[self.playerid], self.bags, stackarr, comparr, self.atbank);
  if resort_req == TBag.REQ_PART then
    resort_req = resort_req + self.CACHE_REQ
  end
  resort_req = resort_req + cache_req;

  -- Consume a message for bag stacking
  if (self.cfg["stack_once"] == 1) then
    if (self.playerid == TBag.PLAYERID) then
      if TBag:Stack(TBag.STACK_BNK,TBnkItm[self.playerid], stackarr, comparr) then
        self.cfg["stack_once"] = 0;
      end
    end
  end

  if (resort_req >= TBag.REQ_MUST) then
    self.BARITM = TBag:SortItmCache(self.cfg,
      self.playerid, TBnkItm[self.playerid], self.BARITM, self.bags, self.atbank);
    TBag:LayoutWindow(self)
  elseif cache_req > self.CACHE_REQ then
    self.CACHE_REQ = cache_req
  end

  -- Relink the button map
  for _,bag in ipairs(self.bags) do
    for slot = 1, TBag:GetBagMaxItems(bag) do
      if TBnkItm[self.playerid][bag] then
        TBag.BUTTONS[TBag:GetBagItemButtonName(bag, slot)] = TBnkItm[self.playerid][bag][slot]
      else
        TBag.BUTTONS[TBag:GetBagItemButtonName(bag, slot)] = {}
      end
    end
  end

  -- BAGS, to get bag sizes below
  TBnkFrame:UpdateBagGfx();

  -- Update all the buttons
  for _, bag in ipairs(self.bags) do
    local size = TBag:GetPlayerBagCfg(self.playerid, bag, TBag.I_BAGSIZE);
    if (not size) then size = 0; end
    if (self.cfg["show_Bag"..bag] ~= 1 and not TBag:GetBagFrame(bag):GetChecked()) then
      size = 0
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
    MoneyFrame_SetType(TBnkFrame_MoneyFrame,type)
    MoneyFrame_Update("TBnkFrame_MoneyFrame", TBag:GetMoney(self.playerid));
  end

  frame:UpdateDepositButton();

  frame:ClearAllPoints();
  frame:SetPoint(self.cfg["frameYRelativeTo"]..self.cfg["frameXRelativeTo"],
    "UIParent", "BOTTOMLEFT",
    self.cfg["frame"..self.cfg["frameXRelativeTo"]] / frame:GetScale(),
    self.cfg["frame"..self.cfg["frameYRelativeTo"]] / frame:GetScale());

  TBag:ColorFrame(self.cfg, frame, TBag.MAIN_BAR);

  if (self.edit_mode == 1) then
    TBnkFrame_ColumnsAdd:Show();
    TBnkFrame_ColumnsDel:Show();
  else
    TBnkFrame_ColumnsAdd:Hide();
    TBnkFrame_ColumnsDel:Hide();
  end

  TBnkFrame:SetButton_Anchors();

  Bank.WindowIsUpdating = 0;
end


function Bank:SetReplaceBank()
  if BankFrame_Saved == nil then
    BankFrame_Saved = BankFrame;
  end
  if BankFrame_Saved:IsVisible() then
    BankFrame_Saved:Hide();
  end
  BankFrame_Saved:UnregisterEvent("BANKFRAME_OPENED");
  BankFrame_Saved:UnregisterEvent("BANKFRAME_CLOSED");
end


function Bank.UserDropdown_OnLoad(self)
  UIDropDownMenu_Initialize(self, Bank.UserDropdown_Initialize);
  UIDropDownMenu_SetSelectedValue(self, TBnkFrame.playerid);
  self.tooltip = L["You are viewing the selected player's bank."];
  UIDropDownMenu_SetWidth(self, TBag.USERDD_WIDTH)
  -- UIDropDownMenu_SetWidth actually adds 50 to our width, we really only want
  -- 25 to avoid the control running into our buttons on the right.
  self:SetWidth(TBag.USERDD_WIDTH + 25);
--  OptionsFrame_EnableDropDown(self);
end

function Bank.UserDropdown_Initialize(self, level)
  TBag:UserDropdown_Init(Bank.UserDropdown_OnClick,
    TBnkItm, TBnkFrame.playerid, TBag.REALM, level);
end

function Bank.UserDropdown_OnClick(self)
  local this = self or _G.this
  UIDropDownMenu_SetSelectedValue(TBnk_UserDropdown, this.value);
  if ( this.value ) then
    TBnkFrame:SetPlayer(this.value);
  end
  if ( not TBnkFrame.playerid ) then
    TBag:PrintDEBUG("UserDropdown_OnClick Failed");
    return;
  end
  TBag:PrintDEBUG("Selected Player "..TBnkFrame.playerid);
  -- Show in whatever state the cache was in before
  TBnkFrame.atbank = 0;
  TBnkFrame:UpdateWindow(TBag.REQ_MUST);
end
