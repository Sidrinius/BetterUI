local _
local LAM = LibStub:GetLibrary("LibAddonMenu-2.0")

function BETTERUI.CIM.InitModule(m_options)
	m_options["attributeIcons"] = true
	m_options["triggerSpeed"] = 10
	m_options["enhanceCompat"] = false
	m_options["skinSize"] = "Default"
	m_options["rhScrollSpeed"] = 50
	m_options["tooltipSize"] = "Default"
	return m_options
end

function BETTERUI.CIM.Setup()
	-- Apply compatibility patches to enhance compatibility between BETTERUI and other addons which hook the interfaces
	-- Warning: this is HIGHLY likely to break some addons' functionality, but this is unavoidable.

	if BETTERUI.Settings.Modules["CIM"].enhanceCompat then

		-- only apply compat patches if the module is enabled!
		if BETTERUI.Settings.Modules["Inventory"].m_enabled then
			-- Replace the default interface class with the shrinkwrapped version. This means that any hooks applied by other addons
			-- get hooked into BETTERUI.Inventory.Class instead
		end
	end
end
