@tool
extends QuiverCharacterState

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

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
	_character.velocity.y += _gravity * delta


func _has_reached_ground() -> bool:
	return _character.global_position.y >= _attributes.ground_level

### -----------------------------------------------------------------------------------------------
