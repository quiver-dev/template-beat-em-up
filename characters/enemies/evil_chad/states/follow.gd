extends "res://characters/playable/chad/states/chad_state.gd"

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const MoveState = preload("res://characters/playable/chad/states/move.gd")

@export var OFFSET_FROM_TARGET = 230
@export var ARRIVE_RANGE = 10


#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _target_node: Node2D = null

@onready var _move_state := get_parent() as MoveState
@onready var _squared_arrive = pow(ARRIVE_RANGE, 2)

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	_move_state.enter(msg)
	_skin.transition_to(_skin.SkinStates.WALK)
	
	if not msg.has("target_node") or not msg.target_node is Node2D:
		_state_machine.transition_to("Ground/Move/Idle")
		return
	
	_target_node = msg.target_node


func unhandled_input(_event: InputEvent) -> void:
	pass


func physics_process(delta: float) -> void:
	var facing_direction = sign((_target_node.global_position - _character.global_position).x)
	_skin.scale.x = 1 if facing_direction >=0 else -1
	
	var target_position := _target_node.global_position
	if _character.global_position.x >= target_position.x:
		target_position += Vector2.RIGHT * OFFSET_FROM_TARGET
	else:
		target_position += Vector2.LEFT * OFFSET_FROM_TARGET
	
	_move_state._direction = _character.global_position.direction_to(target_position)
	var distance_to_target := _character.global_position.distance_squared_to(target_position)
	
	if distance_to_target <= _squared_arrive:
		_state_machine.transition_to("Ground/Move/Idle")
		state_finished.emit()
		return
	
	_move_state.physics_process(delta)


func exit() -> void:
	super()
	_move_state.exit()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------

