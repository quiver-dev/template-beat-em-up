class_name QuiverKnockback
extends RefCounted

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

var strength: QuiverCyclicHelper.KnockbackStrength = QuiverCyclicHelper.KnockbackStrength.NONE
var hurt_type: QuiverCyclicHelper.HurtTypes = QuiverCyclicHelper.HurtTypes.HIGH
var launch_vector := Vector2.ZERO

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _init(
		p_knockback: QuiverCyclicHelper.KnockbackStrength, 
		p_hurt: QuiverCyclicHelper.HurtTypes, 
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

