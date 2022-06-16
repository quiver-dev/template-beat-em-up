@tool
class_name QuiverAiStateMachine
extends QuiverStateMachine

## State Machine for AIs
##
## It will automatically connect all direct child states [signal QuiverState.state_finished] 
## signal to the [method _decide_next_action] virtual method. Then the user can extend this class 
## and override that method with the required logic.
## [br][br]
## The Ai State Machine should only take [QuiverAiState] and [QuiverStateSequence] as children.


### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return
	
	for child in get_children():
		var child_state := child as QuiverState
		if not is_instance_valid(child_state):
			continue
		
		child_state.state_finished.connect(_decide_next_action.bind(child_state.name))


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	
	for child in get_children():
		if not child is QuiverAiState and not child is QuiverStateSequence:
			warnings.append("%s is not a QuiverAiState or QuiverSequenceState"%[child.name])
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

## Virtual method that is executed whenever a state emits the [signal QuiverState.state_finished] signal
func _decide_next_action(_last_state: StringName) -> void:
	push_warning("This is a virtual function and should not be used directly, but overriden.")

### -----------------------------------------------------------------------------------------------

