@tool
class_name QuiverSpriteRepeater
extends Node2D

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------
@export var is_vertical := false:
	set(value):
		is_vertical = value
		update_configuration_warnings()
@export var main_texture: Texture2D = null:
	set(value):
		main_texture = value
		queue_redraw()
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

@export_group("Cap Textures", "cap_")
@export var cap_begin: Texture2D = null:
	set(value):
		cap_begin = value
		queue_redraw()
@export var cap_begin_offset := Vector2.ZERO:
	set(value):
		cap_begin_offset = value
		queue_redraw()
@export var cap_end: Texture2D = null:
	set(value):
		cap_end = value
		queue_redraw()
@export var cap_end_offset := Vector2.ZERO:
	set(value):
		cap_end_offset = value
		queue_redraw()

@export_group("Texture Variations", "variation_")
@export var variation_textures: Array[Texture2D]:
	set(value):
		variation_textures = value
		if _textures.is_empty() or _textures.size() != variation_textures.size() + 1:
			_update_textures()
			var old_size := _variations_weights.size()
			var new_size := _textures.size()
			_variations_weights.resize(new_size)
			if new_size > old_size:
				for index in range(old_size, new_size):
					_variations_weights[index] = 1.0
		
		_create_random_sequence()
		notify_property_list_changed()
		queue_redraw()

#--- private variables - order: export > normal var > onready -------------------------------------

var _variations_weights: Array[float] = []
var _textures: Array[Texture2D] = []
var _texture_sequence: Array[int] = []

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	if not Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)


func _draw() -> void:
	_update_textures()
	_draw_cap_begin()
	_draw_main_body()
	_draw_cap_end()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func get_global_rect_on_editor() -> Rect2:
	var rect := get_global_rect()
	var editor_transform := get_viewport_transform() * get_canvas_transform()
	rect.position = editor_transform * rect.position
	rect.size = editor_transform.get_scale() * rect.size
	return rect


func get_global_rect() -> Rect2:
	var rect := Rect2()
	
	rect.position = global_position + offset
	
	var total_separation = separation * (length - 1)
	var total_size := main_texture.get_size()
	if is_vertical:
		total_size.y = total_size.y * length + total_separation
	else:
		total_size.x = total_size.x * length + total_separation
	
	rect.size = global_scale * total_size
	
	return rect

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _update_textures() -> void:
	_textures = [main_texture]
	_textures.append_array(variation_textures)


func _draw_cap_begin() -> void:
	if cap_begin != null:
		draw_texture(cap_begin, offset + cap_begin_offset)


func _draw_main_body() -> void:
	for index in _texture_sequence.size():
		var texture := _textures[_texture_sequence[index]]
		var draw_position := offset
		if is_vertical:
			draw_position.y = (texture.get_size().y + separation) * index + offset.y
		else:
			draw_position.x = (texture.get_size().x + separation) * index + offset.x
		
		draw_texture(texture, draw_position)


func _draw_cap_end() -> void:
	if cap_end != null:
		var draw_position := offset + cap_end_offset
		var size := main_texture.get_size()
		if is_vertical:
			draw_position.y = (size.y + separation) * length + offset.y + cap_end_offset.y
		else:
			draw_position.x = (size.x + separation) * length + offset.x + cap_end_offset.x
		
		draw_texture(cap_end, draw_position)


func _create_random_sequence() -> void:
	_texture_sequence.clear()
	for index in length:
		var random_index := QuiverMathHelper.draw_random_weighted_index(_variations_weights)
		_texture_sequence.append(random_index)

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

### Custom Inspector built in functions -----------------------------------------------------------

func _get_property_list() -> Array:
	var properties: = []
	
	properties.append({
		name = "Weight Settings",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_SUBGROUP,
		hint_string = "weight_for_"
	})
	
	for index in _textures.size():
		var sub_name = "main" if index == 0 else str(index - 1)
		properties.append({
			name = "weight_for_%s"%[sub_name],
			type = TYPE_FLOAT,
			usage = PROPERTY_USAGE_EDITOR,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0.01,0.99,0.01" if _textures.size() > 1 else "1.0,1.0,1.0"
		})
	
	properties.append({
		name = "Sequence Overrides",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_SUBGROUP,
		hint_string = "override_for_"
	})
	
	var enum_hint := "Main"
	for index in variation_textures.size():
		enum_hint += ",%s"%[index]
	
	for index in _texture_sequence.size():
		properties.append({
			name = "override_for_%s"%[index],
			type = TYPE_INT,
			usage = PROPERTY_USAGE_EDITOR,
			hint = PROPERTY_HINT_ENUM,
			hint_string = enum_hint
		})
	
	properties.append({
		name = "variations_weights",
		type = TYPE_DICTIONARY,
		usage = PROPERTY_USAGE_STORAGE,
	})
	
	properties.append({
		name = "texture_sequence",
		type = TYPE_DICTIONARY,
		usage = PROPERTY_USAGE_STORAGE,
	})
	
	return properties


func _get(property: StringName):
	var value
	
	match property:
		&"variations_weights":
			value = _variations_weights
		&"texture_sequence":
			value = _texture_sequence
		_:
			if (property as String).begins_with("weight_for_"):
				var index := _get_weight_index(property)
				if index < _variations_weights.size():
					value = _variations_weights[index] / _variations_weights.size()
			elif (property as String).begins_with("override_for_"):
				var index := _get_sequence_index(property)
				if index < _texture_sequence.size():
					value = _texture_sequence[index]
	
	return value


func _set(property: StringName, value) -> bool:
	var has_handled: = false
	
	match property:
		&"variations_weights":
			_variations_weights = value
		&"texture_sequence":
			_texture_sequence = value
		_:
			if (property as String).begins_with("weight_for_"):
				var weight_index := _get_weight_index(property)
				if weight_index < _variations_weights.size():
					_variations_weights[weight_index] = value * _variations_weights.size()
					_normalize_weights()
					has_handled = true
			elif (property as String).begins_with("override_for_"):
				var index := _get_sequence_index(property)
				if index < _texture_sequence.size():
					_texture_sequence[index] = value
					queue_redraw()
					has_handled = true
			
	return has_handled


func _get_weight_index(property: String) -> int:
	var value := -1
	
	var sub_property := property.replace("weight_for_", "")
	if sub_property == "main":
		value = 0
	else:
		value = sub_property.to_int() + 1
	
	return value


func _get_sequence_index(property: String) -> int:
	var value := property.replace("override_for_", "").to_int()
	return value

### -----------------------------------------------------------------------------------------------

### Custom Inspector Private Methods --------------------------------------------------------------

func _normalize_weights() -> void:
	if _variations_weights.is_empty():
		return
	
	var max_weight := float(_variations_weights.size())
	var callable := Callable(QuiverMathHelper, "sum_array")
	var actual_weight := _variations_weights.reduce(callable) as float
	for index in _variations_weights.size():
		_variations_weights[index] = _variations_weights[index] / actual_weight * max_weight
	
	_create_random_sequence()
	queue_redraw()

### -----------------------------------------------------------------------------------------------
