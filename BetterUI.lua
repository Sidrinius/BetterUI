local _
local LAM = LibStub:GetLibrary("LibAddonMenu-2.0")
local dirtyModules = false

if BUI == nil then BUI = {} end


function BUI.InitModuleOptions()

	local panelData = Init_ModulePanel("Master", "Master Addon Settings")

	local optionsTable = {
		{
			type = "header",
			name = "Master Settings",
			width = "full",
		},
		{
			type = "checkbox",
			name = "Enable |c0066FFGeneral Interface Improvements|r",
			tooltip = "Vast improvements to the ingame tooltips and unit frames",
			getFunc = function() return BUI.Settings.Modules["Tooltips"].m_enabled end,
			setFunc = function(value) BUI.Settings.Modules["Tooltips"].m_enabled = value
						dirtyModules = true
						if value == true then
		                    BUI.Settings.Modules["CIM"].m_enabled = true
		              	elseif not BUI.Settings.Modules["Tooltips"].m_enabled and not BUI.Settings.Modules["Inventory"].m_enabled and not BUI.Settings.Modules["Banking"].m_enabled then
		                    BUI.Settings.Modules["CIM"].m_enabled = false
		                end
					end,
			width = "full",
			requiresReload = true,
		},
		{
			type = "checkbox",
			name = "Enable |c0066FFEnhanced Inventory|r",
			tooltip = "Completely redesigns the gamepad's inventory interface",
			getFunc = function() return BUI.Settings.Modules["Inventory"].m_enabled end,
			setFunc = function(value) BUI.Settings.Modules["Inventory"].m_enabled = value
						dirtyModules = true
						if value == true then
		                    BUI.Settings.Modules["CIM"].m_enabled = true
		              	elseif not BUI.Settings.Modules["Tooltips"].m_enabled and not BUI.Settings.Modules["Inventory"].m_enabled and not BUI.Settings.Modules["Banking"].m_enabled then
		                    BUI.Settings.Modules["CIM"].m_enabled = false
		                end
		            end,
			width = "full",
			requiresReload = true,
		},
		{
			type = "checkbox",
			name = "Enable |c0066FFEnhanced Banking|r",
			tooltip = "Completely redesigns the gamepad's banking interface",
			getFunc = function() return BUI.Settings.Modules["Banking"].m_enabled end,
			setFunc = function(value) BUI.Settings.Modules["Banking"].m_enabled = value
						dirtyModules = true
						if value == true then
		                    BUI.Settings.Modules["CIM"].m_enabled = true
		                elseif not BUI.Settings.Modules["Tooltips"].m_enabled and not BUI.Settings.Modules["Inventory"].m_enabled and not BUI.Settings.Modules["Banking"].m_enabled then
		                    BUI.Settings.Modules["CIM"].m_enabled = false
		                end
		            end,
			width = "full",
			requiresReload = true,
		},
		{
			type = "checkbox",
			name = "Enable |c0066FFDaily Writ module|r",
			tooltip = "Displays the daily writ, and progress, at each crafting station",
			getFunc = function() return BUI.Settings.Modules["Writs"].m_enabled end,
			setFunc = function(value) BUI.Settings.Modules["Writs"].m_enabled = value
									dirtyModules = true  end,
			width = "full",
			requiresReload = true,
		},
		{
			type = "checkbox",
			name = "Common Interface Module",
			tooltip = "Enables added functionality to the completely redesigned \"Enhanced\" interfaces!",
			getFunc = function() return BUI.Settings.Modules["CIM"].m_enabled end,
			setFunc = function(value) BUI.Settings.Modules["CIM"].m_enabled = value
						dirtyModules = true
						if not BUI.Settings.Modules["Tooltips"].m_enabled and not BUI.Settings.Modules["Inventory"].m_enabled and not BUI.Settings.Modules["Banking"].m_enabled then
		                    BUI.Settings.Modules["CIM"].m_enabled = false
		                end
		            end,
            disabled = function() return BUI.Settings.Modules["CIM"].m_enabled or not BUI.Settings.Modules["CIM"].m_enabled end,
			width = "full",
		},
	}

	LAM:RegisterAddonPanel("BUI_".."Modules", panelData)
	LAM:RegisterOptionControls("BUI_".."Modules", optionsTable)
