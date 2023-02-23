extends EditorInspectorPlugin

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const QuiverPropertyAiStateDropDown = preload(
		"res://addons/quiver.beat_em_up/custom_inspectors/ai_states_dropdown/"
		+"ai_state_dropdown_property.gd"
)

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _can_handle(object) -> bool:
	return (
			object is QuiverAiState 
			or (object is QuiverStateSequence and object._state_machine is QuiverAiStateMachine)
			or object is QuiverAiStateMachine
	)


func _parse_property(
		_object: Object, 
		_type: Variant.Type, 
		name: String, 
		_hint_type: PropertyHint, 
		hint_string: String, 
		usage_flags: PropertyUsageFlags, 
		_wide: bool
) -> bool:
	var replace_built_in := false
	
	if (
			QuiverBitwiseHelper.has_flag_on(PROPERTY_USAGE_EDITOR, usage_flags)
			and hint_string == QuiverState.HINT_AI_STATE_LIST
	):
		var property := QuiverPropertyAiStateDropDown.new()
		replace_built_in = true
		add_property_editor(name, property)
	
	return replace_built_in

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
