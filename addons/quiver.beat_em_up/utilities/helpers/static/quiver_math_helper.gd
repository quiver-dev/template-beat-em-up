class_name QuiverMathHelper
extends RefCounted

## Static Helper for common Math situations/problems/techniques useful in games.

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

## Gets a position vector based on an angle and radius with a center offset.
static func get_position_by_polar_coordinates(
		center_position: Vector2, angle_rad: float, radius: float
) -> Vector2:
	var polar_coordinate := get_direction_by_angle(angle_rad) * radius
	var value = center_position + polar_coordinate
	return value


## Gets a normalized direction vector based on an angle in radians
static func get_direction_by_angle(angle_rad: float) -> Vector2:
	return Vector2(
		cos(angle_rad),
		sin(angle_rad)
	).normalized()


## Helper method to be used in [method Array.reduce] and facilitate summing Array members
static func sum_array(accum: float, number: float) -> float:
	return accum + number


## Helper method to be used in [method Array.reduce] and facilitate summing Array members 
## returning an int
static func sum_arrayi(accum: int, number: int) -> int:
	return accum + number


static func draw_random_weighted_index(weights_pool: Array) -> int:
	const INVALID_MSG = "weights pool is invalid, it contains elements that are "\
			+ "neither a float nor an int"
	var is_valid_pool := weights_pool.all(func(number): return number is float or number is int)
	var value := -1
	assert(is_valid_pool, INVALID_MSG)
	
	if is_valid_pool:
		if weights_pool.size() == 1:
			value = 0
		else:
			var callable = Callable(QuiverMathHelper, "sum_array")
			var weights_sum = weights_pool.reduce(callable)
			var random_value := randf_range(0, weights_sum)
			for index in weights_pool.size():
				var current_weight := weights_pool[index] as float
				if random_value < current_weight:
					value = index
					break
				else:
					random_value -= current_weight
	
	return value

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------

