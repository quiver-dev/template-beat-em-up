@tool
class_name QuiverActionMoveFollow
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

@export_category("Arrive Settings")
@export var OFFSET_FROM_TARGET = 230
@export var ARRIVE_RANGE = 10

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _walk_skin_state := &"walk"
var _turn_skin_state := &"turn"
var _turning_speed_modifier := 0.6
var _path_next_state := "Ground/Move/Idle"

var _target_node: Node2D = null
var _fixed_position := Vector2.ONE * INF
var _should_use_fixed := false
var _should_use_only_y := false

var _is_turning := false

@onready var _move_state := get_parent() as MoveState
@onready var _squared_arrive = pow(ARRIVE_RANGE, 2)

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
	super(msg)
	_move_state.enter(msg)
	_skin.transition_to(_walk_skin_state)
	
	if msg.has("use_only_y"):
		_should_use_only_y = msg.use_only_y
	
	if msg.has("target_node"): 
		if msg.target_node is Node2D:
			_target_node = msg.target_node
	elif msg.has("target_position") and msg.target_position is Vector2:
		_target_node = QuiverCharacterHelper.find_closest_player_to(_character)
		_fixed_position = msg.target_position
		_should_use_fixed = true
	else:
		_state_machine.transition_to(_path_next_state)


func unhandled_input(_event: InputEvent) -> void:
	pass


func physics_process(delta: float) -> void:
	_handle_facing_target_node()
	var target_position := _handle_target_position()
	
	_move_state._direction = _character.global_position.direction_to(target_position)
	var distance_to_target := _character.global_position.distance_squared_to(target_position)
	
	var is_in_same_lane := true 
	if not _should_use_fixed and _target_node is QuiverCharacter:
		is_in_same_lane = CombatSystem.is_in_same_lane_as(
				_attributes, _target_node.attributes
		)
	
	if is_in_same_lane and distance_to_target <= _squared_arrive:
		_state_machine.transition_to(_path_next_state)
		state_finished.emit()
		return
	
	if _is_turning:
		_move_state._direction *= _turning_speed_modifier
	
	_move_state.physics_process(delta)


func exit() -> void:
	super()
	_move_state.exit()
	_fixed_position = Vector2.ONE * INF
	_target_node = null
	_should_use_fixed = false
	_should_use_only_y = false
	_is_turning = false

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _disconnect_signals() -> void:
	super()
	
	if _skin != null:
		QuiverEditorHelper.disconnect_between(
				_skin.skin_animation_finished, _on_skin_animation_finished
		)


func _handle_facing_target_node() -> void:
	if not is_instance_valid(_target_node):
		_state_machine.transition_to(_path_next_state)
		return
	
	var facing_direction = sign((_target_node.global_position - _character.global_position).x)
	if facing_direction != 0 and facing_direction != _skin.skin_direction:
		_skin.skin_direction = facing_direction
		_skin.transition_to(_turn_skin_state)
		_skin.skin_animation_finished.connect(_on_skin_animation_finished)
		_is_turning = true


func _handle_target_position() -> Vector2:
	var target_position := _fixed_position if _should_use_fixed else _target_node.global_position
	
	if not _should_use_fixed:
		if _target_node is QuiverCharacter:
			if _target_node.is_on_air:
				target_position.y = _attributes.ground_level
		
			if _character.global_position.x >= target_position.x:
				target_position += Vector2.RIGHT * OFFSET_FROM_TARGET
			else:
				target_position += Vector2.LEFT * OFFSET_FROM_TARGET
	
	if _should_use_only_y:
		target_position.x = _character.global_position.x
	
	return target_position


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
		"_path_next_state": {
			default_value = "Ground/Move/Idle",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_NONE,
			hint_string = QuiverState.HINT_STATE_LIST,
		},
		"_turning_speed_modifier": {
			default_value = 0.6,
			type = TYPE_FLOAT,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0.1,1,0.01,or_greater"
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
