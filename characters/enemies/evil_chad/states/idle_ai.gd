extends QuiverCharacterState

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const MoveState = preload("res://characters/playable/chad/states/move.gd")

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

@onready var _move_state := get_parent() as MoveState

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	_move_state.enter(msg)
	_skin.transition_to(_skin.SkinStates.IDLE)


func process(delta: float) -> void:
	var player := QuiverCharacterHelper.find_closest_player_to(_character)
	if is_instance_valid(player):
		var facing_direction = sign((player.global_position - _character.global_position).x)
		_skin.scale.x = 1 if facing_direction >=0 else -1
	
	_move_state.process(delta)


func physics_process(delta: float) -> void:
	_move_state.physics_process(delta)


func exit() -> void:
	_move_state.exit()
	super()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------

