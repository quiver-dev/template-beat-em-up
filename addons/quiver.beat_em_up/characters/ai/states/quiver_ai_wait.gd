@tool
class_name QuiverAiWait
extends QuiverAiState

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

var _wait_time := 0.0

var _use_range := false:
	set(value):
		_use_range = value
		notify_property_list_changed()

var _min_wait := 3.0:
	set(value):
		_min_wait = value
		if _min_wait > _max_wait:
			_max_wait = _min_wait
var _max_wait := 6.0:
	set(value):
		_max_wait = value
		if _max_wait < _min_wait:
			_min_wait = _max_wait

var _wait_timer: Timer

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return
	
	if not has_node("Timer"):
		_wait_timer = ONE_SHOT_TIMER.instantiate()
		add_child(_wait_timer, true)

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	var current_wait = randf_range(_min_wait, _max_wait) if _use_range else _wait_time
	_wait_timer.start(current_wait)
	QuiverEditorHelper.connect_between(_wait_timer.timeout, _on_wait_timer_timeout)


func exit() -> void:
	super()
	QuiverEditorHelper.disconnect_between(_wait_timer.timeout, _on_wait_timer_timeout)
	if not _wait_timer.is_stopped():
		_wait_timer.stop()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_wait_timer_timeout() -> void:
	state_finished.emit()

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

func _get_custom_properties() -> Dictionary:
	var custom_properties := {
		"_use_range": {
			default_value = false,
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_NONE,
			hint_string = "",
		},
		"_wait_time": {
			default_value = 0.0,
			type = TYPE_FLOAT,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0.0,10.0,0.01,or_greater",
		},
		"_min_wait": {
			default_value = 3.0,
			type = TYPE_FLOAT,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0.0,10.0,0.01,or_greater",
		},
		"_max_wait": {
			default_value = 6.0,
			type = TYPE_FLOAT,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0.0,10.0,0.01,or_greater",
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
	
	if _use_range:
		custom_properties._wait_time.usage = PROPERTY_USAGE_STORAGE
	else:
		custom_properties._min_wait.usage = PROPERTY_USAGE_STORAGE
		custom_properties._max_wait.usage = PROPERTY_USAGE_STORAGE
	
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
