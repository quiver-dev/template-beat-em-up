@tool
extends QuiverCharacterAction

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _skin_state_hurt_light := &"hurt_light"
var _skin_state_hurt_medium := &"hurt_medium"
var _skin_state_hurt_knockout := &"hurt_knockout"

var _path_knockout := "Ground/KnockoutKneeled"
var _path_retaliate := "Ground/GrabReject"
var _path_idle := "Ground/Move/IdleAi"

var _should_knockout := false

var _tax_man: TaxManBoss = null

@onready var _ground_state := get_parent() as QuiverActionGround

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
	
	if not get_parent() is QuiverActionGround:
		@warning_ignore("return_value_discarded")
		warnings.append(
				"This ActionState must be a child of Action QuiverActionGround or a state " 
				+ "inheriting from it."
		)
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	_ground_state.enter(msg)
	
	_tax_man._update_cumulated_damage()
	
	var threshold_hurt_medium = _tax_man._max_damage_in_one_combo
	var threshold_hurt_light = threshold_hurt_medium / 2.0
	var current_health := _attributes.get_health_as_percentage()
	
	if current_health <= 0.0:
		_should_knockout = true
		_skin.transition_to(_skin_state_hurt_knockout)
	else:
		var new_phase := -1
		for phase_type in _tax_man._phases_health_thresholds:
			var threshold_value = _tax_man._phases_health_thresholds[phase_type]
			if _has_changed_phase(threshold_value):
				_should_knockout = true
				new_phase = phase_type
				_character._reset_cumulated_damage()
				break
		
		if _should_knockout:
			_skin.transition_to(_skin_state_hurt_knockout)
			_tax_man.phase_changed_to.emit(new_phase)
		else:
			if _tax_man._current_cumulated_damage <=threshold_hurt_light:
				_skin.transition_to(_skin_state_hurt_light)
			elif _tax_man._current_cumulated_damage <= threshold_hurt_medium:
				_skin.transition_to(_skin_state_hurt_medium)
			else:
				_skin.transition_to(_skin_state_hurt_knockout)


func _has_changed_phase(health_threshold: float) -> bool:
	var has_not_crossed_threshold_yet := _tax_man._health_previous > health_threshold
	var is_below_threshold := _attributes.get_health_as_percentage() <= health_threshold
	return has_not_crossed_threshold_yet and is_below_threshold


func exit() -> void:
	_ground_state.exit()
	super()
	
	_should_knockout = false

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_owner_ready() -> void:
	super()
	_tax_man = _character as TaxManBoss


func _on_skin_skin_animation_finished() -> void:
	if _should_knockout:
		_state_machine.transition_to(_path_knockout)
	elif _tax_man._current_cumulated_damage >= _tax_man._max_damage_in_one_combo:
		_state_machine.transition_to(_path_retaliate)
	else:
		_state_machine.transition_to(_path_idle)
	
	_character._reset_cumulated_damage()

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

func _get_custom_properties() -> Dictionary:
	return {
		"Tax Man Hurt State": {
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_CATEGORY,
		},
		"Skin States": {
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_GROUP,
			hint_string = "_skin_state_",
		},
		"_skin_state_hurt_light": {
			default_value = &"hurt_light",
			type = TYPE_STRING_NAME,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_ENUM,
			hint_string = \
					'ExternalEnum{"property": "_skin", "property_name": "_animation_list"}'
			,
		},
		"_skin_state_hurt_medium": {
			default_value = &"hurt_medium",
			type = TYPE_STRING_NAME,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_ENUM,
			hint_string = \
					'ExternalEnum{"property": "_skin", "property_name": "_animation_list"}'
			,
		},
		"_skin_state_hurt_knockout": {
			default_value = &"hurt_knockout",
			type = TYPE_STRING_NAME,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_ENUM,
			hint_string = \
					'ExternalEnum{"property": "_skin", "property_name": "_animation_list"}'
			,
		},
		"Next State Paths": {
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_GROUP,
			hint_string = "_path_",
		},
		"_path_knockout": {
			default_value = "Ground/KnockoutKneeled",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_NONE,
			hint_string = QuiverState.HINT_STATE_LIST,
		},
		"_path_retaliate": {
			default_value = "Ground/GrabReject",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_NONE,
			hint_string = QuiverState.HINT_STATE_LIST,
		},
		"_path_idle": {
			default_value = "Ground/Move/IdleAi",
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
