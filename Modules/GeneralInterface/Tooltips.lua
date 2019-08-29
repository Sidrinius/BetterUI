_G.mmErrorSuppress = 0
local _

function BETTERUI.Tooltips.GetNumberOfMatchingItems(itemLink, BAG)

    -- Get bag size
    local bagSize = GetNumBagUsedSlots(BAG)
 
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

local function AddInventoryPostInfo(tooltip, itemLink, bagId, slotIndex, storeStackCount)
    local stackCount
    if itemLink then
        if storeStackCount then
            stackCount = storeStackCount
        else
            stackCount = GetSlotStackSize(bagId, slotIndex)
        end
    end

    if TamrielTradeCentre ~= nil and BETTERUI.Settings.Modules["Tooltips"].ttcIntegration then
        local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
        if(priceInfo == nil) then
            tooltip:AddLine(string.format("TTC Price: " .. GetString(TTC_PRICE_NOLISTINGDATA)), { fontSize = 24, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1 }, tooltip:GetStyle("title"))
        else
            if(priceInfo.SuggestedPrice ~= nil) then
                if stackCount > 1 then 
                    tooltip:AddLine(zo_strformat("TTC price: <<1>> |t18:18:<<2>>|t,   Stack(<<3>>): <<4>> |t18:18:<<2>>|t ", TamrielTradeCentre:FormatNumber(priceInfo.SuggestedPrice, 0), GetCurrencyGamepadIcon(CURT_MONEY), stackCount, TamrielTradeCentre:FormatNumber(priceInfo.SuggestedPrice * stackCount, 0)), { fontSize = 24, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1 }, tooltip:GetStyle("title"))
                else
                    tooltip:AddLine(zo_strformat("TTC price: <<1>> |t18:18:<<2>>|t ", TamrielTradeCentre:FormatNumber(priceInfo.SuggestedPrice, 0), GetCurrencyGamepadIcon(CURT_MONEY)), { fontSize = 24, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1 }, tooltip:GetStyle("title"))
                end
            else
                tooltip:AddLine(zo_strformat("TTC price: <<1>> |t18:18:<<2>>|t ", TamrielTradeCentre:FormatNumber(priceInfo.Avg, 0), GetCurrencyGamepadIcon(CURT_MONEY)), { fontSize = 24, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1 }, tooltip:GetStyle("title"))
            end
            tooltip:AddLine(string.format(GetString(TTC_PRICE_AGGREGATEPRICESXYZ), TamrielTradeCentre:FormatNumber(priceInfo.Avg), 
            TamrielTradeCentre:FormatNumber(priceInfo.Min), TamrielTradeCentre:FormatNumber(priceInfo.Max)), { fontSize = 24, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1 }, tooltip:GetStyle("title"))
        end
    end

	if MasterMerchant ~= nil and BETTERUI.Settings.Modules["Tooltips"].mmIntegration then 
        -- Turning on error suppression for MasterMerchant guildstore browse/sell (Hacky work around for now)
        if BETTERUI.Settings.Modules["Tooltips"].mmIntegrationErrorSuppress then 
            if SCENE_MANAGER.scenes['gamepad_trading_house']:IsShowing() and mmErrorSuppress == 0 then
                ZO_UIErrors_ToggleSupressDialog()
               -- d("Suppression on")
                mmErrorSuppress = 1
            elseif not SCENE_MANAGER.scenes['gamepad_trading_house']:IsShowing() and mmErrorSuppress == 1 then
                ZO_UIErrors_ToggleSupressDialog()
               -- d("Suppression off Guild Store not Showing")
                mmErrorSuppress = 0
            end
        end

        local tipLine, avgPrice = MasterMerchant:itemPriceTip(itemLink, false, clickable)
		if(tipLine ~= nil) then
            tooltip:AddLine(zo_strformat("<<1>> ", tipLine), { fontSize = 24, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1 }, tooltip:GetStyle("title"))
            if stackCount > 1 then
                tooltip:AddLine(zo_strformat("Stack(<<1>>): <<2>> |t18:18:<<3>>|t ", stackCount, avgPrice * stackCount, GetCurrencyGamepadIcon(CURT_MONEY)), { fontSize = 24, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1 })
            end
        else
			tooltip:AddLine(string.format("MM price: UNKNOWN"), { fontSize = 24, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1 }, tooltip:GetStyle("title"))
		end
	end
    -- Whitespace buffer
    tooltip:AddLine(string.format(""), { fontSize = 12, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1 }, tooltip:GetStyle("title"))
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

function BETTERUI.InventoryHook(tooltipControl, method, linkFunc, method2, linkFunc2, method3, linkFunc3)
    local newMethod = tooltipControl[method]
    local newMethod2 = tooltipControl[method2]
    local newMethod3 = tooltipControl[method3]
    local bagId
    local itemLink
    local slotIndex
    local storeItemLink
    local storeStackCount

    tooltipControl[method2] = function(self, ...)
        bagId, slotIndex = linkFunc2(...)
        newMethod2(self, ...)
    end
    tooltipControl[method3] = function(self, ...)
        storeItemLink, storeStackCount = linkFunc3(...)
        newMethod3(self, ...)
    end
    tooltipControl[method] = function(self, ...)
        if storeItemLink then
            itemLink = storeItemLink
        else
            itemLink = linkFunc(...)
        end
        AddInventoryPreInfo(self, itemLink)
        AddInventoryPostInfo(self, itemLink, bagId, slotIndex, storeStackCount)
        newMethod(self, ...)
    end
end

function BETTERUI.ReturnItemLink(itemLink)
    return itemLink
end

function BETTERUI.ReturnSelectedData(bagId, slotIndex)
    return bagId, slotIndex
end

function BETTERUI.ReturnStoreSearch(storeItemLink, storeStackCount)
    return storeItemLink, storeStackCount
end