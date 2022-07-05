extends EditorInspectorPlugin

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const ExternalEnumProperty = preload(
		"res://addons/quiver.beat_em_up/custom_inspectors/external_enum/external_enum_property.gd"
)

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _can_handle(object) -> bool:
	return object is Node or object is Resource


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
	
	if (
			QuiverBitwiseHelper.has_flag_on(PROPERTY_USAGE_EDITOR, usage_flags)
			# I can't use the condition below now because advanced exports are broken
#			and hint_type == PROPERTY_HINT_ENUM 
	):
		# DELETE-ME The line below is hack-fix while advanced exports aren't working
		hint_string = _get_real_hint_string_hack(object, name, hint_string)
		
		if hint_string.begins_with("ExternalEnum"):
			var options_dict = str2var(hint_string.replace("ExternalEnum", ""))
			if options_dict != null and options_dict is Dictionary:
				var property := ExternalEnumProperty.new()
				property.external_property = (
						object.get(options_dict.property).get(options_dict.property_name)
				)
				add_property_editor(name, property)
				replace_built_in = true
	
	return replace_built_in

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

# DELETE-ME Remove this once advanced exports are working
func _get_real_hint_string_hack(object: Object, name: String, hint_string: String) -> String:
	var value := hint_string
	var custom_properties = object.get("CUSTOM_PROPERTIES")
	
	if custom_properties is Dictionary and not custom_properties.is_empty():
		var treated_name = name.substr(1) if name.begins_with("_") else name
		if (
				custom_properties.has(treated_name) 
				and custom_properties[treated_name].has("hint_string")
		):
			value = object.CUSTOM_PROPERTIES[treated_name].hint_string
	
	return value

### -----------------------------------------------------------------------------------------------

