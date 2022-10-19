@tool
class_name QuiverFence
extends QuiverSpriteRepeater

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export var pole_texture: Texture2D = null:
	set(value):
		pole_texture = value
		queue_redraw()
@export_range(1, 1, 1, "or_greater") var pole_distance := 1:
	set(value):
		pole_distance = value
		queue_redraw()

#--- private variables - order: export > normal var > onready -------------------------------------

var _draw_position := Vector2.ZERO
var _pole_amount := 1
var _pole_indexes: Array[int] = []

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()
	if not Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)


func _get_configuration_warnings() -> PackedStringArray:
	var msgs := PackedStringArray()
	if is_vertical:
		msgs.append("QuiverFence has no implementation for is_vertical")
	return msgs

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func get_global_rect_on_editor() -> Rect2:
	var rect := Rect2()
	var editor_transform := get_viewport_transform() * get_canvas_transform()
	
	rect.position = editor_transform * (position + offset)
	
	var total_size_x = \
			main_texture.get_size().x * length \
			+ pole_texture.get_size().x * _pole_amount
	var total_separation = separation * (length - 1)
	rect.size = editor_transform.get_scale() * scale * Vector2(
			total_size_x + total_separation,
			main_texture.get_size().y
	)
	
	return rect


func get_global_rect() -> Rect2:
	var rect := Rect2()
	
	rect.position = position + offset
	
	var total_size_x = \
			main_texture.get_size().x * length \
			+ pole_texture.get_size().x * _pole_amount
	var total_separation = separation * (length - 1)
	rect.size = scale * Vector2(
			total_size_x + total_separation,
			main_texture.get_size().y
	)
	
	return rect

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _update_pole_indexes() -> void:
	_pole_amount = max(0, length/pole_distance)
	var count := 1
	_pole_indexes = []
	for _index in _pole_amount:
		_pole_indexes.append(pole_distance * count)
		count += 1


func _draw_main_body() -> void:
	_update_pole_indexes()
	var current_pole := 0
	_draw_position = Vector2(
			offset.x, 
			offset.y
	)
	for index in _texture_sequence.size():
		var texture := _textures[_texture_sequence[index]]
		draw_texture(texture, _draw_position)
		_draw_position.x += (texture.get_size().x + separation)
		
		if _should_draw_pole(index, current_pole):
			draw_texture(pole_texture, _draw_position)
			_draw_position.x += pole_texture.get_size().x
			if current_pole + 1 < _pole_indexes.size():
				current_pole += 1


func _should_draw_pole(index, current_pole) -> bool:
	return (
			pole_texture != null and _pole_indexes.size() > 0 
			and index == _pole_indexes[current_pole]
	)


func _draw_cap_end() -> void:
	if cap_end != null:
		draw_texture(cap_end, _draw_position + cap_end_offset)

### -----------------------------------------------------------------------------------------------
