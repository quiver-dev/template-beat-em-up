extends EditorInspectorPlugin

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const QuiverPropertyStateDropDown = preload(
		"res://addons/quiver.beat_em_up/custom_inspectors/states_dropdown/"
		+"state_dropdown_property.gd"
)

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _can_handle(object) -> bool:
	return object is QuiverState


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
	var state := object as QuiverState
	if not is_instance_valid(state):
		return replace_built_in
	
	if QuiverBitwiseHelper.has_flag_on(PROPERTY_USAGE_EDITOR, usage_flags):
		if hint_string == QuiverState.HINT_STATE_LIST:
			var property := QuiverPropertyStateDropDown.new()
			replace_built_in = true
			add_property_editor(name, property)
	
	return replace_built_in

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
