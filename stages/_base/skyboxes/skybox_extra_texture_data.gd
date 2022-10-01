@tool
class_name SkyBoxExtraTextureData
extends Resource
## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

signal speed_changed
signal color_mode_changed

#--- enums ----------------------------------------------------------------------------------------

enum ColorMode {
	NONE,
	PARENT,
	GRADIENT_MAP
}

#--- constants ------------------------------------------------------------------------------------

const SHADER_GRADIENT_MAP = preload("res://stages/_base/skyboxes/gradient_map.gdshader")

#--- public variables - order: export > normal var > onready --------------------------------------

var sprite: Sprite2D = null:
	set(value):
		sprite = value
		apply_color_mode_on_sprite(false)

#--- private variables - order: export > normal var > onready -------------------------------------

var _speed := 0:
	set(value):
		_speed = value
		speed_changed.emit()
var _color_mode := ColorMode.PARENT:
	set(value):
		_color_mode = value
		apply_color_mode_on_sprite()
var _gradient_dict := {}

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func move_sprite_region(delta: float) -> void:
	var sprite_width := sprite.texture.get_size().x
	var new_position := sprite.region_rect.position.x + _speed * delta
	sprite.region_rect.position.x = fposmod(new_position, sprite_width)


func reset_sprite_region() -> void:
	sprite.region_rect.position.x = 0


func apply_color_mode_on_sprite(should_emit_signal := true) -> void:
	if not is_instance_valid(sprite):
		return
	
	match _color_mode:
		ColorMode.NONE:
			sprite.use_parent_material = false
		ColorMode.PARENT:
			sprite.use_parent_material = true
		ColorMode.GRADIENT_MAP:
			sprite.use_parent_material = false
			var new_material := ShaderMaterial.new()
			new_material.shader = SHADER_GRADIENT_MAP
			sprite.material = new_material
		_:
			should_emit_signal = false
			push_error("Unknown ColorMode: %s"%[_color_mode])
	
	if should_emit_signal:
		color_mode_changed.emit()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

func _get_custom_properties() -> Dictionary:
	return {
		"speed": {
			backing_field = "_speed",
			type = TYPE_FLOAT,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0.0,200.0,0.1,or_greater",
		},
		"color_mode": {
			backing_field = "_color_mode",
			type = TYPE_INT,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_ENUM,
			hint_string = ",".join(ColorMode.keys()),
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
	if property in custom_properties and custom_properties[property].has("backing_field"):
		value = get(custom_properties[property]["backing_field"])
	
	return value


func _set(property: StringName, value) -> bool:
	var has_handled: = false
	
	var custom_properties := _get_custom_properties()
	if property in custom_properties and custom_properties[property].has("backing_field"):
		set(custom_properties[property]["backing_field"], value)
		has_handled = true
	
	return has_handled

### -----------------------------------------------------------------------------------------------
