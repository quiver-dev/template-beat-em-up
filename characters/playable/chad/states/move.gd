extends "res://characters/playable/chad/states/chad_state.gd"

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

@export var MAX_SPEED = 600

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _direction := Vector2.ZERO

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	get_parent().enter(msg)
	if msg.has("velocity"):
		_character.velocity = msg.velocity
		_direction = Vector2(msg.velocity.x, 0).normalized()


func unhandled_input(event: InputEvent) -> void:
	var has_handled := false
	
	if event.is_action_pressed("attack"):
		_state_machine.transition_to("Ground/Attack/Combo1")
	
	if event.is_action_pressed("jump") and _direction.is_equal_approx(Vector2.ZERO):
		_state_machine.transition_to("Air/Jump")
	elif event.is_action_pressed("jump") and not _direction.is_equal_approx(Vector2.ZERO):
		_state_machine.transition_to("Air/Jump", {velocity = _character.velocity})
	
	if not has_handled:
		get_parent().unhandled_input(event)


func physics_process(delta: float) -> void:
	get_parent().physics_process(delta)
	
	if not _direction.is_equal_approx(Vector2.ZERO):
		_character.velocity = MAX_SPEED * _direction
	else:
		_character.velocity = _character.velocity.move_toward(Vector2.ZERO, MAX_SPEED)
	
	_character.move_and_slide()


func exit() -> void:
	_direction = Vector2.ZERO
	_character.velocity = Vector2.ZERO
	
	super()
	get_parent().exit()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------

