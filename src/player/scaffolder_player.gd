tool
class_name ScaffolderPlayer, \
"res://addons/scaffolder/assets/images/editor_icons/scaffolder_player.png"
extends KinematicBody2D


export var player_name := ""

## -   This helps your `ScaffolderPlayer` detect when other areas or bodies
##     collide with the player.[br]
## -   The default `PhysicsBody2D.collision_layer` property is limited, because
##     the `move_and_slide` system will adjust our movement when we collide
##     with matching objects.[br]
## -   So this separate `collision_detection_layers` property lets us detect
##     collisions without adjusting our movement.[br]
export(int, LAYERS_2D_PHYSICS) var collision_detection_layers := 0

## Used for things like the fill-color of exclamation-mark annotations.
export var primary_annotation_color := Color.black
## Used for things like the border-color of exclamation-mark annotations.
export var secondary_annotation_color := Color.white

export var exclamation_mark_width_start := 4.0
export var exclamation_mark_length_start := 24.0
export var exclamation_mark_stroke_width_start := 1.2
export var exclamation_mark_duration := 1.8
export var exclamation_mark_throttle_interval := 1.0

export var logs_player_events := false
export var logs_computer_player_events := false

var is_human_player := false
var _is_ready := false
var _is_destroyed := false

var _configuration_warning := ""

var behavior := PlayerBehaviorType.REST
var velocity := Vector2.ZERO
var collider_half_width_height := Vector2.INF
var start_position := Vector2.INF
var previous_position := Vector2.INF
var did_move_last_frame := false

var collider: CollisionShape2D
var animator: ScaffolderPlayerAnimator

var _extra_collision_detection_area: Area2D
# Dictionary<String, Area2D>
var _layers_for_entered_proximity_detection := {}
# Dictionary<String, Area2D>
var _layers_for_exited_proximity_detection := {}

var _debounced_update_editor_configuration: FuncRef
var _throttled_show_exclamation_mark: FuncRef


func _enter_tree() -> void:
    _update_editor_configuration()


func _ready() -> void:
    _is_ready = true
    
    start_position = position
    
    _debounced_update_editor_configuration = Sc.time.debounce(
            funcref(self, "_update_editor_configuration_debounced"),
            0.02,
            true)
    _throttled_show_exclamation_mark = Sc.time.throttle(
            funcref(self, "_show_exclamation_mark_throttled"),
            exclamation_mark_throttle_interval,
            false,
            TimeType.PLAY_PHYSICS_SCALED)
    
    _update_editor_configuration_debounced()
    _initialize_children_proximity_detectors()
    
    if Engine.editor_hint:
        return
    
    # Start facing right.
    animator.face_right()
    
    var collision_detection_layer_names: Array = \
            Sc.utils.get_physics_layer_names_from_bitmask(
                    collision_detection_layers)
    for layer_name in collision_detection_layer_names:
        _add_layer_for_collision_detection(layer_name)
    
    Sc.device.connect(
            "display_resized",
            self,
            "_on_resized")
    _on_resized()


func _destroy() -> void:
    _is_destroyed = true
    if is_instance_valid(animator):
        animator._destroy()
    if !is_queued_for_deletion():
        queue_free()


func _on_resized() -> void:
    Sc.camera_controller._on_resized()


func _on_annotators_ready() -> void:
    pass


func add_child(child: Node, legible_unique_name := false) -> void:
    .add_child(child, legible_unique_name)
    _update_editor_configuration()


func remove_child(child: Node) -> void:
    .remove_child(child)
    _update_editor_configuration()


func _update_editor_configuration() -> void:
    if !_is_ready:
        return
    _debounced_update_editor_configuration.call_func()


func _update_editor_configuration_debounced() -> void:
    if !Sc.utils.check_whether_sub_classes_are_tools(self):
        _set_configuration_warning(
                "Subclasses of ScaffolderPlayer must be marked as tool.")
        return
    
    if player_name == "":
        _set_configuration_warning("Must define player_name.")
        return
    
    # Get AnimationPlayer from scene configuration.
    if !is_instance_valid(animator):
        var player_animators: Array = Sc.utils.get_children_by_type(
                self,
                ScaffolderPlayerAnimator)
        if player_animators.size() > 1:
            _set_configuration_warning(
                    "Must only define a single ScaffolderPlayerAnimator child node.")
            return
        elif player_animators.size() < 1:
            _set_configuration_warning(
                    "Must define a ScaffolderPlayerAnimator-subclass child node.")
            return
        animator = player_animators[0]
        animator.is_desaturatable = true
    
    if !is_instance_valid(collider):
        collider = Sc.utils.get_child_by_type(self, CollisionShape2D)
        collider_half_width_height = \
                Sc.geometry.calculate_half_width_height(
                        collider.shape, collider.rotation) if \
                is_instance_valid(collider) else \
                Vector2.INF
    
    _set_configuration_warning("")


