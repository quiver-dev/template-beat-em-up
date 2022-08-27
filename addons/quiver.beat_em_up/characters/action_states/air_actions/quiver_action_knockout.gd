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

var _path_bounce := "Air/Knockout/Bounce"
var _path_launch := "Air/Knockout/Launch"

var _launch_count := 0

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
	_air_state.enter(msg)


func physics_process(delta: float) -> void:
	_air_state._move_and_apply_gravity(delta)
	if _air_state._has_reached_ground():
		_handle_bounce()


func exit() -> void:
	super()
	_launch_count = 0
	_air_state.exit()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _handle_bounce() -> void:
	_character.global_position.y = _attributes.ground_level
	var bounce_direction = Vector2(
			_character.velocity.x,
			_air_state._skin_velocity_y * -1
	).normalized()
	
	_air_state._skin_velocity_y = 0.0
	_state_machine.transition_to(_path_bounce, {bounce_direction = bounce_direction})


func _launch_charater(launch_vector: Vector2) -> void:
	var knockback_velocity = _attributes.knockback_amount * launch_vector
	_character.velocity.x += knockback_velocity.x
	_air_state._skin_velocity_y += knockback_velocity.y
	_attributes.knockback_amount = 0


func _connect_signals() -> void:
	super()
	
	QuiverEditorHelper.connect_between(_attributes.hurt_requested, _on_hurt_requested)
	QuiverEditorHelper.connect_between(_attributes.knockout_requested, _on_knockout_requested)
	QuiverEditorHelper.connect_between(_attributes.wall_bounced, _on_wall_bounced)

func _disconnect_signals() -> void:
	super()
	
	if _attributes != null:
		QuiverEditorHelper.disconnect_between(_attributes.hurt_requested, _on_hurt_requested)
		QuiverEditorHelper.disconnect_between(
				_attributes.knockout_requested, _on_knockout_requested
		)
		QuiverEditorHelper.disconnect_between(_attributes.wall_bounced, _on_wall_bounced)


func _on_hurt_requested(knockback: QuiverKnockback) -> void:
	# This is here because ANY hit you receive on air generates a knockout.
	_state_machine.transition_to(_path_launch, {launch_vector = knockback.launch_vector})


func _on_knockout_requested(knockback: QuiverKnockback) -> void:
	_state_machine.transition_to(_path_launch, {launch_vector = knockback.launch_vector})


func _on_wall_bounced() -> void:
	_state_machine.transition_to(_path_launch, {is_wall_bounce = true})

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

const CUSTOM_PROPERTIES = {
	"Knockout State":{
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY,
		hint = PROPERTY_HINT_NONE,
	},
	"path_bounce": {
		backing_field = "_path_bounce",
		type = TYPE_STRING,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_NONE,
		hint_string = QuiverState.HINT_STATE_LIST,
	},
	"_path_launch": {
		backing_field = "_path_launch",
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
