@tool
extends QuiverCharacterState

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const GroundState = preload(
		"res://addons/quiver.beat_em_up/characters/action_states/quiver_action_ground.gd"
)

@export var MAX_SPEED = 600

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

@export var _path_jump_state := NodePath("Air/Jump")
@export var _path_attack_state := NodePath("Ground/Combo1")

var _direction := Vector2.ZERO

@onready var _ground_state := get_parent() as GroundState

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
	
	if not get_parent() is GroundState:
		warnings.append(
				"This ActionState must be a child of Action GroundState or a state " 
				+ "inheriting from it."
		)
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	get_parent().enter(msg)
	if msg.has("velocity"):
		_character.velocity = msg.velocity
		_direction = Vector2(msg.velocity.x, 0).normalized()


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
		_character.velocity = MAX_SPEED * _direction
	else:
		_character.velocity = _character.velocity.move_toward(Vector2.ZERO, MAX_SPEED)
	
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

const CUSTOM_PROPERTIES = {
	"path_jump_state": {
		backing_field = "_path_jump_state",
		type = TYPE_NODE_PATH,
		usage = PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_NONE,
		hint_string = QuiverState.HINT_STATE_LIST,
	},
	"path_attack_state": {
		backing_field = "_path_attack_state",
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
