class_name QuiverAttackData
extends Resource

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export_range(0, 1, 1, "or_greater") var attack_damage = 1
@export var hurt_type: QuiverCyclicHelper.HurtTypes = QuiverCyclicHelper.HurtTypes.HIGH
@export var knockback: QuiverCyclicHelper.KnockbackStrength = \
	QuiverCyclicHelper.KnockbackStrength.NONE
@export_range(0, 360, 1) var launch_angle := 0:
	set(value):
		launch_angle = value
		var raw_direction := QuiverMathHelper.get_direction_by_angle(deg2rad(launch_angle))
		launch_vector = raw_direction.reflect(Vector2.RIGHT)

var launch_vector := Vector2.RIGHT

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------

