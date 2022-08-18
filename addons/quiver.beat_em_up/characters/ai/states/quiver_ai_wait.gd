@tool
extends QuiverAiState

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const ONE_SHOT_TIMER = preload("res://addons/quiver.beat_em_up/utilities/OneShotTimer.tscn")

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
	_actions.transition_to("Ground/Move/Idle")
	var current_wait = randf_range(_min_wait, _max_wait) if _use_range else _wait_time
	_wait_timer.start(current_wait)
	QuiverEditorHelper.connect_between(_wait_timer.timeout, _on_wait_timer_timeout)


func exit() -> void:
	super()
	QuiverEditorHelper.disconnect_between(_wait_timer.timeout, _on_wait_timer_timeout)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_wait_timer_timeout() -> void:
	state_finished.emit()

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

const CUSTOM_PROPERTIES = {
	"Wait Behavior":{
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY,
		hint = PROPERTY_HINT_NONE,
	},
	"use_range": {
		backing_field = "_use_range",
		type = TYPE_BOOL,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_NONE,
		hint_string = "",
	},
	"wait_time": {
		backing_field = "_wait_time",
		type = TYPE_FLOAT,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_RANGE,
		hint_string = "0.0,10.0,0.01,or_greater",
	},
	"min_wait": {
		backing_field = "_min_wait",
		type = TYPE_FLOAT,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_RANGE,
		hint_string = "0.0,10.0,0.01,or_greater",
	},
	"max_wait": {
		backing_field = "_max_wait",
		type = TYPE_FLOAT,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_RANGE,
		hint_string = "0.0,10.0,0.01,or_greater",
	},
#	"": {
#		backing_field = "",
#		name = "",
#		type = TYPE_NIL,
#		usage = PROPERTY_USAGE_DEFAULT,
#		hint = PROPERTY_HINT_NONE,
#		hint_string = "",
#	},
}

### Custom Inspector built in functions -----------------------------------------------------------

func _get_property_list() -> Array:
	var properties: = []
	
	
	for key in CUSTOM_PROPERTIES:
		var add_property := true
		var dict: Dictionary = CUSTOM_PROPERTIES[key].duplicate()
		if not dict.has("name"):
			dict.name = key
		
		match key:
			"wait_time":
				if _use_range:
					dict.usage = PROPERTY_USAGE_STORAGE
				else:
					dict.usage = CUSTOM_PROPERTIES[key].usage
			"min_wait", "max_wait":
				if not _use_range:
					dict.usage = PROPERTY_USAGE_STORAGE
				else:
					dict.usage = CUSTOM_PROPERTIES[key].usage
		
		if add_property:
			properties.append(dict)
	
	return properties


func _get(property: StringName):
	var value
	
	if property in CUSTOM_PROPERTIES and CUSTOM_PROPERTIES[property].has("backing_field"):
		value = get(CUSTOM_PROPERTIES[property]["backing_field"])
	
	return value


func _set(property: StringName, value) -> bool:
	var has_handled: = false
	
	if property in CUSTOM_PROPERTIES and CUSTOM_PROPERTIES[property].has("backing_field"):
		set(CUSTOM_PROPERTIES[property]["backing_field"], value)
		has_handled = true
	
	return has_handled

### -----------------------------------------------------------------------------------------------
