extends "res://characters/playable/chad/states/chad_state.gd"

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

@export var JUMP_FORCE := -1200

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	get_parent().enter(msg)
	
	if msg.has("velocity"):
		_character.velocity = msg.velocity
	
	_state_machine.set_physics_process(false)
	_skin.transition_to(_skin.SkinStates.JUMP)
	_character._disable_collisions()
	await get_tree().process_frame
	_character.velocity.y = JUMP_FORCE
	await get_tree().process_frame
	_state_machine.set_physics_process(true)


func unhandled_input(_event: InputEvent) -> void:
	return


func physics_process(delta: float) -> void:
	_character.move_and_slide()
	_character.velocity.y += _gravity * delta
	if _character.global_position.y >= _character.ground_level:
		if _character.velocity.x != 0:
			var conserved_velocity = Vector2(_character.velocity.x, 0)
			_state_machine.transition_to("Ground/Move/Walk", {velocity = conserved_velocity})
		else:
			_state_machine.transition_to("Ground/Move/Idle")


func exit() -> void:
	_character.global_position.y = _character.ground_level
	_character._enable_collisions()
	get_parent().exit()
	super()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------

