@tool
class_name QuiverAttackData
extends Resource

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export_range(0, 1, 1, "or_greater") var attack_damage = 1:
	set(value):
		attack_damage = value
		emit_changed()

@export var hurt_type: CombatSystem.HurtTypes = CombatSystem.HurtTypes.HIGH:
	set(value):
		hurt_type = value
		emit_changed()

@export var knockback: CombatSystem.KnockbackStrength = CombatSystem.KnockbackStrength.NONE:
	set(value):
		knockback = value
		emit_changed()

@export_range(0, 360, 1) var launch_angle := 0:
	set(value):
		launch_angle = value
		var raw_direction := QuiverMathHelper.get_direction_by_angle(deg_to_rad(launch_angle))
		launch_vector = raw_direction.reflect(Vector2.RIGHT)
		emit_changed()

var launch_vector := Vector2.RIGHT

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------

