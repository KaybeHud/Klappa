if not (Klappa2) then return; end;
local _G = getfenv(0);

local Klappa2 = Klappa2;
local config = {};

local L = LibStub("AceLocale-3.0"):GetLocale("Klappa2")

Klappa2.Header = {}
Klappa2.Header.prototype = {}
Klappa2.Header.metatable = {__index= Klappa2.Header.prototype}

function Klappa2.Header:new(idx, bar)
	local instance = setmetatable({}, self.metatable)
	instance:init(idx, bar)
	return instance
end

function Klappa2.Header.prototype:init(idx, bar)

	self.index = idx;

	self.bar = bar;
	self.barid = bar.index;

	config = Klappa2.config.bars;
	self:CreateHeader();
	self:AddOptions();

	self.popupButtons = {};
	self.header.popupButtons = self.popupButtons;
	self.header.popups = 0;

	if(config[self.barid].headers[idx].popups ~= nil) then
		for i, popup in pairs (config[self.barid].headers[idx].popups) do
			self.header.popups = self.header.popups + 1;
			self.header.popupButtons[i] = Klappa2.PopUpButton:new(self, i, popup.id, bar);
		end
	else
		config[self.barid].headers[idx] = {};
		config[self.barid].headers[idx].popups = {};
		self.header.popups = self.header.popups + 1;
		self.header.popupButtons[1] = Klappa2.PopUpButton:new(self, 1, 1, bar);
	end

	--self.header.overlay:SetWidth(config[self.barid].size * self.header.popups);
	--self.header.overlay:SetHeight(config[self.barid].size);
	--Klappa2:Debug("Header: "..self.header:GetName().." created");
end

function Klappa2.Header.prototype:CreateHeader()
	local name = "Klappa2Bar"..self.barid.."Header"..self.index;
	self.header = CreateFrame("Button", name, self.bar.root, "SecureHandlerClickTemplate, SecureHandlerEnterLeaveTemplate, SecureHandlerAttributeTemplate");
	self.header.name = name;
	self.header:SetPoint("TOPLEFT", self.bar.root, "TOPLEFT", 0, 0);
	
	self.header:SetWidth(config[self.barid].size);
	self.header:SetHeight(config[self.barid].size);
	
	-- self.header:SetBackdrop({
		-- bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		-- tile = true,
		-- tileSize = 1,
		-- edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		-- edgeSize = 0,
		-- insets = {left = 0, right = 0, top = 0, bottom = 0}
	-- })
	-- self.header:SetBackdropColor(1, 1, 0, 1)
	-- self.header:SetBackdropBorderColor(0.5, 0.5, 0, 0)
	
	
	self.header.texture = self.header:CreateTexture();
	self.header.texture:SetTexture(0,0.5,0.5,0.5);
	self.header.texture:SetAllPoints(self.header);
	
	self.header:Show()
	
	
	
	------------
	-- local overlay = CreateFrame("Button", name .. "Overlay", bar)
	-- overlay:EnableMouse(true)
	-- overlay:RegisterForDrag("LeftButton")
	-- overlay:RegisterForClicks("LeftButtonUp")
	-- overlay:SetBackdrop({
		-- bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		-- tile = true,
		-- tileSize = 1,
		-- edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		-- edgeSize = 0,
		-- insets = {left = 0, right = 0, top = 0, bottom = 0}
	-- })
	-- overlay:SetBackdropColor(0, 1, 1, 0.5)
	-- overlay:SetBackdropBorderColor(0.5, 0.5, 0, 0)
	-- overlay.Text = overlay:CreateFontString(nil, "ARTWORK")
	-- overlay.Text:SetFontObject(GameFontNormal)
	-- overlay.Text:SetText("Main:"..self.barid)
	-- overlay.Text:Show()
	-- overlay.Text:ClearAllPoints()
	-- overlay.Text:SetPoint("CENTER", overlay, "CENTER")

	--overlay:ClearAllPoints()
	-- overlay:SetFrameLevel(self.header:GetFrameLevel() + 20)
	-- overlay:SetWidth(self.header:GetWidth());
	-- overlay:SetHeight(self.header:GetHeight());

	-- local anchor = "CENTER"
	-- overlay:SetPoint(anchor, self.header, anchor)
	-- overlay:Hide()
	-- self.header.overlay = overlay
----------
	self.header.class = self;
	self.header.index = self.index;

	self:SetAttributes();
end

function Klappa2.Header.prototype:SetAttributes()

	self.header:Execute ( [[show = [=[
		local popups = newtable(self:GetChildren())
		for i, button in ipairs(popups) do
			--print(button:GetName())
			isDel = button:GetAttribute("deleted")
			if not (isDel) then
				button:Show()
			end
		end
	]=] ]])

	self.header:Execute( [[close = [=[
		local popups = newtable(self:GetChildren())
		isUnder = false;
			--for i, button in ipairs(popups) do
				--if (button:IsUnderMouse(true)) then
				--	isUnder = true;
				--	return;
				--end
			--end
			if not (isUnder) or (clicked) then
				for i, button in ipairs(popups) do
					if not (i == 1) then
						button:Hide()
					end
				end
				clicked = false;
			end
		]=] ]])
		
	
	self.header:SetAttribute("_onleave",[[
		return
		]])
		
