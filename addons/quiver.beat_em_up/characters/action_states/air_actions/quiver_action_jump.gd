@tool
class_name QuiverActionAirJump
extends QuiverCharacterAction

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _path_landing := "Air/Jump/Landing"
var _path_knockout := "Air/Knockout/Launch"

var _air_attack_count := 0

@onready var _air_state := get_parent() as QuiverActionAir

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
	
	if not get_parent() is QuiverActionAir:
		warnings.append(
				"This ActionState must be a child of Action QuiverActionAir or a state " 
				+ "inheriting from it."
		)
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	_air_state.enter(msg)


func physics_process(delta: float) -> void:
	_air_state._move_and_apply_gravity(delta)
	if _air_state._has_reached_ground():
		_air_state._handle_landing(_path_landing)


func exit() -> void:
	super()
	_air_state.exit()
	_air_attack_count = 0

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _connect_signals() -> void:
	super()
	
	QuiverEditorHelper.connect_between(_attributes.hurt_requested, _on_hurt_requested)
	QuiverEditorHelper.connect_between(_attributes.knockout_requested, _on_knockout_requested)


func _disconnect_signals() -> void:
	super()
	
	if _attributes != null:
		QuiverEditorHelper.disconnect_between(_attributes.hurt_requested, _on_hurt_requested)
		QuiverEditorHelper.disconnect_between(
				_attributes.knockout_requested, _on_knockout_requested
		)


func _on_hurt_requested(knockback: QuiverKnockbackData) -> void:
	# We force exit here when jump is interrupted because normally only the Jump/Landing state
	# triggers the Jump exit
	exit()
	# This is here because ANY hit you receive on air generates a knockout.
	_state_machine.transition_to(_path_knockout, {launch_vector = knockback.launch_vector})


func _on_knockout_requested(knockback: QuiverKnockbackData) -> void:
	# We force exit here when jump is interrupted because normally only the Jump/Landing state
	# triggers the Jump exit
	exit()
	_state_machine.transition_to(_path_knockout, {launch_vector = knockback.launch_vector})


### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

func _get_custom_properties() -> Dictionary:
	return {
		"_path_landing": {
			default_value = "Air/Jump/Landing",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_NONE,
			hint_string = QuiverState.HINT_STATE_LIST,
		},
		"_path_knockout": {
			default_value = "Air/Knockout/Launch",
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
