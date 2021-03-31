class_name GameScreen
extends Screen

const NAME := "game"
const LAYER_NAME := "game_screen"
const AUTO_ADAPTS_GUI_SCALE := true
const INCLUDES_STANDARD_HIERARCHY := false

func _init().( \
        NAME, \
        LAYER_NAME, \
        AUTO_ADAPTS_GUI_SCALE, \
        INCLUDES_STANDARD_HIERARCHY \
        ) -> void:
    pass

func _enter_tree() -> void:
    move_canvas_layer_to_game_viewport("annotation")
    
    _on_resized()

func move_canvas_layer_to_game_viewport(name: String) -> void:
    var layer: CanvasLayer = Gs.canvas_layers.layers[name]
    layer.get_parent().remove_child(layer)
    $PanelContainer/ViewportContainer/Viewport.add_child(layer)

func _process(_delta_sec: float) -> void:
    if !is_instance_valid(Gs.level):
        return
    
    # Transform the annotation layer to follow the camera within the
    # game-screen viewport.
    Gs.canvas_layers.layers.annotation.transform = \
            Gs.level.get_canvas_transform()

func _on_resized() -> void:
    ._on_resized()
    _update_viewport_region_helper()
    
    # TODO: This hack seems to be needed in order for the viewport to actually
    #       update its dimensions correctly.
    Gs.time.set_timeout(funcref(self, "_update_viewport_region_helper"), 1.0)

func _update_viewport_region_helper() -> void:
    var viewport_size := get_viewport().size
    var game_area_position := \
            (viewport_size - Gs.game_area_region.size) * 0.5
    
    $PanelContainer.rect_size = viewport_size
    $PanelContainer/ViewportContainer.rect_position = game_area_position
    $PanelContainer/ViewportContainer/Viewport.size = \
            Gs.game_area_region.size
    
    call_deferred("_fix_viewport_dimensions_hack")
    Gs.time.set_timeout(funcref(self, "_fix_viewport_dimensions_hack"), 0.4)

func _fix_viewport_dimensions_hack() -> void:
    # TODO: This hack seems to be needed in order for the viewport to actually
    #       update its dimensions correctly.
    self.visible = false
    call_deferred("set_visible", true)

func start_level(level_id: String) -> void:
    if is_instance_valid(Gs.level):
        return
    
    Gs.level = Gs.utils.add_scene( \
            null, \
            Gs.level_config.get_level_config(level_id).scene_path, \
            false, \
            true)
    Gs.level.id = level_id
    $PanelContainer/ViewportContainer/Viewport.add_child(Gs.level)
    Gs.level.start()
