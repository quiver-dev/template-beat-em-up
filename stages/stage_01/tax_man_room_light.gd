@tool
extends PointLight2D

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

var _day_cycle_data := preload("res://stages/_base/day_cycle_data.tres")

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	_on_twilight_changed()
	_day_cycle_data.twilight_changed.connect(_on_twilight_changed)
	pass

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_twilight_changed() -> void:
	enabled = _day_cycle_data.twilight_transition >= 0.5
	if enabled:
		var progress := smoothstep(0.5, 1.0, _day_cycle_data.twilight_transition)
		energy = progress
	elif energy != 0:
		energy = 0

### -----------------------------------------------------------------------------------------------
