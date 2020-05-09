extends Node2D
class_name PlatformGraphTreeView

# FIXME: LEFT OFF HERE: --------------------------------------
# - Figure out how to expand/collapse certain items by default.

signal platform_graph_selected
signal surface_selected
signal edge_attempt_selected
signal edge_step_selected

var global

# Array<PlatformGraph>
var graphs: Array

var step_tree_view: Tree
var step_tree_root: TreeItem

## Dictionary<TreeItem, MovementCalcStepDebugState>
#var tree_item_to_step_attempt := {}
## Dictionary<MovementCalcStepDebugState, Array<TreeItem>>
#var step_attempt_to_tree_items := {}
#
## Array<TreeItem>
#var current_highlighted_tree_items := []
#
#var edge_attempt: MovementCalcOverallDebugState

func _init(graphs: Array) -> void:
    self.graphs = graphs

func _ready() -> void:
    global = $"/root/Global"
    
    step_tree_view = Tree.new()
    step_tree_view.rect_min_size = Vector2( \
            0.0, \
            DebugPanel.SECTIONS_HEIGHT)
    step_tree_view.hide_root = true
    step_tree_view.hide_folding = false
    step_tree_view.connect( \
            "item_selected", \
            self, \
            "_on_tree_item_selected")
    global.debug_panel.add_section(step_tree_view)

func _draw() -> void:
    # FIXME: Only clear parts that actually need to be cleared.
    
    # Clear any previous items.
    step_tree_view.clear()
    step_tree_root = step_tree_view.create_item()
    
    for graph in graphs:
        _draw_platform_graph_item( \
                graph, \
                step_tree_root)

func _draw_platform_graph_item( \
        graph: PlatformGraph, \
        parent_item: TreeItem) -> void:
    var graph_item := step_tree_view.create_item(parent_item)
    graph_item.set_text( \
            0, \
            "Platform graph [%s]" % graph.movement_params.name)
    graph_item.set_metadata( \
            0, \
            graph)
    graph_item.collapsed = false
    
    var floors_item := step_tree_view.create_item(graph_item)
    floors_item.collapsed = true
    var left_walls_item := step_tree_view.create_item(graph_item)
    left_walls_item.collapsed = true
    var right_walls_item := step_tree_view.create_item(graph_item)
    right_walls_item.collapsed = true
    var ceilings_item := step_tree_view.create_item(graph_item)
    ceilings_item.collapsed = true
    
    for surface in graph.surfaces_set:
        match surface.side:
            SurfaceSide.FLOOR:
                parent_item = floors_item
            SurfaceSide.LEFT_WALL:
                parent_item = left_walls_item
            SurfaceSide.RIGHT_WALL:
                parent_item = right_walls_item
            SurfaceSide.CEILING:
                parent_item = ceilings_item
            _:
                Utils.error()
        
        _draw_surface_item( \
                surface, \
                graph, \
                parent_item)
    
    floors_item.set_text( \
            0, \
            "Floors [%s]" % graph.counts.FLOOR)
    left_walls_item.set_text( \
            0, \
            "Left walls [%s]" % graph.counts.LEFT_WALL)
    right_walls_item.set_text( \
            0, \
            "Right walls [%s]" % graph.counts.RIGHT_WALL)
    ceilings_item.set_text( \
            0, \
            "Ceilings [%s]" % graph.counts.CEILING)
    
    var global_counts_item := step_tree_view.create_item(graph_item)
    global_counts_item.set_text( \
            0, \
            "Global counts")
    global_counts_item.collapsed = false
    
    var total_surfaces_item := step_tree_view.create_item(global_counts_item)
    total_surfaces_item.set_text( \
            0, \
            "%s total surfaces" % graph.counts.total_surfaces)
    
    var total_edges_item := step_tree_view.create_item(global_counts_item)
    total_edges_item.set_text( \
            0, \
            "%s total edges" % graph.counts.total_edges)
    
    var edge_type_count_item: TreeItem
    for type_name in EdgeType.keys():
        edge_type_count_item = step_tree_view.create_item(global_counts_item)
        edge_type_count_item.set_text( \
                0, \
                "%s %ss" % [ \
                        graph.counts[type_name], \
                        type_name, \
                        ])

func _draw_surface_item( \
        surface: Surface, \
        graph: PlatformGraph, \
        parent_item: TreeItem) -> void:
    var surface_item := step_tree_view.create_item(parent_item)
    var text := "%s [%s, %s]" % [ \
            SurfaceSide.get_side_string(surface.side), \
            surface.first_point, \
            surface.last_point, \
            ]
    surface_item.set_text( \
            0, \
            text)
    surface_item.set_metadata( \
            0, \
            surface)
    surface_item.collapsed = true
    
    var edge: Edge
    var edge_item: TreeItem
    
    for origin_node in graph.surfaces_to_outbound_nodes[surface]:
        for destination_node in graph.nodes_to_nodes_to_edges[origin_node]:
            edge = graph.nodes_to_nodes_to_edges[origin_node][destination_node]
            
            edge_item = step_tree_view.create_item(surface_item)
            text = "%s [%s, %s]" % [ \
                    edge.name, \
                    edge.start, \
                    edge.end, \
                    ]
            edge_item.set_text( \
                    0, \
                    text)
            edge_item.set_metadata( \
                    0, \
                    edge)
            edge_item.collapsed = true

