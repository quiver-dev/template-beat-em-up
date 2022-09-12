@tool
extends QuiverCharacterSkin

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

signal suplex_landed
signal sliding_stopped

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

@onready var _suplex_landing := $Positions/SuplexLanding as Marker2D

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		_animation_tree.set_deferred("active", false)
		return

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func get_suplex_landing_position() -> Vector2:
	return _suplex_landing.global_position


func end_of_suplex() -> void:
	suplex_landed.emit()


func end_of_slide() -> void:
	sliding_stopped.emit()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
