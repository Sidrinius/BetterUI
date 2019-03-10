local _

function BETTERUI.Tooltips.GetNumberOfMatchingItems(itemLink, BAG)

    -- Get bag size
    local bagSize = GetBagSize(BAG)
 
    -- Var to hold item matches
    local itemMatches = 0
 
    -- Iterate through BAG
    for i = 0, bagSize do

        -- Get current item
        local currentItem = GetItemLink(BAG, i)
 
        -- Check if current item is researchable
        if(CanItemLinkBeTraitResearched(currentItem)) then
 
            -- Check if current item trait equals item's trait we're checking
            if (GetItemLinkTraitInfo(currentItem) == GetItemLinkTraitInfo(itemLink)) then
                itemMatches = itemMatches + 1
            end
        end
    end
 
    -- return number of matches
    return itemMatches;
end

local function AddInventoryPostInfo(tooltip, itemLink)
	if itemLink then --and itemLink ~= tooltip.lastItemLink then
		--tooltip.lastItemLink = itemLink
        if TamrielTradeCentre ~= nil and BETTERUI.Settings.Modules["Tooltips"].ttcIntegration then
            local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
            if(priceInfo == nil) then
                tooltip:AddLine(string.format("|c0066ff[BETTERUI]|r  TTC " .. GetString(TTC_PRICE_NOLISTINGDATA)), { fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1 }, tooltip:GetStyle("bodySection"))
            else
                if(priceInfo.SuggestedPrice ~= nil) then
                    tooltip:AddLine(string.format("|c0066ff[BETTERUI]|r  TTC " .. GetString(TTC_PRICE_SUGGESTEDXTOY), 
                        TamrielTradeCentre:FormatNumber(priceInfo.SuggestedPrice, 0), TamrielTradeCentre:FormatNumber(priceInfo.SuggestedPrice * 1.25, 0)), { fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1 }, tooltip:GetStyle("bodySection"))
                else
                    tooltip:AddLine(string.format("|c0066ff[BETTERUI]|r  TTC Suggested : NONE "), { fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1 }, tooltip:GetStyle("bodySection"))
                end
                tooltip:AddLine(string.format(GetString(TTC_PRICE_AGGREGATEPRICESXYZ), TamrielTradeCentre:FormatNumber(priceInfo.Avg), 
                TamrielTradeCentre:FormatNumber(priceInfo.Min), TamrielTradeCentre:FormatNumber(priceInfo.Max)), { fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1 }) 
            end
            --     tooltip:AddLine(zo_strformat("|c0066ff[BETTERUI]|r <<1>>",priceInfo), { fontSize = 28, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1 }, tooltip:GetStyle("bodySection"))
        end

		if MasterMerchant ~= nil and BETTERUI.Settings.Modules["Tooltips"].mmIntegration then
			local tipLine, avePrice, graphInfo = MasterMerchant:itemPriceTip(itemLink, false, clickable)
			if(tipLine ~= nil) then
				tooltip:AddLine(string.format("|c0066ff[BETTERUI]|r  " .. tipLine), { fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1 }, tooltip:GetStyle("bodySection"))
			else
				tooltip:AddLine(string.format("|c0066ff[BETTERUI]|r  MM price (0 sales, 0 days): UNKNOWN"), { fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1 }, tooltip:GetStyle("bodySection"))
			end
		end
	end
end

local function AddInventoryPreInfo(tooltip, itemLink)

    if itemLink and BETTERUI.Settings.Modules["Tooltips"].showStyleTrait then
        local traitString
        if(CanItemLinkBeTraitResearched(itemLink))  then
            -- Find owned items that can be researchable
            if(BETTERUI.Tooltips.GetNumberOfMatchingItems(itemLink, BAG_BACKPACK) > 0) then
                traitString = "|c00FF00Researchable|r - |cFF9900Found in Inventory|r"
            elseif(BETTERUI.Tooltips.GetNumberOfMatchingItems(itemLink, BAG_BANK) + BETTERUI.Tooltips.GetNumberOfMatchingItems(itemLink, BAG_SUBSCRIBER_BANK) > 0) then
                traitString = "|c00FF00Researchable|r - |cFF9900Found in Bank|r"
            elseif(BETTERUI.Tooltips.GetNumberOfMatchingItems(itemLink, BAG_HOUSE_BANK_ONE) + BETTERUI.Tooltips.GetNumberOfMatchingItems(itemLink, BAG_HOUSE_BANK_TWO) + BETTERUI.Tooltips.GetNumberOfMatchingItems(itemLink, BAG_HOUSE_BANK_THREE) + BETTERUI.Tooltips.GetNumberOfMatchingItems(itemLink, BAG_HOUSE_BANK_FOUR) + BETTERUI.Tooltips.GetNumberOfMatchingItems(itemLink, BAG_HOUSE_BANK_FIVE) + BETTERUI.Tooltips.GetNumberOfMatchingItems(itemLink, BAG_HOUSE_BANK_SIX) + BETTERUI.Tooltips.GetNumberOfMatchingItems(itemLink, BAG_HOUSE_BANK_SEVEN) + BETTERUI.Tooltips.GetNumberOfMatchingItems(itemLink, BAG_HOUSE_BANK_EIGHT) + BETTERUI.Tooltips.GetNumberOfMatchingItems(itemLink, BAG_HOUSE_BANK_NINE) + BETTERUI.Tooltips.GetNumberOfMatchingItems(itemLink, BAG_HOUSE_BANK_TEN) > 0) then
                traitString = "|c00FF00Researchable|r - |cFF9900Found in House Bank|r"
            elseif(BETTERUI.Tooltips.GetNumberOfMatchingItems(itemLink, BAG_WORN) > 0) then
                traitString = "|c00FF00Researchable|r - |cFF9900Found Equipped|r"
            else
                traitString = "|c00FF00Researchable|r"
            end
        else
            return
        end    

        local style = GetItemLinkItemStyle(itemLink)
        local itemStyle = string.upper(GetString("SI_ITEMSTYLE", style))                    

        tooltip:AddLine(zo_strformat("<<1>> Trait: <<2>>", itemStyle, traitString), { fontSize = 28, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1 }, tooltip:GetStyle("title"))

        if(itemStyle ~= ("NONE")) then
            tooltip:AddLine(zo_strformat("<<1>>", itemStyle), { fontSize = 28, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1 }, tooltip:GetStyle("title"))
        end
    else
        return
    end
end

function BETTERUI.InventoryHook(tooltipControl, method, linkFunc)
	local origMethod = tooltipControl[method]

	tooltipControl[method] = function(self, ...)
		AddInventoryPreInfo(self, linkFunc(...))
		origMethod(self, ...)
		AddInventoryPostInfo(self, linkFunc(...))
	end
end

function BETTERUI.ReturnItemLink(itemLink)
	return itemLink
end