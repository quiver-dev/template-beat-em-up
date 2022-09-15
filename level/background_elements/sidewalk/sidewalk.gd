@tool
extends Node2D

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export var texture_variations: Array[Texture2D]
@export var offset := Vector2.ZERO:
	set(value):
		offset = value
		queue_redraw()
@export var length := 5:
	set(value):
		length = value
		queue_redraw()

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	pass


func _draw() -> void:
	if texture_variations.size() == 0:
		return

	for index in length:
		var random_index := randi() % texture_variations.size()
		var texture := texture_variations[random_index] as Texture2D
		var draw_position = Vector2((texture.get_size().x + offset.x) * index, offset.y)
		draw_texture(texture, draw_position)
	pass

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
