extends InspectorItemController
class_name GlobalCountsTopLevelGroupItemController

const TYPE := InspectorItemType.GLOBAL_COUNTS_TOP_LEVEL_GROUP
const IS_LEAF := false
const STARTS_COLLAPSED := false
const PREFIX := "Global counts"

var graph: PlatformGraph

func _init( \
        parent_item: TreeItem, \
        tree: Tree, \
        graph: PlatformGraph) \
        .( \
        TYPE, \
        IS_LEAF, \
        STARTS_COLLAPSED, \
        parent_item, \
        tree) -> void:
    self.graph = graph
    _post_init()

func get_text() -> String:
    return PREFIX

func _create_children_inner() -> void:
    DescriptionItemController.new( \
            tree_item, \
            tree, \
            "%s total surfaces" % graph.counts.total_surfaces)
    DescriptionItemController.new( \
            tree_item, \
            tree, \
            "%s total edges" % graph.counts.total_edges)
    
    var type_name: String
    var text: String
    for edge_type in EdgeType.values():
        if InspectorItemController.EDGE_TYPES_TO_SKIP.find(edge_type) >= 0:
            continue
        
        type_name = EdgeType.get_type_string(edge_type)
        text = "%s %ss" % [ \
            graph.counts[type_name], \
            type_name, \
        ]
        DescriptionItemController.new( \
                tree_item, \
                tree, \
                text)

func _destroy_children_inner() -> void:
    # Do nothing.
    pass

func _draw_annotations() -> void:
    # Do nothing.
    pass
