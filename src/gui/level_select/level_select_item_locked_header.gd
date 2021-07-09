class_name LevelSelectItemLockedHeader
extends Control


signal unlock_finished

const LOCK_LOW_PART_DELAY := 0.2
const LOCK_HIGH_PART_DELAY := 0.15
const HINT_PULSE_DURATION := 2.0

var level_id: String
var hint_tween: ScaffolderTween

var previous_gui_scale: float

var header_stylebox: StyleBoxFlatScalable
var hint_stylebox: StyleBoxFlatScalable


func _enter_tree() -> void:
    hint_tween = ScaffolderTween.new()
    $HintWrapper/Hint.add_child(hint_tween)


func _exit_tree() -> void:
    if is_instance_valid(header_stylebox):
        header_stylebox.destroy()
    if is_instance_valid(hint_stylebox):
        hint_stylebox.destroy()


func init_children() -> void:
    $HintWrapper.modulate.a = 0.0
    previous_gui_scale = Gs.gui.scale
    
    header_stylebox = Gs.styles.create_stylebox_scalable({
        stylebox = get_stylebox("panel"),
        corner_radius = Gs.styles.dropdown_corner_radius,
        corner_detail = Gs.styles.dropdown_corner_detail,
        shadow_size = Gs.styles.dropdown_shadow_size,
        border_width = Gs.styles.dropdown_border_width,
        border_color = Gs.colors.dropdown_border,
    })
    add_stylebox_override("panel", header_stylebox)
    
    hint_stylebox = Gs.styles.create_stylebox_scalable({
        stylebox = get_stylebox("panel"),
        corner_radius = Gs.styles.dropdown_corner_radius,
        corner_detail = Gs.styles.dropdown_corner_detail,
        shadow_size = Gs.styles.dropdown_shadow_size,
        border_width = Gs.styles.dropdown_border_width,
        border_color = Gs.colors.dropdown_border,
    })
    $HintWrapper.add_stylebox_override("panel", hint_stylebox)


func update_size(header_size: Vector2) -> bool:
    if !$HintWrapper/Hint.has_meta("gs_rect_min_size"):
        $HintWrapper/Hint.set_meta(
                "gs_rect_min_size", $HintWrapper/Hint.rect_min_size)
    var original_hint_rect_min_size: Vector2 = \
            $HintWrapper/Hint.get_meta("gs_rect_min_size")
    
    rect_min_size = header_size
    
    $HintWrapper/Hint.rect_min_size = \
            original_hint_rect_min_size * Gs.gui.scale
    $HintWrapper/Hint.rect_size = header_size
    $HintWrapper.rect_size = header_size
    $LockAnimation._on_gui_scale_changed()
    
    rect_size = header_size
    
    return true


func update_is_unlocked(is_unlocked: bool) -> void:
    var unlock_hint_message: String = \
            Gs.level_config.get_unlock_hint(level_id)
    var is_next_level_to_unlock: bool = \
            Gs.level_config.get_next_level_to_unlock() == level_id
    
    $HintWrapper/Hint.text = unlock_hint_message
    visible = !is_unlocked
    
    # TODO: Remove?
    var is_unlock_pulse_auto_shown := false
#    var is_unlock_pulse_auto_shown := \
#            unlock_hint_message != "" and \
#            is_next_level_to_unlock
    if is_unlock_pulse_auto_shown:
        # Finish the unlock animation for the previous item before showing the
        # unlock hint for this item.
        var delay := 0.0
#        var delay := \
#                0.0 if \
#                !Gs.save_state.get_new_unlocked_levels().empty() else \
#                (0.3 + \
#                LOCK_LOW_PART_DELAY + \
#                LockAnimation.UNLOCK_DURATION + \
#                FADE_TWEEN_DURATION)
        Gs.time.set_timeout(funcref(self, "pulse_unlock_hint"), delay)


func unlock() -> void:
    visible = true
    
    Gs.time.set_timeout(
            funcref($LockAnimation, "unlock"),
            LOCK_LOW_PART_DELAY)
    
    Gs.time.set_timeout(
            funcref(Gs.audio, "play_sound"),
            LOCK_LOW_PART_DELAY,
            ["lock_low"])
    Gs.time.set_timeout(
            funcref(Gs.audio, "play_sound"),
            LOCK_LOW_PART_DELAY + LOCK_HIGH_PART_DELAY,
            ["lock_high"])


func pulse_unlock_hint() -> void:
    hint_tween.stop_all()
    var fade_in_duration := 0.3
    hint_tween.interpolate_property(
            $HintWrapper,
            "modulate:a",
            0.0,
            1.0,
            fade_in_duration,
            "ease_in_out")
    hint_tween.interpolate_property(
            $HintWrapper,
            "modulate:a",
            1.0,
            0.0,
            fade_in_duration,
            "ease_in_out",
            HINT_PULSE_DURATION - fade_in_duration)
    hint_tween.start()


func _on_LevelSelectItemLockedHeader_gui_input(event: InputEvent) -> void:
    var is_mouse_up: bool = \
            event is InputEventMouseButton and \
            !event.pressed and \
            event.button_index == BUTTON_LEFT
    var is_touch_up: bool = \
            (event is InputEventScreenTouch and \
                    !event.pressed)
    
    if is_mouse_up or is_touch_up:
        pulse_unlock_hint()


func _on_LockAnimation_unlock_finished() -> void:
    emit_signal("unlock_finished")
