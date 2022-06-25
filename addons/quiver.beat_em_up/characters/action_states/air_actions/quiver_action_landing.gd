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

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

@export var _skin_state: int = -1
@export var _path_idle := "Ground/Move/Idle"
@export var _path_walk := "Ground/Move/Walk"

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
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	_skin.transition_to(_skin_state)
	_state_machine.set_physics_process(false)


func exit() -> void:
	super()
	_state_machine.set_physics_process(true)
	_air_state.exit()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _connect_signals() -> void:
	super()
	
	if not _skin.landing_finished.is_connected(_on_skin_landing_finished):
		_skin.landing_finished.connect(_on_skin_landing_finished)


func _disconnect_signals() -> void:
	super()
	
	if _skin != null:
		if _skin.landing_finished.is_connected(_on_skin_landing_finished):
			_skin.landing_finished.disconnect(_on_skin_landing_finished)


func _on_skin_landing_finished() -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction.is_equal_approx(Vector2.ZERO):
		_state_machine.transition_to(_path_idle)
	else:
		_state_machine.transition_to(_path_walk)

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
	"path_idle": {
		backing_field = "_path_idle",
		type = TYPE_STRING,
		usage = PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_NONE,
		hint_string = QuiverState.HINT_STATE_LIST,
	},
	"path_walk": {
		backing_field = "_path_walk",
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
