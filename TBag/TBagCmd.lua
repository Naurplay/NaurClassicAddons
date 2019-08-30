local _G = getfenv(0)
local TBag = _G.TBag

-- Localization support
local L = TBag.LOCALE;

local TBNK_HELP = {
    L["TBnk Commands:"],
    L[" /tbnk show  -- open window"],
    L[" /tbnk hide  -- hide window"],
    L[" /tbnk update  -- refresh the window"],
    L[" /tbnk config  -- configuration options"],
    L[" /tbnk debug  -- turn debug info on/off"],
    L[" /tbnk reset  -- sets everything back to default values"],
    L[" /tbnk resetpos -- put the bank back to its default position"],
    L[" /tbnk resetsorts -- clears the item search list"],
    L[" /tbnk printchars -- prints a list of all the chars with cached info"],
    L[" /tbnk deletechar CHAR SERVER -- clears all cached info for character "]
};

local TINV_HELP = {
    L["TInv Commands:"],
    L[" /tinv show  -- open window"],
    L[" /tinv hide  -- hide window"],
    L[" /tinv update  -- refresh the window"],
    L[" /tinv config  -- configuration options"],
    L[" /tinv debug  -- turn debug info on/off"],
    L[" /tinv reset  -- sets everything back to default values"],
    L[" /tinv resetpos -- put the inventory window back to its default position"],
    L[" /tinv resetsorts -- clears the item search list"],
    L[" /tinv printchars -- prints a list of all the chars with cached info"],
    L[" /tinv deletechar CHAR SERVER -- clears all cached info for character "]
};


function TBag:ShowHelp(arr)
  for _, line in ipairs(arr) do
    self:Print(line);
  end
end

function TBnk_cmd(msg)
  local cmd, params = TBag:SplitStr(msg," ");

  cmd = string.lower(cmd);

  if (cmd == L["hide"]) then
    TBnkFrame:Hide();
  elseif (cmd == L["show"]) then
    TBnkFrame:Show();
  elseif (cmd == L["update"]) then
    TBnkFrame:UpdateWindow(TBag.REQ_MUST);
  elseif (cmd == L["debug"]) then
    if (TBag.DEBUGMESSAGES == 0) then
      TBag.DEBUGMESSAGES = 1;
      TBag:Print("TBnk: Debugging messages on.");
    else
      TBag.DEBUGMESSAGES = 0;
      TBag:Print("TBnk: Debugging messages off.");
    end
  elseif (cmd == L["reset"]) then
    TBagCfg["Bnk"] = {};
    TBnkFrame:init(1);
    TBnkOpt_ResizeUpdate();
  elseif (cmd == L["resetsorts"]) then
    TBag:ResetSorts(TBnkFrame.cfg);
    TBnkFrame:UpdateWindow(TBag.REQ_MUST);
  elseif (cmd == L["resetpos"]) then
    TBnkFrame:SetDefPos(TBnkFrame.cfg,1);
    TBnkFrame:UpdateWindow(TBag.REQ_MUST);
  elseif (cmd == L["printchars"]) then
    TBag:PrintCachedCharacters();
  elseif (cmd == L["deletechar"]) then
    local char, realm = TBag:SplitStr(params," ");
    TBag:DeleteCachedCharacter(char,realm);
  elseif (cmd == L["config"]) then
    TBnk_OptsFrame:Show();
  elseif (cmd == L["getcat"] and TBag.GetCategory and type(TBag.GetCategory) == "function") then
    TBag:GetCategory(params);
  elseif (cmd == L["tests"] and TBag.RunTests and type(TBag.RunTests) == "function") then
    TBag:RunTests(params == "verbose");
  else
    TBag:ShowHelp(TBNK_HELP);
  end
end


function TInv_cmd(msg)
  local cmd, params = TBag:SplitStr(msg," ");

  cmd = string.lower(cmd);

  if (cmd == L["hide"]) then
    TInvFrame:Hide();
  elseif (cmd == L["show"]) then
    TInvFrame:Show();
  elseif (cmd == L["update"]) then
    TInvFrame:UpdateWindow(TBag.REQ_MUST);
  elseif (cmd == L["debug"]) then
    if (TBag.DEBUGMESSAGES == 0) then
      TBag.DEBUGMESSAGES = 1;
      TBag:Print("TInv: Debugging messages on.");
    else
      TBag.DEBUGMESSAGES = 0;
      TBag:Print("TInv: Debugging messages off.");
    end
  elseif (cmd == L["reset"]) then
    TBagCfg["Inv"] = {};
    TInvFrame:init(1);
    TInvOpt_ResizeUpdate();
  elseif (cmd == L["resetsorts"]) then
    TBag:ResetSorts(TInvFrame.cfg);
    TInvFrame:UpdateWindow(TBag.REQ_MUST);
  elseif (cmd == L["resetpos"]) then
    TInvFrame:SetDefPos(TInvFrame.cfg,1);
    TInvFrame:UpdateWindow(TBag.REQ_MUST);
  elseif (cmd == L["printchars"]) then
    TBag:PrintCachedCharacters();
  elseif (cmd == L["deletechar"]) then
    local char, realm = TBag:SplitStr(params," ");
    TBag:DeleteCachedCharacter(char,realm);
  elseif (cmd == L["config"]) then
    TInv_OptsFrame:Show();
  elseif (cmd == L["getcat"] and TBag.GetCategory and type(TBag.GetCategory) == "function") then
    TBag:GetCategory(params);
  elseif (cmd == L["tests"] and TBag.RunTests and type(TBag.RunTests) == "function") then
    TBag:RunTests(params == "verbose");
  else
    TBag:ShowHelp(TINV_HELP);
  end
end
