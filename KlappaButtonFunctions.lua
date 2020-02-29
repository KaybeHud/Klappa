if not (Klappa2) then return; end;
local _G = getfenv(0);

local Klappa2 = Klappa2;
local LBF = LibStub("LibButtonFacade",true)
local LibSpellCount = LibStub("LibClassicSpellActionCount-1.0", true)

function Klappa2.PopUpButton.prototype:LoadSpell()
	self.button:SetAttribute("action", self.button.id);
	self:UpdateButton();
end

function Klappa2.PopUpButton.prototype:ApplyStyle()
	if LBF and self.bar.root.LBFGroup then
		self.bar.root.LBFGroup:Skin(Klappa2.config.bars[self.barid].skin.ID, Klappa2.config.bars[self.barid].skin.Gloss, Klappa2.config.bars[self.barid].skin.Backdrop, Klappa2.config.bars[self.barid].skin.Colors)
	else
		local header = CreateFrame("Frame", self.button:GetName().."DL", self.button);
		header:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 1, edgeFile = "", edgeSize = 0, insets = {left = 0, right = 0, top = 0, bottom = 0},});
		header:SetBackdropColor(0, 0, 0, 0.6);
		header:SetAllPoints(self.button);
		header:SetFrameLevel(0);
	end
end

--Update functions
function Klappa2.PopUpButton.prototype:UpdateIcon()
	local texture = GetActionTexture(self.button.id);

	if ( texture ) then
		self.button.icon:SetTexture(texture);
		self.button.icon:Show();
		self.rangeTimer = -1
--Test		self.button.normalTexture:SetTexture("Interface\\Buttons\\UI-Quickslot2");
--Test		self.button.normalTexture:SetTexCoord(0,0,0,0);
	else
		self.button.icon:Hide();
		self.button.cooldown:Hide();
		self.rangeTimer = nil
		self.button.normalTexture:SetTexture("Interface\\Buttons\\UI-Quickslot");
		self.button.hotkey:SetVertexColor(0.6, 0.6, 0.6);
--Test		self.button.normalTexture:SetTexCoord(-0.1,1.1,-0.1,1.12);
	end
end

--[[function Klappa2.PopUpButton.prototype:UpdateAction()
	local oldaction = self.button.id;
	self.button.id = SecureButton_GetModifiedAttribute(self.button, "action", SecureStateChild_GetEffectiveButton(self.button)) or 1
	if ( oldaction ~= self.button.id ) then
		self.button.id = oldaction;
		--Klappa2:Debug("action changed UpdateButton");
		self:UpdateButton();
	end
end--]]

function Klappa2.PopUpButton.prototype:UpdateHotkeys()
    local actionButtonType = "ACTIONBUTTON";

    local hotkey = self.button.hotkey;
	local key1, key2 = GetBindingKey(("ACTIONBUTTON%d"):format(self.button.id));
	local key = key1 or key2;
	local text = GetBindingText(key, "KEY_", 1);
    if ( text == "" or not HasAction(self.button.id)) then
        hotkey:SetText(RANGE_INDICATOR);
        hotkey:SetPoint("TOPLEFT", self.button, "TOPLEFT", 1, -2);
        hotkey:Hide();
    else
        hotkey:SetText(text);
        hotkey:SetPoint("TOPLEFT", self.button, "TOPLEFT", -2, -2);
        hotkey:Show();
    end
end

function Klappa2.PopUpButton.prototype:UpdateCount()
	local text = self.button.count;
	local action = self.button.id;
	if (IsConsumableAction(action) or IsStackableAction(action)) then
		if (LibSpellCount) then
			text:SetText(LibSpellCount:GetActionCount(action));
		else
			text:SetText(GetActionCount(action));
		end
	else
		text:SetText("");
	end
end

function Klappa2.PopUpButton.prototype:UpdateCooldown()
	if (self.button.cooldown) then
		local start, duration, enable = GetActionCooldown(self.button.id);
		CooldownFrame_Set(self.button.cooldown, start, duration, enable)
	end
end

function Klappa2.PopUpButton.prototype:UpdateMacroText()
	if ( not IsConsumableAction(self.button.id) and not IsStackableAction(self.button.id) ) then
		local text = GetActionText(self.button.id);
		self.button.macroName:SetText(text);
	else
		self.button.macroName:SetText("");
	end
end

function Klappa2.PopUpButton.prototype:UpdateState()
	local action = self.button.id
	local isChecked = IsCurrentAction(action) or IsAutoRepeatAction(action)
	self.button:SetChecked(isChecked)
end

