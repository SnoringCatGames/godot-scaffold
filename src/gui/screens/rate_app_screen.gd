class_name RateAppScreen
extends Screen


const NAME := "rate_app"
const LAYER_NAME := "menu_screen"
const IS_ALWAYS_ALIVE := false
const AUTO_ADAPTS_GUI_SCALE := true
const INCLUDES_STANDARD_HIERARCHY := true
const INCLUDES_NAV_BAR := true
const INCLUDES_CENTER_CONTAINER := true

const NEXT_SCREEN_TYPE := "main_menu"


func _init().(
        NAME,
        LAYER_NAME,
        IS_ALWAYS_ALIVE,
        AUTO_ADAPTS_GUI_SCALE,
        INCLUDES_STANDARD_HIERARCHY,
        INCLUDES_NAV_BAR,
        INCLUDES_CENTER_CONTAINER \
        ) -> void:
    pass


func _on_activated(previous_screen: Screen) -> void:
    ._on_activated(previous_screen)
    assert(Gs.gui.is_rate_app_shown)


func _get_focused_button() -> ScaffolderButton:
    return $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/VBoxContainer2/RateAppButton as \
            ScaffolderButton


func _on_RateAppButton_pressed():
    Gs.save_state.set_gave_feedback(true)
    Gs.nav.open(NEXT_SCREEN_TYPE)
    var app_store_url: String = \
            Gs.app_metadata.ios_app_store_url if \
            Gs.utils.get_is_ios_device() else \
            Gs.app_metadata.android_app_store_url
    OS.shell_open(app_store_url)


func _on_DontAskAgainButton_pressed():
    Gs.save_state.set_gave_feedback(true)
    Gs.nav.open(NEXT_SCREEN_TYPE)


func _on_KeepPlayingButton_pressed():
    Gs.nav.open(NEXT_SCREEN_TYPE)


func _on_SendFeedbackButton_pressed() -> void:
    Gs.nav.open(NEXT_SCREEN_TYPE)
    OS.shell_open(Gs.get_support_url_with_params())
