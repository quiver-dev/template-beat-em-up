@tool
class_name SpawnData
extends Resource

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

enum SpawnMode {
	WALK_TO_POSITION,
	IN_PLACE,
}

#--- constants ------------------------------------------------------------------------------------

const NODEPATH_INVALID = ^"invalid"

#--- public variables - order: export > normal var > onready --------------------------------------

var enemy_scene: PackedScene = null

var spawn_mode := SpawnMode.WALK_TO_POSITION:
	set(value):
		spawn_mode = value
		notify_property_list_changed()

var use_vector2 := false:
	set(value):
		use_vector2 = value
		notify_property_list_changed()

var target_node_path := NODEPATH_INVALID
var target_position := Vector2.ZERO

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

func _get_custom_properties() -> Dictionary:
	var dict := {
		"_enemy_scene": {
			backing_field = "enemy_scene",
			type = TYPE_OBJECT,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_RESOURCE_TYPE,
			hint_string = "PackedScene",
		},
		"_spawn_mode": {
			backing_field = "spawn_mode",
			type = TYPE_INT,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_ENUM,
			hint_string = ",".join(SpawnMode.keys()),
		},
		"_use_vector2": {
			backing_field = "use_vector2",
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		},
		"_target_node_path": {
			backing_field = "target_node_path",
			type = TYPE_NODE_PATH,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_NODE_PATH_VALID_TYPES,
			hint_string = "Marker2D",
		},
		"_target_position": {
			backing_field = "target_position",
			type = TYPE_VECTOR2,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		},
#		"": {
#			backing_field = "",
#			name = "",
#			type = TYPE_NIL,
#			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
#			hint = PROPERTY_HINT_NONE,
#			hint_string = "",
#		},
	}
	
	return dict

### Custom Inspector built in functions -----------------------------------------------------------

func _get_property_list() -> Array:
	var properties: = []
	
	var custom_properties := _get_custom_properties()
	for key in custom_properties:
		var add_property := true
		var dict: Dictionary = custom_properties[key]
		if not dict.has("name"):
			dict.name = key
		
		if spawn_mode == SpawnMode.IN_PLACE:
			if key in ["_use_vector2", "_target_node_path", "_target_position"]:
				add_property = false
		elif spawn_mode == SpawnMode.WALK_TO_POSITION:
			if use_vector2 and key == "_target_node_path":
				add_property = false
			elif not use_vector2 and key == "_target_position":
				add_property = false
		
		if add_property:
			properties.append(dict)
	
	return properties


func _get(property: StringName):
	var value
	
	var custom_properties := _get_custom_properties()
	if property in custom_properties and custom_properties[property].has("backing_field"):
		value = get(custom_properties[property]["backing_field"])
	
	return value


func _set(property: StringName, value) -> bool:
	var has_handled: = false
	
	var custom_properties := _get_custom_properties()
	if property in custom_properties and custom_properties[property].has("backing_field"):
		set(custom_properties[property]["backing_field"], value)
		has_handled = true
	
	return has_handled

### -----------------------------------------------------------------------------------------------
