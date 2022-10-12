@tool
extends Node2D

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export var use_banner := true:
	set(value):
		use_banner = value
		if not is_inside_tree():
			await ready
		_banner.visible = use_banner
@export var use_window_covers := true:
	set(value):
		use_window_covers = value
		if not is_inside_tree():
			await ready
		_window_covers.visible = use_window_covers

#--- private variables - order: export > normal var > onready -------------------------------------

@onready var _window_covers := $WindowCovers as Sprite2D
@onready var _banner := $Banner as Sprite2D

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	pass

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