function Klappa2.PopUpButton.prototype:UpdateUsable()
	local icon = self.button.icon;
	local normalTexture = self.button.normalTexture;
	local isUsable, notEnoughMana = IsUsableAction(self.button.id);
	if (isUsable) then
		icon:SetVertexColor(1.0, 1.0, 1.0);
		normalTexture:SetVertexColor(1.0, 1.0, 1.0);
	elseif (notEnoughMana) then
		icon:SetVertexColor(0.5, 0.5, 1.0);
		normalTexture:SetVertexColor(0.5, 0.5, 1.0);
	else
		icon:SetVertexColor(0.4, 0.4, 0.4);
		normalTexture:SetVertexColor(1.0, 1.0, 1.0);
	end
	if(self.outOfRange) then
		icon:SetVertexColor(1.0, 0.0, 0.0);
	end
end

function Klappa2.PopUpButton.prototype:UpdateFlash()
	local action = self.button.id;
	if ( (IsAttackAction(action) and IsCurrentAction(action)) or IsAutoRepeatAction(action) ) then
		self:StartFlash();
	else
		self:StopFlash();
	end

end

function Klappa2.PopUpButton.prototype:UpdateButton()
	self:UpdateIcon();
	--self:UpdateHotkeys();
	self:UpdateCount();
	if(HasAction(self.button.id) ) then
		self:RegisterButtonEvents();
		--if (not self.button:GetAttribute("statehidden") or not self.isPopup ) then
		--	self.button:Show();
		--end
		self:UpdateState();
		self:UpdateUsable();
		self:UpdateCooldown();
		self:UpdateFlash();
		if not (self.isMain) and not InCombatLockdown() then
			self.button:Hide()
			--self.button:Execute([[self:Run(hide)]])
		end
	else
		self.button:SetScript("OnUpdate", nil);
		self:UnregisterButtonEvents();
		if( self.showgrid == 0) then
			self.button.normalTexture:Hide()
			if self.button.overlay then
				self.button.overlay:Hide()
			end
			if not (self.isMain) then
				--self.button:Hide();
				self.button:Execute([[self:Run(hide)]])
			end
		else
			self.button.normalTexture:Show()
			if self.button.overlay then
				self.button.overlay:Show()
			end
		end
		self.button.cooldown:Hide()
		--print("setChecked false");
		self.button:SetChecked(false)

	end

	-- Add a green border if button is an equipped item
	if ( IsEquippedAction(self.button.id) ) then
		self.button.border:SetVertexColor(0, 1.0, 0, 0.35);
		self.button.border:Show();
	else
		self.button.border:Hide();
	end

	-- Update Macro Text
	self:UpdateMacroText();

	-- Update tooltip
	if ( GameTooltip:IsOwned(self.button) ) then
		self:ShowTooltip();
	end
end
-------------------------------------------------------------------------------------------------------------

-- will return true if the action actually changed
function Klappa2.PopUpButton.prototype:RefreshAction()
	local oldaction = self.button.id;
	self.button.id = SecureButton_GetModifiedAttribute(self.button, "action", SecureStateChild_GetEffectiveButton(self.button));
	local result = (oldaction ~= self.button.id);

	--Klappa2:Debug("RefreshAction result: "..tostring(result));
	return result;
end

function Klappa2.PopUpButton.prototype:OnUpdate(arg1, elapsed)
	self.elapsed = self.elapsed + elapsed;
	if self.elapsed < 0.2 then
		return;
	end

	if ( self:IsFlashing() ) then
		self.flashtime = self.flashtime - self.elapsed;
		if ( self.flashtime <= 0 ) then
			local overtime = - self.flashtime;
			if ( overtime >= ATTACK_BUTTON_FLASH_TIME ) then
				overtime = 0;
			end
			self.flashtime = ATTACK_BUTTON_FLASH_TIME - overtime;

			local flashTexture = self.button.flash;
			if ( flashTexture:IsVisible() ) then
				flashTexture:Hide();
			else
				flashTexture:Show();
			end
		end
	end

	if ( self.rangeTimer ) then
		self.rangeTimer = self.rangeTimer - self.elapsed
		if ( self.rangeTimer <= 0 ) then
			local hotkey = self.button.hotkey;
			local valid = IsActionInRange( self.button.id);
			if(hotkey:GetText() == RANGE_INDICATOR ) then
				if ( valid == 0 ) then
					hotkey:Show();
					hotkey:SetVertexColor(1.0, 0.1, 0.1);
				elseif( valid == 1 ) then
					hotkey:Show();
					hotkey:SetVertexColor(0.6, 0.6, 0.6);
				else
					hotkey:Hide();
				end
			else
				if ( valid == 0 ) then
					hotkey:SetVertexColor(1.0, 0.1, 0.1);
				else
					hotkey:SetVertexColor(0.6, 0.6, 0.6);
				end
			end
			self.outOfRange = (valid == 0);
			self:UpdateUsable();
			self.rangeTimer = TOOLTIP_UPDATE_TIME;
		end
	end
	self.elapsed = 0;
