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

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------

