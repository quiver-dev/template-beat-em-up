@tool
extends QuiverAiState

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const ONE_SHOT_TIMER = preload("res://addons/quiver.beat_em_up/utilities/OneShotTimer.tscn")

#--- public variables - order: export > normal var > onready --------------------------------------

@export_range(0.0, 10.0, 0.1, "or_greater") var wait_time := 5.0

#--- private variables - order: export > normal var > onready -------------------------------------

var _wait_timer: Timer

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return
	
	if not has_node("Timer"):
		_wait_timer = ONE_SHOT_TIMER.instantiate()
		add_child(_wait_timer, true)

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	_actions.transition_to("Ground/Move/Idle")
	_wait_timer.start(wait_time)
	QuiverEditorHelper.connect_between(_wait_timer.timeout, _on_wait_timer_timeout)


func exit() -> void:
	super()
	QuiverEditorHelper.disconnect_between(_wait_timer.timeout, _on_wait_timer_timeout)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_wait_timer_timeout() -> void:
	state_finished.emit()

### -----------------------------------------------------------------------------------------------

