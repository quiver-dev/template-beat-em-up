@tool
extends QuiverCharacterState

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _dash_skin_state := &"attack_dash_begin"
var _attack_skin_state := &"attack_dash_end"

var _path_next_state := "Ground/Move/IdleAi"

var _movement_is_enabled := false
var _movement_speed := 0.0
var _movement_direction := Vector2.ZERO

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	get_parent().enter(msg)
	super(msg)
	_skin.transition_to(_dash_skin_state)


func physics_process(_delta: float) -> void:
	if _movement_is_enabled:
		if not _movement_direction.is_equal_approx(Vector2.ZERO):
			_character.velocity = _movement_direction * _movement_speed
		
		@warning_ignore("return_value_discarded")
		_character.move_and_slide()


func exit() -> void:
	if _movement_is_enabled:
		_disable_movement()
	super()
	get_parent().exit()


func is_attack_state() -> bool:
	return true

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _disable_movement() -> void:
	_movement_direction = Vector2.ZERO
	_movement_speed = 0.0
	_movement_is_enabled = false
	_character.velocity = Vector2.ZERO


func _connect_signals() -> void:
	get_parent()._connect_signals()
	super()


func _disconnect_signals() -> void:
	get_parent()._disconnect_signals()
	super()


func _on_skin_attack_movement_started(p_direction: Vector2, p_speed: float) -> void:
	_movement_direction = p_direction
	_movement_speed = p_speed
	_movement_is_enabled = true


func _on_skin_attack_movement_ended() -> void:
	_disable_movement()


func _on_skin_animation_finished() -> void:
	_state_machine.transition_to(_path_next_state)


func _on_skin_dash_attack_succeeded() -> void:
	_skin.transition_to(_attack_skin_state)


func _on_skin_dash_attack_failed() -> void:
	_state_machine.transition_to(_path_next_state)

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

func _get_custom_properties() -> Dictionary:
	return {
		"Dash Attack State":{
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_CATEGORY,
			hint = PROPERTY_HINT_NONE,
		},
		"dash_skin_state": {
			backing_field = "_dash_skin_state",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_ENUM,
			hint_string = \
					'ExternalEnum{"property": "_skin", "property_name": "_animation_list"}'
		},
		"attack_skin_state": {
			backing_field = "_attack_skin_state",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_ENUM,
			hint_string = \
					'ExternalEnum{"property": "_skin", "property_name": "_animation_list"}'
		},
		"path_next_state": {
			backing_field = "_path_next_state",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_NONE,
			hint_string = QuiverState.HINT_STATE_LIST,
		},
#		"": {
#			backing_field = "",
#			name = "",
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
		var add_property := true
		var dict: Dictionary = custom_properties[key]
		if not dict.has("name"):
			dict.name = key
		
		if add_property:
			properties.append(dict)
	
	return properties


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
