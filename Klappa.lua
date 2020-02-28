Klappa2 = LibStub("AceAddon-3.0"):NewAddon("Klappa2", "AceConsole-3.0")  --"LibFuBarPlugin-3.0",

local _G = getfenv(0)
local L = LibStub("AceLocale-3.0"):GetLocale("Klappa2")

-- LDB
local ldb = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Klappa", {
    type = "launcher",
    icon = "Interface\\Icons\\INV_Weapon_ShortBlade_17",
    OnClick = function(self, button)
		if (button == "RightButton") then
			for idx, bar in pairs(Klappa2.bars) do
				bar:ToggleLock()
			end
		else
			LibStub("AceConfigDialog-3.0"):Open("Klappa")
		end
	end,
	OnTooltipShow = function(Tip)
		if not Tip or not Tip.AddLine then
			return
		end
		Tip:AddLine("Klappa")
		Tip:AddLine("|cFFff4040"..L["Left Click|r to open configuration"], 1, 1, 1)
		Tip:AddLine("|cFFff4040"..L["Right Click|r to lock/unlock bars"], 1, 1, 1)
	end,
})
--------------------------------------

-- Fubar-Options
Klappa2.name = "Klappa";
Klappa2.hasIcon = "Interface\\Icons\\INV_Weapon_ShortBlade_17";
Klappa2.hasNoColor = true;
Klappa2.defaultMinimapPosition = 200;
Klappa2.clickableTooltip  = false;
Klappa2.independentProfile = true;
Klappa2.defaultPosition = "RIGHT";
Klappa2.hideWithoutStandby = true;
Klappa2.cannotDetachTooltip = true;

--Fubar methods
function Klappa2:OnUpdateFuBarText()
	self:SetFuBarText("Klappa")
end

function Klappa2:OnUpdateFuBarTooltip()
    GameTooltip:AddLine("Klappa")
    GameTooltip:AddLine("Click to open the configuration", 0, 1, 0)
end

function Klappa2:OnFuBarClick(button)
	self:OpenConfigMenu();
end
--------------------------------

local defaults =
{
	char =
	{
	bars = {
		{
			headers = {
				{
					popups =
					{
						{
							["id"] = 1,
						}, -- [1]
					},
				},
			},
			skin = {},
			orient = "vertleft",
			buttonScale = 1,
			popupScale = 1,
			alpha = 1,
			popupAlpha = 1,
			locked = true,
			lockButtons = true,
			padding = 1,
			size = 35,
			tooltip = true,
			numberButtons = 1,
		},
	},

	hideUI = false,
	numberBars = 1
	}
}

----------------
function Klappa2:OnInitialize()

	self.db = LibStub("AceDB-3.0"):New("KlappaDB", defaults)
end

function Klappa2:InitOptions()
	local options = {
		name = "Klappa",
		desc = "Action bars with popup buttons",
		icon = "Interface\\Icons\\INV_Weapon_ShortBlade_17",
		type="group",
		args = {
			showUI = {
				name = L["Hide mainbar"],
				desc = L["Hides the default mainbar"],
				type = "toggle",
				order = 1,
				get = function() return Klappa2.config.hideUI end,
				set = function(info,value) Klappa2:SetDefaultUIElements(value); Klappa2.config.hideUI = value; end,
			},

			add = {
				name = L["Add Bar"],
				desc = L["Add a new bar"],
				type = "execute",
				order = 3,
				func = function() self:AddBar() end,
			},
			del = {
				name = L["Delete Bar"],
				desc = L["Delete the last bar"],
				type = "execute",
				order = 6,
				func = function() self:DeleteBar() end,
			},
			ids = {
				name = L["Show all buttonids"],
				desc = L["Shows all buttons with their ids"],
				type = "execute",
				order = 9,
				func = function() self:ShowIDs() end,
			},
		}
	}

	return options;
end

