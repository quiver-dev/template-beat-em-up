extends EditorInspectorPlugin

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const CreateNewActionWidget = preload(
		"res://addons/quiver.beat_em_up/custom_inspectors/create_new_action/"
		+"create_new_action_widget.gd"
)
const SCENE_WIDGET = preload(
		"res://addons/quiver.beat_em_up/custom_inspectors/create_new_action/"
		+"create_new_action_widget.tscn"
)

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _can_handle(object) -> bool:
	var value = false
	var is_valid_state_machine: bool = (
			object is QuiverStateMachine
			and not object is QuiverAiStateMachine
	)
	var is_valid_state: bool = (
			object is QuiverState and 
			not object is QuiverAiState
			and not (
				object is QuiverStateSequence 
				and object._state_machine is QuiverAiStateMachine
			)
	)
	
	if (is_valid_state_machine or is_valid_state):
		var is_owner_character: bool = (
				"owner" in object 
				and object.owner != null 
				and object.owner is QuiverCharacter
		)
		value = is_owner_character
	
	return value


func _parse_begin(object: Object) -> void:
	var widget: = SCENE_WIDGET.instantiate() as CreateNewActionWidget
	widget.selected_node = object
	# TODO - pass the editor undo_redo to the widget and add node using it
	add_custom_control(widget)

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------

