extends Node2D

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

@onready var _animator := $AnimationPlayer as AnimationPlayer

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	pass

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_left_area_body_entered(_body: Node2D) -> void:
	if _animator.assigned_animation == "closed":
		_animator.play("opening")
	else:
		_animator.play("open_player_on_left")


func _on_right_area_body_entered(_body: Node2D) -> void:
	_animator.play("open_player_on_right")

### -----------------------------------------------------------------------------------------------
