BUI.General = {}
BUI.General.Window = ZO_GamepadInventory:Subclass()
local function RemoveAllKeyButtonGroups(self, stateIndex)
	assert(0)
	dd("remove all")
    local state = self:GetKeybindState(stateIndex)
    if state then
        return ZO_KeybindStrip.RemoveAllKeyButtonGroupsStack(state)
    end

    if next(self.keybindGroups) ~= nil then
        local prevKeybindGroups = ZO_ShallowTableCopy(self.keybindGroups)
        for _, groupDescriptor in pairs(prevKeybindGroups) do
            self:RemoveKeybindButtonGroup(groupDescriptor, stateIndex)
        end
    end
end
function testAddKeybindButtonGroup(self, keybindButtonGroupDescriptor, stateIndex)
	d("ag: 1")
    local state = self:GetKeybindState(stateIndex)
    if state then
        return AddKeybindButtonGroupStack(keybindButtonGroupDescriptor, state)
    end
d("ag: 2")
    if not self.keybindGroups[keybindButtonGroupDescriptor] then
	d("ag: 3")
        self.batchUpdating = true

        self.keybindGroups[keybindButtonGroupDescriptor] = keybindButtonGroupDescriptor

        for i, keybindButtonDescriptor in ipairs(keybindButtonGroupDescriptor) do
            keybindButtonDescriptor.keybindButtonGroupDescriptor = keybindButtonGroupDescriptor
            local button = self:AddKeybindButton(keybindButtonDescriptor, stateIndex)
			d("ag: bbb", stateIndex)
            if button then
                self:SetUpButton(button)
				d("ag: aaa")
            end
        end

        self:UpdateAnchors()

        self.batchUpdating = false
		d("ag: 4")
        return true
    end
	d("ag: 5")
    return false
end


function testAddKeybindButton(self, keybindButtonDescriptor, stateIndex)
	dd("1")
    local state = self:GetKeybindState(stateIndex)
    if state then
        return AddKeybindButtonStack(keybindButtonDescriptor, state)
    end
dd("2")
    -- Asserting here usually means that a key is already bound (typically because someone forgot to remove a keybinding).
    local currentSceneName = ""
    if SCENE_MANAGER then
        local currentScene = SCENE_MANAGER:GetCurrentScene()
        if currentScene then
            currentSceneName = currentScene:GetName()
        end
    end 
    local existingButtonOrEtheralDescriptor = self.keybinds[keybindButtonDescriptor.keybind]
    if existingButtonOrEtheralDescriptor then
        local existingDescriptor = GetDescriptorFromButton(existingButtonOrEtheralDescriptor)
        local existingSceneName = ""
        local existingDescriptorName = ""
        if existingDescriptor then
            --We tried to re-add the same exact button, just return
            if existingDescriptor == keybindButtonDescriptor then
			dd("3")
                return
            end
dd("4")
            existingSceneName = existingDescriptor.addedForSceneName
            local descriptorName = GetValueFromRawOrFunction(existingDescriptor, "name")
            if descriptorName then
                existingDescriptorName = descriptorName
            end
        end
        local newDescriptorName = GetValueFromRawOrFunction(keybindButtonDescriptor, "name") or ""
        local context = string.format("Duplicate Keybind: %s. Before: %s (%s). After: %s (%s).", keybindButtonDescriptor.keybind, existingSceneName, existingDescriptorName, currentSceneName, newDescriptorName)
        assert(false, context)
    end
dd("5")
    keybindButtonDescriptor.addedForSceneName = currentSceneName

    if keybindButtonDescriptor.ethereal then
        self.keybinds[keybindButtonDescriptor.keybind] = keybindButtonDescriptor
		dd("6")
    else
        local button, key = self.keybindButtonPool:AcquireObject()
        button.keybindButtonDescriptor = keybindButtonDescriptor
        button.key = key

        self.insertionId = (self.insertionId or 0) + 1
        button.insertionOrder = self.insertionId

        self.keybinds[keybindButtonDescriptor.keybind] = button

        if not self.batchUpdating then
            -- clear this out in case it was previously in a group
            keybindButtonDescriptor.keybindButtonGroupDescriptor = nil
        end

        self:AddButtonToAnchors(button)

        if not self.batchUpdating then
            self:SetUpButton(button)
            self:UpdateAnchors()
        end
        return button
    end
end

