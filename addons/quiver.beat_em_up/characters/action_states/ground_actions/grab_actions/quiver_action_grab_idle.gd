@tool
class_name QuiverActionGrabIdle
extends QuiverCharacterAction

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

# this is broken for exports on alpha 16
#const ONE_SHOT_TIMER = preload("res://addons/quiver.beat_em_up/utilities/OneShotTimer.tscn")
@onready var ONE_SHOT_TIMER = load("res://addons/quiver.beat_em_up/utilities/OneShotTimer.tscn")

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _release_delay := 1.5
var _skin_state: StringName
var _path_release := "Ground/Grab/Release"
var _path_throw_forward := "Ground/Grab/ThrowForward"
var _path_throw_backwards := "Ground/Grab/ThrowBackward"
var _path_grab_denied := "Ground/Hurt"

var _is_holding_backwards := false
var _release_action := ""
var _release_timer: Timer = null

@onready var _grab_state := get_parent() as QuiverActionGroundGrab

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()
	update_configuration_warnings()
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return
	
	_release_timer = ONE_SHOT_TIMER.instantiate()
	add_child(_release_timer, true)


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
	_skin.transition_to(_skin_state)
	
	_release_action = "move_left" if _skin.skin_direction == 1 else "move_right"
	_is_holding_backwards = Input.is_action_pressed(_release_action)


func unhandled_input(event: InputEvent) -> void:
	var has_handled := false
	
	if event.is_action_pressed(_release_action):
		if _release_timer.is_stopped():
			QuiverEditorHelper.connect_between(_release_timer.timeout, _on_release_timer_timeout)
			_release_timer.start(_release_delay)
		_is_holding_backwards = true
		has_handled = true
	elif event.is_action_released(_release_action):
		if not _release_timer.is_stopped():
			QuiverEditorHelper.disconnect_between(_release_timer.timeout, _on_release_timer_timeout)
			_release_timer.stop()
		_is_holding_backwards = false
		has_handled = true
	
	if event.is_action_pressed("attack"):
		if _is_holding_backwards:
			_state_machine.transition_to(_path_throw_backwards)
			has_handled = true
		else:
			_state_machine.transition_to(_path_throw_forward)
			has_handled = true
	
	if not has_handled:
		_grab_state.unhandled_input(event)


func exit() -> void:
	super()
	_release_action = ""
	_is_holding_backwards = false
	QuiverEditorHelper.disconnect_between(_release_timer.timeout, _on_release_timer_timeout)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _connect_signals() -> void:
	super()
	
	QuiverEditorHelper.connect_between(
			_grab_state.grab_target.grab_denied, _on_grab_target_grab_denied
	)


func _disconnect_signals() -> void:
	super()
	
	if not is_instance_valid(_grab_state):
		QuiverEditorHelper.disconnect_between(
				_grab_state.grab_target.grab_denied, _on_grab_target_grab_denied
		)


func _on_grab_target_grab_denied() -> void:
	_grab_state.exit()
	_state_machine.transition_to(_path_grab_denied)


func _on_release_timer_timeout() -> void:
	_state_machine.transition_to(_path_release)

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

func _get_custom_properties() -> Dictionary:
	return {
		"_release_delay": {
			default_value = 1.5,
			type = TYPE_FLOAT,
			usage = PROPERTY_USAGE_DEFAULT,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0.0,3.0,0.05,or_greater",
		},
		"_skin_state": {
			default_value = &"grab_idle",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_ENUM,
			hint_string = \
					'ExternalEnum{"property": "_skin", "property_name": "_animation_list"}'
		},
		"Follow Up Actions":{
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_GROUP,
			hint_string = "path_"
		},
		"_path_grab_denied": {
			default_value = "Ground/Hurt",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_NONE,
			hint_string = QuiverState.HINT_STATE_LIST,
		},
		"_path_release": {
			default_value = "Ground/Grab/Release",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_NONE,
			hint_string = QuiverState.HINT_STATE_LIST,
		},
		"_path_throw_forward": {
			default_value = "Ground/Grab/ThrowForward",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_NONE,
			hint_string = QuiverState.HINT_STATE_LIST,
		},
		"_path_throw_backwards": {
			default_value = "Ground/Grab/ThrowBackward",
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
