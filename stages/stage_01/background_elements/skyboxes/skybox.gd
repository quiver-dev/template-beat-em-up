extends Sprite2D

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export var is_playing := true:
	set(value):
		is_playing = value
		
		if not is_inside_tree():
			return
		
		if is_playing:
			play_animations()
		else:
			stop_animations()

@export var gradients: Array[Gradient]

@export_range(0.0, 200.0, 0.1, "or_greater") var cloud1_speed := 100.0:
	set(value):
		cloud1_speed = value
		_reset_clouds()
@export_range(0.0, 200.0, 0.1, "or_greater") var cloud2_speed := 100.0:
	set(value):
		cloud2_speed = value
		_reset_clouds()
@export_range(0.0, 200.0, 0.1, "or_greater") var cloud3_speed := 100.0:
	set(value):
		cloud3_speed = value
		_reset_clouds()
@export_range(0.0, 200.0, 0.1, "or_greater") var cloud4_speed := 100.0:
	set(value):
		cloud4_speed = value
		_reset_clouds()

#--- private variables - order: export > normal var > onready -------------------------------------

var _tween_main: Tween
var _tween_motion: Tween
var _tween_colors: Tween

var _shader_gradient := material.get_shader_parameter("gradient").gradient as Gradient

@onready var _cloud1 := $Cloud1 as Sprite2D
@onready var _cloud2 := $Cloud2 as Sprite2D
@onready var _cloud3 := $Cloud3 as Sprite2D
@onready var _cloud4 := $Cloud4 as Sprite2D

@onready var _all_clouds := [
		_cloud1,
		_cloud2,
		_cloud3,
		_cloud4,
]

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	if is_playing:
		play_animations()
	else:
		stop_animations()
	pass


func _process(delta: float) -> void:
	if _all_clouds.any(_is_invalid_node):
		return
	
	var all_speeds := [
			cloud1_speed,
			cloud2_speed,
			cloud3_speed,
			cloud4_speed,
	]
	for index in _all_clouds.size():
		var cloud := _all_clouds[index] as Sprite2D
		var speed := all_speeds[index] as float
		_move_cloud(cloud, speed * delta)

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func play_animations() -> void:
	set_process(true)
	_reset_clouds()
	_reset_colors_to(0)
	
	if _tween_main:
		_tween_main.kill()
	_tween_main = create_tween()
	
	for index in gradients.size():
		var next_index := mini(index + 1, gradients.size() - 1)
		if next_index > index:
			_tween_main.tween_callback(
					_animate_gradients.bind(gradients[index], gradients[next_index], 1.0)
			).set_delay(1.0)


func stop_animations() -> void:
	set_process(false)
	_reset_clouds()
	_reset_colors_to(0)
	if _tween_main:
		_tween_main.kill()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _move_cloud(cloud: Sprite2D, motion: float) -> void:
	var sprite_width := cloud.texture.get_size().x
	var new_position := cloud.region_rect.position.x + motion
	cloud.region_rect.position.x = fposmod(new_position, sprite_width)


func _animate_gradients(gradient1: Gradient, gradient2: Gradient, duration: float) -> void:
	if gradient1.get_point_count() != gradient2.get_point_count():
		push_error(
				"Gradients must have the same amount of points to be animated!"
				+ "Gradient1: %s x Gradient2: %s"%[
						gradient1.get_point_count(), gradient2.get_point_count()
				]
		)
		return
	
	var point_count := gradient1.get_point_count()
	_resize_shader_gradient(point_count)
	
	if _tween_colors:
		_tween_colors.kill()
	_tween_colors = create_tween().set_parallel()
	
	for index in point_count:
		var color_offset1 := gradient1.get_offset(index)
		var color_offset2 := gradient2.get_offset(index)
		var color1 := gradient1.get_color(index)
		var color2 := gradient2.get_color(index)
		_tween_colors.tween_method(
				_animate_gradient_offset.bind(index), color_offset1, color_offset2, duration
		)
		_tween_colors.tween_method(
				_animate_gradient_color.bind(index), color1, color2, duration
		)


func _animate_gradient_offset(p_offset: float, index: int) -> void:
	_shader_gradient.set_offset(index, p_offset)


func _animate_gradient_color(p_color: Color, index: int) -> void:
	_shader_gradient.set_color(index, p_color)


func _reset_clouds() -> void:
	if not is_inside_tree():
		await ready
	
	for cloud in _all_clouds:
		(cloud as Sprite2D).region_rect.position.x = 0


func _reset_colors_to(p_index: int) -> void:
	if p_index >= gradients.size():
		push_error("invalid gradient index: %s | gradients size: %s"%[p_index, gradients.size()])
		return
	
	var gradient := gradients[p_index] as Gradient
	var gradient_points := gradient.get_point_count()
	_resize_shader_gradient(gradient_points)
	
	for index in gradient_points:
		_shader_gradient.set_color(index, gradient.get_color(index))
		_shader_gradient.set_offset(index, gradient.get_offset(index))


func _resize_shader_gradient(p_size) -> void:
	if p_size != _shader_gradient.get_point_count():
		_shader_gradient.offsets.resize(p_size)
		_shader_gradient.colors.resize(p_size)


func _is_invalid_node(node: Node) -> bool:
	return not is_instance_valid(node)

### -----------------------------------------------------------------------------------------------
