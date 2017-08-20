
BUI.Bank = {}
BUI.Bank.Window = BUI.General.Window:Subclass()

local GAMEPAD_BANKING_SCENE_NAME = "gamepad_banking"

function BUI.Bank.Window:Initialize(control)
    GAMEPAD_BANKING_SCENE = ZO_InteractScene:New(GAMEPAD_BANKING_SCENE_NAME, SCENE_MANAGER, BANKING_INTERACTION)
    BUI.General.Window:Initialize(control, false, true, GAMEPAD_BANKING_SCENE)
	--self:SetupTabs()
end
 local GAMEPAD_DRIVEN_UI_WINDOW =
    {
        MOUSE_UI_MODE_FRAGMENT, --still need this as it blocks clicks from becoming attacks
        GAMEPAD_UI_MODE_FRAGMENT,
        GAMEPAD_ACTION_LAYER_FRAGMENT,
        KEYBIND_STRIP_GAMEPAD_FRAGMENT,
        KEYBIND_STRIP_GAMEPAD_BACKDROP_FRAGMENT,
        UI_SHORTCUTS_ACTION_LAYER_FRAGMENT,
        CLEAR_CURSOR_FRAGMENT,
        UI_COMBAT_OVERLAY_FRAGMENT,
        END_IN_WORLD_INTERACTIONS_FRAGMENT,
        HIDE_MOUSE_FRAGMENT,
    }

function BUI.Bank.Init()
	GAMEPAD_BANKING = BUI.Bank.Window:New(BUI_BANK_WINDOW) 

	GAMEPAD_BANKING_FRAGMENT = ZO_SimpleSceneFragment:New(BUI_BANK_WINDOW) -- **Replaces** the old inventory with a new one defined in "Templates/GamepadInventory.xml"
    GAMEPAD_BANKING_FRAGMENT:SetHideOnSceneHidden(true)

    -- Now update the changes throughout the interface...
	GAMEPAD_BANKING_SCENE:AddFragmentGroup(GAMEPAD_DRIVEN_UI_WINDOW)
	GAMEPAD_BANKING_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
	GAMEPAD_BANKING_SCENE:AddFragment(GAMEPAD_BANKING_FRAGMENT)
	GAMEPAD_BANKING_SCENE:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
	GAMEPAD_BANKING_SCENE:AddFragment(MINIMIZE_CHAT_FRAGMENT)
	GAMEPAD_BANKING_SCENE:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)
SCENE_MANAGER.scenes['gamepad_banking'] =  GAMEPAD_BANKING_SCENE
end