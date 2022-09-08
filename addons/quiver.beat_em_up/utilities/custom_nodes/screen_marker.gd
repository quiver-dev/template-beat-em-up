@tool
extends Control

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export var preview_radius := 25.0:
	set(value):
		preview_radius = value
		queue_redraw()

@export var preview_color := Color.CYAN:
	set(value):
		preview_color = value
		queue_redraw()

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	if Engine.is_editor_hint():
		show()
	else:
		hide()
	pass


func _draw() -> void:
	if Engine.is_editor_hint():
		draw_circle(Vector2.ZERO, preview_radius, preview_color)

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
