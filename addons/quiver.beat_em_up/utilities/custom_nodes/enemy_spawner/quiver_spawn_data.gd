@tool
class_name QuiverSpawnData
extends Resource

## Resource that holds information on which enemy scene should be spawned, and how.

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

enum SpawnMode {
	WALK_TO_POSITION, 	## Should spawn enemy at spawner position and make it walk to the target position.
	IN_PLACE, ## Spawns enemy directly at the target position.
}

#--- constants ------------------------------------------------------------------------------------

## Value used to check for invalid or unset nodepaths.
const NODEPATH_INVALID = ^"invalid"

#--- public variables - order: export > normal var > onready --------------------------------------

## PackedScene that will be used to instantiate enemy.
var enemy_scene: PackedScene = null

## Defines what spawn mode will be used.
var spawn_mode := SpawnMode.WALK_TO_POSITION:
	set(value):
		spawn_mode = value
		notify_property_list_changed()

## Flag to toggle between using a target node as reference for position, or an absolute position 
## set manually in the inspector.
var use_vector2 := false:
	set(value):
		use_vector2 = value
		notify_property_list_changed()

## Flag used only in [code]SpawnMode.IN_PLACE[/code] to spawn the enemy in the same position 
## as the spawner
var use_spawner_position := true:
	set(value):
		use_spawner_position = value
		notify_property_list_changed()

## Property to hold the target [NodePath]. Will only be used if [member use_vector2] is disabled.
var target_node_path := NODEPATH_INVALID

## Property to hold the target global position. Will only be used if [member use_vector2] is 
## enabled.
var target_position := Vector2.ZERO

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

## Returns which spawn position should be used.
func get_spawn_position(spawner: Node2D) -> Vector2:
	var value := Vector2.ZERO
	
	if spawn_mode == SpawnMode.IN_PLACE and use_spawner_position:
		value = spawner.global_position
	elif use_vector2:
		value = target_position
	else:
		var marker2D = spawner.get_node(target_node_path) as Marker2D
		value = marker2D.global_position
	
	return value

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

func _get_custom_properties() -> Dictionary:
	const DICT_USE_VECTOR2 = {
		default_value = false,
		type = TYPE_BOOL,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
	}
	const DICT_TARGET_NODE_PATH = {
		type = TYPE_NODE_PATH,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_NODE_PATH_VALID_TYPES,
		hint_string = "Marker2D",
	}
	const DICT_TARGET_POSITION = {
		default_value = Vector2.ZERO,
		type = TYPE_VECTOR2,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
	}
	const DICT_USE_SPAWNER_POSITION = {
		default_value = true,
		type = TYPE_BOOL,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
	}
	
	var custom_properties := {
		"enemy_scene": {
			type = TYPE_OBJECT,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_RESOURCE_TYPE,
			hint_string = "PackedScene",
		},
		"spawn_mode": {
			default_value = SpawnMode.WALK_TO_POSITION,
			type = TYPE_INT,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_ENUM,
			hint_string = ",".join(SpawnMode.keys()),
		},
#		"": {
#			backing_field = "", # use if dict key and variable name are different
#			default_value = "", # use if you want property to have a default value
#			type = TYPE_NIL,
#			usage = PROPERTY_USAGE_DEFAULT,
#			hint = PROPERTY_HINT_NONE,
#			hint_string = "",
#		},
	}
	
	
	if spawn_mode == SpawnMode.IN_PLACE:
		custom_properties["use_spawner_position"] = DICT_USE_SPAWNER_POSITION.duplicate()
		if not use_spawner_position:
			custom_properties["use_vector2"] = DICT_USE_VECTOR2.duplicate()
	elif spawn_mode == SpawnMode.WALK_TO_POSITION:
		custom_properties["use_vector2"] = DICT_USE_VECTOR2.duplicate()
	
	if custom_properties.has("use_vector2"):
		if use_vector2:
			custom_properties["target_position"] = DICT_TARGET_POSITION.duplicate()
		else:
			custom_properties["target_node_path"] = DICT_TARGET_NODE_PATH.duplicate()
	
	return custom_properties

### Custom Inspector built in functions -----------------------------------------------------------

func _get_property_list() -> Array:
	var properties: = []
	
	var custom_properties := _get_custom_properties()
	for key in custom_properties:
		var dict: Dictionary = custom_properties[key]
		if not dict.has("name"):
			dict.name = key
		properties.append(dict)
	
	return properties


func _property_can_revert(property: StringName) -> bool:
	var custom_properties := _get_custom_properties()
	if property in custom_properties and custom_properties[property].has("default_value"):
		return true
	else:
		return false


func _property_get_revert(property: StringName):
	var value
	
	var custom_properties := _get_custom_properties()
	if property in custom_properties and custom_properties[property].has("default_value"):
		value = custom_properties[property]["default_value"]
	
	return value


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
