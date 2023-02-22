extends Node

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

enum KnockbackStrength { 
	NONE, 
	WEAK, 
	MEDIUM, 
	STRONG, 
	MASSIVE 
}

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func is_in_same_lane_as(defender: QuiverAttributes, attacker: QuiverAttributes) -> bool:
	var lane_limits := defender.get_hit_lane_limits()
	var value := lane_limits.is_value_inside_lane(attacker.ground_level)
	return value


func apply_damage(attack: QuiverAttackData, target: QuiverAttributes) -> void:
	if target.is_invulnerable:
		return
	target.health_current -= attack.attack_damage
	HitFreeze.start()


func apply_knockback(
		knockback: QuiverKnockbackData, 
		target: QuiverAttributes
) -> void:
	if target.is_invulnerable:
		return
	
	target.add_knockback(knockback.strength)
	if target.should_knockout():
		if not target.is_alive():
			target.add_death_knockback()
		target.knockout_requested.emit(knockback)
	elif not target.has_superarmor:
		target.hurt_requested.emit(knockback)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------

