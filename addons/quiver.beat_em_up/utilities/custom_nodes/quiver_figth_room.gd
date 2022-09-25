@tool
class_name QuiverFightRoom
extends ReferenceRect

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export_group("Fight Room")
@export var limit_left := 0: set = _set_limit_left
@export var limit_top := 0: set = _set_limit_top
@export var limit_right := 0: set = _set_limit_right
@export var limit_bottom := 0

@export_range(0.1, 3.0, 0.01, "or_greater") var zoom := 1.0:
	set(value):
		zoom = value
		queue_redraw()
@export_range(0.0, 3.0, 0.01, "or_greater") var zoom_duration := 0.3

var after_fight_use_new_room := false:
	set(value):
		after_fight_use_new_room = value
		if after_fight_use_new_room:
			_reset_after_room_limits()
		notify_property_list_changed()
		queue_redraw()
var after_fight_limit_left := 0:
	set(value):
		after_fight_limit_left = value
		queue_redraw()
var after_fight_limit_top := 0:
	set(value):
		after_fight_limit_top = value
		queue_redraw()
var after_fight_limit_right := 0:
	set(value):
		after_fight_limit_right = value
		queue_redraw()
var after_fight_limit_bottom := 0:
	set(value):
		after_fight_limit_bottom = value
		queue_redraw()
var after_fight_zoom := 1.0
var after_fight_zoom_duration := 0.3

#--- private variables - order: export > normal var > onready -------------------------------------

var _preview_camera_color := Color.INDIGO
var _preview_camera := false:
	set(value):
		_preview_camera = value
		queue_redraw()
var _preview_after_color := Color.TEAL
var _preview_after_room := false:
	set(value):
		_preview_after_room = value
		queue_redraw()

var _ignore_setters := false

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		var limits := [limit_left, limit_top, limit_right, after_fight_limit_bottom]
		if limits.all(_is_value_zero):
			var project_size := _get_default_resolution()
			size = project_size
			_update_limits()
		
		set_process(true)
	else:
		set_process(false)


func _process(_delta: float) -> void:
	if _has_rect_moved_or_changed():
		_update_limits()
		queue_redraw()


func _draw() -> void:
	if not Engine.is_editor_hint() and editor_only:
		return
	
	if _preview_camera:
		var camera_size := _get_default_resolution()
		var limits_center = size/2.0 - camera_size / zoom / 2.0
		var camera_rect := Rect2(limits_center, camera_size / zoom)
		draw_rect(camera_rect, _preview_camera_color, false, border_width)
	
	if _preview_after_room and after_fight_use_new_room:
		var transform := get_global_transform().affine_inverse()
		var begin := transform * Vector2(after_fight_limit_left, after_fight_limit_top)
		var end := transform * Vector2(after_fight_limit_right, after_fight_limit_bottom)
		var after_room_rect := Rect2(begin, end - begin)
		draw_rect(after_room_rect, _preview_after_color, false, border_width)

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func setup_fight_room() -> void:
	var camera2D := get_viewport().get_camera_2d() as QuiverLevelCamera
	if camera2D == null:
		_push_no_valid_camera_error()
		return
	
	camera2D.delimitate_room(limit_left, limit_top, limit_right, limit_bottom, zoom, zoom_duration)


func setup_after_fight_room() -> void:
	var camera2D := get_viewport().get_camera_2d() as QuiverLevelCamera
	if camera2D == null:
		_push_no_valid_camera_error()
		return
	
	camera2D.delimitate_room(
			after_fight_limit_left, after_fight_limit_top, 
			after_fight_limit_right, after_fight_limit_bottom, 
			after_fight_zoom, after_fight_zoom_duration
	)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _is_value_zero(value: int) -> bool:
	return value == 0


func _get_default_resolution() -> Vector2:
	var project_size := Vector2(
			ProjectSettings.get_setting("display/window/size/viewport_width"),
			ProjectSettings.get_setting("display/window/size/viewport_height")
	)
	return project_size


