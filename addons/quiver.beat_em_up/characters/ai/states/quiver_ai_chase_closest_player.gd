@tool
extends QuiverAiState

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export_range(1,10,0.1,"or_greater") var max_chase_time := 5

#--- private variables - order: export > normal var > onready -------------------------------------

@export var _path_follow_state := "Ground/Move/Follow"

var _target: QuiverCharacter
var _chase_timer: SceneTreeTimer

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	_target = QuiverCharacterHelper.find_closest_player_to(_character)
	if is_instance_valid(_target):
		_actions.transition_to(_path_follow_state, {target_node = _target})
		_actions.transitioned.connect(_on_actions_transitioned)
		_chase_timer = get_tree().create_timer(max_chase_time)
		_chase_timer.timeout.connect(_on_chase_timer_timeout)


func exit() -> void:
	_actions.transitioned.disconnect(_on_actions_transitioned)
	if is_instance_valid(_chase_timer):
		_chase_timer.timeout.disconnect(_on_chase_timer_timeout)
	_chase_timer = null
	super()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _target_reached() -> void:
	state_finished.emit()


func _on_actions_transitioned(_path_state: String) -> void:
	_target_reached()


func _on_chase_timer_timeout() -> void:
	state_finished.emit()

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

const CUSTOM_PROPERTIES = {
	"path_follow_state": {
		backing_field = "_path_follow_state",
		type = TYPE_STRING,
		usage = PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_NONE,
		hint_string = QuiverState.HINT_STATE_LIST,
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
		var dict: Dictionary = CUSTOM_PROPERTIES[key]
		if not dict.has("name"):
			dict.name = key
		
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
