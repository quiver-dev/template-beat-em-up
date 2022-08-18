extends EditorInspectorPlugin

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const PropertyStateDropDown = preload(
		"res://addons/quiver.beat_em_up/custom_inspectors/states_dropdown/"
		+"state_dropdown_property.gd"
)

const PropertyAttackStateDropDown = preload(
		"res://addons/quiver.beat_em_up/custom_inspectors/states_dropdown/"
		+"attack_state_dropdown_property.gd"
)

const PropertyNotAttackStateDropDown = preload(
		"res://addons/quiver.beat_em_up/custom_inspectors/states_dropdown/"
		+"not_attack_state_dropdown_property.gd"
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
		var editor_property: EditorProperty = null
		match hint_string:
			QuiverState.HINT_STATE_LIST:
				editor_property = PropertyStateDropDown.new()
			QuiverState.HINT_ATTACK_STATE_LIST:
				editor_property = PropertyAttackStateDropDown.new()
			QuiverState.HINT_NOT_ATTACK_STATE_LIST:
				editor_property = PropertyNotAttackStateDropDown.new()
		
		if editor_property != null:
			replace_built_in = true
			add_property_editor(name, editor_property)
	
	return replace_built_in

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
