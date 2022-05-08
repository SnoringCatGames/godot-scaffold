class_name RadialMenuLabel
extends Node2D


const _BOTTOM_MARGIN := 8.0

var text := "" setget _set_text
var color: Color = Sc.palette.get_color("white") setget _set_color

var panel_container: ScaffolderPanelContainer
var label: ScaffolderLabel


func _ready() -> void:
    _initialize_node_references()
    
    label.size_override = Vector2(
        (Sc.gui.hud.radial_menu_radius + \
            Sc.gui.hud.radial_menu_item_radius) * 2.0,
        0.0)
    
    _set_color(color)
    
    Sc.gui.add_gui_to_scale(self)
    
    _on_gui_scale_changed()


func _initialize_node_references() -> void:
    panel_container = $ScaffolderPanelContainer
    label = $ScaffolderPanelContainer/ScaffolderLabel


func _destroy() -> void:
    Sc.gui.remove_gui_to_scale(self)
    if !is_queued_for_deletion():
        queue_free()


func _on_gui_scale_changed() -> bool:
    for child in Sc.utils.get_children_by_type(self, Control):
        Sc.gui.scale_gui_recursively(child)
    
    # Position the label above the top radial-menu-item when expanded.
    self.position.y = \
        -(Sc.gui.hud.radial_menu_item_radius * \
        Sc.gui.hud.radial_menu_item_hovered_scale * 2.0 + \
        Sc.gui.hud.radial_menu_radius + \
        _BOTTOM_MARGIN) * \
        Sc.gui.scale
    
    # Anchored at the bottom middle.
    panel_container.rect_position = Vector2(
        -panel_container.rect_size.x / 2.0,
        -panel_container.rect_size.y)
    
    return true


func _set_text(value: String) -> void:
    var old_text := text
    text = value
    if old_text != text:
        label.text = text
        _on_gui_scale_changed()


func _set_color(value: Color) -> void:
    color = value
    label.add_color_override("font_color", color)