function Klappa2:OnEnable()
	Klappa2.config = self.db.char;
	self.options = self:InitOptions();
	self.OnMenuRequest = self.options;
	--self:SetConfigTable(self.options);	--for Fubar  config
	--self:SetFuBarIcon("Interface\\Icons\\INV_Weapon_ShortBlade_17");
	--self:ToggleFuBarMinimapAttached()
	--self:Hide()
	self:CreateRoot();
	self:CreateShowIDs()
	self:SetDefaultUIElements(Klappa2.config.hideUI)
	--altes self:SetConfigTable(self.options);

	LibStub("AceConfig-3.0"):RegisterOptionsTable("Klappa", self.options)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Klappa", "Klappa")
	self.optionsFrameGui = LibStub("AceConfigDialog-3.0"):Open("Klappa")
	self:RegisterChatCommand("kl", "ChatCommand")
	self:RegisterChatCommand("klappa", "ChatCommand")

end

function Klappa2:ChatCommand(input)
	if not input or input:trim() == "" then
	--InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
	LibStub("AceConfigDialog-3.0"):Open("Klappa")
  else
  print("console")
    LibStub("AceConfigCmd-3.0").HandleCommand(Klappa, "kl2", "Options", input)
  end
end

function Klappa2:SetDefaultUIElements(v)
	if(v) then
		-- Hide the main grafics
		MainMenuBarArtFrame:Hide()
		MainMenuBar:Hide()
	else
		--Show the main grafics
		MainMenuBarArtFrame:Show()
		MainMenuBar:Show()
	end
end

function Klappa2:CreateRoot()
	self.bars = {};

	if (Klappa2.config.bars == nil) then
		self.bars[1] = Klappa2.Bar:new(1);
	else
		for i, bar in pairs (Klappa2.config.bars) do
			self.bars[i] = Klappa2.Bar:new(i);
		end
	end
	self:HideEmpty();
end

function Klappa2:AddBar()
	idx = Klappa2.config.numberBars + 1;
	Klappa2.config.bars[idx] = {};
	self.bars[idx] = Klappa2.Bar:new(idx);
	Klappa2.config.numberBars = idx;
end

function Klappa2:DeleteBar()
	local idx = Klappa2.config.numberBars;
	if (idx == 0 or idx == nil) then return end;
	self.bars[idx].root:Hide();
	for i, mainbutton in pairs (self.bars[idx].root.headers) do
		self.bars[idx]:DelMainButton();
	end

	Klappa2.config.bars[idx] = nil;
	Klappa2.options.args["Bar"..idx] = nil;
	Klappa2.config.numberBars = idx-1;
end

function Klappa2:HideEmpty()
	for k, bar in pairs(Klappa2.bars) do
		for i, main in pairs(bar.root.headers) do
			for k,popup in pairs(bar.root.headers[i].popupButtons) do
				if not ( k == 1 ) then
					local popuptexture = GetActionTexture(popup.button.id);
					if not(popuptexture) then
						popup.button:Hide();
					end
				end
			end
		end
	end
end

--Creating/handling the button id overview

function Klappa2:ShowIDs()
	if(Klappa2.showIDs.show) then
		Klappa2.showIDs.show = false;
		Klappa2.showIDs:Hide();
		Klappa2.showIDs:UnregisterEvent("ACTIONBAR_SLOT_CHANGED");
	else
		Klappa2:UpdateIDs();
		Klappa2.showIDs:Show();
		Klappa2.showIDs.show = true;
		Klappa2.showIDs:RegisterEvent("ACTIONBAR_SLOT_CHANGED");
	end
end

