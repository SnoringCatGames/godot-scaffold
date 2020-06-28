class_name ProfilerMetric

enum {
    # SurfaceParser metrics.
    PARSE_TILE_MAP_INTO_SIDES_DURATION,
    REMOVE_INTERNAL_SURFACES_DURATION,
    MERGE_CONTINUOUS_SURFACES_DURATION,
    REMOVE_INTERNAL_COLLINEAR_VERTICES_DURATION,
    STORE_SURFACES_DURATION,
    ASSIGN_NEIGHBOR_SURFACES_DURATION,
    CALCULATE_SHAPE_BOUNDING_BOXES_FOR_SURFACES_DURATION,
    ASSERT_SURFACES_FULLY_CALCULATED_DURATION,
    
    FIND_SURFACES_IN_JUMP_FALL_RANGE_FROM_SURFACE,
    EDGE_CALC_BROAD_PHASE_CHECK,
    CALCULATE_JUMP_LAND_POSITIONS_FOR_SURFACE_PAIR,
    NARROW_PHASE_EDGE_CALCULATION,
    CHECK_CONTINUOUS_HORIZONTAL_STEP_FOR_COLLISION,
    
    CALCULATE_JUMP_INTER_SURFACE_EDGE,
    FALL_FROM_FLOOR_WALK_TO_FALL_OFF_POINT_CALCULATION,
    FIND_SURFACES_IN_FALL_RANGE_FROM_POINT,
    FIND_LANDING_TRAJECTORY_BETWEEN_POSITIONS,
    CALCULATE_LAND_POSITIONS_ON_SURFACE,
    CREATE_EDGE_CALC_PARAMS,
    CALCULATE_VERTICAL_STEP,
    CALCULATE_JUMP_INTER_SURFACE_STEPS,
    CONVERT_CALCULATION_STEPS_TO_MOVEMENT_INSTRUCTIONS,
    CALCULATE_TRAJECTORY_FROM_CALCULATION_STEPS,
    CALCULATE_HORIZONTAL_STEP,
    CALCULATE_WAYPOINTS_AROUND_SURFACE,
    
    # Counts
    INVALID_COLLISION_STATE_IN_CALCULATE_STEPS_BETWEEN_WAYPOINTS,
    COLLISION_IN_CALCULATE_STEPS_BETWEEN_WAYPOINTS,
    CALCULATE_STEPS_BETWEEN_WAYPOINTS_WITHOUT_BACKTRACKING_ON_HEIGHT,
    CALCULATE_STEPS_BETWEEN_WAYPOINTS_WITH_BACKTRACKING_ON_HEIGHT,
    
    UNKNOWN,
}

const VALUES = [
    # SurfaceParser metrics.
    PARSE_TILE_MAP_INTO_SIDES_DURATION,
    REMOVE_INTERNAL_SURFACES_DURATION,
    MERGE_CONTINUOUS_SURFACES_DURATION,
    REMOVE_INTERNAL_COLLINEAR_VERTICES_DURATION,
    STORE_SURFACES_DURATION,
    ASSIGN_NEIGHBOR_SURFACES_DURATION,
    CALCULATE_SHAPE_BOUNDING_BOXES_FOR_SURFACES_DURATION,
    ASSERT_SURFACES_FULLY_CALCULATED_DURATION,
    
    FIND_SURFACES_IN_JUMP_FALL_RANGE_FROM_SURFACE,
    EDGE_CALC_BROAD_PHASE_CHECK,
    CALCULATE_JUMP_LAND_POSITIONS_FOR_SURFACE_PAIR,
    NARROW_PHASE_EDGE_CALCULATION,
    CHECK_CONTINUOUS_HORIZONTAL_STEP_FOR_COLLISION,
    
    CALCULATE_JUMP_INTER_SURFACE_EDGE,
    FALL_FROM_FLOOR_WALK_TO_FALL_OFF_POINT_CALCULATION,
    FIND_SURFACES_IN_FALL_RANGE_FROM_POINT,
    FIND_LANDING_TRAJECTORY_BETWEEN_POSITIONS,
    CALCULATE_LAND_POSITIONS_ON_SURFACE,
    CREATE_EDGE_CALC_PARAMS,
    CALCULATE_VERTICAL_STEP,
    CALCULATE_JUMP_INTER_SURFACE_STEPS,
    CONVERT_CALCULATION_STEPS_TO_MOVEMENT_INSTRUCTIONS,
    CALCULATE_TRAJECTORY_FROM_CALCULATION_STEPS,
    CALCULATE_HORIZONTAL_STEP,
    CALCULATE_WAYPOINTS_AROUND_SURFACE,
    
    # Counts
    INVALID_COLLISION_STATE_IN_CALCULATE_STEPS_BETWEEN_WAYPOINTS,
    COLLISION_IN_CALCULATE_STEPS_BETWEEN_WAYPOINTS,
    CALCULATE_STEPS_BETWEEN_WAYPOINTS_WITHOUT_BACKTRACKING_ON_HEIGHT,
    CALCULATE_STEPS_BETWEEN_WAYPOINTS_WITH_BACKTRACKING_ON_HEIGHT,
]
static func values() -> Array:
    return VALUES

const SURFACE_PARSER_VALUES = [
    PARSE_TILE_MAP_INTO_SIDES_DURATION,
    REMOVE_INTERNAL_SURFACES_DURATION,
    MERGE_CONTINUOUS_SURFACES_DURATION,
    REMOVE_INTERNAL_COLLINEAR_VERTICES_DURATION,
    STORE_SURFACES_DURATION,
    ASSIGN_NEIGHBOR_SURFACES_DURATION,
    CALCULATE_SHAPE_BOUNDING_BOXES_FOR_SURFACES_DURATION,
    ASSERT_SURFACES_FULLY_CALCULATED_DURATION,
]
static func surface_parser_values() -> Array:
    return SURFACE_PARSER_VALUES

