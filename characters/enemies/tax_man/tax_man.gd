@tool
class_name TaxManBoss
extends QuiverEnemyCharacter

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

signal phase_changed_to(phase: int)

#--- enums ----------------------------------------------------------------------------------------

enum TaxManPhases { PHASE_ONE, PHASE_TWO, PHASE_THREE, PHASE_DIE }

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _phases_health_thresholds := {
	TaxManPhases.PHASE_ONE: 1.00,
	TaxManPhases.PHASE_TWO: 0.50,
	TaxManPhases.PHASE_THREE: 0.15,
	TaxManPhases.PHASE_DIE: 0.0,
}

# Used by tax man's hurt state
@warning_ignore(unused_private_class_variable)
var _max_damage_in_one_combo := 0.1

var _health_previous := 1.0
var _current_cumulated_damage := 0.0

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()
	
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return
	
	_health_previous = attributes.get_health_as_percentage()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func can_deny_grabs() -> bool:
	return true

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _update_cumulated_damage() -> void:
	_current_cumulated_damage += _health_previous - attributes.get_health_as_percentage()


func _reset_cumulated_damage() -> void:
	_current_cumulated_damage = 0.0
	_health_previous = attributes.get_health_as_percentage()

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

const CUSTOM_PROPERTIES = {
	"max_damage_in_one_combo": {
		backing_field = "_max_damage_in_one_combo",
		type = TYPE_FLOAT,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_RANGE,
		hint_string = "0.0,1.0,0.01",
	},
	"Boss Phases Health Thresholds": {
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_GROUP,
		hint_string = "health_threshold_",
	},
	"health_threshold_model": {
		backing_field = "_phases_health_thresholds:%s",
		type = TYPE_FLOAT,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_RANGE,
		hint_string = "0.0,1.0,0.01",
	},
#	"": {
#		backing_field = "",
#		name = "",
#		type = TYPE_NIL,
#		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
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
		
		if key == "health_threshold_model":
			add_property = false
			for type in TaxManPhases.values():
				var new_dict = dict.duplicate()
				new_dict.name = new_dict.name.replace(
						"model", 
						TaxManPhases.keys()[type].to_lower()
				)
				properties.append(new_dict)
		
		if add_property:
			properties.append(dict)
	
	return properties


func _get(property: StringName):
	var value
	
	if (property as String).begins_with("health_threshold_"):
		var phase_type = (property as String).replace("health_threshold_", "").to_upper()
		if not _phases_health_thresholds.has(TaxManPhases[phase_type]):
			_phases_health_thresholds[TaxManPhases[phase_type]] = 0.0
		value = _phases_health_thresholds[TaxManPhases[phase_type]]
	elif property in CUSTOM_PROPERTIES and CUSTOM_PROPERTIES[property].has("backing_field"):
		value = get(CUSTOM_PROPERTIES[property]["backing_field"])
	
	return value


func _set(property: StringName, value) -> bool:
	var has_handled: = false
	if (property as String).begins_with("health_threshold_"):
		var phase_type = (property as String).replace("health_threshold_", "").to_upper()
		_phases_health_thresholds[TaxManPhases[phase_type]] = value
		has_handled = true
	elif property in CUSTOM_PROPERTIES and CUSTOM_PROPERTIES[property].has("backing_field"):
		set(CUSTOM_PROPERTIES[property]["backing_field"], value)
		has_handled = true
	
	return has_handled

### -----------------------------------------------------------------------------------------------
