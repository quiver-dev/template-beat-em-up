@tool
extends Sprite2D

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export var color_darkest: Color:
	get:
		return _get_shader_gradient_color_at(0, Color.BLACK)
	set(value):
		_set_shader_gradient_color_at(0, value)

@export var color_shadow: Color:
	get:
		return _get_shader_gradient_color_at(1, Color.DARK_GRAY)
	set(value):
		_set_shader_gradient_color_at(1, value)

@export var color_base: Color:
	get:
		return _get_shader_gradient_color_at(2, Color.LIGHT_GRAY)
	set(value):
		_set_shader_gradient_color_at(2, value)

@export var color_highlights: Color:
	get:
		return _get_shader_gradient_color_at(3, Color.WHITE)
	set(value):
		_set_shader_gradient_color_at(3, value)

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	pass

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _get_shader_gradient_color_at(index: int, fallback_color := Color.BLACK) -> Color:
	var value := fallback_color
	
	var gradient := \
			(material as ShaderMaterial).get_shader_parameter("gradient").gradient as Gradient
	if gradient.get_point_count() != 4:
		push_error("Brick wall's shader gradient must have 4 points.")
	else:
		value = gradient.get_color(index)
	
	return value


func _set_shader_gradient_color_at(index: int, value: Color) -> void:
	var gradient := \
			(material as ShaderMaterial).get_shader_parameter("gradient").gradient as Gradient
	if gradient.get_point_count() != 4:
		push_error("Brick wall's shader gradient must have 4 points.")
	else:
		gradient.set_color(index, value)

### -----------------------------------------------------------------------------------------------
