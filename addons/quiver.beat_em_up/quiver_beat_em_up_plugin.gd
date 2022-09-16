@tool
extends EditorPlugin
## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

enum HandleSides {
	LEFT,
	RIGHT
}

#--- constants ------------------------------------------------------------------------------------

const COLOR_GODOT_ORANGE = Color("ff786b")
const INVALID_HANDLE = -1

#--- public variables - order: export > normal var > onready --------------------------------------

const PATH_CUSTOM_INSPECTORS = "res://addons/quiver.beat_em_up/custom_inspectors/"

const PATH_AUTOLOADS = {
	"HitFreeze": "res://addons/quiver.beat_em_up/utilities/helpers/autoload/hit_freeze.tscn",
}

var SETTINGS = {
	QuiverCyclicHelper.SETTINGS_DEFAULT_HIT_LANE_SIZE:{
			value = 60,
			type = TYPE_INT,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0,1,1,or_greater"
	},
	QuiverCyclicHelper.SETTINGS_LOGGING: {
			value = true,
			type = TYPE_BOOL,
			hint = PROPERTY_HINT_NONE,
			hint_string = "",
	},
	QuiverCyclicHelper.SETTINGS_FALL_GRAVITY_MODIFIER: {
			value = 1.0,
			type = TYPE_FLOAT,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0.0,2.0,0.01,or_greater"
	},
}

#--- private variables - order: export > normal var > onready -------------------------------------

var _sprite_repeater: SpriteRepeater = null
var _sprite_repeater_rect := Rect2()
var _sprite_repeater_handles: = {} 
var _dragged_handle := INVALID_HANDLE
var _loaded_inspectors := {}

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _handles(object) -> bool:
	var value := false
	
	if object is SpriteRepeater:
		value = true
	
	return value


func _edit(object) -> void:
	_sprite_repeater = object as SpriteRepeater


func _make_visible(visible: bool) -> void:
	if visible:
		update_overlays()
	else:
		_sprite_repeater = null
		update_overlays()


func _forward_canvas_draw_over_viewport(viewport_control: Control) -> void:
	if not (is_instance_valid(_sprite_repeater) and _sprite_repeater.is_inside_tree()):
		return
	
	_sprite_repeater_rect = _calculate_sprite_repeater_rect()
	viewport_control.draw_rect(_sprite_repeater_rect, COLOR_GODOT_ORANGE, false, 1.0)
	
	_sprite_repeater_handles = _calculate_sprite_repeater_handles()
	for handle in _sprite_repeater_handles.values():
		viewport_control.draw_rect(handle, COLOR_GODOT_ORANGE, true, 1.0)
		viewport_control.draw_rect(handle, Color.WHITE, false, 1.0)


func _forward_canvas_gui_input(event: InputEvent) -> bool:
	var has_handled := false
	if not (is_instance_valid(_sprite_repeater) and _sprite_repeater.visible):
		return has_handled
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if _dragged_handle == INVALID_HANDLE and event.is_pressed():
			for key in _sprite_repeater_handles:
				var handle := _sprite_repeater_handles[key] as Rect2
				if handle.has_point(event.position):
					_dragged_handle = key
					has_handled = true
					break
		elif _dragged_handle != INVALID_HANDLE and not event.is_pressed():
			_drag_to(event)
			_dragged_handle = INVALID_HANDLE
			has_handled = true
	elif _dragged_handle != INVALID_HANDLE and event is InputEventMouseMotion:
		_drag_to(event)
		update_overlays()
		has_handled = true
	
	if event.is_action_pressed("ui_cancel"):
		_dragged_handle = INVALID_HANDLE
		has_handled = true
	
	return has_handled


func _calculate_sprite_repeater_rect() -> Rect2:
	var rect := Rect2()
	var editor_transform := \
			_sprite_repeater.get_viewport_transform() * _sprite_repeater.get_canvas_transform()
	
	rect.position = editor_transform * (_sprite_repeater.position + _sprite_repeater.offset)
	
	var total_size_x = _sprite_repeater.main_texture.get_size().x * _sprite_repeater.length
	var total_separation = _sprite_repeater.separation * (_sprite_repeater.length - 1)
	rect.size = editor_transform.get_scale() * Vector2(
			total_size_x + total_separation,
			_sprite_repeater.main_texture.get_size().y
	)
	
	return rect


