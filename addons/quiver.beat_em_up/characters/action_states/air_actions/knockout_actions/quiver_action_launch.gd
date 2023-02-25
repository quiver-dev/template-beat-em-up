@tool
class_name QuiverActionKnockoutLaunch
extends QuiverCharacterAction

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _skin_state_launch: StringName
var _skin_state_rising: StringName
var _path_next_state := "Air/Knockout/MidAir"
## Value that will be passed to Engine.time_scale on the hit the player dies.
var _death_slowdown_speed := 0.2

@onready var _knockout_state := get_parent() as QuiverActionAirKnockout

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
	
	if not get_parent() is QuiverActionAirKnockout:
		warnings.append(
				"This ActionState must be a child of Action QuiverActionAirKnockout or a state " 
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

func _get_custom_properties() -> Dictionary:
	var custom_properties := {
		"_skin_state_launch": {
			default_value = &"knockout_launch",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_ENUM,
			hint_string = \
					'ExternalEnum{"property": "_skin", "property_name": "_animation_list"}'
		},
		"_skin_state_rising": {
			default_value = &"knockout_rising",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_ENUM,
			hint_string = \
					'ExternalEnum{"property": "_skin", "property_name": "_animation_list"}'
		},
		"_path_next_state": {
			default_value = "Air/Knockout/MidAir",
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
	
	if is_instance_valid(_character) and _character.is_in_group("players"):
		custom_properties["_death_slowdown_speed"] = {
			default_value = 0.2,
			type = TYPE_FLOAT,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0.0,1.0,0.1",
		}
	
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
