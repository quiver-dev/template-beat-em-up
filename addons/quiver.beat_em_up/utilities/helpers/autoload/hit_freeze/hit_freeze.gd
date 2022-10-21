extends Node

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export_range(0, 60, 1, "or_greater" ) var freeze_frames := 3

#--- private variables - order: export > normal var > onready -------------------------------------

var _frames_to_wait := 0

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	set_physics_process(false)
	pass


func _physics_process(_delta: float) -> void:
	_frames_to_wait -= 1
#	print("frames_to_wait: %s"%[_frames_to_wait])
	if _frames_to_wait <= 0:
		get_tree().paused = false
		set_physics_process(false)

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func start(custom_wait := INF) -> void:
	_frames_to_wait = freeze_frames if custom_wait == INF else custom_wait
	if _frames_to_wait > 0:
		get_tree().paused = true
		set_physics_process(true)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