func _calculate_sprite_repeater_handles() -> Dictionary:
	var editor_transform := \
			_sprite_repeater.get_viewport_transform() * _sprite_repeater.get_canvas_transform()
	
	var handle_size := Vector2(10, _sprite_repeater_rect.size.y)
	var left_handle_start := _sprite_repeater_rect.position - Vector2.RIGHT * handle_size.x
	var right_handle_start := \
			_sprite_repeater_rect.position + Vector2(_sprite_repeater_rect.size.x, 0)
	
	var handles = {
			HandleSides.LEFT: Rect2(left_handle_start, handle_size),
			HandleSides.RIGHT: Rect2(right_handle_start, handle_size)
	}
	
	return handles


func _drag_to(event: InputEventMouse) -> void:
	if _dragged_handle == INVALID_HANDLE:
		return
	
	var editor_transform := \
			_sprite_repeater.get_viewport_transform() * _sprite_repeater.get_canvas_transform()
	
	var handle := _sprite_repeater_handles[_dragged_handle] as Rect2
	if _dragged_handle == HandleSides.RIGHT:
		var distance := event.position.x - _sprite_repeater_rect.position.x
		var base_distance := _sprite_repeater_rect.size.x / float(_sprite_repeater.length)
		var value := round(distance / base_distance) as float
		_sprite_repeater.length = max(1, value)
	elif _dragged_handle == HandleSides.LEFT:
		var distance := _sprite_repeater_rect.end.x - event.position.x
		var base_distance := _sprite_repeater_rect.size.x / float(_sprite_repeater.length)
		var value := max(1, round(distance / base_distance)) as float
		
		var local_end := editor_transform.affine_inverse() * _sprite_repeater_rect.end
		var local_size := (
				_sprite_repeater.main_texture.get_size().x * value 
				+ _sprite_repeater.separation * (value-1)
		)
		_sprite_repeater.length = value
		_sprite_repeater.position.x = local_end.x - local_size


func _enter_tree() -> void:
	_add_custom_inspectors()


func _exit_tree() -> void:
	_remove_custom_inspectors()


func _enable_plugin() -> void:
	_add_plugin_settings()
	_add_autoloads()


func _disable_plugin() -> void:
	_remove_plugin_settings()
	_remove_autoloads()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _add_custom_inspectors() -> void:
	var dir := Directory.new()
	var error := dir.open(PATH_CUSTOM_INSPECTORS)
	
	if error == OK:
		dir.list_dir_begin()
		var folder_name := dir.get_next()
		while not folder_name.is_empty():
			if dir.current_is_dir(): 
				_load_custom_inspector_from(folder_name)
			folder_name = dir.get_next()
	else:
		var error_msg = "Error code: %s | Something went wrong trying to open %s"%[
			error, PATH_CUSTOM_INSPECTORS
		]
		push_error(error_msg)


func _load_custom_inspector_from(folder: String) -> void:
	const PATH_SCRIPT = "inspector_plugin.gd"
	var full_path := PATH_CUSTOM_INSPECTORS.path_join(folder).path_join(PATH_SCRIPT)
	if ResourceLoader.exists(full_path):
		var custom_inspector := load(full_path).new() as EditorInspectorPlugin
		add_inspector_plugin(custom_inspector)
		if "undo_redo" in custom_inspector:
			custom_inspector.undo_redo = get_undo_redo()
			
		_loaded_inspectors[folder] = custom_inspector


func _remove_custom_inspectors() -> void:
	for inspector in _loaded_inspectors.values():
		remove_inspector_plugin(inspector)


func _add_plugin_settings() -> void:
	for setting in SETTINGS:
		if not ProjectSettings.has_setting(setting):
			var dict: Dictionary = SETTINGS[setting]
			ProjectSettings.set_setting(setting, dict.value)
			ProjectSettings.add_property_info({
				"name": setting,
				"type": dict.type,
				"hint": dict.hint,
				"hint_string": dict.hint_string,
			})
	
	if Engine.is_editor_hint():
		ProjectSettings.save()


func _remove_plugin_settings() -> void:
	for setting in SETTINGS:
		if ProjectSettings.has_setting(setting):
			ProjectSettings.set_setting(setting, null)
	
	if Engine.is_editor_hint():
		ProjectSettings.save()


func _add_autoloads() -> void:
	for key in PATH_AUTOLOADS:
		add_autoload_singleton(key, PATH_AUTOLOADS[key])


func _remove_autoloads() -> void:
	for key in PATH_AUTOLOADS:
		remove_autoload_singleton(key)

### -----------------------------------------------------------------------------------------------
