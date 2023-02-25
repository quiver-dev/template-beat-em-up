@tool
class_name QuiverActionJumpMidAir
extends QuiverCharacterAction

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _skin_state_rising: StringName
var _skin_state_falling: StringName

var _can_attack := true:
	set(value):
		var has_changed = value != _can_attack
		_can_attack = value
		if has_changed:
			notify_property_list_changed()
		
		if not _can_attack:
			_path_air_attack = ""
		else:
			update_configuration_warnings()

var _path_air_attack := "Air/Jump/Attack":
	set(value):
		if _can_attack:
			_path_air_attack = value
		else:
			_path_air_attack = ""
		update_configuration_warnings()

var _air_control_max_speed := 0.0

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
				"This ActionState must be a child of Action Jump state or a state " 
				+ "inheriting from it."
		)
	
	if _can_attack and _path_air_attack.is_empty():
		warnings.append("You must select an attack state when _can_attack is true.")
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	_jump_state.enter(msg)
	
	_handle_mid_air_animation()
	
	_air_control_max_speed = _attributes.speed_max * _attributes.air_control
	
	if not _can_attack:
		_state_machine.set_process_unhandled_input(false)


func unhandled_input(event: InputEvent) -> void:
	if not _can_attack:
		return
	
	var has_handled := false
	
	if event.is_action_pressed("attack"):
		_attack()
		has_handled = true
	
	if not has_handled:
		_jump_state.unhandled_input(event)


func physics_process(delta: float) -> void:
	var h_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down").x
	var air_control_influence: float = _air_control_max_speed * h_direction
	
	if _should_apply_air_control(h_direction):
		_character.velocity.x = air_control_influence
	
	_handle_mid_air_animation()
	_jump_state.physics_process(delta)
	_handle_facing_direction()


func exit() -> void:
	super()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _handle_mid_air_animation() -> void:
	if _jump_state._air_state._skin_velocity_y < 0:
		_skin.transition_to(_skin_state_rising)
	else:
		_skin.transition_to(_skin_state_falling)


func _handle_facing_direction() -> void:
	var facing_direction :int = sign(_character.velocity.x)
	if facing_direction != 0 and facing_direction != _skin.skin_direction:
		_skin.skin_direction = facing_direction


func _should_apply_air_control(input_direction: float) -> bool:
	var is_not_neutral: bool = not is_zero_approx(input_direction)
	var is_opposite_directions: bool = sign(input_direction) != sign(_character.velocity.x)
	var has_already_changed_direction: bool = abs(_character.velocity.x) <= _air_control_max_speed
	return is_not_neutral and (is_opposite_directions or has_already_changed_direction)


func _attack() -> void:
	if _has_air_attack():
		_jump_state._air_attack_count += 1
		_state_machine.transition_to(_path_air_attack)


func _has_air_attack() -> bool:
	return _can_attack and _jump_state._air_attack_count == 0

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

func _get_custom_properties() -> Dictionary:
	var custom_properties := {
		"_skin_state_rising": {
			default_value = &"rising",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_ENUM,
			hint_string = \
					'ExternalEnum{"property": "_skin", "property_name": "_animation_list"}'
		},
		"_skin_state_falling": {
			default_value = &"falling",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_ENUM,
			hint_string = \
					'ExternalEnum{"property": "_skin", "property_name": "_animation_list"}'
		},
		"_can_attack": {
			default_value = true,
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_NONE,
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
	
	if _can_attack:
		custom_properties["_path_air_attack"] = {
				default_value = "Air/Jump/Attack",
				type = TYPE_STRING,
				usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
				hint = PROPERTY_HINT_NONE,
				hint_string = QuiverState.HINT_STATE_LIST,
		}
	
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
