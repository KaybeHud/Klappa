if not (Klappa2) then return; end;
local _G = getfenv(0);

local Klappa2 = Klappa2;
local config = {};

local L = LibStub("AceLocale-3.0"):GetLocale("Klappa2")
local LBF = LibStub("LibButtonFacade",true)



Klappa2.PopUpButton = {}
Klappa2.PopUpButton.prototype ={}
Klappa2.PopUpButton.metatable ={__index = Klappa2.PopUpButton.prototype}

function Klappa2.PopUpButton:new(parent, idx, id, bar)
	local instance = setmetatable({}, self.metatable)
	instance:init(parent, idx, id, bar)
	return instance
end


function Klappa2.PopUpButton.prototype:init(parent, idx, id, bar)
	self.index = idx;
	if (self.index == 1) then
		self.isMain = true;
	else
		self.isMain = false
	end
	self.id = id;
	self.bar = bar;
	self.barid = bar.index;
	self.hindex = parent.index
	self.outOfRange = false;
	self.showgrid = 0;
	self.flashing = 0;
	self.flashtime = 0;
	self.elapsed = 0;

	config = Klappa2.config.bars;
	self.parent = parent;
	
	if not (parent.header.popupButtons[self.index] == nil) then
		self.button = self.parent.header.popupButtons[self.index].button
		self.button:SetAttribute("deleted", false);
		--self.button:SetParent(self.parent)
		self.button:Show()
		--self:AddButtonToMasque(self.button)
	else
		self:CreatePopupButton();
	end
	self:LoadSpell();
	self:AddOptions()
	
end


function Klappa2.PopUpButton.prototype:CreatePopupButton()
	local name = "Klappa2".."Bar"..self.barid.."Row"..self.hindex.."Button"..self.index;

	self.button = CreateFrame("CheckButton", name, self.parent.header, "SecureHandlerStateTemplate, SecureHandlerEnterLeaveTemplate, SecureActionButtonTemplate,ActionButtonTemplate")--"SecureAnchorUpDownTemplate,SecureActionButtonTemplate,ActionButtonTemplate"); --,SecureHandlerShowHideTemplate
	self.button.name = name;

	self.button:SetWidth(config[self.barid].size);
	self.button:SetHeight(config[self.barid].size);
	--self.button:SetClampedToScreen(true);
	self.button.class = self;
	self.button.id = self.id;
	self.button.index = self.index;
	self.button:SetScript("OnEnter", function() self:ShowTooltip(self.button); end);
	self.button:SetScript("OnLeave", function() self:HideTooltip(self.button); end);

	self:ButtonProperties();
	self:SetAttributes();
	if LBF and self.bar.root.LBFGroup then
		self.button.LBFButtonData = {
			Button = self.button,
			Highlight = self.button:GetHighlightTexture(),
			Pushed = self.button:GetPushedTexture(),
			Checked = self.button:GetCheckedTexture(),
		}
		self.bar.root.LBFGroup:AddButton(self.button, self.button.LBFButtonData)
	end
	--self:AddButtonToMasque(self.button)
	self.button:Show();
	
end

function Klappa2.PopUpButton.prototype:SetAttributes()
	SecureHandlerWrapScript(self.button,"OnEnter",self.parent.header, [[
		control:Run(show);
		--print("enter pop")
		]]);
	--SetUpAnimation(self.button, self.button:Hide(),nil,0.3,nil,nil)
	-- SecureHandlerWrapScript(self.button,"OnLeave",self.parent.header, [[
		-- inHandler = self:IsUnderMouse(true)
		
		-- if not inHandler then
			-- --header:SetAttribute("show", false)
			-- print("is under1")
			-- queued = control:SetTimer(1.0,"hideTimer");
			-- print("queued")
			-- print(queued)
			-- --control:Run(close);
		-- end	    
		-- --control:Run(close);	--control:SetTimer(fadetime,"hide");
		
		-- --print("leave pop")

		-- ]]);
		
		self.button:SetAttribute("_ontimer", [[
			print("in Timer_1")
			control:Run(close)]]);
	self.parent.header:SetAttribute("_ontimer", [[
			print("in Timer_Header")
			control:Run(close)]]);
		
	SecureHandlerWrapScript(self.button,"OnLeave",self.parent.header,[[return true, ""]], [[
		inHeader =  control:IsUnderMouse(true)
		
		if not inHeader then
			--header:SetAttribute("show", false)
			control:Run(close);
		end	    

	]]);
		
		
	SecureHandlerWrapScript(self.button, "OnClick", self.parent.header, [[clicked = true;
										control:Run(close);
										]]);
	
	--self.button:SetParent(self.parent.header)
end

