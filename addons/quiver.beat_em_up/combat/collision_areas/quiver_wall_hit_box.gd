@tool
class_name WallHitBox
extends QuiverHitBox

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()
	attack_data.changed.connect(update_configuration_warnings)


func _get_configuration_warnings() -> PackedStringArray:
	const ERROR_KNOCKBACK = "WallHitBox have their own rules for knockback, and attack data's" \
			+ " knockback properties will be ignored"
	
	var warnings := PackedStringArray()
	
	if (
			attack_data.knockback != CombatSystem.KnockbackStrength.NONE
			or attack_data.launch_angle != 0
	):
		warnings.append(ERROR_KNOCKBACK)
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
