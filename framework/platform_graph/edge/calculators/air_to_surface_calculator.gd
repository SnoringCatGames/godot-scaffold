extends EdgeCalculator
class_name AirToSurfaceCalculator

const NAME := "AirToSurfaceCalculator"
const EDGE_TYPE := EdgeType.AIR_TO_SURFACE_EDGE
const IS_A_JUMP_CALCULATOR := false

func _init().( \
        NAME, \
        EDGE_TYPE, \
        IS_A_JUMP_CALCULATOR) -> void:
    pass

func get_can_traverse_from_surface(surface: Surface) -> bool:
    return surface == null

func get_all_inter_surface_edges_from_surface( \
        inter_surface_edges_results: Array, \
        collision_params: CollisionCalcParams, \
        origin_surface: Surface, \
        surfaces_in_fall_range_set: Dictionary, \
        surfaces_in_jump_range_set: Dictionary) -> void:
    Utils.error( \
            "AirToSurfaceCalculator." + \
            "get_all_inter_surface_edges_from_surface should not be called")

func calculate_edge( \
        edge_result_metadata: EdgeCalcResultMetadata, \
        collision_params: CollisionCalcParams, \
        position_start: PositionAlongSurface, \
        position_end: PositionAlongSurface, \
        velocity_start := Vector2.INF, \
        needs_extra_jump_duration := false, \
        needs_extra_wall_land_horizontal_speed := false) -> Edge:
    edge_result_metadata = \
            edge_result_metadata if \
            edge_result_metadata != null else \
            EdgeCalcResultMetadata.new(false, false)
    return find_a_landing_trajectory( \
            edge_result_metadata, \
            collision_params, \
            {}, \
            position_start, \
            velocity_start, \
            position_end, \
            position_end, \
            needs_extra_wall_land_horizontal_speed)

func optimize_edge_land_position_for_path( \
        collision_params: CollisionCalcParams, \
        path: PlatformGraphPath, \
        edge_index: int, \
        edge: Edge, \
        next_edge: IntraSurfaceEdge) -> void:
    assert(edge is AirToSurfaceEdge)
    
    EdgeCalculator.optimize_edge_land_position_for_path_helper( \
            collision_params, \
            path, \
            edge_index, \
            edge, \
            next_edge, \
            self)

# Finds a movement step that will result in landing on a surface, with an
# attempt to minimize the path the player would then have to travel between
# surfaces to reach the given target.
#
# Returns null if no possible landing exists.
func find_a_landing_trajectory( \
        edge_result_metadata: EdgeCalcResultMetadata, \
        collision_params: CollisionCalcParams, \
        all_possible_surfaces_set: Dictionary, \
        origin: PositionAlongSurface, \
        velocity_start: Vector2, \
        goal: PositionAlongSurface, \
        exclusive_land_position: PositionAlongSurface, \
        needs_extra_wall_land_horizontal_speed := false) -> AirToSurfaceEdge:
    # TODO: Use goal param.
    
    assert(!needs_extra_wall_land_horizontal_speed or \
            exclusive_land_position != null)
    
    var calc_result: EdgeCalcResult
    
    if exclusive_land_position != null:
        calc_result = \
                FallMovementUtils.find_landing_trajectory_between_positions( \
                        edge_result_metadata, \
                        collision_params, \
                        origin, \
                        exclusive_land_position, \
                        velocity_start, \
                        needs_extra_wall_land_horizontal_speed)
        if calc_result == null:
            return null
    else:
        # Find all possible surfaces in landing range.
        var result_set := {}
        FallMovementUtils.find_surfaces_in_fall_range_from_point( \
                collision_params.movement_params, \
                all_possible_surfaces_set, \
                result_set, \
                origin.target_point, \
                velocity_start)
        var possible_landing_surfaces_from_point := result_set.keys()
        possible_landing_surfaces_from_point.sort_custom( \
                SurfaceMaxYComparator, \
                "sort")
        
        # Find the closest landing trajectory.
        var inter_surface_edges_results := []
        FallMovementUtils.find_landing_trajectories_to_any_surface( \
                inter_surface_edges_results, \
                collision_params, \
                all_possible_surfaces_set, \
                origin, \
                velocity_start, \
                self, \
                false, \
                possible_landing_surfaces_from_point, \
                true)
        if inter_surface_edges_results.empty() or \
                inter_surface_edges_results[0].edge_calc_results.empty():
            return null
        calc_result = inter_surface_edges_results[0].edge_calc_results[0]
    
    # Calculate instructions for the given landing trajectory.
    var land_position := calc_result.edge_calc_params.destination_position
    var instructions := EdgeInstructionsUtils \
            .convert_calculation_steps_to_movement_instructions( \
                    false, \
                    calc_result, \
                    false, \
                    land_position.surface.side)
    var trajectory := \
            EdgeTrajectoryUtils.calculate_trajectory_from_calculation_steps( \
                    false, \
                    calc_result, \
                    instructions)
    
    var velocity_end: Vector2 = \
            calc_result.horizontal_steps.back().velocity_step_end
    
    return AirToSurfaceEdge.new( \
            self, \
            origin, \
            land_position, \
            velocity_start, \
            velocity_end, \
            calc_result.edge_calc_params \
                    .needs_extra_wall_land_horizontal_speed, \
            collision_params.movement_params, \
            instructions, \
            trajectory)

class SurfaceMaxYComparator:
    static func sort(a: Surface, b: Surface) -> bool:
        return a.bounding_box.position.y < b.bounding_box.position.y