end

function Klappa2.Header.prototype:UpdateLayout(x, y, isVert, isRtDn)
	self.header:ClearAllPoints();
	--local border = 10			-- Rahmen um mit der Maus verschieben zu können
	local headerX = x
	local headerY = y
	local scale = config[self.barid].headerScale;
	local size = config[self.barid].size;
	
	for idx, popButtonClass in pairs(self.header.popupButtons) do
		local x, y = 0, 0;
		local index = idx;
		local padding = 0;
		if not(index == 1) then
			padding = config[self.barid].padding;
		end
		
		if (isVert and isRtDn) then
			x = (size+padding)* index - size;
			 
			self.header:SetPoint("TOPLEFT", self.bar.root, "TOPLEFT", headerX, headerY);
			self.header:SetWidth(config[self.barid].size * (self.header.popups)+ (padding * self.header.popups));
			self.header:SetHeight(config[self.barid].size);
		elseif (isVert and not isRtDn) then
			x = -((size+padding)* index - size)
			
			self.header:SetPoint("TOPRIGHT", self.bar.root, "TOPRIGHT", -headerX, headerY);
			self.header:SetWidth(config[self.barid].size * (self.header.popups) + (padding * self.header.popups));
			self.header:SetHeight(config[self.barid].size);
		elseif (not isVert and isRtDn) then
			y = (-size-padding)* index + size
			
			self.header:SetPoint("TOPLEFT", self.bar.root, "TOPLEFT", headerX, headerY);
			self.header:SetWidth(config[self.barid].size);
			self.header:SetHeight(config[self.barid].size * self.header.popups + (padding * self.header.popups));
		elseif (not isVert and not isRtDn) then
			y = -((-size-padding)* index + size)
			
			self.header:SetPoint("BOTTOMLEFT", self.bar.root, "BOTTOMLEFT", headerX, headerY);
			self.header:SetWidth(config[self.barid].size);
			self.header:SetHeight(config[self.barid].size * self.header.popups + (padding * self.header.popups));
		end
		popButtonClass:UpdateLayout(isVert, isRtDn, x, y);
	end
	self.header:SetAlpha(config[self.barid].alpha);
end

function Klappa2.Header.prototype:ShowPops()
	self.header:Execute([[
		control:Run(show)
		]]
	)
end

function Klappa2.Header.prototype:HidePops()
	self.header:Execute([[
		control:Run(close)
		]]
	)
end

function Klappa2.Header.prototype:AddOptions()
	Klappa2.options.args["Bar"..self.barid].args["Header"..self.index] = {
		name = L["Main button "]..self.index,
		desc = L["Options for this main button"],
		type = "group",
		order = self.index + 10,
		args = {}
		};
	Klappa2.options.args["Bar"..self.barid].args["Header"..self.index].args = {
		addPopup = {
			name = L["Add popup button"],
			desc = L["Add a new popup button"],
			type = "execute",
			order = 2,
			func = function() self:AddPopup() end
		},
		delPopup = {
			name = L["Delete popup button"],
			desc = L["Delete the last popup button"],
			type = "execute",
			order = 3,
			func = function() self:DelPopup() end
		},
	}
end

function Klappa2.Header.prototype:AddPopup()
	self.header.popups = self.header.popups + 1;
	local popupid = self.header.popups;
	if(popupid >= 120 or popupid == nil) then self.header.popups = 120; end
	self.header.popupButtons[self.header.popups] = Klappa2.PopUpButton:new(self, self.header.popups, popupid, self.bar);
	config[self.barid].headers[self.index].popups[self.header.popups] = {};
	config[self.barid].headers[self.index].popups[self.header.popups].id = popupid;
	myGroup:AddButton(self.header.popupButtons[self.header.popups])
	self.bar:UpdateLayout();
end

function Klappa2.Header.prototype:DelPopup()
	local lastpopup = self.header.popups;
	--Klappa2:Debug(lastpopup)
	if(lastpopup <= 1) then self.header.popups = 1; print("kein button mehr") return end;
	self.header.popupButtons[lastpopup].button:Hide();
	self.header.popupButtons[lastpopup].button:SetAttribute("deleted", true);

	config[self.barid].headers[self.index].popups[lastpopup] = nil;
	self.header.popups = lastpopup - 1;
	self.bar:UpdateLayout();

	Klappa2.options.args["Bar"..self.barid].args["Header"..self.index].args[lastpopup] = nil;
end
