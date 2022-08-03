@tool
extends _BASE_

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const GroundState = preload(
		"res://addons/quiver.beat_em_up/characters/action_states/quiver_action_ground.gd"
)

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

@onready var _ground_state := get_parent() as GroundState

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()
	update_configuration_warnings()
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	
	if not get_parent() is GroundState:
		warnings.append(
				"This ActionState must be a child of Action GroundState or a state " 
				+ "inheriting from it."
		)
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	_ground_state.enter(msg)


func unhandled_input(event: InputEvent) -> void:
	var has_handled := false
	
	if not has_handled:
		_ground_state.unhandled_input(event)


func process(delta: float) -> void:
	_ground_state.process(delta)


func physics_process(delta: float) -> void:
	_ground_state.physics_process(delta)


func exit() -> void:
	super()
	_ground_state.exit()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------