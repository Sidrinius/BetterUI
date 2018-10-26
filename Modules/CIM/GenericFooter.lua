local _

function BUI.GenericFooter:Initialize()
	if(self.footer == nil) then self.footer = self.control.container:GetNamedChild("FooterContainer").footer end

	if(self.footer.GoldLabel ~= nil) then BUI.GenericFooter.Refresh(self) end
end

function BUI.GenericFooter:Refresh()
	-- a hack until I completely generalize these functions... 
	if(self.footer.GoldLabel ~= nil) then
		self.footer.GoldLabel:SetText(zo_strformat("GOLD: |cFFBF00<<1>>|r |t24:24:<<2>>|t",BUI.DisplayNumber(GetCurrencyAmount(CURT_MONEY)),GetCurrencyGamepadIcon(CURT_MONEY)))
		self.footer.TVLabel:SetText(zo_strformat("TEL VAR: |c00FF00<<1>>|r |t24:24:<<2>>|t",BUI.DisplayNumber(GetCurrencyAmount(CURT_TELVAR_STONES)),GetCurrencyGamepadIcon(CURT_TELVAR_STONES)))
		self.footer.CWLabel:SetText(zo_strformat("|t32:32:/esoui/art/inventory/inventory_all_tabicon_inactive.dds|t(<<1>>)",zo_strformat(SI_GAMEPAD_INVENTORY_CAPACITY_FORMAT, GetNumBagUsedSlots(BAG_BACKPACK), GetBagSize(BAG_BACKPACK))))
		self.footer.APLabel:SetText(zo_strformat("AP: |c00FF00<<1>>|r |t24:24:<<2>>|t",BUI.DisplayNumber(GetCurrencyAmount(CURT_ALLIANCE_POINTS)),GetCurrencyGamepadIcon(CURT_ALLIANCE_POINTS)))
		--self.footer.GemsLabel:SetText(zo_strformat("GEMS: |c00FF00<<1>>|r |t24:24:<<2>>|t",BUI.DisplayNumber(GetCurrencyAmount(CURT_CROWN_GEMS, CURRENCY_LOCATION_ACCOUNT)),GetCurrencyGamepadIcon(CURT_CROWN_GEMS)))
		self.footer.TCLabel:SetText(zo_strformat("TRANSMUTE: |c00FF00<<1>>|r |t24:24:<<2>>|t",BUI.DisplayNumber(GetCurrencyAmount(CURT_CHAOTIC_CREATIA, CURRENCY_LOCATION_ACCOUNT)),GetCurrencyGamepadIcon(CURT_STYLE_STONES)))
		--self.footer.CrownsLabel:SetText(zo_strformat("CROWNS: |c00FF00<<1>>|r |t24:24:<<2>>|t",BUI.DisplayNumber(GetCurrencyAmount(CURT_CROWNS, CURRENCY_LOCATION_ACCOUNT)),GetCurrencyGamepadIcon(CURT_CROWNS)))
		self.footer.WritsLabel:SetText(zo_strformat("WRITS: |c00FF00<<1>>|r |t24:24:<<2>>|t",BUI.DisplayNumber(GetCurrencyAmount(CURT_WRIT_VOUCHERS)),GetCurrencyGamepadIcon(CURT_WRIT_VOUCHERS)))
		self.footer.TicketsLabel:SetText(zo_strformat("TICKETS: |c00FF00<<1>>|r |t24:24:<<2>>|t",BUI.DisplayNumber(GetCurrencyAmount(CURT_EVENT_TICKETS, CURRENCY_LOCATION_ACCOUNT)),GetCurrencyGamepadIcon(CURT_EVENT_TICKETS)))
	else
		self.footer:GetNamedChild("GoldLabel"):SetText(zo_strformat("GOLD: |cFFBF00<<1>>|r |t24:24:<<2>>|t",BUI.DisplayNumber(GetCurrencyAmount(CURT_MONEY)),GetCurrencyGamepadIcon(CURT_MONEY)))
		self.footer:GetNamedChild("TVLabel"):SetText(zo_strformat("TEL VAR: |c00FF00<<1>>|r |t24:24:<<2>>|t",BUI.DisplayNumber(GetCurrencyAmount(CURT_TELVAR_STONES)),GetCurrencyGamepadIcon(CURT_TELVAR_STONES)))
		self.footer:GetNamedChild("CWLabel"):SetText(zo_strformat("|t32:32:/esoui/art/inventory/inventory_all_tabicon_inactive.dds|t(<<1>>)",zo_strformat(SI_GAMEPAD_INVENTORY_CAPACITY_FORMAT, GetNumBagUsedSlots(BAG_BACKPACK), GetBagSize(BAG_BACKPACK))))
		self.footer:GetNamedChild("APLabel"):SetText(zo_strformat("AP: |c00FF00<<1>>|r |t24:24:<<2>>|t",BUI.DisplayNumber(GetCurrencyAmount(CURT_ALLIANCE_POINTS)),GetCurrencyGamepadIcon(CURT_ALLIANCE_POINTS)))
		--self.footer:GetNamedChild("GemsLabel"):SetText(zo_strformat("GEMS: |c00FF00<<1>>|r |t24:24:<<2>>|t",BUI.DisplayNumber(GetCurrencyAmount(CURT_CROWN_GEMS, CURRENCY_LOCATION_ACCOUNT)),GetCurrencyGamepadIcon(CURT_CROWN_GEMS)))
		self.footer:GetNamedChild("TCLabel"):SetText(zo_strformat("TRANSMUTE: |c00FF00<<1>>|r |t24:24:<<2>>|t",BUI.DisplayNumber(GetCurrencyAmount(CURT_CHAOTIC_CREATIA, CURRENCY_LOCATION_ACCOUNT)),GetCurrencyGamepadIcon(CURT_STYLE_STONES)))
		--self.footer:GetNamedChild("CrownsLabel"):SetText(zo_strformat("CROWNS: |c00FF00<<1>>|r |t24:24:<<2>>|t",BUI.DisplayNumber(GetCurrencyAmount(CURT_CROWNS, CURRENCY_LOCATION_ACCOUNT)),GetCurrencyGamepadIcon(CURT_CROWNS)))
		self.footer:GetNamedChild("WritsLabel"):SetText(zo_strformat("WRITS: |c00FF00<<1>>|r |t24:24:<<2>>|t",BUI.DisplayNumber(GetCurrencyAmount(CURT_WRIT_VOUCHERS)),GetCurrencyGamepadIcon(CURT_WRIT_VOUCHERS)))
		self.footer:GetNamedChild("TicketsLabel"):SetText(zo_strformat("TICKETS: |c00FF00<<1>>|r |t24:24:<<2>>|t",BUI.DisplayNumber(GetCurrencyAmount(CURT_EVENT_TICKETS)),GetCurrencyGamepadIcon(CURT_EVENT_TICKETS)))
	end
end
