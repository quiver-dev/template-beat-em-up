@tool
extends PointLight2D

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export var day_cycle_data: DayCycleData

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	_on_twilight_changed()
	QuiverEditorHelper.connect_between(day_cycle_data.twilight_changed, _on_twilight_changed)

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_twilight_changed() -> void:
	enabled = day_cycle_data.twilight_transition >= 0.5
	if enabled:
		var progress := smoothstep(0.5, 1.0, day_cycle_data.twilight_transition)
		energy = progress
	elif energy != 0:
		energy = 0

### -----------------------------------------------------------------------------------------------