func _set_configuration_warning(value: String) -> void:
    _configuration_warning = value
    update_configuration_warning()
    property_list_changed_notify()
    if value != "" and \
            !Engine.editor_hint:
        Sc.logger.error(value)


func _get_configuration_warning() -> String:
    return _configuration_warning


func _initialize_children_proximity_detectors() -> void:
    # Get ProximityDetectors from scene configuration.
    for detector in Sc.utils.get_children_by_type(self, ProximityDetector):
        if detector.is_detecting_enter:
            _add_layer_for_entered_shape_proximity_detection(
                    detector.get_layer_names(),
                    detector.shape,
                    detector.rotation)
        if detector.is_detecting_exit:
            _add_layer_for_exited_shape_proximity_detection(
                    detector.get_layer_names(),
                    detector.shape,
                    detector.rotation)


func set_is_human_player(value: bool) -> void:
    is_human_player = value
    
    var group: String = \
            Sc.players.GROUP_NAME_HUMAN_PLAYERS if \
            is_human_player else \
            Sc.players.GROUP_NAME_COMPUTER_PLAYERS
    self.add_to_group(group)
    
    if is_human_player:
        # Only a single, user-controlled player should have a camera.
        _set_camera()


func _set_camera() -> void:
    var camera := Camera2D.new()
    camera.smoothing_enabled = true
    camera.smoothing_speed = Sc.gui.camera_smoothing_speed
    add_child(camera)
    # Register the current camera, so it's globally accessible.
    Sc.camera_controller.set_current_camera(camera, self)


func _physics_process(delta: float) -> void:
    if !_is_ready or \
            _is_destroyed or \
            Engine.editor_hint:
        return
    
    previous_position = position
    _on_physics_process(delta)
    did_move_last_frame = previous_position != position


func _on_physics_process(delta: float) -> void:
    _process_animation()
    _process_sounds()


func _process_animation() -> void:
    pass


func _process_sounds() -> void:
    pass


# Conditionally prints the given message, depending on the ScaffolderPlayer's
# configuration.
func _log_player_event(
        message_template: String,
        message_args = null,
        is_low_level_framework_event = false) -> void:
    if logs_player_events and \
            (!is_low_level_framework_event or \
                Sc.metadata.is_logging_low_level_player_framework_events) and \
            (is_human_player or \
                logs_computer_player_events):
        if message_args != null:
            Sc.logger.print(message_template % message_args)
        else:
            Sc.logger.print(message_template)


func show_exclamation_mark() -> void:
    _throttled_show_exclamation_mark.call_func()


func _show_exclamation_mark_throttled() -> void:
    Sc.annotators.add_transient(ExclamationMarkAnnotator.new(
            self,
            collider_half_width_height.y,
            primary_annotation_color,
            secondary_annotation_color,
            exclamation_mark_width_start,
            exclamation_mark_length_start,
            exclamation_mark_stroke_width_start,
            exclamation_mark_duration))


func set_is_sprite_visible(is_visible: bool) -> void:
    animator.visible = is_visible


func get_is_sprite_visible() -> bool:
    return animator.visible


# Uses physics layers and an auxiliary Area2D to detect collisions with areas
# and objects.
func _add_layer_for_collision_detection(layer_name_or_names) -> void:
    # Create the Area2D if it doesn't exist yet.
    if !is_instance_valid(_extra_collision_detection_area):
        _extra_collision_detection_area = _add_detection_area(
                collider.shape,
                collider.rotation,
                "_on_started_colliding",
                "_on_stopped_colliding")
    _enable_layer(layer_name_or_names, _extra_collision_detection_area)


func _remove_layer_for_collision_detection(layer_name_or_names) -> void:
    if !is_instance_valid(_extra_collision_detection_area):
        return
    
    _disable_layer(layer_name_or_names, _extra_collision_detection_area)
    
    # Destroy the Area2D if it is no longer listening to anything.
    if _extra_collision_detection_area.collision_mask == 0:
        _extra_collision_detection_area.queue_free()
        _extra_collision_detection_area = null


func _add_layer_for_entered_radius_proximity_detection(
        layer_name_or_names,
        radius: float) -> void:
    var shape := CircleShape2D.new()
    shape.radius = radius
    _add_layer_for_entered_shape_proximity_detection(
            layer_name_or_names,
            shape,
            0.0)


func _add_layer_for_exited_radius_proximity_detection(
        layer_name_or_names,
        radius: float) -> void:
    var shape := CircleShape2D.new()
    shape.radius = radius
    _add_layer_for_exited_shape_proximity_detection(
            layer_name_or_names,
            shape,
            0.0)


