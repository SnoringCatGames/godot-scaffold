extends InspectorItemController
class_name DescriptionItemController

const TYPE := InspectorItemType.DESCRIPTION
const IS_LEAF := true
const STARTS_COLLAPSED := true

var text: String

func _init( \
        tree_item: TreeItem, \
        tree: Tree, \
        text: String) \
        .( \
        TYPE, \
        IS_LEAF, \
        STARTS_COLLAPSED, \
        tree_item, \
        tree) -> void:
    self.text = text
    _post_init()

func to_string() -> String:
    return "%s { text=%s }" % [ \
        InspectorItemType.get_type_string(type), \
        text, \
    ]

func get_text() -> String:
    return text

func find_and_expand_controller( \
        search_type: int, \
        metadata: Dictionary) -> InspectorItemController:
    return null

func _create_children_inner() -> void:
    # Do nothing.
    pass

func _destroy_children_inner() -> void:
    # Do nothing.
    pass

func _draw_annotations() -> void:
    # Do nothing.
    pass
