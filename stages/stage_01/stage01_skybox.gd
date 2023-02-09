@tool
extends SkyBox

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export var day_cycle_data: DayCycleData

#--- private variables - order: export > normal var > onready -------------------------------------

var _day_to_sunset: GradientTransitioner = null
var _sunset_to_night: GradientTransitioner = null
var _night_to_sunrise: GradientTransitioner = null
var _sunrise_to_day: GradientTransitioner = null

var _tween_twilight: Tween = null

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()
	day_cycle_data.twilight_transition = 0
	_day_to_sunset = gradient_transitions_array[1] as GradientTransitioner
	_sunset_to_night = gradient_transitions_array[2] as GradientTransitioner
	_night_to_sunrise = gradient_transitions_array[4] as GradientTransitioner
	_sunrise_to_day = gradient_transitions_array[5] as GradientTransitioner
	
	
	QuiverEditorHelper.connect_between(
			_day_to_sunset.transition_started,_on_day_to_sunset_started
	)
	QuiverEditorHelper.connect_between(
			_sunset_to_night.transition_started,_on_sunset_to_night_started
	)
	QuiverEditorHelper.connect_between(
			_night_to_sunrise.transition_started,_on_night_to_sunrise_started
	)
	QuiverEditorHelper.connect_between(
			_sunrise_to_day.transition_started,_on_sunrise_to_day_started
	)

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_day_to_sunset_started() -> void:
	if _tween_twilight:
		_tween_twilight.kill()
	_tween_twilight = create_tween()
	day_cycle_data.twilight_transition = 0
	
	@warning_ignore("return_value_discarded")
	_tween_twilight.tween_property(
			day_cycle_data, "twilight_transition", 0.5, _day_to_sunset.duration
	)


func _on_sunset_to_night_started() -> void:
	if _tween_twilight:
		_tween_twilight.kill()
	_tween_twilight = create_tween()
	day_cycle_data.twilight_transition = 0.5
	
	@warning_ignore("return_value_discarded")
	_tween_twilight.tween_property(
			day_cycle_data, "twilight_transition", 1.0, _sunset_to_night.duration
	)


func _on_night_to_sunrise_started() -> void:
	if _tween_twilight:
		_tween_twilight.kill()
	_tween_twilight = create_tween()
	day_cycle_data.twilight_transition = 1.0
	
	@warning_ignore("return_value_discarded")
	_tween_twilight.tween_property(
			day_cycle_data, "twilight_transition", 0.5, _day_to_sunset.duration
	)


func _on_sunrise_to_day_started() -> void:
	if _tween_twilight:
		_tween_twilight.kill()
	_tween_twilight = create_tween()
	day_cycle_data.twilight_transition = 0.5
	@warning_ignore("return_value_discarded")
	_tween_twilight.tween_property(
			day_cycle_data, "twilight_transition", 0.0, _sunset_to_night.duration
	)

### -----------------------------------------------------------------------------------------------
