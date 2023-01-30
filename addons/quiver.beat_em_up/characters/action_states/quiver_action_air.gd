@tool
extends QuiverCharacterAction

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var _fall_modifier: float = \
		ProjectSettings.get_setting(QuiverCyclicHelper.SETTINGS_FALL_GRAVITY_MODIFIER)

# This one is just to help tweak it by using F6
@export_range(0.0,5.0,0.05,"or_greater") var _debug_fall_modifier := 1.0:
	set(value):
		_debug_fall_modifier = value
		ProjectSettings.set_setting(QuiverCyclicHelper.SETTINGS_FALL_GRAVITY_MODIFIER, value)
		if Engine.is_editor_hint():
			ProjectSettings.save()
	get:
		var value := _debug_fall_modifier
		if ProjectSettings.has_setting(QuiverCyclicHelper.SETTINGS_FALL_GRAVITY_MODIFIER):
			value = ProjectSettings.get_setting(QuiverCyclicHelper.SETTINGS_FALL_GRAVITY_MODIFIER)
		return value

var _skin_velocity_y := 0.0

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()
	update_configuration_warnings()
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	_character._disable_ceiling_collisions()


func exit() -> void:
	_character._enable_ceiling_collisions()
	super()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _move_and_apply_gravity(delta: float) -> void:
	_character.move_and_slide()
	_skin.position.y += _skin_velocity_y * delta
	
	var actual_gravity = _gravity if _skin_velocity_y < 0 else _gravity * _fall_modifier
	if QuiverEditorHelper.is_standalone_run(_character):
		actual_gravity = _gravity if _skin_velocity_y < 0 else _gravity * _debug_fall_modifier
	
	_skin_velocity_y += actual_gravity * delta


func _has_reached_ground() -> bool:
	return _skin.position.y >= 0


func _handle_landing(p_path: NodePath) -> void:
	_skin.position.y = 0.0
	_skin_velocity_y = 0.0
	_state_machine.transition_to(p_path)

### -----------------------------------------------------------------------------------------------
