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

static func get_position_by_polar_coordinates(
		center_position: Vector2, angle: float, radius: float
) -> Vector2:
	var polar_coordinate = Vector2(
		cos(angle) * radius,
		sin(angle) * radius
	)
	var value = center_position + polar_coordinate
	return value

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
