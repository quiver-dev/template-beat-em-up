@tool
extends CanvasModulate

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

enum DayTimes {
	DAY,
	SUNSET,
	NIGHT,
}

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

@export var _color_day := Color.WHITE:
	set(value):
		_color_day = value
		color = _color_day
@export var _color_sunset := Color.ORANGE_RED:
	set(value):
		_color_sunset = value
		color = _color_sunset
@export var _color_night := Color.BLUE_VIOLET:
	set(value):
		_color_night = value
		color = _color_night

@export var _preview_time := DayTimes.DAY: set = _set_preview_time

var _day_cycle_data := preload("res://stages/_base/day_cycle_data.tres")

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	_on_twilight_changed()
	_day_cycle_data.twilight_changed.connect(_on_twilight_changed)

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_twilight_changed() -> void:
	if _day_cycle_data.twilight_transition < 0.5:
		var progress := smoothstep(0.0, 0.5, _day_cycle_data.twilight_transition)
		color = _color_day.lerp(_color_sunset, progress)
	else:
		var progress := smoothstep(0.5, 1.0, _day_cycle_data.twilight_transition)
		color = _color_sunset.lerp(_color_night, progress)


func _set_preview_time(value: DayTimes) -> void:
	_preview_time = value
	match _preview_time:
		DayTimes.DAY:
			color = _color_day
		DayTimes.SUNSET:
			color = _color_sunset
		DayTimes.NIGHT:
			color = _color_night
		_:
			push_error("Undefined DayTime: %s"%[_preview_time])

### -----------------------------------------------------------------------------------------------