func _get_scaled_rect() -> Rect2:
	var rect := get_global_rect()
	rect.size * scale
	return rect


func _has_rect_moved_or_changed() -> bool:
	var rect := _get_scaled_rect()
	var rect_values := [rect.position.x, rect.position.y, rect.end.x, rect.end.y]
	var limit_values := [limit_left, limit_top, limit_right, limit_bottom]
	
	var value := false
	for index in rect_values.size():
		value = rect_values[index] != limit_values[index]
		if value:
			break
	
	return value


func _update_limits() -> void:
	var rect := _get_scaled_rect()
	_ignore_setters = true
	limit_right = rect.end.x
	limit_bottom = rect.end.y
	limit_left = rect.position.x
	limit_top = rect.position.y
	_ignore_setters = false


func _set_limit_left(value: int) -> void:
	limit_left = value
	if _ignore_setters:
		return
	
	if not is_inside_tree():
		await ready
	
	var difference := global_position.x - limit_left
	global_position.x = limit_left
	size.x += difference / scale.x


func _set_limit_top(value: int) -> void:
	limit_top = value
	if _ignore_setters:
		return
	
	if not is_inside_tree():
		await ready
	
	var difference := global_position.y - limit_top
	global_position.y = limit_top
	size.y += difference / scale.y


func _set_limit_right(value: int) -> void:
	limit_right = value
	if _ignore_setters:
		return
	
	if not is_inside_tree():
		await ready
	
	var new_size = limit_right - limit_left
	if new_size != size.x * scale.x:
		size.x = new_size / scale.x


func _set_limit_bottom(value: int) -> void:
	limit_bottom = value
	if _ignore_setters:
		return
	
	if not is_inside_tree():
		await ready
	
	var new_size = limit_bottom - limit_top
	if new_size != size.y * scale.y:
		size.y = new_size / scale.y


func _reset_after_room_limits() -> void:
	after_fight_limit_left = limit_left
	after_fight_limit_top = limit_top
	after_fight_limit_right = limit_right
	after_fight_limit_bottom = limit_bottom


func _push_no_valid_camera_error() -> void:
	push_error("Did not find a valid QuiverLevelCamera to delimitate room.")

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

func _get_custom_properties() -> Dictionary:
	return {
		"After Fight Room": {
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_GROUP,
			hint_string = "_after_fight_",
		},
		"_after_fight_use_new_room": {
			backing_field = "after_fight_use_new_room",
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		},
		"_after_fight_limit_left": {
			backing_field = "after_fight_limit_left",
			type = TYPE_INT,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		},
		"_after_fight_limit_top": {
			backing_field = "after_fight_limit_top",
			type = TYPE_INT,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		},
		"_after_fight_limit_right": {
			backing_field = "after_fight_limit_right",
			type = TYPE_INT,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		},
		"_after_fight_limit_bottom": {
			backing_field = "after_fight_limit_bottom",
			type = TYPE_INT,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		},
		"_after_fight_zoom": {
			backing_field = "after_fight_zoom",
			type = TYPE_FLOAT,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0.0,3.0,0.01,or_greater",
		},
		"_after_fight_zoom_duration": {
			backing_field = "after_fight_zoom_duration",
			type = TYPE_FLOAT,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0.0,3.0,0.01,or_greater",
		},
		"Editor Previews": {
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_GROUP,
			hint_string = "preview_",
		},
		"preview_camera": {
			backing_field = "_preview_camera",
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		},
		"preview_camera_color": {
			backing_field = "_preview_camera_color",
			type = TYPE_COLOR,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		},
		"preview_after_room": {
			backing_field = "_preview_after_room",
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		},
		"preview_after_color": {
			backing_field = "_preview_after_color",
			type = TYPE_COLOR,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
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
		
		if key.begins_with("_after_fight_limit_") or key.begins_with("_after_fight_zoom"):
			add_property = after_fight_use_new_room
		
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
