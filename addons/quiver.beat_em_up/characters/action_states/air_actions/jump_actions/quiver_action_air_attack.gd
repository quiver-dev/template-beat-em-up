@tool
class_name QuiverActionJumpAttack
extends QuiverCharacterAction

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

enum EndConditions {
	ANIMATION, ## Triggers end of state when air attack animation emits [signal QuiverCharacterSkin.skin_animation_finished].
	DISTANCE_FROM_GROUND, ## Triggers end of state using [member _min_distance_from_ground].
	FIRST_TO_TRIGGER, ## Triggers end of state by whatever happens first, ANIMATION or DISTANCE_FROM_GROUND
}

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _skin_state: StringName
var _path_falling_state := "Air/Jump/MidAir"

## What Condition should trigger the end of the air attack. See enum [b]EndContitions.[/b]
var _end_condition: EndConditions = EndConditions.DISTANCE_FROM_GROUND:
	set(value):
		_end_condition = value
		notify_property_list_changed()

## Minimum distance the air attack can have from ground. Anything below this will trigger 
## the end of the air attack if [member _end_condition] is either 
## [b]EndConditions.DISTANCE_FROM_GROUND[/b] or [b]EndConditions.FIRST_TO_TRIGGER[/b].
var _min_distance_from_ground = 100

@onready var _jump_state := get_parent() as QuiverActionAirJump

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
	
	if not get_parent() is QuiverActionAirJump:
		warnings.append(
				"This ActionState must be a child of Action QuiverActionAir or a state " 
				+ "inheriting from it."
		)
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	_skin.transition_to(_skin_state)


func physics_process(delta: float) -> void:
	_jump_state.physics_process(delta)
	if _has_distance_condition():
		if _skin.position.y >= _min_distance_from_ground:
			_state_machine.transition_to(_path_falling_state)


func exit() -> void:
	super()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _has_animation_condition() -> bool:
	return (
			_end_condition == EndConditions.ANIMATION 
			or _end_condition == EndConditions.FIRST_TO_TRIGGER
	)


func _has_distance_condition() -> bool:
	return (
			_end_condition == EndConditions.DISTANCE_FROM_GROUND 
			or _end_condition == EndConditions.FIRST_TO_TRIGGER
	)

func _connect_signals() -> void:
	super()
	
	if _has_animation_condition():
		QuiverEditorHelper.connect_between(
				_skin.skin_animation_finished, _on_skin_animation_finished
		)


func _disconnect_signals() -> void:
	super()
	
	if _skin != null and _has_animation_condition():
		QuiverEditorHelper.disconnect_between(
				_skin.skin_animation_finished, _on_skin_animation_finished
		)


func _on_skin_animation_finished() -> void:
	_state_machine.transition_to(_path_falling_state)

### -----------------------------------------------------------------------------------------------


###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

func _get_custom_properties() -> Dictionary:
	var custom_properties := {
		"_skin_state": {
			default_value = &"air_attack",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_ENUM,
			hint_string = \
					'ExternalEnum{"property": "_skin", "property_name": "_animation_list"}'
		},
		"_path_falling_state": {
			default_value = "Air/Jump/MidAir",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_NONE,
			hint_string = QuiverState.HINT_STATE_LIST,
		},
		"_end_condition": {
			default_value = EndConditions.DISTANCE_FROM_GROUND,
			type = TYPE_INT,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_ENUM,
			hint_string = ",".join(EndConditions.keys()),
		},
		"_min_distance_from_ground": {
			default_value = 100,
			type = TYPE_INT,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0,1000,10,or_greater",
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
	
	if not _has_distance_condition():
		custom_properties["_min_distance_from_ground"].usage = PROPERTY_USAGE_STORAGE
	
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
