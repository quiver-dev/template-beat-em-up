@tool
extends QuiverCharacterState

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const AirState = preload(
		"res://addons/quiver.beat_em_up/characters/action_states/quiver_action_air.gd"
)

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

@export var _path_landing := "Air/Jump/Landing"
@export var _path_knockout := "Air/Knockout/Launch"

var _air_attack_count := 0

@onready var _air_state := get_parent() as AirState

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
	
	if not get_parent() is AirState:
		warnings.append(
				"This ActionState must be a child of Action AirState or a state " 
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
		_handle_landing()


func exit() -> void:
	super()
	_air_state.exit()
	_air_attack_count = 0

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _handle_landing() -> void:
	_character.global_position.y = _attributes.ground_level
	_character.velocity.y = 0.0
	_state_machine.transition_to(_path_landing)


func _connect_signals() -> void:
	super()
	
	if not _attributes.hurt_requested.is_connected(_on_hurt_requested):
		_attributes.hurt_requested.connect(_on_hurt_requested)
	
	if not _attributes.knockout_requested.is_connected(_on_knockout_requested):
		_attributes.knockout_requested.connect(_on_knockout_requested)


func _disconnect_signals() -> void:
	super()
	
	if _attributes != null:
		if _attributes.hurt_requested.is_connected(_on_hurt_requested):
			_attributes.hurt_requested.disconnect(_on_hurt_requested)
		
		if _attributes.knockout_requested.is_connected(_on_knockout_requested):
			_attributes.knockout_requested.disconnect(_on_knockout_requested)


func _on_hurt_requested(knockback: QuiverKnockback) -> void:
	_air_attack_count = 0
	# This is here because ANY hit you receive on air generates a knockout.
	_state_machine.transition_to(_path_knockout, {launch_vector = knockback.launch_vector})


func _on_knockout_requested(knockback: QuiverKnockback) -> void:
	_air_attack_count = 0
	_state_machine.transition_to(_path_knockout, {launch_vector = knockback.launch_vector})


### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

const CUSTOM_PROPERTIES = {
	"path_knockout": {
		backing_field = "_path_knockout",
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
