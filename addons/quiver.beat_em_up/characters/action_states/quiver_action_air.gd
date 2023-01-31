@tool
class_name QuiverActionAir
extends QuiverCharacterAction

## Base Action for all Air Actions. Adds useful properties and methods other Air Actions 
## might need.

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

## Shortcut to gravity defined in Project Settings' physics 2d setion.
var _gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
## Shortcut to gravity defined in Project Settings' beat'em up setion.
var _fall_modifier: float = \
		ProjectSettings.get_setting(QuiverCyclicHelper.SETTINGS_FALL_GRAVITY_MODIFIER)

## Exported property that is just to help tweak the fall modifier while the game is running, 
## instead of having to change it in the project setting and run the game again.
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

## When the character jump, it's actually just the "skin" that is jumping, to five an illustion of 
## three dimensions, as the character actually moves like a top down game. This is the velocity of ## the skin's vertical movement.
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

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

## Helper function to move character while in the air.
func _move_and_apply_gravity(delta: float) -> void:
	_character.move_and_slide()
	_skin.position.y += _skin_velocity_y * delta
	
	var actual_gravity = _gravity if _skin_velocity_y < 0 else _gravity * _fall_modifier
	if QuiverEditorHelper.is_standalone_run(_character):
		actual_gravity = _gravity if _skin_velocity_y < 0 else _gravity * _debug_fall_modifier
	
	_skin_velocity_y += actual_gravity * delta


## Helper function to check if the character has reached the ground.
func _has_reached_ground() -> bool:
	return _skin.position.y >= 0


## Helper function for landing.
func _handle_landing(p_path: NodePath) -> void:
	_skin.position.y = 0.0
	_skin_velocity_y = 0.0
	_state_machine.transition_to(p_path)

### -----------------------------------------------------------------------------------------------
