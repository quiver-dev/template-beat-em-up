@tool
extends _BASE_

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const KnockoutState = preload(
		"res://addons/quiver.beat_em_up/characters/action_states/air_actions/"
		+ "quiver_action_knockout.gd"
)

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

@onready var _knockout_state := get_parent() as KnockoutState

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
	
	if not get_parent() is KnockoutState:
		warnings.append(
				"This ActionState must be a child of Action KnockoutState or a state " 
				+ "inheriting from it."
		)
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	_knockout_state.enter(msg)


func unhandled_input(event: InputEvent) -> void:
	var has_handled := false
	
	if not has_handled:
		_knockout_state.unhandled_input(event)


func process(delta: float) -> void:
	_knockout_state.process(delta)


func physics_process(delta: float) -> void:
	_knockout_state.physics_process(delta)


func exit() -> void:
	super()
	_knockout_state.exit()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
