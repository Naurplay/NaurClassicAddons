QuestieFramePool = {...} -- GLobal Functions
local _QuestieFramePool = {...} --Local Functions
qNumberOfFrames = 0

local unusedframes = {}
local usedFrames = {};

local allframes = {}

local HBD = LibStub("HereBeDragonsQuestie-2.0")
local HBDPins = LibStub("HereBeDragonsQuestie-Pins-2.0")
local HBDMigrate = LibStub("HereBeDragonsQuestie-Migrate")

_QuestieFramePool.addonPath = "Interface\\Addons\\Questie\\"

--TODO: Add all types
ICON_TYPE_AVAILABLE =  _QuestieFramePool.addonPath.."Icons\\available.blp"
ICON_TYPE_SLAY =  _QuestieFramePool.addonPath.."Icons\\slay.blp"
ICON_TYPE_COMPLETE =  _QuestieFramePool.addonPath.."Icons\\complete.blp"
ICON_TYPE_ITEM =  _QuestieFramePool.addonPath.."Icons\\item.blp"
ICON_TYPE_LOOT =  _QuestieFramePool.addonPath.."Icons\\loot.blp"
ICON_TYPE_EVENT =  _QuestieFramePool.addonPath.."Icons\\event.blp"
ICON_TYPE_OBJECT =  _QuestieFramePool.addonPath.."Icons\\object.blp"
ICON_TYPE_GLOW = _QuestieFramePool.addonPath.."Icons\\glow.blp"
ICON_TYPE_BLACK = _QuestieFramePool.addonPath.."Icons\\black.blp"

-- Global Functions --
function QuestieFramePool:GetFrame()
    local f = nil--tremove(unusedframes)
    
    -- im not sure its this, but using string keys for the table prevents double-adding to unusedframes, calling unload() twice could double-add it maybe?
    for k,v in pairs(unusedframes) do -- yikes (why is tremove broken? is there a better to get the first key of a non-indexed table?)
        f = v
        unusedframes[k] = nil
        break
    end
    
    
    if f and f.GetName and usedFrames[f:GetName()] then
        -- something went horribly wrong (desync bug?) don't use this frame since its already in use
        f = nil
    end
    if not f then
        f = _QuestieFramePool:QuestieCreateFrame()
    end
    if f ~= nil and f.hidden and f._show ~= nil and f._hide ~= nil then -- restore state to normal (toggle questie)
        f.hidden = false
        f.Show = f._show;
        f.Hide = f._hide;
        f._show = nil
        f._hide = nil
    end
    f.fadeLogic = nil
    f.miniMapIcon = nil
    f._hidden_toggle_hack = nil -- TODO: this will be removed later, see QuestieQuest:UpdateHiddenNotes()

    --if f.IsShowing ~= nil and f:IsShowing() then
    f.data = {} -- this should probably be nil but QuestieCreateFrame sets it to an empty table for some reason
    f.x = nil;f.y = nil;f.AreaID = nil;
    f:Hide();
    --end
    
    if f.texture then
        f.texture:SetVertexColor(1, 1, 1, 1)
    end
    f.loaded = true
    f.shouldBeShowing = nil
    f.hidden = nil
    
    if f.baseOnShow then
        f:SetScript("OnShow", f.baseOnShow)
    end
    
    if f.baseOnUpdate then
        f:SetScript("OnUpdate", f.baseOnUpdate)
    else
        f:SetScript("OnUpdate", nil)
    end
    
    if f.baseOnHide then
        f:SetScript("OnHide", f.baseOnHide)
    end
    
    usedFrames[f:GetName()] = f
    return f
end

--for i, frame in ipairs(allframes) do
--    if(frame.loaded == nil)then
--        return frame
--    end
--end

