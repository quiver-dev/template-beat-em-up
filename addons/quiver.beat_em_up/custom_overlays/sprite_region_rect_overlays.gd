extends QuiverCustomOverlay

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

enum HandlePoints {
	TOP_LEFT,
	TOP,
	TOP_RIGHT,
	RIGHT,
	BOTTOM_RIGHT,
	BOTTOM,
	BOTTOM_LEFT,
	LEFT,
}

const INVALID_HANDLE = -1
const INVALID_VECTOR = Vector2(INF, INF)
const HANDLE_SIZE = Vector2(6,6)
const HANDLE_OFFSET = Vector2(2,2)

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _sprite: Sprite2D = null
var _handles: = {} 
var _dragged_handle := INVALID_HANDLE

var _starting_local_end := INVALID_VECTOR
var _undo_redo: EditorUndoRedoManager = null

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func handles(object) -> bool:
	return object is Sprite2D


func edit(object) -> void:
	_sprite = object as Sprite2D
	pass


func make_visible(visible: bool) -> void:
	if not visible:
		_sprite = null
	main_plugin.update_overlays()


func forward_canvas_draw_over_viewport(viewport_control: Control) -> void:
	if not _should_draw_handles():
		return
	
	var color := COLOR_GODOT_ORANGE
	_handles = _calculate_region_rect_handles()
	for handle in _handles.values():
		var white = Rect2(handle.position - Vector2.ONE, handle.size + Vector2.ONE * 2)
		viewport_control.draw_rect(white, Color.BLACK, false, 2.0)
		viewport_control.draw_rect(white, Color.WHITE)
		viewport_control.draw_rect(handle, color)


func forward_canvas_gui_input(event: InputEvent) -> bool:
	var has_handled := false
	
	if is_instance_valid(_sprite) and _sprite.visible:
		has_handled = _drag_handles(event)
	
	return has_handled

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_main_plugin_set() -> void:
	_undo_redo = main_plugin.get_undo_redo()
	pass


func _should_draw_handles() -> bool:
	var value := false
	var is_sprite_valid := is_instance_valid(_sprite) and _sprite.is_inside_tree()
	if is_sprite_valid:
		value = _sprite.region_enabled
	
	return value


func _drag_handles(event: InputEvent) -> bool:
	var has_handled := false
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if _dragged_handle == INVALID_HANDLE and event.is_pressed():
			has_handled = _start_dragging_clicked_handle(event)
		elif _dragged_handle != INVALID_HANDLE and not event.is_pressed():
			_stop_dragging_released_handle(event)
			has_handled = true
	elif _dragged_handle != INVALID_HANDLE and event is InputEventMouseMotion:
		_drag_to(event)
		main_plugin.update_overlays()
		has_handled = true
	
	if event.is_action_pressed("ui_cancel"):
		_dragged_handle = INVALID_HANDLE
		
		_undo_redo.commit_action()
		var undo_redo_id = _undo_redo.get_object_history_id(_sprite)
		_undo_redo.get_history_undo_redo(undo_redo_id).undo()
		
		main_plugin.update_overlays()
		has_handled = true
	
	return has_handled


func _start_dragging_clicked_handle(event: InputEventMouseButton) -> bool:
	var has_handled := false
	for key in _handles:
		var handle := _handles[key] as Rect2
		if handle.has_point(event.position):
			_dragged_handle = key
			_undo_redo.create_action(
					"%s region_rect changed"%[_sprite.name], UndoRedo.MERGE_DISABLE, _sprite
			)
			_undo_redo.add_undo_property(_sprite, "region_rect", _sprite.region_rect)
			_undo_redo.add_undo_property(_sprite, "position", _sprite.position)
			_undo_redo.add_undo_method(main_plugin, "update_overlays")
			
			has_handled = true
			break
	
	return has_handled


func _stop_dragging_released_handle(event: InputEventMouseButton) -> void:
	_undo_redo.add_do_property(_sprite, "region_rect", _sprite.region_rect)
	_undo_redo.add_do_property(_sprite, "position", _sprite.position)
	_undo_redo.add_do_method(main_plugin, "update_overlays")
	_undo_redo.commit_action(false)
	_dragged_handle = INVALID_HANDLE


