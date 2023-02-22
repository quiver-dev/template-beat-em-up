@tool
class_name QuiverAiGoToPosition
extends QuiverAiState

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const INVALID_NODEPATH = ^"invalid"
const INVALID_POSITION = Vector2(INF, INF)

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _path_follow_state := "Ground/Move/Follow"

var _use_node := false:
	set(value):
		_use_node = value
		notify_property_list_changed()

var _fallback_position := INVALID_POSITION
var _fallback_node_path := INVALID_NODEPATH
var _fallback_node: Node = null

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return
	
	if _use_node and _fallback_node_path != INVALID_NODEPATH:
		_fallback_node = get_node(_fallback_node_path)

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	
	if msg.has("position") and msg.position is Vector2:
		_actions.transition_to(_path_follow_state, {target_position = msg.position})
	elif msg.has("node") and msg.node is Node2D:
		if is_instance_valid(msg.node):
			_actions.transition_to(_path_follow_state, {target_node = msg.node})
	elif _use_node and is_instance_valid(_fallback_node):
		if _fallback_node is Node2D:
			_actions.transition_to(_path_follow_state, {target_node = _fallback_node})
		elif _fallback_node is Control:
			_actions.transition_to(
					_path_follow_state, 
					{target_position = _fallback_node.global_position}
			)
	elif not _use_node and _fallback_position != INVALID_POSITION:
		_actions.transition_to(_path_follow_state, {target_position = _fallback_position})
	else:
		push_error("Could not find any valid messages or fallbacks to identify position: %s"%[msg])
		state_finished.emit()
		return
	
	QuiverEditorHelper.connect_between(_actions.transitioned, _on_actions_transitioned)


func exit() -> void:
	super()
	QuiverEditorHelper.disconnect_between(_actions.transitioned, _on_actions_transitioned)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_actions_transitioned(_path_state: String) -> void:
	state_finished.emit()

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

func _get_custom_properties() -> Dictionary:
	var custom_properties := {
		"_path_follow_state": {
			default_value = "Ground/Move/Follow",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_NONE,
			hint_string = QuiverState.HINT_STATE_LIST,
		},
		"_use_node": {
			default_value = false,
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
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
	
	if _use_node:
		custom_properties["_fallback_node_path"] = {
			type = TYPE_NODE_PATH,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_NODE_PATH_VALID_TYPES,
			hint_string = "Node2D,Control",
		}
	else:
		custom_properties["_fallback_position"] = {
			type = TYPE_VECTOR2,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		}
	
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
