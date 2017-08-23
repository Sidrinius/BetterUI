
BUI.Bank = {}
BUI.Bank.Window = BUI.General.Window:Subclass()

local GAMEPAD_BANKING_SCENE_NAME = "bui_gamepad_banking"

function BUI.Bank.Window:New( ... )
    local window = BUI.General.Window.New(self, ...)
    return window
end

function BUI.Bank.Window:Initialize(control)
    BUI_GAMEPAD_BANKING_SCENE = ZO_InteractScene:New(GAMEPAD_BANKING_SCENE_NAME, SCENE_MANAGER, BANKING_INTERACTION)
    BUI.General.Window.Initialize(self, control, false, true, BUI_GAMEPAD_BANKING_SCENE)
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
	BUI_GAMEPAD_BANKING_SCENE:AddFragmentGroup(GAMEPAD_DRIVEN_UI_WINDOW)
	BUI_GAMEPAD_BANKING_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
	BUI_GAMEPAD_BANKING_SCENE:AddFragment(GAMEPAD_BANKING_FRAGMENT)
	BUI_GAMEPAD_BANKING_SCENE:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
	BUI_GAMEPAD_BANKING_SCENE:AddFragment(MINIMIZE_CHAT_FRAGMENT)
	BUI_GAMEPAD_BANKING_SCENE:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)
    SCENE_MANAGER.scenes['gamepad_banking'] =  BUI_GAMEPAD_BANKING_SCENE



    local function SceneStateChange(oldState, newState)
        if(newState == SCENE_SHOWING) then
            KEYBIND_STRIP:AddKeybindButtonGroup(GAMEPAD_BANKING.keybindStripDescriptor)
            --BUI.CIM.SetTooltipWidth(BUI_GAMEPAD_DEFAULT_PANEL_WIDTH)
            dd("bb1")
        elseif(newState == SCENE_HIDING) then
            KEYBIND_STRIP:RemoveKeybindButtonGroup(GAMEPAD_BANKING.keybindStripDescriptor)
          -- BUI.CIM.SetTooltipWidth(BUI_ZO_GAMEPAD_DEFAULT_PANEL_WIDTH)
          dd("bb2")
        elseif(newState == SCENE_HIDDEN) then
            dd("bb3")
        end
        dd("bb4")
    end
    BUI_GAMEPAD_BANKING_SCENE:RegisterCallback("StateChange",  SceneStateChange)
end