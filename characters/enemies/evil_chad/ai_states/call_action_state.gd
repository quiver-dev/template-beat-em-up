@tool
extends "res://characters/enemies/evil_chad/ai_states/base_ai_state.gd"

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

# DELETE-ME using this as a STUPID worka around for advanced exports not working. 
enum PossibleStates {IDLE,FOLLOW,COMBO1,COMBO2,JUMP,AIR_ATTACK}

# DELETE-ME using this as a STUPID worka around for advanced exports not working. 
const STATE_PATHS = {
	PossibleStates.IDLE: "Ground/Move/Idle",
	PossibleStates.FOLLOW: "Ground/Move/Follow",
	PossibleStates.COMBO1: "Ground/Attack/Combo1",
	PossibleStates.COMBO2: "Ground/Attack/Combo2",
	PossibleStates.JUMP: "Air/Jump",
	PossibleStates.AIR_ATTACK: "Air/Attack",
}

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

# DELETE-ME using this as a STUPID worka around for advanced exports not working. 
@export var state_to_call :PossibleStates

#--- private variables - order: export > normal var > onready -------------------------------------

# In the future, when advanced exports are working this variable will be a drop down selector
# in the inspector, auto generated wit the paths to the current state machine's leaf states
# for now it is unused because advanced exports are broken
@warning_ignore(unused_private_class_variable)
var _state_path: String = ""

var _possible_states := []

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	_actions.transition_to(STATE_PATHS[state_to_call])
	_actions.transitioned.connect(_on_actions_transitioned)


func exit() -> void:
	super()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_actions_transitioned(_p_state_path: NodePath) -> void:
	_actions.transitioned.disconnect(_on_actions_transitioned)
	state_finished.emit()


func _on_owner_ready() -> void:
	super()
	_possible_states = _actions.get_leaf_nodes_path_list()
	
	CUSTOM_PROPERTIES["state_path"].hint_string = ",".join(PackedStringArray(_possible_states))
	print(CUSTOM_PROPERTIES["state_path"].hint_string)

### -----------------------------------------------------------------------------------------------


###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

### Editor Methods --------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

var CUSTOM_PROPERTIES = {
	"call_state_category": {
		"name": "Call State",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_CATEGORY,
	},
	"state_path": {
		backing_field = "_state_path",
		type = TYPE_STRING,
		usage = PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_ENUM,
		hint_string = "",
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


func _get_configuration_warning() -> String:
	var msg: = ""

	return msg

### -----------------------------------------------------------------------------------------------
