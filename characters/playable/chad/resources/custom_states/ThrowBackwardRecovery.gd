@tool
extends QuiverCharacterState

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const GrabState = preload(
		"res://addons/quiver.beat_em_up/characters/action_states/ground_actions/"
		+"quiver_action_grab.gd"
)

@export var SLIDE_IMPULSE := 300
@export var SLIDE_FRICTION := 150

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

@export var _recovery_1: StringName
@export var _recovery_2: StringName
@export var _path_next_state := "Ground/Move/Idle"

var _friction_direction := 1
var _slide_direction := -1

@onready var _grab_state := get_parent() as GrabState

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
	
	if not get_parent() is GrabState:
		warnings.append(
				"This ActionState must be a child of Action GrabState or a state " 
				+ "inheriting from it."
		)
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	_skin.transition_to(_recovery_1)
	_skin.skin_animation_finished.connect(_on_skin_animation_finished.bind(_recovery_1))
	var next_position = _skin.get_suplex_landing_position()
	
	# I Have to wait two frames for the animation to update properly before changing position.
	await  get_tree().process_frame
	await  get_tree().process_frame
	
	_character.global_position = next_position
	_friction_direction = sign(_skin.scale.x)
	_slide_direction = _friction_direction * -1
	_character.velocity.x += SLIDE_IMPULSE * _slide_direction


func physics_process(delta: float) -> void:
	if _character.velocity.x != 0:
		_character.velocity.x = move_toward(
				_character.velocity.x, 0, 
				SLIDE_FRICTION * _friction_direction * delta
		)
		_character.move_and_slide()


func exit() -> void:
	super()
	_grab_state.exit()
	
	_friction_direction = 1
	_slide_direction = -1
	_character.velocity.x = 0
	
	if _skin.skin_animation_finished.is_connected(_on_skin_animation_finished):
		_skin.skin_animation_finished.disconnect(_on_skin_animation_finished)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_skin_animation_finished(phase_finished: StringName) -> void:
	if phase_finished == _recovery_1:
		_skin.transition_to(_recovery_2)
		_skin.skin_animation_finished.disconnect(_on_skin_animation_finished)
		_skin.skin_animation_finished.connect(_on_skin_animation_finished.bind(_recovery_2))
		_character.velocity.x = 0
	elif phase_finished == _recovery_2:
		_skin.skin_animation_finished.disconnect(_on_skin_animation_finished)
		_state_machine.transition_to(_path_next_state)

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

const CUSTOM_PROPERTIES = {
	"recovery_1": {
		backing_field = "_recovery_1",
		type = TYPE_INT,
		usage = PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_ENUM,
		hint_string = \
				'ExternalEnum{"property": "_skin", "property_name": "_animation_list"}'
	},
	"recovery_2": {
		backing_field = "_recovery_2",
		type = TYPE_INT,
		usage = PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_ENUM,
		hint_string = \
				'ExternalEnum{"property": "_skin", "property_name": "_animation_list"}'
	},
	"path_next_state": {
		backing_field = "_path_next_state",
		type = TYPE_STRING,
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
