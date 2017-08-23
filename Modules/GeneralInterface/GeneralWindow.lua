BUI.General = {}
BUI.General.Window = BUI_Gamepad_ParametricList_Screen:Subclass()
function BUI.General.Window:New( ... )
    local window = BUI_Gamepad_ParametricList_Screen.New(self, ...)
    return window
end

function BUI.General.Window:Initialize(control, ...)
	BUI_Gamepad_ParametricList_Screen.Initialize(self, control, ...)

	self.tabsData = {}
end

function BUI.General.Window:OnDeferredInitialize()
    self:InitializeCategoryList()
    self:InitializeHeader()


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