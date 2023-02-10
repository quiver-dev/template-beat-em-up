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
		"_use_spawner_position": {
			backing_field = "use_spawner_position",
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
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
				if use_spawner_position:
					add_property = false
				else:
					if use_vector2 and key == "_target_node_path":
						add_property = false
					elif not use_vector2 and key == "_target_position":
						add_property = false
		elif spawn_mode == SpawnMode.WALK_TO_POSITION:
			if key == "_use_spawner_position":
				add_property = false
			elif use_vector2 and key == "_target_node_path":
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
