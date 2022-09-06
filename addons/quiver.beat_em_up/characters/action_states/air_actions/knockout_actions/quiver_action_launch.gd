@tool
extends QuiverCharacterState

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const KnockoutState = preload(
		"res://addons/quiver.beat_em_up/characters/action_states/air_actions/"
		+ "quiver_action_knockout.gd"
)

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _skin_state_launch: StringName
var _skin_state_rising: StringName
var _path_next_state := "Air/Knockout/MidAir"
## Value that will be passed to Engine.time_scale on the hit the player dies.
var _death_slowdown_speed := 0.2

@onready var _knockout_state := get_parent() as KnockoutState

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
	
	if not get_parent() is KnockoutState:
		warnings.append(
				"This ActionState must be a child of Action KnockoutState or a state " 
				+ "inheriting from it."
		)
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	_knockout_state.enter(msg)
	if _knockout_state._launch_count == 0:
		_skin.transition_to(_skin_state_launch)
	else:
		_skin.transition_to(_skin_state_rising)
	
	if msg.has("launch_vector"):
		_knockout_state._launch_charater(msg.launch_vector)
	elif msg.has("is_wall_bounce") and msg.is_wall_bounce:
		_character.velocity = _character.velocity.reflect(Vector2.UP)
	else:
		assert(false, "No launch vector received on launch state.")
		# The code above will error out in the editor, and the code below will allow the game
		# to at least try to recover from an error scenario, though it will probably launch the
		# enemy in the wrong direction.
		var makeshift_launch_vector := Vector2(1,1).normalized()
		push_error(
				"No launch vector received on launch state. Launching to: %s"
				%[makeshift_launch_vector]
		)
		_knockout_state._launch_charater(makeshift_launch_vector)
	
	_knockout_state._launch_count += 1
	
	if _should_slow_motion():
		Engine.time_scale = _death_slowdown_speed


func physics_process(delta: float) -> void:
	_knockout_state.physics_process(delta)


func exit() -> void:
	super()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _connect_signals() -> void:
	super()
	QuiverEditorHelper.connect_between(_skin.skin_animation_finished, _on_skin_animation_finished)


func _disconnect_signals() -> void:
	super()
	if _skin != null:
		QuiverEditorHelper.disconnect_between(
				_skin.skin_animation_finished, _on_skin_animation_finished
		)


func _should_slow_motion() -> bool:
	var is_player := _character.is_in_group("players")
	var is_normal_time := Engine.time_scale == 1.0 
	var is_dead := _attributes.health_current <= 0
	return is_player and is_dead and is_normal_time


func _on_skin_animation_finished() -> void:
	_state_machine.transition_to(_path_next_state)

### -----------------------------------------------------------------------------------------------


###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

const CUSTOM_PROPERTIES = {
	"Launch State":{
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY,
		hint = PROPERTY_HINT_NONE,
	},
	"skin_state_launch": {
		backing_field = "_skin_state_launch",
		type = TYPE_INT,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_ENUM,
		hint_string = \
				'ExternalEnum{"property": "_skin", "property_name": "_animation_list"}'
	},
	"skin_state_rising": {
		backing_field = "_skin_state_rising",
		type = TYPE_INT,
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
	"death_slowdown_speed": {
		backing_field = "_death_slowdown_speed",
		type = TYPE_FLOAT,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_RANGE,
		hint_string = "0.0,1.0,0.1",
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
		
		if key == "death_slowdown_speed" and not _character.is_in_group("players"):
			add_property = false
		
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
