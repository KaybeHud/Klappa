if not (Klappa2) then return; end;
local _G = getfenv(0);

local Klappa2 = Klappa2;
local config = {};

local L = LibStub("AceLocale-3.0"):GetLocale("Klappa2")
local LBF = LibStub("LibButtonFacade",true)

Klappa2.Bar = {}
Klappa2.Bar.prototype = {}
Klappa2.Bar.metatable = {__index = Klappa2.Bar.prototype}


function Klappa2.Bar:new(index)
	local instance = setmetatable({}, self.metatable)
	instance:init(index)
	return instance
end

function Klappa2.Bar.prototype:init(index)
		config = Klappa2.config.bars;
		self.index = index;
		self.locked = true;
		self:LoadDefaults();
		self:AddOptions();
		self:CreateBar();
		self.root.headers = {};
		if LBF then
			self.root.LBFGroup = LBF:Group("Klappa2", L["Bar "]..self.index)
			LBF:RegisterSkinCallback("Klappa2", self.SkinChanged, self);
		end
		if(config[self.index].headers == nil) then
			config[self.index].headers = {};
			config[self.index].headers[1] = {};
			config[self.index].headers[1].popups = {};
			self.root.headers[1] = Klappa2.Header:new(1, self);
		else
			for i, button in pairs (config[self.index].headers) do
				self.root.headers[i] = Klappa2.Header:new(i, self);
			end
		end
		self:LoadPosition();
		self:UpdateLayout();
end

function Klappa2.Bar.prototype:CreateBar()
	local name = "Klappa2Bar"..self.index
	self.root = CreateFrame("Frame", name, UIParent, "SecureHandlerStateTemplate");
	self.root:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
	self.root:RegisterForDrag("LeftButton");
	self.root:EnableMouse(false);
	self.root:SetMovable(true);
	self.root:SetClampedToScreen(true);
	self.root.name = name;
	-------
	--print("index")
	--print(self.index)
	--self.root:SetWidth(config[self.index].size);
	--self.root:SetHeight(config[self.index].size);
---
	self.root.texture = self.root:CreateTexture();
	self.root.texture:SetTexture(0,0,0.5,0);
	self.root.texture:SetAllPoints(self.root);
end

function Klappa2.Bar.prototype:SkinChanged(SkinID, Gloss, Backdrop, Group, Button, Colors)
	if(Group == L["Bar "]..self.index) then
		config[self.index].skin.ID = SkinID
		config[self.index].skin.Gloss = Gloss
		config[self.index].skin.Backdrop = Backdrop
		config[self.index].skin.Colors = Colors
	end
end

function Klappa2.Bar.prototype:UpdateLayout()
	local rootx, rooty = 0, 0;
	local overlapp = 20;
	local isVert, isRtDn = false, false;
	local size = config[self.index].size;
	local orientation = config[self.index].orient;
	if (orientation == "horzdown") then
		isRtDn = true;
	elseif (orientation == "vertleft") then
		isVert = true;
	elseif (orientation == "vertright") then
		isVert = true;
		isRtDn = true;
	end
	if (isVert) then
		rootx = size;
	else
		rooty = size;
	end
	for idx, buttonClass in pairs(self.root.headers) do
		local x, y = 0, 0;
		local padding = config[self.index].padding;
		if (isVert) then
			y = (-size-padding)*(buttonClass.index - 1);
			rooty = rooty + size + padding;
		else
			x = (size+padding)*(buttonClass.index - 1);
			rootx = rootx + size + padding;
		end
		buttonClass:UpdateLayout(x, y, isVert, isRtDn);
	end
	self.root:SetScale(config[self.index].buttonScale);
	self.root:SetWidth(rootx + overlapp); --overlapp  um für links  und rechts noch einen Rand zu haben
	self.root:SetHeight(rooty + overlapp); -- für den Rand oben und unten,
end

function Klappa2.Bar.prototype:ToggleLock()
	if (config[self.index].locked) then
		-- self.root:EnableMouse(true);
		-- self.root:SetScript("OnDragStart", function() self:StartDrag(); end);
		-- self.root:SetScript("OnDragStop", function() self:StopDrag(); end);
		-- self.root.texture:SetTexture(0, 0, 0.5, 1)
		-- self.root:SetFrameLevel(4);
		config[self.index].locked = false;
		-- Show all popups
		for idx, buttonClass in pairs(self.root.headers) do
			buttonClass:ShowPops();
			--print("unlock BAr, show overlay")
			self.root.headers[idx].header.overlay:SetScript("OnDragStart", function() self:StartDrag(); end);
			self.root.headers[idx].header.overlay:SetScript("OnDragStop", function() self:StopDrag(); end);
			self.root.headers[idx].header.overlay:Show();
		end
	else
		-- self.root:EnableMouse(false);
		-- self.root:SetScript("OnDragStart", nil);
		-- self.root:SetScript("OnDragStop", nil);
		-- self.root.texture:SetTexture(0, 0, 0.5, 0);
		-- self.root:SetAttribute("state", 0)
		config[self.index].locked = true;
		for idx, buttonClass in pairs(self.root.headers) do
			--print("lock BAr, hide overlay")
			buttonClass:HidePops();
			self.root.headers[idx].header.overlay:Hide();
			self.root.headers[idx].header.overlay:SetScript("OnDragStart", nil);
			self.root.headers[idx].header.overlay:SetScript("OnDragStop", nil);
		end
	end
end

function Klappa2.Bar.prototype:ToggleLockButtons()
	if(config[self.index].lockButtons) then
		config[self.index].lockButtons = false;
	else
		config[self.index].lockButtons = true;
	end
end

function Klappa2.Bar.prototype:StartDrag()
	self.root:StartMoving();
