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
@onready var _limit_bottom := $ScreenLimits/Bottom as CollisionShape2D

@onready var _collision_limits: Array[CollisionShape2D] = [
	_limit_left,
	_limit_right,
	_limit_bottom,
]

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	_update_collision_limits_length()
	get_viewport().size_changed.connect(_update_collision_limits_length)
	pass


func _process(_delta: float) -> void:
	for limit in _collision_limits:
		var half_collision_width := collision_width * Vector2.ONE /2.0
		var half_size := get_viewport_rect().size / 2.0 + half_collision_width
		var target_position := get_screen_center_position()
		if limit == _limit_left:
			target_position.x = maxf(
					limit_left - half_collision_width.x , target_position.x - half_size.x
			)
		elif limit == _limit_right:
			target_position.x = minf(
					limit_right + half_collision_width.x, target_position.x + half_size.x
			)
		elif limit == _limit_bottom:
			target_position.y = minf(
					limit_bottom + half_collision_width.y, target_position.y + half_size.y
			)
		
		limit.global_position = target_position

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------



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
	
	var rect := get_viewport_rect()
	for limit in _collision_limits:
		if limit == _limit_bottom:
			(limit.shape as RectangleShape2D).size.x = rect.size.x + collision_width
		else:
			(limit.shape as RectangleShape2D).size.x = rect.size.y + collision_width

### -----------------------------------------------------------------------------------------------
