@tool
class_name SkyBox
extends Sprite2D

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const SCENE_EXTRA := preload("res://stages/_base/skyboxes/extra_texture.tscn")

#--- public variables - order: export > normal var > onready --------------------------------------

@export var is_playing := true:
	set(value):
		is_playing = value
		
		if is_inside_tree():
			if is_playing:
				play_animations()
			else:
				stop_animations()

#--- private variables - order: export > normal var > onready -------------------------------------

# TODO: REMOVE ME
# This is a "hack" because adding setters to Array[Texture2D] is broken 
# https://github.com/godotengine/godot/issues/58285
# I can't make this typed due to the bug above, so I'm exporting it with advanced exports
# and making the inspector accept only Textures2D but the Array itself accepts anything
var _extra_textures: Array:
	set(value):
		_extra_textures = value
		if is_inside_tree():
			_reset_extra_nodes()

var _extra_textures_data: Dictionary = {}
@export var _gradients: Array[Gradient]

var _tween_main: Tween
var _tween_motion: Tween
var _tween_colors: Tween

var _shader_gradient := material.get_shader_parameter("gradient").gradient as Gradient

var _all_clouds: Array[Sprite2D] = []

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
#	if Engine.is_editor_hint():
#		QuiverEditorHelper.disable_all_processing(self)
#		return
	
	for dict in get_property_list():
		if dict.name == "test_data":
			print(JSON.stringify(dict, "\t"))
	_reset_extra_nodes()
	
	if is_playing:
		play_animations()
	else:
		stop_animations()


func _process(delta: float) -> void:
	if _all_clouds.any(_is_invalid_node):
		return
	
	for value in _extra_textures_data.values():
		var extra_data := value as SkyBoxExtraTextureData
		extra_data.move_sprite_region(delta)

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func play_animations() -> void:
	set_process(true)
	_reset_clouds()
	_reset_colors_to(0)
	
	if _tween_main:
		_tween_main.kill()
	_tween_main = create_tween()
	
	for index in _gradients.size():
		var next_index := mini(index + 1, _gradients.size() - 1)
		if next_index > index:
			_tween_main.tween_callback(
					_animate_gradients.bind(_gradients[index], _gradients[next_index], 1.0)
			).set_delay(1.0)


func stop_animations() -> void:
	set_process(false)
	_reset_clouds()
	_reset_colors_to(0)
	if _tween_main:
		_tween_main.kill()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

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


func _reset_extra_nodes() -> void:
	if not is_inside_tree():
		await ready
	
	for child in get_children():
		if child.scene_file_path == SCENE_EXTRA.resource_path:
			child.queue_free()
	
	var found_uids: Array[int] = []
	_all_clouds = []
	for e_texture in _extra_textures:
		if not e_texture is Texture2D:
			continue
		
		var uid := ResourceLoader.get_resource_uid(e_texture.resource_path)
		found_uids.append(uid)
		if not _extra_textures_data.has(uid):
			_extra_textures_data[uid] = SkyBoxExtraTextureData.new()
		_add_extra_texture_node(e_texture, uid)
	
	_clear_unused_data(found_uids)
	notify_property_list_changed()


func _add_extra_texture_node(p_texture: Texture2D, uid: int) -> void:
	var node := SCENE_EXTRA.instantiate() as Sprite2D
	node.texture = p_texture
	node.region_rect = region_rect
	node.name = str(uid)
	add_child(node, true)
	_all_clouds.append(node)
	
	var extra_data := _extra_textures_data[uid] as SkyBoxExtraTextureData
	extra_data.sprite = node
	QuiverEditorHelper.connect_between(extra_data.speed_changed, _reset_clouds)


func _clear_unused_data(found_uids: Array[int]) -> void:
	var uids := _extra_textures_data.keys()
	var unused_data_uid := uids.filter(_is_deleted_extra_texture.bind(found_uids))
	for key in unused_data_uid:
		_extra_textures_data.erase(key)