end

function BUI.GetResearch()
	BUI.ResearchTraits = {}
	for i,craftType in pairs(BUI.CONST.CraftingSkillTypes) do
		BUI.ResearchTraits[craftType] = {}
		for researchIndex = 1, GetNumSmithingResearchLines(craftType) do
			local name, icon, numTraits, timeRequiredForNextResearchSecs = GetSmithingResearchLineInfo(craftType, researchIndex)
			BUI.ResearchTraits[craftType][researchIndex] = {}
			for traitIndex = 1, numTraits do
				local traitType, _, known = GetSmithingResearchLineTraitInfo(craftType, researchIndex, traitIndex)
				BUI.ResearchTraits[craftType][researchIndex][traitIndex] = known
			end
		end
	end
end

function BUI.PostHook(control, method, fn)
	if control == nil then return end

	local originalMethod = control[method]
	control[method] = function(self, ...)
		originalMethod(self, ...)
		fn(self, ...)
	end
end

function BUI.Hook(control, method, postHookFunction, overwriteOriginal)
	if control == nil then return end
	
	local originalMethod = control[method]
	control[method] = function(self, ...)
		if(overwriteOriginal == false) then originalMethod(self, ...) end
		postHookFunction(self, ...)
	end
end

function BUI.RGBToHex(rgba)
	r,g,b,a = unpack(rgba)
	return string.format("%02x%02x%02x", r*255, g*255, b*255)
end

function BUI.ModuleOptions(m_namespace, m_options)
	m_options = m_namespace.InitModule(m_options)
	return m_namespace
end

function BUI.LoadModules()

	if(not BUI._initialized) then
		ddebug("Initializing BUI...")
		BUI.GetResearch()

		if(BUI.Settings.Modules["CIM"].m_enabled) then
			BUI.CIM.Setup()
			if(BUI.Settings.Modules["Inventory"].m_enabled) then
				BUI.Inventory.HookDestroyItem()
				BUI.Inventory.HookActionDialog()
				BUI.Inventory.Setup()
			end
			if(BUI.Settings.Modules["Banking"].m_enabled) then
				BUI.Banking.Setup()
			end
		end
		if(BUI.Settings.Modules["Writs"].m_enabled) then
			BUI.Writs.Setup()
		end
		if(BUI.Settings.Modules["Tooltips"].m_enabled) then
			BUI.Tooltips.Setup()
		end

		ddebug("Finished! BUI is loaded")
		BUI._initialized = true
	end

end

function BUI.Initialize(event, addon)
    -- filter for just BUI addon event as EVENT_ADD_ON_LOADED is addon-blind
	if addon ~= BUI.name then return end

	-- load our saved variables
	BUI.Settings = ZO_SavedVars:New("BetterUISavedVars", 2.65, nil, BUI.DefaultSettings)

	-- Has the settings savedvars JUST been applied? then re-init the module settings
	if(BUI.Settings.firstInstall) then
		local m_CIM = BUI.ModuleOptions(BUI.CIM, BUI.Settings.Modules["CIM"])
		local m_Inventory = BUI.ModuleOptions(BUI.Inventory, BUI.Settings.Modules["Inventory"])
		local m_Banking = BUI.ModuleOptions(BUI.Banking, BUI.Settings.Modules["Banking"])
		local m_Writs = BUI.ModuleOptions(BUI.Writs, BUI.Settings.Modules["Writs"])
		local m_Tooltips = BUI.ModuleOptions(BUI.Tooltips, BUI.Settings.Modules["Tooltips"])

		d("first install!")
		BUI.Settings.firstInstall = false
	end

	BUI.EventManager:UnregisterForEvent("BetterUIInitialize", EVENT_ADD_ON_LOADED)

	BUI.InitModuleOptions()

	if(IsInGamepadPreferredMode()) then
		BUI.LoadModules()
	else
		BUI._initialized = false
	end

end

-- register our event handler function to be called to do initialization
BUI.EventManager:RegisterForEvent(BUI.name, EVENT_ADD_ON_LOADED, function(...) BUI.Initialize(...) end)
BUI.EventManager:RegisterForEvent(BUI.name.."_Gamepad", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function(code, inGamepad)  BUI.LoadModules() end)