function Klappa2.PopUpButton.prototype:ChangeID(id)
	self.button.id = id;
	self:LoadSpell();
	self.button:Show();
	config[self.barid].headers[self.parent.index].popups[self.index].id = id;
end

function Klappa2.PopUpButton.prototype:AddButtonToMasque(button)
	if MSQ then
		if myGroup then
			myGroup:AddButton(button)		
		end
	end
end

function Klappa2.PopUpButton.prototype:RemoveButtonFromMasque(button)
	if MSQ then
		if myGroup then
			myGroup:RemovedButton(button)		
		end
	end
end

function Klappa2.PopUpButton.prototype:UpdateLayout(isVert, isRtDn, x, y)

	local padding = config[self.barid].padding;
	if (isVert and isRtDn) then
		self.button:ClearAllPoints();
		self.button:SetPoint("TOPLEFT", self.parent.header, "TOPLEFT", x , y);
	elseif (isVert and not isRtDn) then
		self.button:ClearAllPoints();
		self.button:SetPoint("TOPRIGHT", self.parent.header, "TOPRIGHT", x , y);
	elseif (not isVert and isRtDn) then
		self.button:ClearAllPoints();
		self.button:SetPoint("TOPLEFT", self.parent.header, "TOPLEFT", x, y );
	elseif (not isVert and not isRtDn) then
		self.button:ClearAllPoints();
		self.button:SetPoint("BOTTOMLEFT", self.parent.header, "BOTTOMLEFT", x, y );
	end

	self.button:SetAlpha(config[self.barid].popupAlpha);
	self.button:SetScale(config[self.barid].popupScale);
end

function Klappa2.PopUpButton.prototype:AddOptions()
	--Klappa2.options.args["Bar"..self.barid].args["Header"..self.hindex].args[self.index] = {
	--local changeId = {}
	if self.isMain then
		--changeId = {
		Klappa2.options.args["Bar"..self.barid].args["Header"..self.hindex].args["Button"..self.index] = {
			name = L["Change main button-ID"],
			desc = L["Change the ID of this mainbutton"],
			type = "range",
			step = 1,
			min = 1,
			max = 120,
			isPercent = false,
			get = function()return self.button.id; end,
			set = function(info,value) self:ChangeID(value); end
		}
	else
		--changeId = {
		Klappa2.options.args["Bar"..self.barid].args["Header"..self.hindex].args["PopUpButton"..self.index] = {
			name = L["Change ID of popup button: "]..self.index -1,
			desc = L["Change the ID of this popup button"],
			type = "range",
			step = 1,
			min = 1,
			max = 120,
			isPercent = false,
			get = function() return self.button.id; end,
			set = function(info,value) self:ChangeID(value); end
		}
	end
	--}
	--Klappa2.options.args["Bar"..self.barid].args["Header"..self.parent.index].args = {type = "group"}
	--table.insert(Klappa2.options.args["Bar"..self.barid].args["Header"..self.parent.index].args, changeId )
	--Klappa2.options.args["Bar"..self.barid].args["Header"..self.parent.index].args
end

function Klappa2.PopUpButton.prototype:ButtonProperties()
	local button = self.button;
	local name = button.name;

	--Create textures
	button.icon = _G[name .. "Icon"];
	button.icon:SetTexCoord(0.06, 0.94, 0.06, 0.94);

	button.normalTexture = _G[name .. "NormalTexture"];
	button.normalTexture:SetVertexColor(1, 1, 1, 0.5);

	button.pushedTexture = button:GetPushedTexture();
	button.highlightTexture = button:GetHighlightTexture();

	button.cooldown = _G[name.."Cooldown"];
	button.border = _G[name.."Border"];
	button.macroName = _G[name.."Name"];
	button.hotkey = _G[name.."HotKey"];
	button.count = _G[name.."Count"];
	button.flash = _G[name.."Flash"];
	button.flash:Hide();

	self:ApplyStyle();

	-- Register Buttons
	button:RegisterForDrag("LeftButton", "RightButton");
	button:RegisterForClicks("AnyUp");

	--Set scripts
	button:SetScript("OnDragStart", function()  self:ButtonDrag(); end);
	button:SetScript("PostClick", function() self:UpdateButton(); end);
	button:SetScript("OnEvent", function(arg1,event) self:OnEventFunc(event, arg1); end);
	button:SetScript("OnUpdate", function(arg1,elapsed) self:OnUpdate(arg1,elapsed); end);
	button:SetScript("OnReceiveDrag", function() self:ButtonDrop(); end );

	--Register general events
	self:RegisterGeneralEvents();

	--Set Attributes
	button:SetAttribute("type", "action");
	button:SetAttribute("checkselfcast", true);
	button:SetAttribute("deleted", false);

	self:UpdateButton();
	--self:UpdateHotkeys();
end
