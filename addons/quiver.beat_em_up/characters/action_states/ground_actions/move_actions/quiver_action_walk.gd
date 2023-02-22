@tool
class_name QuiverActionMoveWalk
extends QuiverCharacterAction

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const MoveState = preload(
		"res://addons/quiver.beat_em_up/characters/action_states/"
		+"ground_actions/quiver_action_move.gd"
)

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _walk_skin_state := &"walk"
var _turn_skin_state := &"turn"
var _path_idle_state := "Ground/Move/Idle"
var _path_grabbing_state := "Ground/Grab/Grabbing"
var _turning_speed_modifier := 0.6

var _is_turning := false

@onready var _move_state := get_parent() as MoveState

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
	
	if not get_parent() is MoveState:
		warnings.append(
				"This ActionState must be a child of Action MoveState or a state " 
				+ "inheriting from it."
		)
	
	return warnings


### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	_move_state._direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	super(msg)
	_move_state.enter(msg)
	_skin.transition_to(_walk_skin_state)
	
	_handle_facing_direction()


func unhandled_input(event: InputEvent) -> void:
	var has_handled := false
	if not has_handled:
		get_parent().unhandled_input(event)


func physics_process(delta: float) -> void:
	_move_state._direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	_handle_facing_direction()
	
	if _is_turning:
		_move_state._direction *= _turning_speed_modifier
	
	_move_state.physics_process(delta)
	
	if _move_state._direction.is_equal_approx(Vector2.ZERO):
		_state_machine.transition_to(_path_idle_state)


func exit() -> void:
	super()
	_move_state.exit()
	_is_turning = false

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _handle_facing_direction() -> void:
	var facing_direction :int = sign(_move_state._direction.x)
	if facing_direction != 0 and facing_direction != _skin.skin_direction:
		_skin.skin_direction = facing_direction
		_skin.transition_to(_turn_skin_state)
		QuiverEditorHelper.connect_between(
				_skin.skin_animation_finished, _on_skin_animation_finished
		)
		_is_turning = true


func _connect_signals() -> void:
	super()
	
	QuiverEditorHelper.connect_between(_attributes.grab_requested, _on_grab_requested)


func _disconnect_signals() -> void:
	super()
	
	if _attributes != null and _state_machine.has_node(_path_grabbing_state):
		QuiverEditorHelper.disconnect_between(_attributes.grab_requested, _on_grab_requested)
	
	if _skin != null:
		QuiverEditorHelper.disconnect_between(
				_skin.skin_animation_finished, _on_skin_animation_finished
		)


func _on_grab_requested(grab_target: QuiverAttributes) -> void:
	_state_machine.transition_to(_path_grabbing_state, {target = grab_target})


func _on_skin_animation_finished() -> void:
	_skin.transition_to(_walk_skin_state)
	_skin.skin_animation_finished.disconnect(_on_skin_animation_finished)
	_is_turning = false

### -----------------------------------------------------------------------------------------------


###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

func _get_custom_properties() -> Dictionary:
	return {
		"_walk_skin_state": {
			default_value = &"walk",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_ENUM,
			hint_string = \
					'ExternalEnum{"property": "_skin", "property_name": "_animation_list"}'
		},
		"_turn_skin_state": {
			default_value = &"turn",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_ENUM,
			hint_string = \
					'ExternalEnum{"property": "_skin", "property_name": "_animation_list"}'
		},
		"_turning_speed_modifier": {
			default_value = 0.6,
			type = TYPE_FLOAT,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0.1,1,0.01,or_greater"
		},
		"_path_idle_state": {
			default_value = "Ground/Move/Idle",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_NONE,
			hint_string = QuiverState.HINT_STATE_LIST,
		},
		"_path_grabbing_state": {
			default_value = "Ground/Grab/Grabbing",
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
