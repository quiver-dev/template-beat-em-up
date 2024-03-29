@tool
class_name QuiverActionAttack
extends QuiverCharacterAction

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _skin_state: StringName

var _can_combo := true:
	set(value):
		var has_changed = value != _can_combo
		_can_combo = value
		if has_changed:
			notify_property_list_changed()
		
		if not _can_combo:
			_path_combo_state = ""
		else:
			update_configuration_warnings()

var _path_combo_state := "":
	set(value):
		if _can_combo:
			_path_combo_state = value
		else:
			_path_combo_state = ""
		update_configuration_warnings()
	
var _path_next_state := "Ground/Move/Idle"
var _should_enter_parent := true
var _should_exit_parent := true
var _should_process_parent := true

var _should_combo := false
var _auto_combo_amount := 0

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


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	
	if _can_combo and _path_combo_state.is_empty():
		warnings.append("You must select a combo state when _can_combo is true.")
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	if _should_enter_parent:
		get_parent().enter(msg)
	
	if msg.has("auto_combo") and msg.auto_combo > 0 and _can_combo:
		_should_combo = true
		_auto_combo_amount = msg.auto_combo
	else:
		_should_combo = false
		_state_machine.set_process_unhandled_input(_can_combo)
	
	_skin.transition_to(_skin_state)


func unhandled_input(event: InputEvent) -> void:
	if not _can_combo:
		return
	
	if event.is_action_pressed("attack"):
		attack()


func physics_process(delta: float) -> void:
	if _should_process_parent:
		get_parent().physics_process(delta)
	
	if _movement_is_enabled:
		if not _movement_direction.is_equal_approx(Vector2.ZERO):
			_character.velocity = _movement_direction * _movement_speed
		
		_character.move_and_slide()


func exit() -> void:
	_auto_combo_amount = 0
	if _movement_is_enabled:
		_disable_movement()
	
	_state_machine.set_process_unhandled_input(true)
	super()
	if _should_exit_parent:
		get_parent().exit()


func attack() -> void:
	_should_combo = true

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
	
	if _can_combo:
		QuiverEditorHelper.connect_between(
				_skin.attack_input_frames_finished, _on_attack_input_frames_finished
		)
	
	QuiverEditorHelper.connect_between(
			_skin.attack_movement_started, _on_skin_attack_movement_started
	)
	QuiverEditorHelper.connect_between(
			_skin.attack_movement_ended, _on_skin_attack_movement_ended
	)
	QuiverEditorHelper.connect_between(_skin.skin_animation_finished, _on_skin_animation_finished)


func _disconnect_signals() -> void:
	get_parent()._disconnect_signals()
	super()
	if _skin != null:
		QuiverEditorHelper.disconnect_between(
				_skin.attack_input_frames_finished, _on_attack_input_frames_finished
		)
		
		QuiverEditorHelper.disconnect_between(
				_skin.attack_movement_started, _on_skin_attack_movement_started
		)
		QuiverEditorHelper.disconnect_between(
				_skin.attack_movement_ended, _on_skin_attack_movement_ended
		)
		
		QuiverEditorHelper.disconnect_between(
				_skin.skin_animation_finished, _on_skin_animation_finished
		)


func _on_attack_input_frames_finished() -> void:
	_state_machine.set_process_unhandled_input(false)
	if _should_combo:
		_auto_combo_amount -= 1
		if _auto_combo_amount > 0:
			_state_machine.transition_to(_path_combo_state, {auto_combo = _auto_combo_amount})
		else:
			_state_machine.transition_to(_path_combo_state)


func _on_skin_attack_movement_started(p_direction: Vector2, p_speed: float) -> void:
	_movement_direction = p_direction
	_movement_speed = p_speed
	_movement_is_enabled = true


func _on_skin_attack_movement_ended() -> void:
	_disable_movement()


## Connect the signal that marks the end of the attack to this function.
func _on_skin_animation_finished() -> void:
	_state_machine.transition_to(_path_next_state)

### -----------------------------------------------------------------------------------------------
#
###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

func _get_custom_properties() -> Dictionary:
	var custom_properties := {
		"_skin_state": {
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_ENUM,
			hint_string = \
					'ExternalEnum{"property": "_skin", "property_name": "_animation_list"}'
		},
		"_can_combo": {
			default_value = true,
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_NONE,
		},
		"_path_combo_state": {
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_NONE,
			hint_string = QuiverState.HINT_ATTACK_STATE_LIST,
		},
		"_path_next_state": {
			default_value = "Ground/Move/Idle",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_NONE,
			hint_string = QuiverState.HINT_STATE_LIST,
		},
		"Parent State Settings":{
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_GROUP,
			hint = PROPERTY_HINT_NONE,
			hint_string = "parent_"
		},
		"parent_should_enter": {
			backing_field = "_should_enter_parent",
			default_value = true,
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_NONE,
		},
		"parent_should_exit": {
			backing_field = "_should_exit_parent",
			default_value = true,
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_NONE,
		},
		"parent_should_process": {
			backing_field = "_should_process_parent",
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
	
	if not _can_combo:
		custom_properties.erase("_path_combo_state")
	
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