func _drag_to(event: InputEventMouse) -> void:
	if _dragged_handle == INVALID_HANDLE:
		return
	
	var editor_transform := \
			_sprite.get_viewport_transform() * _sprite.get_canvas_transform()
	var dragged_local_position = (editor_transform.affine_inverse() * event.position).round()
	var sprite_size := _sprite.region_rect.size * _sprite.scale
	match _dragged_handle:
		HandlePoints.TOP_LEFT:
			var bottom_right = _sprite.global_position + sprite_size
			_sprite.region_rect.size = bottom_right - dragged_local_position
			_sprite.region_rect.size /= _sprite.scale
			_sprite.position = dragged_local_position
		HandlePoints.TOP:
			var bottom = _sprite.global_position + sprite_size * Vector2(0.5, 1.0)
			_sprite.region_rect.size.y = bottom.y - dragged_local_position.y
			_sprite.region_rect.size.y /= _sprite.scale.y
			_sprite.position.y = dragged_local_position.y
		HandlePoints.TOP_RIGHT:
			var bottom_left := _sprite.global_position + sprite_size * Vector2(0, 1.0)
			_sprite.region_rect.size = (dragged_local_position - bottom_left).abs()
			_sprite.region_rect.size /= _sprite.scale
			_sprite.position.y = dragged_local_position.y
		HandlePoints.RIGHT:
			_sprite.region_rect.size.x = dragged_local_position.x - _sprite.global_position.x
			_sprite.region_rect.size.x /= _sprite.scale.x
		HandlePoints.BOTTOM_RIGHT:
			_sprite.region_rect.size = (dragged_local_position - _sprite.global_position)
			_sprite.region_rect.size /= _sprite.scale
		HandlePoints.BOTTOM:
			_sprite.region_rect.size.y = dragged_local_position.y - _sprite.global_position.y
			_sprite.region_rect.size.y /= _sprite.scale.y
		HandlePoints.BOTTOM_LEFT:
			var top_right := _sprite.global_position + sprite_size * Vector2(1.0, 0)
			_sprite.region_rect.size = (top_right - dragged_local_position).abs()
			_sprite.region_rect.size /= _sprite.scale
			_sprite.position.x = dragged_local_position.x
		HandlePoints.LEFT:
			var right := _sprite.global_position + sprite_size * Vector2(1.0, 0.5)
			_sprite.region_rect.size.x = right.x - dragged_local_position.x
			_sprite.region_rect.size.x /= _sprite.scale.x
			_sprite.position.x = dragged_local_position.x
		_:
			print(_dragged_handle)


func _calculate_region_rect_handles() -> Dictionary:
	var editor_transform := \
			_sprite.get_viewport_transform() * _sprite.get_canvas_transform()
	
	var handles = {}
	var sprite_begin := editor_transform * (_sprite.position + _sprite.offset)
	if _sprite.centered:
		sprite_begin -= editor_transform * (_sprite.region_rect.size / 2.0 * _sprite.scale)
		
	var sprite_size := editor_transform.get_scale() * _sprite.region_rect.size * _sprite.scale
	
	for handle in HandlePoints.values():
		var handle_rect := Rect2()
		handle_rect.size = HANDLE_SIZE
		match handle:
			HandlePoints.TOP_LEFT:
				handle_rect.position = sprite_begin
			HandlePoints.TOP:
				handle_rect.position = sprite_begin + Vector2(sprite_size.x / 2.0, 0)
			HandlePoints.TOP_RIGHT:
				handle_rect.position = sprite_begin + Vector2(sprite_size.x, 0)
			HandlePoints.RIGHT:
				handle_rect.position = sprite_begin + Vector2(sprite_size.x, sprite_size.y / 2.0)
			HandlePoints.BOTTOM_RIGHT:
				handle_rect.position = sprite_begin + sprite_size 
			HandlePoints.BOTTOM:
				handle_rect.position = sprite_begin + Vector2(sprite_size.x / 2.0, sprite_size.y)
			HandlePoints.BOTTOM_LEFT:
				handle_rect.position = sprite_begin + Vector2(0, sprite_size.y)
			HandlePoints.LEFT:
				handle_rect.position = sprite_begin + Vector2(0, sprite_size.y / 2.0)
			_:
				print("FOUND NO HANDLE for %s"%[handle])
		
		handle_rect.position += _get_handle_offset(handle)
		handles[handle] = handle_rect
	
	return handles


func _get_handle_offset(handle: int) -> Vector2:
	var offset := Vector2.ZERO
	var editor_scale := \
			(_sprite.get_viewport_transform() * _sprite.get_canvas_transform()).get_scale()
	
	match handle:
		HandlePoints.TOP_LEFT:
			offset = Vector2.ZERO + HANDLE_OFFSET
		HandlePoints.TOP:
			offset = Vector2.LEFT/2.0 * HANDLE_SIZE.x + Vector2(0,HANDLE_OFFSET.y)
		HandlePoints.TOP_RIGHT:
			offset = Vector2.LEFT * HANDLE_SIZE.x + Vector2(-HANDLE_OFFSET.x, HANDLE_OFFSET.y)
		HandlePoints.RIGHT:
			offset = Vector2.LEFT * (HANDLE_SIZE.x + HANDLE_OFFSET.x) \
					+ Vector2.UP/2.0 * HANDLE_SIZE.y
		HandlePoints.BOTTOM_RIGHT:
			offset = Vector2.ONE * HANDLE_SIZE * -1 - HANDLE_OFFSET
		HandlePoints.BOTTOM:
			offset = Vector2.LEFT/2.0 * HANDLE_SIZE.x \
					+ Vector2.UP * (HANDLE_SIZE.y + HANDLE_OFFSET.y)
		HandlePoints.BOTTOM_LEFT:
			offset = Vector2.UP * HANDLE_SIZE.y + Vector2(HANDLE_OFFSET.x, -HANDLE_OFFSET.y)
		HandlePoints.LEFT:
			offset = Vector2.UP/2.0 * HANDLE_SIZE.y + Vector2(HANDLE_OFFSET.x, 0)
	
	return offset

### -----------------------------------------------------------------------------------------------
