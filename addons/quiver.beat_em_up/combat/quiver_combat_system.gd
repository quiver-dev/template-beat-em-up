class_name QuiverCombatSystem
extends RefCounted

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

enum CharacterTypes {
	PLAYERS,
	ENEMIES,
}

enum HurtTypes {
	MID,
	HIGH
}

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

static func apply_damage(attack: QuiverAttackData, target: QuiverAttributes) -> void:
	if target.is_invulnerable:
		return
	
	target.add_knockback(attack.knockback)
	if target.should_knockout():
		target.knockout_requested.emit()
	elif not target.has_superarmor:
		target.hurt_requested.emit(attack.hurt_type)
	
	target.health_current -= attack.attack_damage

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------