end

-- Event registering and handling
function Klappa2.PopUpButton.prototype:RegisterButtonEvents()
	if self.eventsregistered then return end

	--self.button:RegisterEvent("ACTIONBAR_UPDATE_STATE");
	self.button:RegisterEvent("ACTIONBAR_UPDATE_USABLE");
	self.button:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
	self.button:RegisterEvent("PLAYER_TARGET_CHANGED");
	self.button:RegisterEvent("CRAFT_SHOW");
	self.button:RegisterEvent("CRAFT_CLOSE");
	self.button:RegisterEvent("TRADE_SKILL_SHOW");
	self.button:RegisterEvent("TRADE_SKILL_CLOSE");
	self.button:RegisterEvent("PLAYER_ENTER_COMBAT");
	self.button:RegisterEvent("PLAYER_LEAVE_COMBAT");
	self.button:RegisterEvent("START_AUTOREPEAT_SPELL");
	self.button:RegisterEvent("STOP_AUTOREPEAT_SPELL");
	self.button:RegisterEvent("ACTIONBAR_SLOT_CHANGED");
	self.button:RegisterEvent("SPELL_UPDATE_ICON");
	self.button:RegisterEvent("BAG_UPDATE");
	self.eventsregistered = true;
end

function Klappa2.PopUpButton.prototype:UnregisterButtonEvents()
	if not self.eventsregistered then return end

	self.button:UnregisterEvent("ACTIONBAR_UPDATE_STATE");
	self.button:UnregisterEvent("ACTIONBAR_UPDATE_USABLE");
	self.button:UnregisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
	self.button:UnregisterEvent("PLAYER_TARGET_CHANGED");
	self.button:UnregisterEvent("CRAFT_SHOW");
	self.button:UnregisterEvent("CRAFT_CLOSE");
	self.button:UnregisterEvent("TRADE_SKILL_SHOW");
	self.button:UnregisterEvent("TRADE_SKILL_CLOSE");
	self.button:UnregisterEvent("PLAYER_ENTER_COMBAT");
	self.button:UnregisterEvent("PLAYER_LEAVE_COMBAT");
	self.button:UnregisterEvent("START_AUTOREPEAT_SPELL");
	self.button:UnregisterEvent("STOP_AUTOREPEAT_SPELL");
	self.button:UnregisterEvent("ACTIONBAR_SLOT_CHANGED");
	self.button:UnregisterEvent("SPELL_UPDATE_ICON");
	self.button:UnregisterEvent("BAG_UPDATE");
	self.eventsregistered = nil;
end

function Klappa2.PopUpButton.prototype:RegisterGeneralEvents()
	local button = self.button;

	button:RegisterEvent("PLAYER_ENTERING_WORLD");
	button:RegisterEvent("ACTIONBAR_SHOWGRID");
	button:RegisterEvent("ACTIONBAR_HIDEGRID");
	button:RegisterEvent("ACTIONBAR_PAGE_CHANGED");

	button:RegisterEvent("UPDATE_BINDINGS");
end

function Klappa2.PopUpButton.prototype:UnregisterGeneralEvents()
	local button = self.button;

	button:UnregisterEvent("PLAYER_ENTERING_WORLD");
	button:UnregisterEvent("ACTIONBAR_SHOWGRID");
	button:UnregisterEvent("ACTIONBAR_HIDEGRID");
	button:UnregisterEvent("ACTIONBAR_PAGE_CHANGED");
	button:UnregisterEvent("UPDATE_BINDINGS");
end

function Klappa2.PopUpButton.prototype:OnEventFunc(event, arg)
	self:BaseEventHandler(event, arg);
	if self.eventsregistered then
		self:ButtonEventHandler(event, arg)
	end
end

function Klappa2.PopUpButton.prototype:BaseEventHandler(event, arg)
	if(self.button == nil) then return end


	if ( event == "PLAYER_ENTERING_WORLD" ) then
		self:UpdateButton();
		return;
	end
	--if ( event == "ACTIONBAR_PAGE_CHANGED" or event == "UPDATE_BONUS_ACTIONBAR" ) then
	--	self:UpdateAction();
	--	return;
	--end
	if ( event == "ACTIONBAR_SHOWGRID" ) then
		self:ShowGrid();
		return;
	end
	if ( event == "ACTIONBAR_HIDEGRID" ) then
		self:HideGrid();
		return;
	end
	if ( event == "UPDATE_BINDINGS" ) then
		self:UpdateHotkeys();
		return;
	end
