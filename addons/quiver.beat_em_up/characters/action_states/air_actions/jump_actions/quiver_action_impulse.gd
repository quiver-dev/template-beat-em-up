@tool
class_name QuiverActionJumpImpulse
extends QuiverCharacterAction

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const JumpState = preload(
		"res://addons/quiver.beat_em_up/characters/action_states/air_actions/quiver_action_jump.gd"
)

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _skin_state: StringName
var _path_next_state := "Air/Jump/MidAir"

@onready var _jump_state := get_parent() as JumpState

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
	
	if not get_parent() is JumpState:
		warnings.append(
				"This ActionState must be a child of Action Jump state or a state " 
				+ "inheriting from it."
		)
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	_jump_state.enter(msg)
	_skin.transition_to(_skin_state)
	
	if msg.has("velocity"):
		_character.velocity = msg.velocity * Vector2.RIGHT


func exit() -> void:
	super()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _connect_signals() -> void:
	super()
	QuiverEditorHelper.connect_between(_skin.skin_animation_finished, _on_skin_animation_finished)


func _disconnect_signals() -> void:
	super()
	if _skin != null:
		QuiverEditorHelper.disconnect_between(
				_skin.skin_animation_finished, _on_skin_animation_finished
		)


func _on_skin_animation_finished() -> void:
	_jump_state._air_state._skin_velocity_y = _attributes.jump_force
	_state_machine.transition_to(_path_next_state)
	_state_machine.set_physics_process(true)

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

func _get_custom_properties() -> Dictionary:
	return {
		"_skin_state": {
			default_value = &"jump",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_ENUM,
			hint_string = \
					'ExternalEnum{"property": "_skin", "property_name": "_animation_list"}'
		},
		"_path_next_state": {
			default_value = "Air/Jump/MidAir",
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
