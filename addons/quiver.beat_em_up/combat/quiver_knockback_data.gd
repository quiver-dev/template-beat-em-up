class_name QuiverKnockbackData
extends RefCounted

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export var strength: CombatSystem.KnockbackStrength = CombatSystem.KnockbackStrength.NONE
var hurt_type: CombatSystem.HurtTypes = CombatSystem.HurtTypes.HIGH
var launch_vector := Vector2.ZERO

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _init(
		p_knockback: CombatSystem.KnockbackStrength, 
		p_hurt: CombatSystem.HurtTypes, 
		p_vector: Vector2
) -> void:
	strength = p_knockback
	hurt_type = p_hurt
	launch_vector = p_vector

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------

