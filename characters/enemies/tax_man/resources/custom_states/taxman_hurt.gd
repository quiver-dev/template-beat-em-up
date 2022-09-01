@tool
extends QuiverCharacterState

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const GroundState = preload(
		"res://addons/quiver.beat_em_up/characters/action_states/quiver_action_ground.gd"
)

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _threshold_hurt_light := 0.05:
	set(value):
		_threshold_hurt_light = clamp(value, 0, _threshold_hurt_medium)
var _threshold_hurt_medium := 0.10:
	set(value):
		_threshold_hurt_medium = clamp(value, _threshold_hurt_light, 1.0)

var _skin_state_hurt_light := &"hurt_light"
var _skin_state_hurt_medium := &"hurt_medium"
var _skin_state_hurt_knockout := &"hurt_knockout"

var _path_knockout := "Ground/KnockoutKneeled"
var _path_idle := "Ground/Move/IdleAi"

var _should_knockout := false

@onready var _ground_state := get_parent() as GroundState

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
	
	if not get_parent() is GroundState:
		warnings.append(
				"This ActionState must be a child of Action GroundState or a state " 
				+ "inheriting from it."
		)
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	_ground_state.enter(msg)
	
	_character._update_cumulated_damage()
	if _character._current_cumulated_damage <= _threshold_hurt_light:
		_skin.transition_to(_skin_state_hurt_light)
	elif _character._current_cumulated_damage <= _threshold_hurt_medium:
		_skin.transition_to(_skin_state_hurt_medium)
	else:
		_should_knockout = true
		_skin.transition_to(_skin_state_hurt_knockout)


func exit() -> void:
	_ground_state.exit()
	super()
	
	_should_knockout = false

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_skin_skin_animation_finished() -> void:
	_character._reset_cumulated_damage()
	if _should_knockout:
		_state_machine.transition_to(_path_knockout)
	else:
		_state_machine.transition_to(_path_idle)

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

const CUSTOM_PROPERTIES = {
	"Tax Man Hurt State": {
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY,
	},
	"Hurt Type Thresholds": {
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_GROUP,
		hint_string = "threshold_",
	},
	"threshold_hurt_light": {
		backing_field = "_threshold_hurt_light",
		type = TYPE_FLOAT,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_NONE,
		hint_string = "",
	},
	"threshold_hurt_medium": {
		backing_field = "_threshold_hurt_medium",
		type = TYPE_FLOAT,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_NONE,
		hint_string = "",
	},
	"Skin States": {
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_GROUP,
		hint_string = "skin_state_",
	},
	"skin_state_hurt_light": {
		backing_field = "_skin_state_hurt_light",
		type = TYPE_STRING_NAME,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_ENUM,
		hint_string = \
				'ExternalEnum{"property": "_skin", "property_name": "_animation_list"}'
		,
	},
	"skin_state_hurt_medium": {
		backing_field = "_skin_state_hurt_medium",
		type = TYPE_STRING_NAME,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_ENUM,
		hint_string = \
				'ExternalEnum{"property": "_skin", "property_name": "_animation_list"}'
		,
	},
	"skin_state_hurt_knockout": {
		backing_field = "_skin_state_hurt_knockout",
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
		hint_string = "path_",
	},
	"path_knockout": {
		backing_field = "_path_knockout",
		type = TYPE_STRING,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_NONE,
		hint_string = QuiverState.HINT_STATE_LIST,
	},
	"path_idle": {
		backing_field = "_path_idle",
		type = TYPE_STRING,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_NONE,
		hint_string = QuiverState.HINT_STATE_LIST,
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
