class_name DebugPanelSettingsLabeledControlItem
extends CheckboxLabeledControlItem


const LABEL := "Debug panel"
const DESCRIPTION := (
        "The debug panel displays information about various application " +
        "events as they occur. " +
        "These events are helpful for debugging, and normal users won't " +
        "care. " +
        "The debug panel is shown as a transparent overlay covering the " +
        "entire screen.")


func _init(__ = null).(
        LABEL,
        DESCRIPTION \
        ) -> void:
    pass


func on_pressed(pressed: bool) -> void:
    Gs.is_debug_panel_shown = pressed
    Gs.save_state.set_setting(
            Gs.IS_DEBUG_PANEL_SHOWN_SETTINGS_KEY,
            Gs.is_debug_panel_shown)


func get_is_pressed() -> bool:
    return Gs.is_debug_panel_shown


func get_is_enabled() -> bool:
    return true
