@tool
class_name QuiverActionGrabGrabbing
extends QuiverCharacterAction

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _skin_state: StringName
var _path_next_state := "Ground/Grab/Idle"

@onready var _grab_state := get_parent() as QuiverActionGroundGrab

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()
	update_configuration_warnings()
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	
	if not get_parent() is QuiverActionGroundGrab:
		warnings.append(
				"This ActionState must be a child of Action QuiverActionGroundGrab or a state " 
				+ "inheriting from it."
		)
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	_grab_state.enter(msg)
	_skin.transition_to(_skin_state)


func exit() -> void:
	super()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _adjust_grabbed_target_position(ref_position: Marker2D) -> void:
	var grab_target_offset = _grab_state.grab_target.grabbed_offset
	var new_position = ref_position.global_position
	if is_instance_valid(grab_target_offset):
		var local_offset = _grab_state.grab_target_node.to_local(grab_target_offset.global_position)
		new_position -= local_offset
	_grab_state.grab_target_node.global_position = new_position


func _connect_signals() -> void:
	get_parent()._connect_signals()
	super()
	
	QuiverEditorHelper.connect_between(_skin.skin_animation_finished, _on_skin_animation_finished)
	QuiverEditorHelper.connect_between(_skin.grab_frame_reached, _on_skin_grab_frame_reached)


func _disconnect_signals() -> void:
	super()
	if _skin != null:
		QuiverEditorHelper.disconnect_between(
			_skin.skin_animation_finished, _on_skin_animation_finished
		)
		
		QuiverEditorHelper.disconnect_between(_skin.grab_frame_reached, _on_skin_grab_frame_reached)


## Connect the signal that marks the end of the attack to this function.
func _on_skin_animation_finished() -> void:
	_state_machine.transition_to(_path_next_state)


func _on_skin_grab_frame_reached(ref_position: Marker2D) -> void:
	_grab_state.grab_target.grabbed.emit(_grab_state.grab_target.ground_level)
	if not _grab_state.grab_target_node.can_deny_grabs():
		_grab_state.reparent_target_node_to(ref_position)
		_grab_state.grab_pivot = ref_position
		_adjust_grabbed_target_position(ref_position)

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

func _get_custom_properties() -> Dictionary:
	return {
		"_skin_state": {
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_ENUM,
			hint_string = \
					'ExternalEnum{"property": "_skin", "property_name": "_animation_list"}'
		},
		"_path_next_state": {
			default_value = "Ground/Grab/Idle",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_NONE,
			hint_string = QuiverState.HINT_STATE_LIST,
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
