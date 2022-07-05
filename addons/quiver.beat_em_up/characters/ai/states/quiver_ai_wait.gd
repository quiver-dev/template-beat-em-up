extends QuiverAiState

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export_range(0.0, 10.0, 0.1, "or_greater") var wait_time := 5.0

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

var _wait_timer: SceneTreeTimer

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	_actions.transition_to("Ground/Move/Idle")
	_wait_timer = get_tree().create_timer(wait_time)
	_wait_timer.timeout.connect(_on_wait_timer_timeout)


func exit() -> void:
	super()
	if is_instance_valid(_wait_timer):
		_wait_timer.timeout.disconnect(_on_wait_timer_timeout)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_wait_timer_timeout() -> void:
	state_finished.emit()

### -----------------------------------------------------------------------------------------------

