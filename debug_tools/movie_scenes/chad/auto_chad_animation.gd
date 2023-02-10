@tool
extends "res://characters/playable/chad/chad.gd"

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

@onready var _hurt_state := $StateMachine/Ground/Hurt as QuiverState

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_quiver_sequence_state_state_finished() -> void:
	await get_tree().create_timer(0.3).timeout
	var attack := QuiverAttackData.new()
	attack.attack_damage = attributes.health_max * 0.1
	attack.knockback = CombatSystem.KnockbackStrength.WEAK
	
	CombatSystem.apply_damage(attack, attributes)
	var knockback: QuiverKnockbackData = QuiverKnockbackData.new(
			attack.knockback,
			attack.hurt_type,
			attack.launch_vector
	)
	CombatSystem.apply_knockback(knockback, attributes)
	
	await _hurt_state.state_finished
	var attack2 := QuiverAttackData.new()
	attack2.attack_damage = attributes.health_max * 0.1
	attack2.knockback = CombatSystem.KnockbackStrength.WEAK
	attack2.hurt_type = CombatSystem.HurtTypes.MID
	
	CombatSystem.apply_damage(attack2, attributes)
	var knockback2: QuiverKnockbackData = QuiverKnockbackData.new(
			attack2.knockback,
			attack2.hurt_type,
			attack2.launch_vector
	)
	CombatSystem.apply_knockback(knockback2, attributes)
	
	await _hurt_state.state_finished
	var attack3 := QuiverAttackData.new()
	attack3.attack_damage = attributes.health_max
	attack3.knockback = CombatSystem.KnockbackStrength.STRONG
	attack3.hurt_type = CombatSystem.HurtTypes.HIGH
	attack3.launch_angle = 45
	
	CombatSystem.apply_damage(attack3, attributes)
	var knockback3: QuiverKnockbackData = QuiverKnockbackData.new(
			attack3.knockback,
			attack3.hurt_type,
			attack3.launch_vector.reflect(Vector2.UP)
	)
	CombatSystem.apply_knockback(knockback3, attributes)
	
	await get_tree().create_timer(0.01).timeout
	Engine.time_scale = 1

### -----------------------------------------------------------------------------------------------
