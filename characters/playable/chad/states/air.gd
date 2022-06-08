extends "res://characters/playable/chad/states/chad_state.gd"

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	_character._disable_collisions()


func physics_process(delta: float) -> void:
	_character.move_and_slide()
	_character.velocity.y += _gravity * delta
	if _character.global_position.y >= _character.ground_level:
		_character.global_position.y = _character.ground_level
		if _character.velocity.x != 0:
			var conserved_velocity = Vector2(_character.velocity.x, 0)
			_state_machine.transition_to("Ground/Move/Walk", {velocity = conserved_velocity})
		else:
			_state_machine.transition_to("Ground/Move/Idle")


func exit() -> void:
	_character._enable_collisions()
	super()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------

