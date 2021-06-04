class_name LevelInput
extends Node


var _control: Control
var _focused_control: Control
var _an_active_overlay_has_focus := false


func _init() -> void:
    Gs.logger.print("LevelInput._init")
    _control = Control.new()
    add_child(_control)


func _process(_delta: float) -> void:
    var next_focused_control := _control.get_focus_owner()
    if _focused_control != next_focused_control:
        _focused_control = next_focused_control
        for overlay in Gs.active_overlays:
            assert(is_instance_valid(overlay) and overlay is Control)
            if Gs.utils.does_control_have_focus_recursively(overlay):
                _an_active_overlay_has_focus = true
                return
        _an_active_overlay_has_focus = false


func is_action_pressed(name: String) -> bool:
    return _get_is_level_ready_for_input() and \
            Input.is_action_pressed(name)


func is_action_released(name: String) -> bool:
    return _get_is_level_ready_for_input() and \
            Input.is_action_released(name)


func is_action_just_pressed(name: String) -> bool:
    return _get_is_level_ready_for_input() and \
            Input.is_action_just_pressed(name)


func is_action_just_released(name: String) -> bool:
    return _get_is_level_ready_for_input() and \
            Input.is_action_just_released(name)


func is_key_pressed(code: int) -> bool:
    return _get_is_level_ready_for_input() and \
            Input.is_key_pressed(code)


func _get_is_level_ready_for_input() -> bool:
    return Gs.is_user_interaction_enabled and \
            !_an_active_overlay_has_focus
