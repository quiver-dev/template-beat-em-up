@tool
extends QuiverCharacterState

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const MoveState = preload(
		"res://addons/quiver.beat_em_up/characters/action_states/"
		+"ground_actions/quiver_action_move.gd"
)

@export var OFFSET_FROM_TARGET = 230
@export var ARRIVE_RANGE = 10

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

@export var _path_next_state := NodePath("Ground/Move/Idle")

var _target_node: Node2D = null

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
	_skin.transition_to(_skin.SkinStates.WALK)
	
	if not msg.has("target_node") or not msg.target_node is Node2D:
		_state_machine.transition_to(_path_next_state)
		return
	
	_target_node = msg.target_node


func unhandled_input(_event: InputEvent) -> void:
	pass


func physics_process(delta: float) -> void:
	var facing_direction = sign((_target_node.global_position - _character.global_position).x)
	_skin.scale.x = 1 if facing_direction >=0 else -1
	
	var target_position := _target_node.global_position
	if _target_node is QuiverCharacter:
		if _target_node.is_on_air:
			target_position.y = _target_node.ground_level
	
	if _character.global_position.x >= target_position.x:
		target_position += Vector2.RIGHT * OFFSET_FROM_TARGET
	else:
		target_position += Vector2.LEFT * OFFSET_FROM_TARGET
	
	_move_state._direction = _character.global_position.direction_to(target_position)
	var distance_to_target := _character.global_position.distance_squared_to(target_position)
	
	if distance_to_target <= _squared_arrive:
		_state_machine.transition_to(_path_next_state)
		state_finished.emit()
		return
	
	_move_state.physics_process(delta)


func exit() -> void:
	super()
	_move_state.exit()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

const CUSTOM_PROPERTIES = {
	"path_next_state": {
		backing_field = "_path_next_state",
		type = TYPE_NODE_PATH,
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