end

function Klappa2.Bar.prototype:StopDrag()
	self.root:StopMovingOrSizing();
	self:SavePosition();
end

function Klappa2.Bar.prototype:LoadPosition()
	local x, y, s = config[self.index].rootX, config[self.index].rootY, self.root:GetEffectiveScale();

	self.root:ClearAllPoints();
	self.root:SetPoint(x and "TOPLEFT" or "CENTER", UIParent, x and "BOTTOMLEFT" or "CENTER", x or 0, y or 0);
end

function Klappa2.Bar.prototype:SavePosition()
	local x, y, s = self.root:GetLeft(), self.root:GetTop(), self.root:GetEffectiveScale();

	config[self.index].rootX = x;
	config[self.index].rootY = y;
end


function Klappa2.Bar.prototype:AddMainButton()
	idx = config[self.index].numberButtons + 1;
	--local nextid = self.root.headers[idx-1].header.popups + 1;
	--if(nextid >= 120) then nextid = 120; end
	config[self.index].headers[idx] = {};
	--config[self.index].headers[idx].id = nextid or config[self.index].id;
	config[self.index].headers[idx].popups = {};

	self.root.headers[idx] = Klappa2.Header:new(idx, self);
	self.root.headers[idx]:AddPopup()
	config[self.index].numberButtons = idx;
	self:UpdateLayout();
end

function Klappa2.Bar.prototype:DelMainButton()
	index = config[self.index].numberButtons;
	if (index == 0 or index == nil) then return end;
	self.root.headers[index].header:Hide();
	self.root.headers[index].header.popups = nil;
	self.root.headers[index].header = nil;
	self.root.headers[index] = nil;

	config[self.index].headers[index] = nil;
	Klappa2.options.args["Bar"..self.index].args["Header"..index] = nil;
	config[self.index].numberButtons = index-1;
	self:UpdateLayout();
end

function Klappa2.Bar.prototype:LoadDefaults()
	--if(config[self.index] == nil) then config[self.index] = {} end  --Änderung
	if (config[self.index].numberButtons == nil) then config[self.index].numberButtons = 1; end
	if (config[self.index].orient == nil) then config[self.index].orient = "vertleft"; end
	if (config[self.index].buttonScale == nil) then config[self.index].buttonScale = 1; end
	if (config[self.index].popupScale == nil) then config[self.index].popupScale = 1; end
	if (config[self.index].alpha == nil) then config[self.index].alpha = 1; end
	if (config[self.index].popupAlpha == nil) then config[self.index].popupAlpha = 1; end
	if (config[self.index].locked == nil) then config[self.index].locked = true; end
	if (config[self.index].lockButtons == nil) then config[self.index].lockButtons = true; end
	if (config[self.index].padding == nil) then config[self.index].padding = 1; end
	if (config[self.index].size == nil) then config[self.index].size = 36; end
	if (config[self.index].tooltip == nil) then config[self.index].tooltip = true; end
	if (config[self.index].skin == nil) then config[self.index].skin = {}; end
end

function Klappa2.Bar.prototype:AddOptions()
	Klappa2.options.args["Bar"..self.index] = {
		name = L["Bar "]..self.index,
		desc = L["Options for the bar"],
		type = "group",
		args = {}
		};
	Klappa2.options.args["Bar"..self.index].args = {
		lock = {
			name = L["Lock the frame"],
			desc = L["Lock the frame"],
			type = "toggle",
			order = 1,
			get = function() return config[self.index].locked end,
			set = function(info,value) self:ToggleLock() end,
			disabled = function() return InCombatLockdown() end,
		},
		lockbuttons = {
			name = L["Button Lock"],
			desc = L["Lock the buttons"],
			type = "toggle",
			order = 2,
			get = function() return config[self.index].lockButtons end,
			set = function(info,value) self:ToggleLockButtons() end,
		},
		tooltip = {
			name = L["Tooltip"],
			desc = L["Enable/disable the tooltips"],
			type = "toggle",
			order = 3,
			get = function() return config[self.index].tooltip end,
			set = function(info,value) config[self.index].tooltip = value end,
		},
		padding = {
			type = "range",
			name = L["Padding"],
			desc = L["Set the padding of the buttons"],
			order = 4,
			step = 0.05,
			min = 0.05,
			max = 25.0,
			isPercent = false,
			get = function() return config[self.index].padding end,
			set = function(v)
				config[self.index].padding = v;
				self:UpdateLayout();
			end
		},
		mainScale = {
			type = "range",
			name = L["Scale buttons"],
			desc = L["Scale the buttons"],
			order = 5,
			step = 0.05,
			min = 0.25,
			max = 5.0,
			isPercent = false,
			get = function() return config[self.index].buttonScale; end,
			set = function(info,value)
				config[self.index].buttonScale = value; self.root:SetScale(value); end
		},
		orientation = {
			type = "select",
			name = L["Orientation"],
			desc = L["Set the orientation of the Klappa2 Bar."],
			order = 6,
			get = function() return config[self.index].orient; end,
			set = function(info,value) config[self.index].orient = value; self:UpdateLayout(); end,
			values = {
				["horzup"] = L["Horizontal, Grow Up"],
				["horzdown"] = L["Horizontal, Grow Down"],
				["vertright"] = L["Vertical, Grow Right"],
				["vertleft"] = L["Vertical, Grow Left"],
			},
		},
		add = {
			name = L["New main button"],
			desc = L["Add a new main button"],
			order = 7,
			type = "execute",
			func = function() self:AddMainButton() end,
		},
		del = {
			name = L["Delete main button"],
			desc = L["Delete the last main button"],
			order = 8,
			type = "execute",
			func = function() self:DelMainButton() end,
		},
	}
end
