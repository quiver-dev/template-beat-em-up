@tool
extends QuiverStateMachine

## Write your doc string for this file here

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
		var state := child as QuiverState
		if not is_instance_valid(state):
			continue
		
		state.state_finished.connect(_decide_next_action.bind(state.name))

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _decide_next_action(last_state: StringName) -> void:
	match last_state:
		&"ChaseClosestPlayer":
			transition_to("Wait")
		&"Wait":
			transition_to("ChaseClosestPlayer")

### -----------------------------------------------------------------------------------------------

