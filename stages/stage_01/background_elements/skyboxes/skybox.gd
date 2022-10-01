@tool
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
		set_process(value)
		_reset_clouds()

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

var _tween: Tween

@onready var _cloud1 := $Cloud1 as Sprite2D
@onready var _cloud2 := $Cloud2 as Sprite2D
@onready var _cloud3 := $Cloud3 as Sprite2D
@onready var _cloud4 := $Cloud4 as Sprite2D
@onready var _animator := $AnimationPlayer as AnimationPlayer

@onready var _all_clouds := [
		_cloud1,
		_cloud2,
		_cloud3,
		_cloud4,
]

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	set_process(is_playing)
	_reset_clouds()
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

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _move_cloud(cloud: Sprite2D, motion: float) -> void:
	var sprite_width := cloud.texture.get_size().x
	var new_position := cloud.region_rect.position.x + motion
	cloud.region_rect.position.x = fposmod(new_position, sprite_width)


func _reset_clouds() -> void:
	if not is_inside_tree():
		await ready
	
	for cloud in _all_clouds:
		(cloud as Sprite2D).region_rect.position.x = 0


func _is_invalid_node(node: Node) -> bool:
	return not is_instance_valid(node)

### -----------------------------------------------------------------------------------------------
