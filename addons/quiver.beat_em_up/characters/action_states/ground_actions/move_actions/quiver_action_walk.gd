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
	
	if _character.velocity.is_equal_approx(Vector2.ZERO):
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
	
	if _attributes != null:
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

const CUSTOM_PROPERTIES = {
	"Walk State":{
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY,
		hint = PROPERTY_HINT_NONE,
	},
	"walk_skin_state": {
		backing_field = "_walk_skin_state",
		type = TYPE_INT,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_ENUM,
		hint_string = \
				'ExternalEnum{"property": "_skin", "property_name": "_animation_list"}'
	},
	"turn_skin_state": {
		backing_field = "_turn_skin_state",
		type = TYPE_INT,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_ENUM,
		hint_string = \
				'ExternalEnum{"property": "_skin", "property_name": "_animation_list"}'
	},
	"turning_speed_modifier": {
		backing_field = "_turning_speed_modifier",
		type = TYPE_FLOAT,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_RANGE,
		hint_string = "0.1,1,0.01,or_greater"
	},
	"path_idle_state": {
		backing_field = "_path_idle_state",
		type = TYPE_STRING,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_NONE,
		hint_string = QuiverState.HINT_STATE_LIST,
	},
	"path_grabbing_state": {
		backing_field = "_path_grabbing_state",
		type = TYPE_STRING,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
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
