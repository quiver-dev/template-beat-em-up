@tool
class_name QuiverActionGround
extends QuiverCharacterAction

## Base Action for all Ground Actions. Handles transition to Hurt, Grabbed and Knockout states as 
## well as keeping [member QuiverAttributes.ground_level] and [member QuiverCharacter.is_on_air] 
## updated

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _path_hurt := "Ground/Hurt"
var _path_knockout := "Air/Knockout/Launch"
var _path_grabbed := "Ground/Grabbed"

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()
	update_configuration_warnings()
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

## Handles signal connetion and the properties [member QuiverAttributes.ground_level] 
## and [member QuiverCharacter.is_on_air] 
func enter(msg: = {}) -> void:
	super(msg)
	
	if msg.has("ground_level"):
		_attributes.ground_level = msg.ground_level
	else:
		_attributes.ground_level = _character.global_position.y
	
	_character.is_on_air = false


## Keeps [member QuiverAttributes.ground_level] updates.
func physics_process(_delta: float) -> void:
	_attributes.ground_level = _character.global_position.y


## Handles disconnecting signals and [member QuiverCharacter.is_on_air] 
func exit() -> void:
	_character.is_on_air = true
	super()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _connect_signals() -> void:
	super()
	
	QuiverEditorHelper.connect_between(_attributes.hurt_requested, _on_hurt_requested)
	QuiverEditorHelper.connect_between(_attributes.knockout_requested, _on_knockout_requested)
	if _state_machine.has_node(_path_grabbed):
		QuiverEditorHelper.connect_between(_attributes.grabbed, _on_grabbed)


func _disconnect_signals() -> void:
	super()
	
	if _attributes != null:
		QuiverEditorHelper.disconnect_between(_attributes.hurt_requested, _on_hurt_requested)
		QuiverEditorHelper.disconnect_between(
				_attributes.knockout_requested, _on_knockout_requested
		)
		QuiverEditorHelper.disconnect_between(_attributes.grabbed, _on_grabbed)


func _on_hurt_requested(knockback: QuiverKnockbackData) -> void:
	_state_machine.transition_to.call_deferred(_path_hurt, {hurt_type = knockback.hurt_type})


func _on_knockout_requested(knockback: QuiverKnockbackData) -> void:
	_state_machine.transition_to.call_deferred(
			_path_knockout, 
			{launch_vector = knockback.launch_vector}
	)


func _on_grabbed(ground_level: float) -> void:
	_state_machine.transition_to.call_deferred(_path_grabbed, {ground_level = ground_level})

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

func _get_custom_properties() -> Dictionary:
	return {
		"_path_hurt": {
			default_value = "Ground/Hurt",
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
		"_path_grabbed": {
			default_value = "Ground/Grabbed",
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