function Klappa2:CreateShowIDs()
	local buttonsize = 35
	Klappa2.showIDs = CreateFrame("Frame","ShowIDs", UIParent);
	Klappa2.showIDs:SetMovable(true);
	Klappa2.showIDs:SetClampedToScreen(true);
	Klappa2.showIDs:SetPoint("CENTER",0,0);
	Klappa2.showIDs:SetHeight((10*buttonsize)+20);
	Klappa2.showIDs:SetWidth(12*buttonsize);

	--Rahmen um das Fenster zu verschieben
	Klappa2.handle = CreateFrame("Button", "ShowIdHandle", Klappa2.showIDs)
	Klappa2.handle:SetPoint("TOPLEFT", Klappa2.showIDs, "TOPLEFT")
	Klappa2.handle:SetFrameLevel(Klappa2.showIDs:GetFrameLevel()+20)
	Klappa2.handle:SetWidth(12*buttonsize);
	Klappa2.handle:SetHeight(20);
	Klappa2.handle:EnableMouse(true)
	Klappa2.handle:RegisterForDrag("LeftButton")
	Klappa2.handle:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		tile = true,
		tileSize = 1,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 0,
		insets = {left = 0, right = 0, top = 0, bottom = 0}
	})
	Klappa2.handle:SetBackdropColor(0, 1, 1, 0.5)
	Klappa2.handle:SetBackdropBorderColor(0.5, 0.5, 0, 0)
	Klappa2.handle.text = Klappa2.handle:CreateFontString();
	Klappa2.handle.text:SetFont("Fonts\\FRIZQT__.TTF",15);
	Klappa2.handle.text:SetText("Button IDs");
	Klappa2.handle.text:SetAllPoints(Klappa2.handle);

	Klappa2.handle:SetScript("OnDragStart", function() self:StartDrag(); end);
	Klappa2.handle:SetScript("OnDragStop", function() self:StopDrag(); end);

	Klappa2.showIDs:Hide()
	Klappa2.showIDs.show = false;

	local i = 0;
	Klappa2.showIDsTex = {};
	while (i<120) do
		Klappa2.showIDsTex[i] = CreateFrame("Button","ShowIDsTexture"..i, Klappa2.showIDs);
		row,_ = -math.modf(i/12)
		x = i%12;
		Klappa2.showIDsTex[i]:SetPoint("TOPLEFT",x*buttonsize,(row*buttonsize)-20);
		Klappa2.showIDsTex[i]:SetHeight(buttonsize);
		Klappa2.showIDsTex[i]:SetWidth(buttonsize);
		Klappa2.showIDsTex[i].texture = Klappa2.showIDsTex[i]:CreateTexture();
		Klappa2.showIDsTex[i].texture:SetAllPoints(Klappa2.showIDsTex[i]);
		Klappa2.showIDsTex[i].text = Klappa2.showIDsTex[i]:CreateFontString();
		Klappa2.showIDsTex[i].text:SetFont("Fonts\\FRIZQT__.TTF",15);
		Klappa2.showIDsTex[i].text:SetText(i+1);
		Klappa2.showIDsTex[i].text:SetAllPoints(Klappa2.showIDsTex[i]);
		Klappa2.showIDsTex[i].id = i + 1;
		Klappa2.showIDsTex[i]:HookScript("OnEnter", function(self, motion) Klappa2:ShowTooltip(self, self.id); end);
		Klappa2.showIDsTex[i]:HookScript("OnLeave", function(self, motion) Klappa2:HideTooltip(self); end);

		i=i+1;
	end
	Klappa2.showIDs:SetScript("OnEvent", function(self, event, id) Klappa2:Update(id); end);
end

function Klappa2:Update(id)
	if (Klappa2.showIDs == nil) then return end;
	if(Klappa2.showIDs.show) then
		if(id == 0) then UpdateIDs(); return; end
		local texture = GetActionTexture(id);
		Klappa2.showIDsTex[id-1].texture:SetTexture(texture);
	end
end

function Klappa2:ShowTooltip(button, id)
	GameTooltip:SetOwner(button,ANCHOR_RIGHT);
	GameTooltip:SetAction(id);
end

function Klappa2:HideTooltip(button)
	if GameTooltip:IsOwned(button) then
	--print("hide")
		GameTooltip:Hide();
	end
end

function Klappa2:UpdateIDs()
	local i = 0;
	while (i<120) do
		local texture = GetActionTexture(i+1);
		Klappa2.showIDsTex[i].texture:SetTexture(texture);
		i = i+1;
	end
end

function Klappa2:StartDrag()
	Klappa2.showIDs:StartMoving();
end

function Klappa2:StopDrag()
	Klappa2.showIDs:StopMovingOrSizing();
end
--------------------------------------------------
