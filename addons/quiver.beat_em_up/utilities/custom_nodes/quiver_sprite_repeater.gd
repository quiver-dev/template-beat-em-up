@tool
class_name QuiverSpriteRepeater
extends Node2D

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

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
@export var cap_left: Texture2D = null:
	set(value):
		cap_left = value
		queue_redraw()
@export var cap_left_offset := Vector2.ZERO:
	set(value):
		cap_left_offset = value
		queue_redraw()
@export var cap_right: Texture2D = null:
	set(value):
		cap_right = value
		queue_redraw()
@export var cap_right_offset := Vector2.ZERO:
	set(value):
		cap_right_offset = value
		queue_redraw()

@export_group("Texture Variations", "variation_")
@export var variation_textures: Array[Texture2D] = []

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
	_textures = [main_texture]
	_textures.append_array(variation_textures)
	
	if _texture_sequence.is_empty() or _texture_sequence.size() != length:
		_create_random_sequence()
		notify_property_list_changed()
	
	_draw_left_cap()
	_draw_main_body()
	_draw_right_cap()


func _process(_delta: float) -> void:
	# This is a "hack" because adding setters to Array[Texture2D] is broken 
	# https://github.com/godotengine/godot/issues/58285
	var should_redraw := false
	
	if _textures.is_empty() or _textures.size() != variation_textures.size() + 1:
		_textures = [main_texture]
		_textures.append_array(variation_textures)
		should_redraw = true
	
	if _variations_weights.size() != _textures.size():
		var old_size := _variations_weights.size()
		var new_size := _textures.size()
		_variations_weights.resize(new_size)
		if new_size > old_size:
			for index in range(old_size, new_size):
				_variations_weights[index] = 1.0
		notify_property_list_changed()
	
	if should_redraw:
		queue_redraw()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func get_rect_on_editor() -> Rect2:
	var rect := Rect2()
	var editor_transform := get_viewport_transform() * get_canvas_transform()
	
	rect.position = editor_transform * (position + offset)
	
	var total_size_x = main_texture.get_size().x * length
	var total_separation = separation * (length - 1)
	rect.size = editor_transform.get_scale() * scale * Vector2(
			total_size_x + total_separation,
			main_texture.get_size().y
	)
	
	return rect


func get_rect() -> Rect2:
	var rect := Rect2()
	
	rect.position = position + offset
	
	var total_size_x = main_texture.get_size().x * length
	var total_separation = separation * (length - 1)
	rect.size = scale * Vector2(
			total_size_x + total_separation,
			main_texture.get_size().y
	)
	
	return rect

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _draw_left_cap() -> void:
	if cap_left != null:
		draw_texture(cap_left, offset + cap_left_offset)


func _draw_main_body() -> void:
	for index in _texture_sequence.size():
		var texture := _textures[_texture_sequence[index]]
		var draw_position = Vector2(
				(texture.get_size().x + separation) * index + offset.x, 
				offset.y
		)
		
		draw_texture(texture, draw_position)


func _draw_right_cap() -> void:
	if cap_right != null:
		var draw_position = Vector2(
				(main_texture.get_size().x + separation) * length + offset.x + cap_right_offset.x, 
				offset.y + cap_right_offset.y
		)
		draw_texture(cap_right, draw_position)


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
			if _variations_weights.size() != _textures.size():
				_variations_weights.resize(_textures.size())
				_variations_weights.fill(1.0)
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
