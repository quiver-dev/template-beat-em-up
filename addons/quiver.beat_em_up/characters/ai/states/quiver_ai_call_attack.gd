@tool
class_name QuiverAiCallAttack
extends QuiverAiState

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------


#--- private variables - order: export > normal var > onready -------------------------------------

@export_range(1,2,1,"or_greater") var _combo_hits_amount := 1

var _attack_state_path := ""
var _fallback_state_path := "Ground/Move/Idle"

var _transitions_count := 0

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	_transitions_count = _combo_hits_amount
	# the number of auto "combo" transitions is the number of combo hits - 1
	_actions.transition_to(_attack_state_path, { auto_combo = _combo_hits_amount - 1 })
	QuiverEditorHelper.connect_between(_actions.transitioned, _on_actions_transitioned)


func exit() -> void:
	super()
	_transitions_count = 0
	QuiverEditorHelper.disconnect_between(_actions.transitioned, _on_actions_transitioned)


func interrupt_state() -> void:
	QuiverEditorHelper.disconnect_between(_actions.transitioned, _on_actions_transitioned)
	state_finished.emit()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_actions_transitioned(p_state_path: NodePath) -> void:
	_transitions_count -= 1
	if _transitions_count <= 0:
		state_finished.emit()
	elif (p_state_path as String) == _fallback_state_path:
		push_warning(
				"Reached fallback state (%s) before finishing combo! Remaining Combo: %s"%
				[_fallback_state_path, _transitions_count]
		)
		state_finished.emit()

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

func _get_custom_properties() -> Dictionary:
	return {
		"Call Attack":{
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_CATEGORY,
			hint = PROPERTY_HINT_NONE,
		},
		"_attack_state_path": {
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_NONE,
			hint_string = QuiverState.HINT_ATTACK_STATE_LIST,
		},
		"_fallback_state_path": {
			default_value = "Ground/Move/Idle",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_NONE,
			hint_string = QuiverState.HINT_NOT_ATTACK_STATE_LIST,
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