function testAddButtonToAnchors(self, button)
	dd("test:     button")
    local keybindButtonDescriptor = button.keybindButtonDescriptor
    local anchorTable = self:GetAnchorTableFromAlignment(keybindButtonDescriptor.alignment or keybindButtonDescriptor.keybindButtonGroupDescriptor and keybindButtonDescriptor.keybindButtonGroupDescriptor.alignment)
    anchorTable[#anchorTable + 1] = button
end
function SetScene(self, scene)
	dd("tt 1")
    if self.scene then -- Make sure we don't register multiple callbacks
        self.scene:UnregisterCallback("StateChange", self.onStateChangedCallback)
		dd("tt 2")
    end
    if scene then
	dd("tt 3")
        self.onStateChangedCallback = function(...)
            self:OnStateChanged(...)
        end
        scene:RegisterCallback("StateChange", self.onStateChangedCallback)
    end

    self.scene = scene
end
--#### Initialize
function BUI.General.Window:Initialize(control, ...)
ZO_KeybindStrip.AddButtonToAnchors = testAddButtonToAnchors
ZO_KeybindStrip.AddKeybindButton = testAddKeybindButton
ZO_KeybindStrip.AddKeybindButtonGroup = testAddKeybindButtonGroup
ZO_KeybindStrip.RemoveAllKeyButtonGroups = RemoveAllKeyButtonGroups
ZO_Gamepad_ParametricList_Screen.SetScene =SetScene
	BUI_Gamepad_ParametricList_Screen:Initialize(control, ...)

	control:SetHandler("OnUpdate", OnUpdate)
	
	
	self.tabsData = {}
end



function BUI.General.Window:OnDeferredInitialize()
	dd("123123123123")
    self:SetListsUseTriggerKeybinds(true)

    self.categoryPositions = {}
	self.categoryCraftPositions = {}
    self.populatedCategoryPos = false
	self.populatedCraftPos = false
    self.equipToMainSlot = true

    self:InitializeCategoryList()
    self:InitializeHeader()
    self:InitializeKeybindStrip()


    local function RefreshHeader()
        if not self.control:IsHidden() then
            self:RefreshHeader(BLOCK_TABBAR_CALLBACK)
        end
    end

    local function RefreshSelectedData()
        if not self.control:IsHidden() then
            self:SetSelectedInventoryData(self.currentlySelectedData)
        end
    end

    self:RefreshTabs()

    self:SetSelectedItemUniqueId(self:GenerateItemSlotData(self.categoryList:GetTargetData()))
    self:RefreshHeader()
    self:ActivateHeader()

    self.control:RegisterForEvent(EVENT_MONEY_UPDATE, RefreshHeader)
    self.control:RegisterForEvent(EVENT_ALLIANCE_POINT_UPDATE, RefreshHeader)
    self.control:RegisterForEvent(EVENT_TELVAR_STONE_UPDATE, RefreshHeader)
    self.control:RegisterForEvent(EVENT_PLAYER_DEAD, RefreshSelectedData)
    self.control:RegisterForEvent(EVENT_PLAYER_REINCARNATED, RefreshSelectedData)

end



function BUI.General.Window:InitializeHeader()
    local function UpdateTitleText()
		return GetString(SI_BUI_INV_ACTION_INV)
    end

    local tabBarEntries = {
        {
            text = GetString(SI_GAMEPAD_INVENTORY_CATEGORY_HEADER),
            callback = function()
                self:SwitchActiveList(INVENTORY_CATEGORY_LIST)
            end,
        },
        {
            text = GetString(SI_GAMEPAD_INVENTORY_CRAFT_BAG_HEADER),
            callback = function()
                self:SwitchActiveList(INVENTORY_CRAFT_BAG_LIST)
            end,
        },
    }

    self.categoryHeaderData = {
		titleText = UpdateTitleText,
        tabBarEntries = tabBarEntries,
        tabBarData = { parent = self, onNext = BUI_TabBar_OnTabNext, onPrev = BUI_TabBar_OnTabPrev }
    }

     BUI.GenericHeader.Initialize(self.header, ZO_GAMEPAD_HEADER_TABBAR_CREATE)
    --ZO_GamepadGenericHeader_Initialize(self.header, ZO_GAMEPAD_HEADER_TABBAR_CREATE)
     BUI.GenericHeader.Refresh(self.header, self.categoryHeaderData, ZO_GAMEPAD_HEADER_TABBAR_CREATE)
    --ZO_GamepadGenericHeader_Refresh(self.header, self.categoryHeaderData, true)
end

function BUI.General.Window:InitializeCategoryList()
    self.categoryList = self:AddList("Category", SetupCategoryList)
    self.categoryList:SetNoItemText(GetString(SI_GAMEPAD_INVENTORY_EMPTY))

    --Match the tooltip to the selected data because it looks nicer
    local function OnSelectedCategoryChanged(list, selectedData)
		--[[
	    if selectedData ~= nil and self.scene:IsShowing() then
		    self:UpdateCategoryLeftTooltip(selectedData)
		
		    if selectedData.onClickDirection then
			    self:SwitchActiveList(INVENTORY_CRAFT_BAG_LIST)
		    else
			    self:SwitchActiveList(INVENTORY_ITEM_LIST)
		    end
	    end
		]]--
    end

    self.categoryList:SetOnSelectedDataChangedCallback(OnSelectedCategoryChanged)

    --Match the functionality to the target data
    local function OnTargetCategoryChanged(list, targetData)
		--[[
        if targetData then
                self.selectedEquipSlot = targetData.equipSlot
                self:SetSelectedItemUniqueId(self:GenerateItemSlotData(targetData))
                self.selectedItemFilterType = targetData.filterType
        else
            self:SetSelectedItemUniqueId(nil)
        end

        self.currentlySelectedData = targetData
        KEYBIND_STRIP:UpdateKeybindButtonGroup(self.categoryListKeybindStripDescriptor)
		]]--
    end

    self.categoryList:SetOnTargetDataChangedCallback(OnTargetCategoryChanged)
end

function BUI.General.Window:InitializeKeybindDescriptor()

end

--##### Callbacks
local function BUI_GamepadMenuEntryTemplateParametricListFunction(control, distanceFromCenter, continousParametricOffset) end

function BUI_TabBar_OnTabNext(parent, successful)
		dd("tab next")
    if(successful) then
		dd("tab next2")
        parent:SaveListPosition()

        parent.categoryList.targetSelectedIndex = WrapValue(parent.categoryList.targetSelectedIndex + 1, #parent.categoryList.dataList)
        parent.categoryList.selectedIndex = parent.categoryList.targetSelectedIndex
        parent.categoryList.selectedData = parent.categoryList.dataList[parent.categoryList.selectedIndex]
        parent.categoryList.defaultSelectedIndex = parent.categoryList.selectedIndex

        --parent:RefreshItemList()
		BUI.GenericHeader.SetTitleText(parent.header, parent.categoryList.selectedData.text)

        parent:ToSavedPosition()
    end
end

function BUI_TabBar_OnTabPrev(parent, successful)
		dd("tab prev")
    if(successful) then
		dd("tab prev2")
        parent:SaveListPosition()

        parent.categoryList.targetSelectedIndex = WrapValue(parent.categoryList.targetSelectedIndex - 1, #parent.categoryList.dataList)
        parent.categoryList.selectedIndex = parent.categoryList.targetSelectedIndex
        parent.categoryList.selectedData = parent.categoryList.dataList[parent.categoryList.selectedIndex]
        parent.categoryList.defaultSelectedIndex = parent.categoryList.selectedIndex

        --parent:RefreshItemList()
		BUI.GenericHeader.SetTitleText(parent.header, parent.categoryList.selectedData.text)

        parent:ToSavedPosition()
    end
end

local function SetupCategoryList(list)
    list:AddDataTemplate("BUI_GamepadItemEntryTemplate", ZO_SharedGamepadEntry_OnSetup, BUI_GamepadMenuEntryTemplateParametricListFunction)
end


local testTabData = {
	[1] = {
		name = "Cat1",
		icon = "/esoui/art/inventory/gamepad/gp_inventory_icon_craftbag_all.dds",
	},
	[2] = {
		name = "Cat2",
		icon = "/esoui/art/inventory/gamepad/gp_inventory_icon_craftbag_blacksmithing.dds",
	},
}

function BUI.General.Window:SetupTabs(tabsData)
	self.tabsData = testTabData
	self:RefreshTabs()
end

function BUI.General.Window:RefreshTabs()
    self.categoryList:Clear()
    self.header.tabBar:Clear()

	for i = 1, #self.tabsData do
		local tabData = self.tabsData[i]
		local data = ZO_GamepadEntryData:New(tabData.name, tabData.icon)
		data:SetIconTintOnSelection(true)
		self.categoryList:AddEntry("BUI_GamepadItemEntryTemplate", data)
		BUI.GenericHeader.AddToList(self.header, data)
	end

    self.categoryList:Commit()
    self.header.tabBar:Commit()
end

function BUI.General.Window:SetupFields(fieldsData)
	self.fieldsData = fieldsData
	self:RefreshFields()
end

function BUI.General.Window:RefreshFields()
end

function BUI.General.Window:OnSwitchTab()
end

function BUI.General.Window:ActivateHeader()
    ZO_GamepadGenericHeader_Activate(self.header)
	if #self.tabsData > 0 then 
		self.header.tabBar:SetSelectedIndexWithoutAnimation(1, true, false)
	end
end

function BUI.General.Window:DeactivateHeader()
    ZO_GamepadGenericHeader_Deactivate(self.header)
end


function BUI.General.Window:RefreshHeader(blockCallback)
    local currentList = self:GetCurrentList()
    local headerData = self.categoryHeaderData 
    BUI.GenericHeader.Refresh(self.header, headerData, blockCallback)
  
    self:RefreshTabs() 
end



--####Override

-- override of ZO_Gamepad_ParametricList_Screen:OnStateChanged
function BUI.General.Window:OnStateChanged(oldState, newState)
	dd("onstatechagned " .. tostring(newState))
    if newState == SCENE_SHOWING then
        self:PerformDeferredInitialize()

        --figure out which list to land on
        local listToActivate = self.previousListType or INVENTORY_CATEGORY_LIST
        -- We normally do not want to enter the gamepad inventory on the item list
        -- the exception is if we are coming back to the inventory, like from looting a container
        if listToActivate == INVENTORY_ITEM_LIST and not SCENE_MANAGER:WasSceneOnStack(ZO_GAMEPAD_INVENTORY_SCENE_NAME) then
            listToActivate = INVENTORY_CATEGORY_LIST
        end

        -- switching the active list will handle activating/refreshing header, keybinds, etc.
        self:SwitchActiveList(listToActivate)

        ZO_InventorySlot_SetUpdateCallback(function() self:RefreshItemActions() end)
    elseif newState == SCENE_HIDING then
        ZO_InventorySlot_SetUpdateCallback(nil)
        self:Deactivate()
        self:DeactivateHeader()
    elseif newState == SCENE_HIDDEN then
        --clear the currentListType so we can refresh it when we re-enter
        self:SwitchActiveList(nil)

        self.listWaitingOnDestroyRequest = nil
        self:TryClearNewStatusOnHidden()

        self:ClearActiveKeybinds()
        ZO_SavePlayerConsoleProfile()
    end
end

function BUI.General.Window:OnUpdate(currentFrameTimeSeconds)
	dd("onupdate " .. tostring(currentFrameTimeSeconds))
    --if no currentFrameTimeSeconds a manual update was called from outside the update loop.
    if not currentFrameTimeSeconds or (self.nextUpdateTimeSeconds and (currentFrameTimeSeconds >= self.nextUpdateTimeSeconds)) then
        self.nextUpdateTimeSeconds = nil

        if self.actionMode == ITEM_LIST_ACTION_MODE then
            self:RefreshItemList()
            -- it's possible we removed the last item from this list
            -- so we want to switch back to the category list
            if self.itemList:IsEmpty() then
                self:SwitchActiveList(INVENTORY_CATEGORY_LIST)
            else
                -- don't refresh item actions if we are switching back to the category view
                -- otherwise we get keybindstrip errors (Item actions will try to add an "A" keybind
                -- and we already have an "A" keybind)
                self:UpdateRightTooltip()
                self:RefreshItemActions()
            end
        elseif self.actionMode == CRAFT_BAG_ACTION_MODE then
            self:RefreshCraftBagList()
            self:RefreshItemActions()
        else -- CATEGORY_ITEM_ACTION_MODE
            self:UpdateCategoryLeftTooltip(self.categoryList:GetTargetData())
        end
    end

    if self.updateItemActions then
        self.updateItemActions = nil
        if not ZO_Dialogs_IsShowing(ZO_GAMEPAD_INVENTORY_ACTION_DIALOG) then
            self:RefreshItemActions()
        end
    end
end

function BUI.General.Window:InitializeKeybindStripDescriptors()
	self.keybindStripDescriptor =
    {
        {
            name = GetString(SI_GAMEPAD_SELECT_OPTION),
            keybind = "UI_SHORTCUT_PRIMARY",
            callback = function()
                end,
            visible = function()
					return true
                end,
            sound = SOUNDS.GAMEPAD_MENU_FORWARD,
        },
		{
			name = GetString(SI_TRADING_HOUSE_GUILD_LABEL),
			keybind = "UI_SHORTCUT_TERTIARY",
			alignment = KEYBIND_STRIP_ALIGN_LEFT,
			callback = function()
			end,
			visible = function()
				return true
			end,
			enabled = true
		},
		{
			name = function()
				return "abc"
			end,
			keybind = "UI_SHORTCUT_RIGHT_STICK",
			alignment = KEYBIND_STRIP_ALIGN_LEFT,
			callback = function()
			end,
			enabled = true
		},
	}
	
   -- ZO_Gamepad_AddBackNavigationKeybindDescriptors(self.keybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON)
    KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripDescriptor)
    --KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
	dd("added keybind")
end

function BUI.General.Window:PerformUpdate()
	dd("perform update")
    KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
end