@tool
class_name SpriteRepeater
extends Node2D

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export var main_texture: Texture2D = null
@export var offset := Vector2.ZERO:
	set(value):
		offset = value
		queue_redraw()
@export_range(1,1,1,"or_greater") var length := 1:
	set(value):
		length = value
		queue_redraw()
@export var separation := 0:
	set(value):
		separation = value
		queue_redraw()

@export_group("Texture Variations", "variation_")
@export var variation_textures: Array[Texture2D]

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	pass


func _draw() -> void:
	var texture = main_texture
	
	for index in length:
		var draw_position = Vector2(
				(texture.get_size().x + separation) * index + offset.x, 
				offset.y
		)
		
		draw_texture(texture, draw_position)
	pass

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
