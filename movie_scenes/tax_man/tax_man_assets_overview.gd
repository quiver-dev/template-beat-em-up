extends Node2D

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

@onready var _invisible_wall := $Level/InvisibleWall as StaticBody2D
@onready var _camera := $Level/TaxMan/Camera2D as Camera2D

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	ScreenTransitions.fade_out_transition()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func fade_out_movie() -> void:
	await ScreenTransitions.fade_in_transition()
	get_tree().quit()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_dash_attack_state_finished() -> void:
	_invisible_wall.queue_free()


func _on_tax_man_tree_exiting() -> void:
	var backup_positon = _camera.global_position
	_camera.get_parent().remove_child(_camera)
	add_child(_camera)
	_camera.global_position = backup_positon
	pass # Replace with function body.


func _on_tax_man_tree_exited() -> void:
	fade_out_movie()

### -----------------------------------------------------------------------------------------------
