@tool
class_name SkyBox
extends Sprite2D

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const SCENE_EXTRA := preload("res://stages/_base/skyboxes/extra_texture.tscn")
const DEFAULT_TEXTURE1D = preload("res://stages/stage_01/stage_elements/skyboxes/skybox_default_texture1d.tres")

#--- public variables - order: export > normal var > onready --------------------------------------

@export var is_playing := true:
	set(value):
		is_playing = value
		
		if is_inside_tree() and (not Engine.is_editor_hint() or get_tree().edited_scene_root == self):
			if is_playing:
				play_animations()
			else:
				stop_animations()

#--- private variables - order: export > normal var > onready -------------------------------------

@export var gradient_transitions_array : Array[GradientTransitioner]

@export var _extra_textures: Array[Texture2D]:
	set(value):
		_extra_textures = value
		if is_inside_tree():
			_reset_extra_nodes()

## Dictionary in the format of { texture_resource_uid: SkyBoxExtraTextureData }
var _extra_textures_data: Dictionary = {}

var _tween: Tween
var _all_clouds: Array[Sprite2D] = []
var _shader_gradient: Gradient = null

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	_restore_shader_params()
	QuiverEditorHelper.connect_between(item_rect_changed, _resize_all_extra_nodes)
	
	_reset_extra_nodes()
	_setup_all_gradient_transitioners()
	
	if is_playing and (not Engine.is_editor_hint() or get_tree().edited_scene_root == self):
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
	_play_gradients()


func _play_gradients() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween().set_loops()
	
	var delay := gradient_transitions_array.back().duration as float
	for data in gradient_transitions_array:
		var transition_data := data as GradientTransitioner
		@warning_ignore("return_value_discarded")
		_tween.tween_callback(transition_data.animate_gradient).set_delay(delay)
		delay = transition_data.duration


func stop_animations() -> void:
	set_process(false)
	_reset_clouds()
	gradient_transitions_array[0].reset_transition()
	if _tween:
		_tween.kill()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

# TODO: REMOVE ME Shader hack
## This is a hack that for some reason is needed in the exported version because of a bug where 
## all values from shader parameters loaded from tscns are lost, even though when running from 
## the editor everything is fine.
func _restore_shader_params() -> void:
	var shader_material = (material as ShaderMaterial)
	var texture_1D := DEFAULT_TEXTURE1D.duplicate(true)
	shader_material.set_shader_parameter("gradient", texture_1D)
	shader_material.set_shader_parameter("is_active", true)
	shader_material.set_shader_parameter("show_grayscale", false)
	
	_shader_gradient = texture_1D.gradient as Gradient


func _reset_extra_nodes() -> void:
	if not is_inside_tree():
		await ready
	
	for child in get_children():
		if child.scene_file_path == SCENE_EXTRA.resource_path:
			child.queue_free()
	
	var found_uids: Array[int] = []
	_all_clouds = []
	for e_texture in _extra_textures:
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
		var success := _extra_textures_data.erase(key)
		if not success:
			push_error("Failed to remove key %s from data: %s"%[key, _extra_textures_data])


func _is_deleted_extra_texture(uid: int, found_uids: Array[int]) -> bool:
	return not uid in found_uids


func _resize_all_extra_nodes() -> void:
	for child in get_children():
		if child.scene_file_path == SCENE_EXTRA.resource_path:
			var extra_sprite := child as Sprite2D
			extra_sprite.region_rect = region_rect


func _reset_clouds() -> void:
	if _all_clouds.any(_is_invalid_node):
		return
	
	for value in _extra_textures_data.values():
		var extra_data := value as SkyBoxExtraTextureData
		extra_data.reset_sprite_region()


func _is_invalid_node(node: Node) -> bool:
	return not is_instance_valid(node)


func _setup_all_gradient_transitioners() -> void:
	for data in gradient_transitions_array:
		var transition_data := data as GradientTransitioner
		transition_data.setup_transitioner(_shader_gradient, self)

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

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

func _get_custom_properties() -> Dictionary:
	var properties := {}
	properties["extra_textures_data"] = {
			backing_field = "_extra_textures_data",
			type = TYPE_ARRAY,
			usage = PROPERTY_USAGE_STORAGE,
			hint = PROPERTY_HINT_NONE,
			hint_string = "",
	}
	_resgister_extra_textures_properties(properties)
	
	return properties


func _is_exported_variable(prop_dict: Dictionary) -> bool:
	var is_property_dict := prop_dict.has("usage") and prop_dict.has("hint")
	var has_script_flag := \
			QuiverBitwiseHelper.has_flag_on(PROPERTY_USAGE_SCRIPT_VARIABLE, prop_dict.usage)
	var is_not_private := prop_dict.hint > 0 as bool
	return is_property_dict and has_script_flag and is_not_private


func _resgister_extra_textures_properties(properties: Dictionary) -> void:
	var extra_textures_properties: Array = \
		SkyBoxExtraTextureData.new().get_property_list().filter(_is_exported_variable)
	if not _extra_textures_data.is_empty():
		for index in _extra_textures.size():
			var uid := ResourceLoader.get_resource_uid(_extra_textures[index].resource_path)
			
			for p_index in extra_textures_properties.size():
				var prop_dict := extra_textures_properties[p_index].duplicate() as Dictionary
				var property_name := prop_dict.name as String
				var new_key = "extra_textures_data/%s/%s"%[index, property_name]
				prop_dict["name"] = new_key
				prop_dict["usage"] = PROPERTY_USAGE_EDITOR
				prop_dict["get_callable"] = \
						_get_dict_sub_property.bind(_extra_textures_data, uid, property_name)
				prop_dict["set_callable"] = \
						_set_dict_sub_property.bind(_extra_textures_data, uid, property_name)
				properties[new_key] = prop_dict


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
