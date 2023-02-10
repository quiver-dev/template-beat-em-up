@tool
extends QuiverAiStateMachine

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

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _decide_next_behavior(last_state: StringName) -> void:
	match last_state:
		&"Chase":
			transition_to(^"Attack")
		&"GoToPosition":
			transition_to(^"Wait")
		&"Attack":
			transition_to(^"Wait")
		&"Wait":
			transition_to(^"Chase")
		&"WaitTillIdle":
			transition_to(_state_to_resume)

### -----------------------------------------------------------------------------------------------
