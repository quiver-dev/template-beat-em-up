@tool
extends Sprite2D

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const DEFAULT_TEXTURE1D = preload("res://stages/stage_01/stage_elements/buildings/walls/brick_wall/brick_wall_default_grayscale1D.tres")
const DEFAULT_GRADIENT = preload("res://stages/stage_01/stage_elements/buildings/walls/brick_wall/brick_wall_default_gradient.tres")

#--- public variables - order: export > normal var > onready --------------------------------------

@export var color_darkest: Color = Color.BLACK:
	get:
		return _get_shader_gradient_color_at(0, color_darkest)
	set(value):
		color_darkest = value
		_set_shader_gradient_color_at(0, color_darkest)

@export var color_shadow: Color = Color.DARK_GRAY:
	get:
		return _get_shader_gradient_color_at(1, color_shadow)
	set(value):
		color_shadow = value
		_set_shader_gradient_color_at(1, color_shadow)

@export var color_base: Color = Color.LIGHT_GRAY:
	get:
		return _get_shader_gradient_color_at(2, color_base)
	set(value):
		color_base = value
		_set_shader_gradient_color_at(2, color_base)

@export var color_highlights: Color = Color.WHITE:
	get:
		return _get_shader_gradient_color_at(3, color_highlights)
	set(value):
		color_highlights = value
		_set_shader_gradient_color_at(3, color_highlights)

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	_restore_shader_params()
	pass

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

## This is a hack that for some reason is needed in the exported version because of a bug where 
## all values from shader parameters loaded from tscns are lost, even though when running from 
## the editor everything is fine.
func _restore_shader_params() -> void:
	var shader_material = (material as ShaderMaterial)
	var texture_1D := DEFAULT_TEXTURE1D.duplicate(true)
	var gradient := DEFAULT_GRADIENT.duplicate(true)
	texture_1D.gradient = gradient
	shader_material.set_shader_parameter("gradient", texture_1D)
	shader_material.set_shader_parameter("is_active", true)
	shader_material.set_shader_parameter("show_grayscale", false)
	
	var count := 0
	for color in [color_darkest, color_shadow, color_base, color_highlights]:
		_set_shader_gradient_color_at(count, color)
		count += 1


func _get_shader_gradient_color_at(index: int, fallback_color := Color.BLACK) -> Color:
	var value := fallback_color
	if is_inside_tree():
		var gradient := \
				(material as ShaderMaterial).get_shader_parameter("gradient").gradient as Gradient
		if gradient.get_point_count() != 4:
			push_error("Brick wall's shader gradient must have 4 points.")
		else:
			value = gradient.get_color(index)
		
	return value


func _set_shader_gradient_color_at(index: int, value: Color) -> void:
	if not is_inside_tree():
		await ready
	
	var gradient := \
			(material as ShaderMaterial).get_shader_parameter("gradient").gradient as Gradient
	if gradient.get_point_count() != 4:
		push_error("Brick wall's shader gradient must have 4 points.")
	else:
		gradient.set_color(index, value)

### -----------------------------------------------------------------------------------------------
