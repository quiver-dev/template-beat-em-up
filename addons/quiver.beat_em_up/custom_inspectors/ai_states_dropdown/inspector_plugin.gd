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
		object: Object, 
		_type: int, 
		name: String, 
		hint_type: int, 
		hint_string: String, 
		usage_flags: int, 
		_wide: bool
) -> bool:
	var replace_built_in := false
	
	if QuiverBitwiseHelper.has_flag_on(PROPERTY_USAGE_EDITOR, usage_flags):
		# DELETE-ME The line below is hack-fix while advanced exports aren't working
		hint_string = _get_real_hint_string_hack(object, name, hint_string)
		
		if hint_string == QuiverState.HINT_AI_STATE_LIST:
			var property := QuiverPropertyAiStateDropDown.new()
			replace_built_in = true
			add_property_editor(name, property)
	
	return replace_built_in

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

# DELETE-ME Remove this once advanced exports are working
func _get_real_hint_string_hack(state, name: String, hint_string: String) -> String:
	var value := hint_string
	var custom_properties = state.get("CUSTOM_PROPERTIES")
	
	if custom_properties is Dictionary and not custom_properties.is_empty():
		var treated_name = name.substr(1) if name.begins_with("_") else name
		if (
				custom_properties.has(treated_name) 
				and custom_properties[treated_name].has("hint_string")
		):
			value = state.CUSTOM_PROPERTIES[treated_name].hint_string
	
	return value

### -----------------------------------------------------------------------------------------------

