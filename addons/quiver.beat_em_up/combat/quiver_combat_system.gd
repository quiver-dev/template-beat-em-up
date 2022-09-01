class_name QuiverCombatSystem
extends RefCounted

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

enum CharacterTypes {
	PLAYERS,
	ENEMIES,
	BOUNCE_OBSTACLE,
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

static func is_in_same_lane_as(defender: QuiverAttributes, attacker: QuiverAttributes) -> bool:
	var lane_limits := defender.get_hit_lane_limits()
	var value := lane_limits.is_value_inside_lane(attacker.ground_level)
	return value


static func apply_damage(attack: QuiverAttackData, target: QuiverAttributes) -> void:
	if target.is_invulnerable:
		return
	target.health_current -= attack.attack_damage
	HitFreeze.start()


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

