class_name QuiverLevelCamera
extends Camera2D

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export_range(0,1,1,"or_greater") var collision_width := 80.0:
	set(value):
		collision_width = value
		_update_collision_limits_width()

#--- private variables - order: export > normal var > onready -------------------------------------

@onready var _limit_left := $ScreenLimits/Left as CollisionShape2D
@onready var _limit_right := $ScreenLimits/Right as CollisionShape2D

@onready var _collision_limits: Array[CollisionShape2D] = [
	_limit_left,
	_limit_right,
]

var _tween: Tween

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	_update_collision_limits_length()
	get_viewport().size_changed.connect(_update_collision_limits_length)
	pass


func _process(_delta: float) -> void:
	for limit in _collision_limits:
		var half_collision_width := collision_width * Vector2.ONE /2.0
		var half_size := get_viewport_rect().size / zoom / 2.0 + half_collision_width
		var target_position := get_screen_center_position()
		if limit == _limit_left:
			target_position.x = minf(
					limit_left - half_collision_width.x , target_position.x - half_size.x
			)
		elif limit == _limit_right:
			target_position.x = maxf(
					limit_right + half_collision_width.x, target_position.x + half_size.x
			)
		
		limit.global_position = target_position
	
	if _tween and _tween.is_running():
		_update_collision_limits_length()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func delimitate_room(
		p_limit_left: int, p_limit_top: int, p_limit_right: int, p_limit_bottom: int,
		p_zoom: float, p_duration: float
) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween().set_parallel().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	
	_tween.tween_property(self, "zoom", Vector2.ONE * p_zoom, p_duration)
	_tween.tween_property(self, "limit_left", p_limit_left, p_duration)
	_tween.tween_property(self, "limit_top", p_limit_top, p_duration)
	_tween.tween_property(self, "limit_right", p_limit_right, p_duration)
	_tween.tween_property(self, "limit_bottom", p_limit_bottom, p_duration)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _update_collision_limits_width() -> void:
	if not is_inside_tree():
		await self.ready
	
	for limit in _collision_limits:
		(limit.shape as RectangleShape2D).size.y = collision_width


func _update_collision_limits_length() -> void:
	if not is_inside_tree():
		await self.ready
	
	var rect_size := get_viewport_rect().size / zoom
	for limit in _collision_limits:
		(limit.shape as RectangleShape2D).size.x = rect_size.y + collision_width

### -----------------------------------------------------------------------------------------------
