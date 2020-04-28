BETTERUI = {
	ResearchTraits = {}
}

BETTERUI.name = "BetterUI"
BETTERUI.version = "2.72"

-- Program Global (scope of BETTERUI, though) variable initialization
BETTERUI.WindowManager = GetWindowManager()
BETTERUI.EventManager = GetEventManager()

-- pseudo-Class definitions
BETTERUI.CONST = {}
--BETTERUI.Lib = {}
BETTERUI.CIM = {}

BETTERUI.GenericHeader = {}
BETTERUI.GenericFooter = {}
BETTERUI.Interface = {}
BETTERUI.Interface.Window = {}

BETTERUI.Inventory = {
	List = {},
	Class = {},
}

BETTERUI.Writs = {
	List = {}
}


BETTERUI.Banking = {
	Class = {}
}

BETTERUI.Tooltips = {

}

BETTERUI.Settings = {}

BETTERUI.Helper = {
	GamePadBuddy = {},
	AutoCategory = {},
}

BETTERUI.DefaultSettings = {
	firstInstall = true,
	Modules = {
		["*"] = { -- Module setting template
			m_enabled = false
		}
	}
}


function ddebug(str)
	return d("|c0066ff[BETTERUI]|r "..str)
end

function BETTERUI.roundNumber(number, decimals)
	if number ~= nil or number ~= 0 then
    	local power = 10^decimals
    	return string.format("%.2f", math.floor(number * power) / power)
    else
    	return 0
    end
end

-- Thanks to Bart Kiers for this function :)
function BETTERUI.DisplayNumber(number)
	  local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
	  -- reverse the int-string and append a comma to all blocks of 3 digits
	  int = int:reverse():gsub("(%d%d%d)", "%1,")
	  -- reverse the int-string back remove an optional comma and put the
	  -- optional minus and fractional part back
	  return minus .. int:reverse():gsub("^,", "") .. fraction
end

function Init_ModulePanel(moduleName, moduleDesc)
	return {
		type = "panel",
		name = "|t24:24:/esoui/art/buttons/gamepad/xbox/nav_xbone_b.dds|t "..BETTERUI.name.." ("..moduleName..")",
		displayName = "|c0066ffBETTERUI|r :: "..moduleDesc,
		author = "prasoc, RockingDice, Goobsnake",
		version = BETTERUI.version,
		slashCommand = "/betterui",
		registerForRefresh = true,
		registerForDefaults = true
	}
end

ZO_Store_OnInitialize_Gamepad = function(...) end

-- Imagery, you dont need to localise these strings
ZO_CreateStringId("SI_BETTERUI_INV_EQUIP_TEXT_HIGHLIGHT","|cFF6600<<1>>|r")
ZO_CreateStringId("SI_BETTERUI_INV_EQUIP_TEXT_NORMAL","|cCCCCCC<<1>>|r")