static func get_type_string(result_type: int) -> String:
    match result_type:
        # SurfaceParser metrics.
        PARSE_TILE_MAP_INTO_SIDES_DURATION:
            return "PARSE_TILE_MAP_INTO_SIDES_DURATION"
        REMOVE_INTERNAL_SURFACES_DURATION:
            return "REMOVE_INTERNAL_SURFACES_DURATION"
        MERGE_CONTINUOUS_SURFACES_DURATION:
            return "MERGE_CONTINUOUS_SURFACES_DURATION"
        REMOVE_INTERNAL_COLLINEAR_VERTICES_DURATION:
            return "REMOVE_INTERNAL_COLLINEAR_VERTICES_DURATION"
        STORE_SURFACES_DURATION:
            return "STORE_SURFACES_DURATION"
        ASSIGN_NEIGHBOR_SURFACES_DURATION:
            return "ASSIGN_NEIGHBOR_SURFACES_DURATION"
        CALCULATE_SHAPE_BOUNDING_BOXES_FOR_SURFACES_DURATION:
            return "CALCULATE_SHAPE_BOUNDING_BOXES_FOR_SURFACES_DURATION"
        ASSERT_SURFACES_FULLY_CALCULATED_DURATION:
            return "ASSERT_SURFACES_FULLY_CALCULATED_DURATION"
            
        FIND_SURFACES_IN_JUMP_FALL_RANGE_FROM_SURFACE:
            return "FIND_SURFACES_IN_JUMP_FALL_RANGE_FROM_SURFACE"
        EDGE_CALC_BROAD_PHASE_CHECK:
            return "EDGE_CALC_BROAD_PHASE_CHECK"
        CALCULATE_JUMP_LAND_POSITIONS_FOR_SURFACE_PAIR:
            return "CALCULATE_JUMP_LAND_POSITIONS_FOR_SURFACE_PAIR"
        NARROW_PHASE_EDGE_CALCULATION:
            return "NARROW_PHASE_EDGE_CALCULATION"
        CHECK_CONTINUOUS_HORIZONTAL_STEP_FOR_COLLISION:
            return "CHECK_CONTINUOUS_HORIZONTAL_STEP_FOR_COLLISION"
            
        CALCULATE_JUMP_INTER_SURFACE_EDGE:
            return "CALCULATE_JUMP_INTER_SURFACE_EDGE"
        FALL_FROM_FLOOR_WALK_TO_FALL_OFF_POINT_CALCULATION:
            return "FALL_FROM_FLOOR_WALK_TO_FALL_OFF_POINT_CALCULATION"
        FIND_SURFACES_IN_FALL_RANGE_FROM_POINT:
            return "FIND_SURFACES_IN_FALL_RANGE_FROM_POINT"
        FIND_LANDING_TRAJECTORY_BETWEEN_POSITIONS:
            return "FIND_LANDING_TRAJECTORY_BETWEEN_POSITIONS"
        CALCULATE_LAND_POSITIONS_ON_SURFACE:
            return "CALCULATE_LAND_POSITIONS_ON_SURFACE"
        CREATE_EDGE_CALC_PARAMS:
            return "CREATE_EDGE_CALC_PARAMS"
        CALCULATE_VERTICAL_STEP:
            return "CALCULATE_VERTICAL_STEP"
        CALCULATE_JUMP_INTER_SURFACE_STEPS:
            return "CALCULATE_JUMP_INTER_SURFACE_STEPS"
        CONVERT_CALCULATION_STEPS_TO_MOVEMENT_INSTRUCTIONS:
            return "CONVERT_CALCULATION_STEPS_TO_MOVEMENT_INSTRUCTIONS"
        CALCULATE_TRAJECTORY_FROM_CALCULATION_STEPS:
            return "CALCULATE_TRAJECTORY_FROM_CALCULATION_STEPS"
        CALCULATE_HORIZONTAL_STEP:
            return "CALCULATE_HORIZONTAL_STEP"
        CALCULATE_WAYPOINTS_AROUND_SURFACE:
            return "CALCULATE_WAYPOINTS_AROUND_SURFACE"
        
        # Counts
        INVALID_COLLISION_STATE_IN_CALCULATE_STEPS_BETWEEN_WAYPOINTS:
            return "INVALID_COLLISION_STATE_IN_CALCULATE_STEPS_BETWEEN_WAYPOINTS"
        COLLISION_IN_CALCULATE_STEPS_BETWEEN_WAYPOINTS:
            return "COLLISION_IN_CALCULATE_STEPS_BETWEEN_WAYPOINTS"
        CALCULATE_STEPS_BETWEEN_WAYPOINTS_WITHOUT_BACKTRACKING_ON_HEIGHT:
            return "CALCULATE_STEPS_BETWEEN_WAYPOINTS_WITHOUT_BACKTRACKING_ON_HEIGHT"
        CALCULATE_STEPS_BETWEEN_WAYPOINTS_WITH_BACKTRACKING_ON_HEIGHT:
            return "CALCULATE_STEPS_BETWEEN_WAYPOINTS_WITH_BACKTRACKING_ON_HEIGHT"
            
        UNKNOWN:
            return "UNKNOWN"
            
        _:
            Utils.error("Invalid ProfilerMetric: %s" % result_type)
            return "UNKNOWN"