#func _draw() -> void:
#    # FIXME: Only clear parts that actually need to be cleared.
#
#    # Clear any previous items.
#    step_tree_view.clear()
#    step_tree_root = step_tree_view.create_item()
#    tree_item_to_step_attempt.clear()
#    step_attempt_to_tree_items.clear()
#    current_highlighted_tree_items.clear()
#
#    if edge_attempt != null:
#        _draw_step_tree_panel()
#
#func _draw_step_tree_panel() -> void:
#    if !edge_attempt.failed_before_creating_steps:
#        # Draw rows for each step-attempt.
#        for step_attempt in edge_attempt.children_step_attempts:
#            _draw_step_tree_item( \
#                    step_attempt, \
#                    step_tree_root)
#    else:
#        # Draw a message for the invalid edge.
#        var tree_item := step_tree_view.create_item(step_tree_root)
#        tree_item.set_text( \
#                0, \
#                EdgeCalculationTrajectoryAnnotator.INVALID_EDGE_TEXT)
#        tree_item_to_step_attempt[tree_item] = null
#        step_attempt_to_tree_items[null] = [tree_item]
#
#func _draw_step_tree_item( \
#        step_attempt: MovementCalcStepDebugState, \
#        parent_tree_item: TreeItem) -> void:
#    # Draw the row for the given step-attempt.
#    var tree_item := step_tree_view.create_item(parent_tree_item)
#    var text := _get_tree_item_text( \
#            step_attempt, \
#            0, \
#            false)
#    tree_item.set_text( \
#            0, \
#            text)
#    tree_item_to_step_attempt[tree_item] = step_attempt
#    step_attempt_to_tree_items[step_attempt] = [tree_item]
#
#    # Recursively draw rows for each child step-attempt.
#    for child_step_attempt in step_attempt.children_step_attempts:
#        _draw_step_tree_item( \
#                child_step_attempt, \
#                tree_item)
#
#    if step_attempt.description_list.size() > 1:
#        # Draw a closing row for the given step-attempt.
#        var tree_item_2 := step_tree_view.create_item(parent_tree_item)
#        text = _get_tree_item_text( \
#                step_attempt, \
#                1, \
#                false)
#        tree_item_2.set_text( \
#                0, \
#                text)
#        tree_item_to_step_attempt[tree_item_2] = step_attempt
#        step_attempt_to_tree_items[step_attempt].push_back(tree_item_2)

func _on_tree_item_selected() -> void:
    var selected_tree_item := step_tree_view.get_selected()
    var metadata = selected_tree_item.get_metadata(0)
    
    var print_message: String
    
    if metadata == null:
        print_message = selected_tree_item.get_text(0)
    elif metadata is PlatformGraph:
        print_message = metadata.to_string()
    elif metadata is Surface:
        print_message = metadata.to_string()
    elif metadata is Edge:
        print_message = metadata.to_string()
    elif metadata is MovementCalcStepDebugState:
        print_message = metadata.to_string()
    else:
        Utils.error("Invalid metadata object stored on TreeItem: %s" % metadata)
    
    print("PlatformGraphInspector item selected: %s" % print_message)
    
    # FIXME: -----------------------
    # - Determine the type of the tree item.
    # - Expand recursively to the correct spot.
    # - Scroll to the correct spot.
    pass
    
#    if !tree_item_to_step_attempt.has(selected_tree_item):
#        Utils.error("Invalid tree-view item state")
#        return
#
#    var selected_step_attempt: MovementCalcStepDebugState = \
#            tree_item_to_step_attempt[selected_tree_item]
#    if selected_step_attempt != null:
#        _on_step_selected(selected_step_attempt)
#        emit_signal( \
#                "step_selected", \
#                selected_step_attempt)

#func _on_step_selected(selected_step_attempt: MovementCalcStepDebugState) -> void:
#    var tree_item: TreeItem
#    var old_highlighted_step_attempt: MovementCalcStepDebugState
#    var text: String
#
#    # Unmark previously matching tree items.
#    for i in range(current_highlighted_tree_items.size()):
#        tree_item = current_highlighted_tree_items[i]
#        old_highlighted_step_attempt = tree_item_to_step_attempt[tree_item]
#        text = _get_tree_item_text( \
#                old_highlighted_step_attempt, \
#                i, \
#                false)
#        tree_item.set_text(0, text)
#
#    current_highlighted_tree_items = step_attempt_to_tree_items[selected_step_attempt]
#
#    # Mark all matching tree items.
#    for i in range(current_highlighted_tree_items.size()):
#        tree_item = current_highlighted_tree_items[i]
#        text = _get_tree_item_text( \
#                selected_step_attempt, \
#                i, \
#                true)
#        tree_item.set_text(0, text)
#
#func _get_tree_item_text( \
#        step_attempt: MovementCalcStepDebugState, \
#        description_index: int, \
#        includes_highlight_marker: bool) -> String:
#    return "%s%s: %s%s%s" % [ \
#            "*" if \
#                    includes_highlight_marker else \
#                    "",
#            step_attempt.index + 1, \
#            "[BT] " if \
#                    step_attempt.is_backtracking and description_index == 0 \
#                    else "", \
#            "[RF] " if \
#                    step_attempt.replaced_a_fake and description_index == 0 else \
#                    "", \
#            step_attempt.description_list[description_index], \
#        ]
