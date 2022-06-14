extends "res://characters/enemies/evil_chad/ai_states/base_ai_state.gd"

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _target: QuiverCharacter

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	_target = QuiverCharacterHelper.find_closest_player_to(_character)
	if is_instance_valid(_target):
		_actions.transition_to("Ground/Move/Follow", {target_node = _target})
		_actions.transitioned.connect(_on_actions_transitioned)


func exit() -> void:
	super()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _target_reached() -> void:
	state_finished.emit()


func _on_actions_transitioned(_path_state: String) -> void:
	_actions.transitioned.disconnect(_on_actions_transitioned)
	_target_reached()

### -----------------------------------------------------------------------------------------------

