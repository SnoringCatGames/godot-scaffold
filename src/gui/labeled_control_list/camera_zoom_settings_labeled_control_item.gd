class_name CameraZoomSettingsLabeledControlItem
extends SliderLabeledControlItem


const LABEL := "Cam. zoom"
const DESCRIPTION := ""

const MIN_RESULT_VALUE := 0.2
const MAX_RESULT_VALUE := 5.0
const MID_RESULT_VALUE := 1.0

const STEP := (MAX_CONTROL_VALUE - MIN_CONTROL_VALUE) / 32.0
const WIDTH := 128.0
const TICK_COUNT := 3


func _init(__ = null).(
        LABEL,
        DESCRIPTION,
        MIN_RESULT_VALUE,
        MID_RESULT_VALUE,
        MAX_RESULT_VALUE,
        STEP,
        WIDTH,
        TICK_COUNT
        ) -> void:
    pass


func on_value_changed(control_value: float) -> void:
    var result_value := _control_value_to_result_value(control_value)
    Gs.camera_controller.zoom_factor = result_value
    Gs.save_state.set_setting(
            SaveState.ZOOM_FACTOR_SETTINGS_KEY,
            result_value)


func get_value() -> float:
    return _result_value_to_control_value(Gs.camera_controller.zoom_factor)


func get_is_enabled() -> bool:
    return true
