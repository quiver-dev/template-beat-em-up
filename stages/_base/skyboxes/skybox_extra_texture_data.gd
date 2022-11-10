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
	PARENT
}

#--- constants ------------------------------------------------------------------------------------

const SHADER_GRADIENT_MAP = preload("res://stages/_base/skyboxes/gradient_map.gdshader")

#--- public variables - order: export > normal var > onready --------------------------------------

var sprite: Sprite2D = null:
	set(value):
		sprite = value
		apply_color_mode_on_sprite(false)

#--- private variables - order: export > normal var > onready -------------------------------------

@export_range(0.0,200.0,0.1,"or_greater") var speed := 0:
	set(value):
		speed = value
		speed_changed.emit()
@export var color_mode := ColorMode.PARENT:
	set(value):
		color_mode = value
		apply_color_mode_on_sprite()

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func move_sprite_region(delta: float) -> void:
	var sprite_width := sprite.texture.get_size().x
	var new_position := sprite.region_rect.position.x + speed * delta
	sprite.region_rect.position.x = fposmod(new_position, sprite_width)


func reset_sprite_region() -> void:
	sprite.region_rect.position.x = 0


func apply_color_mode_on_sprite(should_emit_signal := true) -> void:
	if not is_instance_valid(sprite):
		return
	
	match color_mode:
		ColorMode.NONE:
			sprite.use_parent_material = false
			sprite.material = null
		ColorMode.PARENT:
			sprite.use_parent_material = true
			sprite.material = null
		_:
			should_emit_signal = false
			push_error("Unknown ColorMode: %s"%[color_mode])
	
	if should_emit_signal:
		color_mode_changed.emit()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