function QuestieFramePool:UnloadAll()

    Questie:Debug(DEBUG_DEVELOP, "[QuestieFramePool] ".. QuestieLocale:GetUIString('DEBUG_UNLOAD_ALL', #allframes))
    for i, frame in ipairs(allframes) do
        --_QuestieFramePool:UnloadFrame(frame);
        frame:Unload()
    end
    qQuestIdFrames = {}
end

function QuestieFramePool:UpdateGlowConfig(mini, mode)
    if mode then
        for _, icon in pairs(usedFrames) do
            if (((mini and icon.miniMapIcon) or not mini) and icon.glow) and icon.IsShown and icon:IsShown() then
                icon:GetScript("OnShow")(icon) -- forces a glow update
            end
        end
    else
        for _, icon in pairs(usedFrames) do
            if ((mini and icon.miniMapIcon) or (not mini and not icon.miniMapIcon)) and icon.glow then
                icon.glow:Hide()
            end
        end
    end
end

-- Local Functions --

--[[Use FRAME.Unload(FRAME) on frame object to unload!
function _QuestieFramePool:UnloadFrame(frame)
    --We are reseting the frames, making sure that no data is wrong.
  HBDPins:RemoveMinimapIcon(Questie, frame);
  HBDPins:RemoveWorldMapIcon(Questie, frame);
  frame.data = nil; -- Just to be safe
  frame.loaded = nil;
    table.insert(unusedframes, frame)
end]]--

function _QuestieFramePool:QuestieCreateFrame()
    qNumberOfFrames = qNumberOfFrames + 1
    local f = CreateFrame("Button", "QuestieFrame"..qNumberOfFrames, nil)
    if(qNumberOfFrames > 5000) then
        Questie:Debug(DEBUG_CRITICAL, "[QuestieFramePool] Over 5000 frames... maybe there is a leak?", qNumberOfFrames)
    end

    f.glow = CreateFrame("Button", "QuestieFrame"..qNumberOfFrames.."Glow", f) -- glow frame
    f.glow:SetFrameStrata("TOOLTIP");
    f.glow:SetWidth(18) -- Set these to whatever height/width is needed
    f.glow:SetHeight(18)


    f:SetFrameStrata("TOOLTIP");
    f:SetWidth(16) -- Set these to whatever height/width is needed
    f:SetHeight(16) -- for your Texture
    local t = f:CreateTexture(nil, "TOOLTIP")
    --t:SetTexture("Interface\\Icons\\INV_Misc_Eye_02.blp")
    --t:SetTexture("Interface\\Addons\\!Questie\\Icons\\available.blp")
    t:SetWidth(16)
    t:SetHeight(16)
    t:SetAllPoints(f)
    t:SetTexelSnappingBias(0)
    t:SetSnapToPixelGrid(false)

    local glowt = f.glow:CreateTexture(nil, "TOOLTIP")
    glowt:SetWidth(18)
    glowt:SetHeight(18)
    glowt:SetAllPoints(f.glow)

    f.texture = t;
    f.glowTexture = glowt
    f.glowTexture:SetTexture(ICON_TYPE_GLOW)
    f.glow:Hide()
    f:SetPoint("CENTER", 0, 0)
    f.glow:SetPoint("CENTER", - 1, - 1) -- 2 pixels bigger than normal icon
    f.glow:EnableMouse(false)
    f:EnableMouse(true)--f:EnableMouse()

    --f.mouseIsOver = false;
    --f:SetScript("OnUpdate", function()
    --  local mo = MouseIsOver(self); -- function exists in classic but crashes the game
    --  if mo and (not f.mouseIsOver) then
    --    f.mouseIsOver = true
    --    _QuestieFramePool:Questie_Tooltip(self)
    --  elseif (not mo) and f.mouseIsOver then
    --    f.mouseIsOver = false
    --    if(WorldMapTooltip) then WorldMapTooltip:Hide() end if(GameTooltip) then GameTooltip:Hide() end
    --  end
    --end)

    --f:SetScript('OnEnter', function() Questie:Print("Enter") end)
    --f:SetScript('OnLeave', function() Questie:Print("Leave") end)

    f:SetScript("OnEnter", function(self) _QuestieFramePool:Questie_Tooltip(self) end); --Script Toolip
    f:SetScript("OnLeave", function() if(WorldMapTooltip) then WorldMapTooltip:Hide(); WorldMapTooltip._rebuild = nil; end if(GameTooltip) then GameTooltip:Hide(); GameTooltip._rebuild = nil; end end) --Script Exit Tooltip
    f:SetScript("OnClick", function(self)
        --_QuestieFramePool:Questie_Click(self)
        if self and self.data and self.data.UiMapID and WorldMapFrame and WorldMapFrame:IsShown() and self.data.UiMapID ~= WorldMapFrame:GetMapID() then
            WorldMapFrame:SetMapID(self.data.UiMapID);
        end
    end);
    f.glowUpdate = function(self)--f:HookScript("OnUpdate", function(self)
        if self.glow and self.glow.IsShown and self.glow:IsShown() then
            self.glow:SetWidth(self:GetWidth()*1.13)
            self.glow:SetHeight(self:GetHeight()*1.13)
            self.glow:SetPoint("CENTER", self, 0, 0)
            if self.data and self.data.ObjectiveData and self.data.ObjectiveData.Color and self.glowTexture then
                local _,_,_,alpha = self.texture:GetVertexColor()
                self.glowTexture:SetVertexColor(self.data.ObjectiveData.Color[1], self.data.ObjectiveData.Color[2], self.data.ObjectiveData.Color[3], alpha or 1);
            end
        end
        --self.glow:SetPoint("BOTTOMLEFT", self, 1, 1)
    end--end)
    f.baseOnUpdate = function(self)
        if self.glowUpdate then
            self:glowUpdate()
        end
    end
    f.baseOnShow = function(self)--f:SetScript("OnShow", function(self)
        if self.data and self.data.Type and self.data.Type == "complete" then
            self:SetFrameLevel(self:GetFrameLevel() + 1)
        end
        if ((self.miniMapIcon and Questie.db.global.alwaysGlowMinimap) or ((not self.miniMapIcon) and Questie.db.global.alwaysGlowMap)) and self.data and self.data.ObjectiveData and self.data.ObjectiveData.Color and (self.data.Type and (self.data.Type ~= "available" and self.data.Type ~= "complete")) then
            self.glow:SetWidth(self:GetWidth()*1.13)
            self.glow:SetHeight(self:GetHeight()*1.13)
            self.glow:SetPoint("CENTER", self, 0, 0)
            local _,_,_,alpha = self.texture:GetVertexColor()
            self.glowTexture:SetVertexColor(self.data.ObjectiveData.Color[1], self.data.ObjectiveData.Color[2], self.data.ObjectiveData.Color[3], alpha or 1);
            self.glow:Show()
            self.glow:SetFrameLevel(self:GetFrameLevel() - 1)
        end
    end--end)
    f.baseOnHide = function(self)--f:HookScript("OnHide", function(self)
        self.glow:Hide()
    end--end)
    --f.Unload = function(frame) _QuestieFramePool:UnloadFrame(frame) end;
    function f:Unload()
        self:SetScript("OnUpdate", nil)
        self:SetScript("OnShow", nil)
        self:SetScript("OnHide", nil)
        
        --We are reseting the frames, making sure that no data is wrong.
        if self ~= nil and self.hidden and self._show ~= nil and self._hide ~= nil then -- restore state to normal (toggle questie)
            self.hidden = false
            self.Show = self._show;
            self.Hide = self._hide;
            self._show = nil
            self._hide = nil
        end
        self.shouldBeShowing = nil
        HBDPins:RemoveMinimapIcon(Questie, self);
        HBDPins:RemoveWorldMapIcon(Questie, self);
        if(self.texture) then
            self.texture:SetVertexColor(1, 1, 1, 1);
        end
        self.miniMapIcon = nil;
        self:SetScript("OnUpdate", nil)
        self:Hide();
        --self.glow:Hide()
        self.data = nil; -- Just to be safe
        self.loaded = nil;
        self.x = nil;self.y = nil;self.AreaID = nil;
        if usedFrames[self:GetName()] then
            usedFrames[self:GetName()] = nil
            unusedframes[self:GetName()] = self--table.insert(unusedframes, self)
        end
    end
    f.data = {}
    f:Hide()
    --f.glow:Hide()
    table.insert(allframes, f)
    return f
end

function QuestieFramePool:euclid(x, y, i, e)
    local xd = math.abs(x - i);
    local yd = math.abs(y - e);
    return math.sqrt(xd * xd + yd * yd);
end

function QuestieFramePool:remap(value, low1, high1, low2, high2)
    return low2 + (value - low1) * (high2 - low2) / (high1 - low1);
end

_QuestieFramePool.lastTooltipShowHack = GetTime()
function _QuestieFramePool:isMinimapInside()
    if _QuestieFramePool._lastMiniInsideCheck and GetTime() - _QuestieFramePool._lastMiniInsideCheck < 1 then
        return _QuestieFramePool._lastMiniInside
    end
    local tempzoom = 0;
    if (GetCVar("minimapZoom") == GetCVar("minimapInsideZoom")) then
        if (GetCVar("minimapInsideZoom")+0 >= 3) then
            Minimap:SetZoom(Minimap:GetZoom() - 1);
            tempzoom = 1;
        else
            Minimap:SetZoom(Minimap:GetZoom() + 1);
            tempzoom = -1;
        end
    end
    if (GetCVar("minimapInsideZoom")+0 == Minimap:GetZoom()) then
        Minimap:SetZoom(Minimap:GetZoom() + tempzoom);
        _QuestieFramePool._lastMiniInside = true
        _QuestieFramePool._lastMiniInsideCheck = GetTime()
        return true
    else
        _QuestieFramePool._lastMiniInside = false
        _QuestieFramePool._lastMiniInsideCheck = GetTime()
        Minimap:SetZoom(Minimap:GetZoom() + tempzoom);
        return false
    end
end

function _QuestieFramePool:Questie_Tooltip(self)
    if GetTime() - _QuestieFramePool.lastTooltipShowHack < 0.05 and GameTooltip:IsShown() then
        return
    end
    _QuestieFramePool.lastTooltipShowHack = GetTime()
    local Tooltip = GameTooltip;
    Tooltip._owner = self;
    Tooltip:SetOwner(self, "ANCHOR_CURSOR"); --"ANCHOR_CURSOR" or (self, self)

    local maxDistCluster = 1.5
    local mid = WorldMapFrame:GetMapID();
    if mid == 947 then -- world
        maxDistCluster = 8
    elseif mid == 1415 or mid == 1414 then -- kalimdor/ek
        maxDistCluster = 4
    end
    if self.miniMapIcon then
        if _QuestieFramePool:isMinimapInside() then
            maxDistCluster = 1 / (1+Minimap:GetZoom())
        else
            maxDistCluster = 2 / (1+Minimap:GetZoom())
        end
    end
    local already = {}; -- per quest
    local alreadyUnique = {}; -- per objective

    local headers = {};
    local footers = {};
    local contents = {};

    -- TODO: change how the logic works, so this can be nil
    if self.data.ObjectiveIndex == nil then -- it is nil on some notes like starters/finishers, because its for objectives. However, it needs to be an integer here for duplicate checks
        self.data.ObjectiveIndex = 0
    end

    --for k,v in pairs(self.data.tooltip) do
    --Tooltip:AddLine(v);
    --end

    local npcOrder = {};
    local questOrder = {};
    if 1 then
        for _, icon in pairs(usedFrames) do -- I added "usedFrames" because I think its a bit more efficient than using _G but I might be wrong
            if icon and icon.data and icon.x and icon.AreaID == self.AreaID then
                local dist = QuestieFramePool:euclid(icon.x, icon.y, self.x, self.y);
                if dist < maxDistCluster then
                    if icon.data.Type == "available" or icon.data.Type == "complete" then
                        if npcOrder[icon.data.Name] == nil then
                            npcOrder[icon.data.Name] = {};
                        end
                        local dat = {};
                        if icon.data.Type == "complete" then
                            dat.type = "(Complete)";
                        else
                            dat.type = "(Available)";
                        end
                        dat.title = icon.data.QuestData:GetColoredQuestName()
                        dat.subData = icon.data.QuestData.Description
                        npcOrder[icon.data.Name][dat.title] = dat
                        --table.insert(npcOrder[icon.data.Name], dat);
                    elseif icon.data.ObjectiveData and icon.data.ObjectiveData.Description then
                        local key = icon.data.QuestData:GetColoredQuestName();
                        if not questOrder[key] then
                            questOrder[key] = {};
                        end
                        icon.data.ObjectiveData:Update(); -- update progress info
                        if icon.data.Type == "event" then
                            questOrder[key][icon.data.ObjectiveData.Description] = true
                        else
                            --dat.subData = icon.data.ObjectiveData
                            local text = icon.data.ObjectiveData.Description
                            if icon.data.ObjectiveData.Needed then
                                text = tostring(icon.data.ObjectiveData.Collected) .. "/" .. tostring(icon.data.ObjectiveData.Needed) .. " " .. text
                            end
                            if not questOrder[key][text] then
                                questOrder[key][text] = {}
                            end
                            if icon.data.Name then
                                questOrder[key][text][icon.data.Name] = true
                            end
                            --table.insert(questOrder[key], text);--questOrder[key][icon.data.ObjectiveData.Description] = tostring(icon.data.ObjectiveData.Collected) .. "/" .. tostring(icon.data.ObjectiveData.Needed) .. " " .. icon.data.ObjectiveData.Description--table.insert(questOrder[key], tostring(icon.data.ObjectiveData.Collected) .. "/" .. tostring(icon.data.ObjectiveData.Needed) .. " " .. icon.data.ObjectiveData.Description);
                        end
                    end
                end
            end
        end
    end

    Tooltip.npcOrder = npcOrder
    Tooltip.questOrder = questOrder
    Tooltip._rebuild = function(self)
        local shift = IsShiftKeyDown()
        local haveGiver = false -- hack
        for k, v in pairs(self.npcOrder) do -- this logic really needs to be improved
            haveGiver = true
            self:AddLine("|cFF33FF33"..k);
            for k2, v2 in pairs(v) do
                if v2.title ~= nil then
                    self:AddDoubleLine("   " .. v2.title, v2.type);
                end
                if v2.subData and shift then
                    for _,line in pairs(v2.subData) do
                        self:AddLine("      |cFFDDDDDD" .. line);
                    end
                end
            end
        end
        for k, v in pairs(self.questOrder) do -- this logic really needs to be improved
            if haveGiver then
                self:AddLine(" ")
                self:AddDoubleLine(k, "(Active)");
                haveGiver = false -- looks better when only the first one shows (active)
            else
                self:AddLine(k);
            end
            if shift then
                for k2, v2 in pairs(v) do
                    for k3 in pairs(v2) do
                        self:AddLine("   |cFFDDDDDD" .. k3);
                    end
                    self:AddLine("      |cFF33FF33" .. k2);
                end
            else
                for k2, v2 in pairs(v) do
                    self:AddLine("   |cFF33FF33" .. k2);
                end
            end
        end
    end
    Tooltip:_rebuild() -- we separate this so things like MODIFIER_STATE_CHANGED can redraw the tooltip
    --Tooltip:AddDoubleLine("" .. self:GetFrameStrata(), ""..self:GetFrameLevel())
    --Tooltip:AddDoubleLine("" .. self.glow:GetFrameStrata(), ""..self.glow:GetFrameLevel())
    Tooltip:SetFrameStrata("TOOLTIP");
    QuestieTooltips.lastTooltipTime = GetTime() -- hack for object tooltips
    Tooltip:Show();
end

function _QuestieFramePool:Questie_Click(self)
    Questie:Print("Click!");
    --TODO Logic for click!
    -- Preferably call something outside, keep it "abstract" here
end
