@tool
class_name QuiverActionGroundMove
extends QuiverCharacterAction

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _path_jump_state := "Air/Jump/Impulse"
var _path_attack_state := "Ground/Combo1"

var _direction := Vector2.ZERO

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
		warnings.append(
				"This ActionState must be a child of Action QuiverActionGround or a state " 
				+ "inheriting from it."
		)
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	get_parent().enter(msg)
	_attributes.reset_knockback()
	
	if msg.has("velocity"):
		_character.velocity = msg.velocity
		_direction = Vector2(msg.velocity.x, 0).normalized()
	else:
		_character.velocity = _attributes.speed_max * _direction


func unhandled_input(event: InputEvent) -> void:
	var has_handled := true
	
	if event.is_action_pressed("attack"):
		attack()
	elif event.is_action_pressed("jump"):
		jump()
	else:
		has_handled = false
	
	if not has_handled:
		get_parent().unhandled_input(event)


func physics_process(delta: float) -> void:
	get_parent().physics_process(delta)
	
	if not _direction.is_equal_approx(Vector2.ZERO):
		_character.velocity = _attributes.speed_max * _direction
	else:
		_character.velocity = _character.velocity.move_toward(Vector2.ZERO, _attributes.speed_max)
	
	_character.move_and_slide()


func exit() -> void:
	_direction = Vector2.ZERO
	_character.velocity = Vector2.ZERO
	
	super()
	get_parent().exit()


func attack() -> void:
	_state_machine.transition_to(_path_attack_state)


func jump() -> void:
	if _direction.is_equal_approx(Vector2.ZERO):
		_state_machine.transition_to(_path_jump_state)
	else:
		_state_machine.transition_to(_path_jump_state, {velocity = _character.velocity})

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

func _get_custom_properties() -> Dictionary:
	return {
		"_path_jump_state": {
			default_value = "Air/Jump/Impulse",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_NONE,
			hint_string = QuiverState.HINT_STATE_LIST,
		},
		"_path_attack_state": {
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
