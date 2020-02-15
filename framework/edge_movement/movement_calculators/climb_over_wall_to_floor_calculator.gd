extends EdgeMovementCalculator
class_name ClimbOverWallToFloorCalculator

const MovementCalcOverallParams := preload("res://framework/edge_movement/models/movement_calculation_overall_params.gd")

const NAME := 'ClimbOverWallToFloorCalculator'

func _init().(NAME) -> void:
    pass

func get_can_traverse_from_surface(surface: Surface) -> bool:
    return surface != null and \
            ((surface.side == SurfaceSide.LEFT_WALL and \
                    surface.concave_counter_clockwise_neighbor != null) or \
            (surface.side == SurfaceSide.RIGHT_WALL and \
                    surface.concave_clockwise_neighbor != null))

func get_all_edges_from_surface(collision_params: CollisionCalcParams, edges_result: Array, \
        surfaces_in_fall_range_set: Dictionary, surfaces_in_jump_range_set: Dictionary, \
        origin_surface: Surface) -> void:
    var movement_params := collision_params.movement_params
    
    var upper_neighbor_floor: Surface
    var wall_top_point: Vector2
    var floor_edge_point: Vector2
    
    if origin_surface.side == SurfaceSide.LEFT_WALL:
        upper_neighbor_floor = origin_surface.concave_counter_clockwise_neighbor
        wall_top_point = origin_surface.first_point
        floor_edge_point = upper_neighbor_floor.last_point
        
    elif origin_surface.side == SurfaceSide.RIGHT_WALL:
        upper_neighbor_floor = origin_surface.concave_clockwise_neighbor
        wall_top_point = origin_surface.last_point
        floor_edge_point = upper_neighbor_floor.first_point
    
    if upper_neighbor_floor == null:
        # There is no floor surface to climb up to.
        return
    
    var start_position := MovementUtils.create_position_from_target_point( \
            wall_top_point, origin_surface, movement_params.collider_half_width_height)
    var end_position := MovementUtils.create_position_from_target_point( \
            floor_edge_point, upper_neighbor_floor, movement_params.collider_half_width_height)
    
    var edge := ClimbOverWallToFloorEdge.new(start_position, end_position)
    edges_result.push_back(edge)