func _is_deleted_extra_texture(uid: int, found_uids: Array[int]) -> bool:
	return not uid in found_uids


func _reset_clouds() -> void:
	if _all_clouds.any(_is_invalid_node):
		return
	
	for value in _extra_textures_data.values():
		var extra_data := value as SkyBoxExtraTextureData
		extra_data.reset_sprite_region()


func _reset_colors_to(p_index: int) -> void:
	if p_index >= _gradients.size():
		push_error("invalid gradient index: %s | gradients size: %s"%[p_index, _gradients.size()])
		return
	
	var gradient := _gradients[p_index] as Gradient
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

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

func _get_custom_properties() -> Dictionary:
	var properties := {
		"extra_textures": {
			backing_field = "_extra_textures",
			type = TYPE_ARRAY,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_TYPE_STRING,
			hint_string = "%s/%s:Texture2D"%[TYPE_OBJECT, PROPERTY_HINT_RESOURCE_TYPE],
		},
		"extra_textures_data": {
			backing_field = "_extra_textures_data",
			type = TYPE_ARRAY,
			usage = PROPERTY_USAGE_STORAGE,
			hint = PROPERTY_HINT_NONE,
			hint_string = "",
		},
#		"": {
#			backing_field = "",
#			name = "",
#			type = TYPE_NIL,
#			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
#			hint = PROPERTY_HINT_NONE,
#			hint_string = "",
#		},
	}
	
	if not _extra_textures_data.is_empty():
		for index in _extra_textures.size():
			var uid := ResourceLoader.get_resource_uid(_extra_textures[index].resource_path)
			var extra_data := _extra_textures_data[uid] as SkyBoxExtraTextureData
			var sub_properties := extra_data._get_custom_properties() as Dictionary
			
			for key in sub_properties:
				var new_key = "extra_textures_data/%s/%s"%[index, key]
				var sub_dict := sub_properties[key] as Dictionary
				sub_dict["usage"] = PROPERTY_USAGE_EDITOR
				sub_dict["get_callable"] = \
						_get_dict_sub_property.bind(_extra_textures_data, uid, key)
				sub_dict["set_callable"] = \
						_set_dict_sub_property.bind(_extra_textures_data, uid, key)
				sub_dict.erase("backing_field")
				properties[new_key] = sub_dict
		
	return properties

### Custom Inspector built in functions -----------------------------------------------------------

func _get_property_list() -> Array:
	var properties: = []
	
	var custom_properties := _get_custom_properties()
	for key in custom_properties:
		var add_property := true
		var dict: Dictionary = custom_properties[key]
		if not dict.has("name"):
			dict.name = key
		
		if add_property:
			properties.append(dict)
	
	return properties


func _get(property: StringName):
	var value
	
	var custom_properties := _get_custom_properties()
	if property in custom_properties: 
		if custom_properties[property].has("backing_field"):
			value = get(custom_properties[property]["backing_field"])
		elif custom_properties[property].has("get_callable"):
			value = custom_properties[property]["get_callable"].call()
	
	return value


func _set(property: StringName, value) -> bool:
	var has_handled: = false
	
	var custom_properties := _get_custom_properties()
	if property in custom_properties: 
		if custom_properties[property].has("backing_field"):
			set(custom_properties[property]["backing_field"], value)
			has_handled = true
		elif custom_properties[property].has("set_callable"):
			custom_properties[property]["set_callable"].call(value)
			has_handled = true
	
	return has_handled

### -----------------------------------------------------------------------------------------------

### Custom Inspector private functions ------------------------------------------------------------

func _set_dict_sub_property(
		value: Variant, dict: Dictionary, key: Variant, property: StringName
) -> void:
	dict[key][property] = value


func _get_dict_sub_property(
		dict: Dictionary, key: Variant, property: StringName
) -> Variant:
	var value = dict[key][property]
	return value

### -----------------------------------------------------------------------------------------------
