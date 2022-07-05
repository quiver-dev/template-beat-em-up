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
	target.health_current -= attack.attack_damage


static func apply_knockback(
		knockback: QuiverKnockback, 
		target: QuiverAttributes
) -> void:
	if target.is_invulnerable:
		return
	
	target.add_knockback(knockback.strength)
	if target.should_knockout():
		if not target.is_alive:
			target.add_knockback(QuiverCyclicHelper.KnockbackStrength.MEDIUM)
		target.knockout_requested.emit(knockback)
	elif not target.has_superarmor:
		target.hurt_requested.emit(knockback)
	

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------