func _add_layer_for_entered_shape_proximity_detection(
        layer_name_or_names,
        detection_shape: Shape2D,
        detection_shape_rotation: float) -> void:
    var area := _add_detection_area(
            detection_shape,
            detection_shape_rotation,
            "_on_entered_proximity",
            "")
    _enable_layer(layer_name_or_names, area)
    
    var layer_names := \
            [layer_name_or_names] if \
            layer_name_or_names is String else \
            layer_name_or_names
    for layer_name in layer_names:
        _layers_for_entered_proximity_detection[layer_name] = area


func _add_layer_for_exited_shape_proximity_detection(
        layer_name_or_names,
        detection_shape: Shape2D,
        detection_shape_rotation: float) -> void:
    var area := _add_detection_area(
            detection_shape,
            detection_shape_rotation,
            "",
            "_on_exited_proximity")
    _enable_layer(layer_name_or_names, area)
    
    var layer_names := \
            [layer_name_or_names] if \
            layer_name_or_names is String else \
            layer_name_or_names
    for layer_name in layer_names:
        _layers_for_exited_proximity_detection[layer_name] = area


func _remove_layer_for_proximity_detection(layer_name_or_names) -> void:
    var layer_names := \
            [layer_name_or_names] if \
            layer_name_or_names is String else \
            layer_name_or_names
    for layer_name in layer_names:
        if _layers_for_entered_proximity_detection.has(layer_name):
            var area: Area2D = \
                    _layers_for_entered_proximity_detection[layer_name]
            if is_instance_valid(area):
                area.queue_free()
            _layers_for_entered_proximity_detection.erase(layer_name)
        
        if _layers_for_exited_proximity_detection.has(layer_name):
            var area: Area2D = \
                    _layers_for_exited_proximity_detection[layer_name]
            if is_instance_valid(area):
                area.queue_free()
            _layers_for_exited_proximity_detection.erase(layer_name)


func _on_detection_area_enter_exit(
        target,
        callback_name: String,
        detection_area: Area2D) -> void:
    # Ignore any events that are triggered at invalid times.
    if _is_destroyed or \
            !Sc.level_session.has_started:
        return
    
    # Get a list of the collision-layer names that are matched between the
    # given detector and detectee.
    var shared_bits: int = \
            target.collision_layer & detection_area.collision_mask
    var layer_names: Array = \
            Sc.utils.get_physics_layer_names_from_bitmask(shared_bits)
    assert(!layer_names.empty())
    
    self.call(callback_name, target, layer_names)


func _on_started_colliding(target: Node2D, layer_names: Array) -> void:
    pass


func _on_stopped_colliding(target: Node2D, layer_names: Array) -> void:
    pass


func _on_entered_proximity(target: Node2D, layer_names: Array) -> void:
    pass


func _on_exited_proximity(target: Node2D, layer_names: Array) -> void:
    pass


func _add_detection_area(
        detection_shape: Shape2D,
        detection_shape_rotation: float,
        enter_callback_name: String,
        exit_callback_name: String) -> Area2D:
    var area := Area2D.new()
    area.monitoring = true
    area.monitorable = false
    area.collision_layer = 0
    area.collision_mask = 0
    
    if enter_callback_name != "":
        area.connect(
                "area_entered",
                self,
                "_on_detection_area_enter_exit",
                [enter_callback_name, area])
        area.connect(
                "body_entered",
                self,
                "_on_detection_area_enter_exit",
                [enter_callback_name, area])
    if exit_callback_name != "":
        area.connect(
                "area_exited",
                self,
                "_on_detection_area_enter_exit",
                [enter_callback_name, area])
        area.connect(
                "body_exited",
                self,
                "_on_detection_area_enter_exit",
                [enter_callback_name, area])
    
    var collision_shape := CollisionShape2D.new()
    collision_shape.shape = detection_shape
    collision_shape.rotation = detection_shape_rotation
    
    area.add_child(collision_shape)
    self.add_child(area)
    
    return area


func _enable_layer(
        layer_name_or_names,
        area: Area2D) -> void:
    assert(layer_name_or_names is String or \
            layer_name_or_names is Array)
    var layer_names := \
            [layer_name_or_names] if \
            layer_name_or_names is String else \
            layer_name_or_names
    
    for layer_name in layer_names:
        # Enable the bit for this layer.
        var layer_bit_mask: int = \
                Sc.utils.get_physics_layer_bitmask_from_name(layer_name)
        area.collision_mask |= layer_bit_mask


func _disable_layer(
        layer_name_or_names,
        area: Area2D) -> void:
    assert(layer_name_or_names is String or \
            layer_name_or_names is Array)
    var layer_names := \
            [layer_name_or_names] if \
            layer_name_or_names is String else \
            layer_name_or_names
    
    for layer_name in layer_names:
        # Disable the bit for this layer.
        var layer_bit_mask: int = \
                Sc.utils.get_physics_layer_bitmask_from_name(layer_name)
        area.collision_mask &= ~layer_bit_mask