end

function Klappa2.PopUpButton.prototype:ButtonEventHandler(event, arg)
--print("ButtonEvent")
--print(event)
--print(arg)
	if(self.button == nil) then return end

	if ( event == "ACTIONBAR_SLOT_CHANGED" ) then
		--print("slotChanged")
		if ( arg == 0 or arg == self.button.id ) then
			--print("slotChanged-UpdateButton")
			self:UpdateButton();
		end
		return;
	end
	if ( event == "SPELL_UPDATE_ICON" ) then
		--print("updateIcon")
		self:UpdateButton();
	end
	if ( event == "PLAYER_TARGET_CHANGED" ) then
		self.rangeTimer = -1;
	elseif ( event == "ACTIONBAR_UPDATE_STATE" ) then
		self:UpdateState();
		--print("updateSTate")
	elseif ( event == "ACTIONBAR_UPDATE_USABLE" ) then
		self:UpdateUsable();
		--print("UpdateUsable")
	elseif ( event == "ACTIONBAR_UPDATE_COOLDOWN" ) then
		self:UpdateCooldown();
		self:UpdateState();  --Test
	elseif ( event == "CRAFT_SHOW" or event == "CRAFT_CLOSE" or event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_CLOSE" ) then
		self:UpdateState();
	elseif ( event == "PLAYER_ENTER_COMBAT" ) then
		if ( IsAttackAction(self.button.id) ) then
			self:StartFlash();
		end
	elseif ( event == "PLAYER_LEAVE_COMBAT" ) then
		if ( IsAttackAction(self.button.id) ) then
			self:StopFlash();
		end
	elseif ( event == "START_AUTOREPEAT_SPELL" ) then
		if ( IsAutoRepeatAction(self.button.id) ) then
			self:StartFlash();
		end
	elseif ( event == "STOP_AUTOREPEAT_SPELL" ) then
		if ( self:IsFlashing() and not IsAttackAction(self.button.id) ) then
			self:StopFlash();
		end
	elseif (event == "BAG_UPDATE") then
		self:UpdateCount();
	end
end
-------------------------------------------------------------------------------------------------------------------------

function Klappa2.PopUpButton.prototype:ButtonDrag()
	if( not Klappa2.config.bars[self.barid].lockButtons or IsShiftKeyDown() ) then
		PickupAction(self.button.id)
		self:UpdateState();
		self:UpdateFlash();
	end
end

function Klappa2.PopUpButton.prototype:ButtonDrop()
	PlaceAction(self.button.id);
	local action = ActionButton_CalculateAction(self.button);
--Test	if ( action ~= self.action or force ) then
	--	self.action = action;
		SetActionUIButton(self.button, self.button.id, self.button.cooldown);
		self:UpdateButton();
--	end
	self:UpdateState();
	self:UpdateFlash();
end

function Klappa2.PopUpButton.prototype:ShowTooltip()
	if(Klappa2.config.bars[self.barid].tooltip) then
		GameTooltip:SetOwner(self.button);
		GameTooltip:SetAction(self.button.id);
	end
end

function Klappa2.PopUpButton.prototype:HideTooltip()
	if GameTooltip:IsOwned(self.button) then
		GameTooltip:Hide();
	end
end

function Klappa2.PopUpButton.prototype:StartFlash()
	--print("startFlash")
	self.flashing = 1;
	self.flashtime = 0;
	self:UpdateState();
end

function Klappa2.PopUpButton.prototype:StopFlash()
--print("stopflash")
	self.flashing = 0;
	self.button.flash:Hide();
	self:UpdateState();
end

function Klappa2.PopUpButton.prototype:IsFlashing()
	if ( self.flashing == 1 ) then
		return 1;
	else
		return nil;
	end
end

function Klappa2.PopUpButton.prototype:ShowGrid()
	self.showgrid = self.showgrid+1;
	self.button.normalTexture:Show();
	self.button:Show();
end

function Klappa2.PopUpButton.prototype:HideGrid()
	self.showgrid = self.showgrid-1;
	self.button.normalTexture:Hide()
	--if ( self.showgrid == 0 and not HasAction(self.button.id)) then
		--if not (self.isMain) then
		--	self.button:Hide();
		--end
	--end

	if not (self.isMain) then
		self.button:Hide();
	end
	--if(self.isPopup and not HasAction(self.button.id)) then
	--	self.button:SetAttribute("showstates", "!*");
	--end
end
