@tool
extends SkyBox

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _day_cycle_data := preload("res://stages/_base/day_cycle_data.tres")

var _day_to_sunset: GradientTransitioner = null
var _sunset_to_night: GradientTransitioner = null

var _tween: Tween = null

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()
	_day_to_sunset = _gradient_transitions_data[2] as GradientTransitioner
	_sunset_to_night = _gradient_transitions_data[3] as GradientTransitioner
	
	_day_to_sunset.transition_started.connect(_on_day_to_sunset_started)
	_sunset_to_night.transition_finished.connect(_on_sunset_to_night_started)

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_day_to_sunset_started() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_day_cycle_data.sunset_transition = 0
	_tween.tween_property(_day_cycle_data, "sunset_transition", 0.5, _day_to_sunset.duration)


func _on_sunset_to_night_started() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_day_cycle_data.sunset_transition = 0.5
	_tween.tween_property(_day_cycle_data, "sunset_transition", 1.0, _sunset_to_night.duration)

### -----------------------------------------------------------------------------------------------
