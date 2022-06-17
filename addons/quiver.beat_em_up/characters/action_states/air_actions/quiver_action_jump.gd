@tool
extends QuiverCharacterState

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const AirState = preload(
		"res://addons/quiver.beat_em_up/characters/action_states/quiver_action_air.gd"
)

@export var JUMP_FORCE := -1200

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

@export var _skin_state: int = -1
@export var _can_attack := true:
	set(value):
		var has_changed = value != _can_attack
		_can_attack = value
		if has_changed:
			notify_property_list_changed()
		
		if not _can_attack:
			_path_air_attack = NodePath("")
		else:
			update_configuration_warnings()

@export var _path_air_attack := NodePath("Air/Attack"):
	set(value):
		if _can_attack:
			_path_air_attack = value
		else:
			_path_air_attack = NodePath()
		update_configuration_warnings()

var _air_attack_count := 0

@onready var _air_state := get_parent() as AirState

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
	
	if not get_parent() is AirState:
		warnings.append(
				"This ActionState must be a child of Action AirState or a state " 
				+ "inheriting from it."
		)
	
	if _can_attack and _path_air_attack.is_empty():
		warnings.append("You must select an attack state when _can_attack is true.")
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	_air_state.enter(msg)
	
	if not _can_attack:
		_state_machine.set_process_unhandled_input(false)
	_skin.transition_to(_skin_state)
	
	if msg.has("velocity"):
		_character.velocity = msg.velocity
	
	if msg.has("air_attack_count"):
		_air_attack_count = msg.air_attack_count
	else:
		_air_attack_count = 0
	
	if msg.has("ignore_jump") and msg.ignore_jump:
		return
	
	_state_machine.set_physics_process(false)
	await get_tree().process_frame
	_character.velocity.y = JUMP_FORCE
	await get_tree().process_frame
	_state_machine.set_physics_process(true)


func unhandled_input(event: InputEvent) -> void:
	if not _can_attack:
		return
	
	if event.is_action_pressed("attack"):
		attack()


func physics_process(delta: float) -> void:
	_air_state.physics_process(delta)


func exit() -> void:
	_air_attack_count = 0
	_state_machine.set_process_unhandled_input(true)
	_air_state.exit()
	super()


func attack() -> void:
	if _has_air_attack():
		_air_attack_count += 1
		_state_machine.transition_to(_path_air_attack)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _has_air_attack() -> bool:
	return _can_attack and _air_attack_count == 0

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

const CUSTOM_PROPERTIES = {
	"skin_state": {
		backing_field = "_skin_state",
		type = TYPE_INT,
		usage = PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_ENUM,
		hint_string = 'ExternalEnum{"property": "_skin", "enum_name": "SkinStates"}'
	},
	"can_attack": {
		backing_field = "_can_attack",
		type = TYPE_BOOL,
		usage = PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_NONE,
	},
	"path_air_attack": {
		backing_field = "_path_air_attack",
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
		
		match key:
			"path_air_attack":
				add_property = _can_attack
		
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
