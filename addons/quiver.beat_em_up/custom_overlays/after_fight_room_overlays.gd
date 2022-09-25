extends QuiverCustomOverlay

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

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

#--- constants ------------------------------------------------------------------------------------

const INVALID_HANDLE = -1
const INVALID_VECTOR = Vector2(INF, INF)
const RADIUS_HANDLE = 4

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _fight_room: QuiverFightRoom = null
var _rect := Rect2()
var _handles: = {} 
var _dragged_handle := INVALID_HANDLE

var _starting_local_end := INVALID_VECTOR
var _undo_redo: EditorUndoRedoManager = null

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func handles(object) -> bool:
	return object is QuiverFightRoom


func edit(object) -> void:
	_fight_room = object as QuiverFightRoom


func make_visible(visible: bool) -> void:
	if not visible:
		_fight_room = null
	main_plugin.update_overlays()


func forward_canvas_draw_over_viewport(viewport_control: Control) -> void:
	if not _should_draw_handles():
		return
	
	var color := _fight_room.preview_after_color as Color
	_rect = _calculate_after_fight_room_in_editor()
	_handles = _calculate_fight_room_handles()
	for handle in _handles.values():
		var origin = handle.position + Vector2.ONE * RADIUS_HANDLE
		viewport_control.draw_circle(origin, RADIUS_HANDLE + 1, Color.WHITE)
		viewport_control.draw_circle(origin, RADIUS_HANDLE, color)


func forward_canvas_gui_input(event: InputEvent) -> bool:
	var has_handled := false
	
	if is_instance_valid(_fight_room) and _fight_room.visible:
		has_handled = _drag_handles(event)
	
	return has_handled

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_main_plugin_set() -> void:
	_undo_redo = main_plugin.get_undo_redo()
	pass


func _should_draw_handles() -> bool:
	var value := false
	var is_fight_room_valid := is_instance_valid(_fight_room) and _fight_room.is_inside_tree()
	if is_fight_room_valid:
		value = _fight_room.after_fight_use_new_room and _fight_room._preview_after_room
	
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
		var undo_redo_id = _undo_redo.get_object_history_id(_fight_room)
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
					"Move After Fight Room Handle", UndoRedo.MERGE_DISABLE, _fight_room
			)
			for direction in ["top", "left", "bottom", "right"]:
				var property := "after_fight_limit_%s"%[direction]
				_undo_redo.add_undo_property(_fight_room, property, _fight_room.get(property))
			_undo_redo.add_undo_method(main_plugin, "update_overlays")
			
			has_handled = true
			break
	
	return has_handled


func _stop_dragging_released_handle(event: InputEventMouseButton) -> void:
	_drag_to(event)
	for direction in ["top", "left", "bottom", "right"]:
		var property := "after_fight_limit_%s"%[direction]
		_undo_redo.add_do_property(_fight_room, property, _fight_room.get(property))
	_undo_redo.add_do_method(main_plugin, "update_overlays")
	_undo_redo.commit_action(false)
	_dragged_handle = INVALID_HANDLE


func _drag_to(event: InputEventMouse) -> void:
	if _dragged_handle == INVALID_HANDLE:
		return
	
	var editor_transform := \
			_fight_room.get_viewport_transform() * _fight_room.get_canvas_transform()
	var fight_room_border := editor_transform.get_scale() * _fight_room.border_width/2.0
	var dragged_global_position = (editor_transform.affine_inverse() * event.position).round()
	match _dragged_handle:
		HandlePoints.TOP_LEFT:
			_fight_room.after_fight_limit_top = dragged_global_position.y
			_fight_room.after_fight_limit_left = dragged_global_position.x
		HandlePoints.TOP:
			_fight_room.after_fight_limit_top = dragged_global_position.y
		HandlePoints.TOP_RIGHT:
			_fight_room.after_fight_limit_top = dragged_global_position.y
			_fight_room.after_fight_limit_right = dragged_global_position.x
		HandlePoints.RIGHT:
			_fight_room.after_fight_limit_right = dragged_global_position.x
		HandlePoints.BOTTOM_RIGHT:
			_fight_room.after_fight_limit_bottom = dragged_global_position.y
			_fight_room.after_fight_limit_right = dragged_global_position.x
		HandlePoints.BOTTOM:
			_fight_room.after_fight_limit_bottom = dragged_global_position.y
		HandlePoints.BOTTOM_LEFT:
			_fight_room.after_fight_limit_bottom = dragged_global_position.y
			_fight_room.after_fight_limit_left = dragged_global_position.x
		HandlePoints.LEFT:
			_fight_room.after_fight_limit_left = dragged_global_position.x
		_:
			print(_dragged_handle)

func _calculate_fight_room_handles() -> Dictionary:
	var editor_scale := \
			(_fight_room.get_viewport_transform() * _fight_room.get_canvas_transform()).get_scale()
	
	var fight_room_border := editor_scale * _fight_room.border_width/2.0
	var handle_size := Vector2.ONE * RADIUS_HANDLE * 2
	var handles = {}
	
	for handle in HandlePoints.values():
		var handle_rect := Rect2()
		handle_rect.size = handle_size
		match handle:
			HandlePoints.TOP_LEFT:
				handle_rect.position = Vector2(_rect.position.x ,_rect.position.y)
			HandlePoints.TOP:
				handle_rect.position = Vector2(_rect.position.x + _rect.size.x / 2.0 ,_rect.position.y)
			HandlePoints.TOP_RIGHT:
				handle_rect.position = Vector2(_rect.end.x ,_rect.position.y)
			HandlePoints.RIGHT:
				handle_rect.position = Vector2(_rect.end.x ,_rect.position.y + _rect.size.y / 2.0)
			HandlePoints.BOTTOM_RIGHT:
				handle_rect.position = Vector2(_rect.end.x ,_rect.end.y)
			HandlePoints.BOTTOM:
				handle_rect.position = Vector2(_rect.position.x + _rect.size.x / 2.0 ,_rect.end.y)
			HandlePoints.BOTTOM_LEFT:
				handle_rect.position = Vector2(_rect.position.x ,_rect.end.y)
			HandlePoints.LEFT:
				handle_rect.position = Vector2(_rect.position.x ,_rect.position.y + _rect.size.y / 2.0)
			_:
				print("FOUND NO HANDLE for %s"%[handle])
		
		handle_rect.position += _get_handle_offset(handle)
		handles[handle] = handle_rect
	
	return handles


func _get_handle_offset(handle: int) -> Vector2:
	var offset := Vector2.ZERO
	var editor_scale := \
			(_fight_room.get_viewport_transform() * _fight_room.get_canvas_transform()).get_scale()
	var fight_room_border := editor_scale * _fight_room.border_width/2.0
	var handle_size := Vector2.ONE * RADIUS_HANDLE * 2
	
	match handle:
		HandlePoints.TOP_LEFT:
			offset = Vector2.ONE * fight_room_border
		HandlePoints.TOP:
			offset = Vector2.DOWN * fight_room_border + Vector2.LEFT/2.0 * handle_size.x
		HandlePoints.TOP_RIGHT:
			offset = (
					(Vector2.DOWN + Vector2.LEFT) * fight_room_border 
					+ Vector2.LEFT * handle_size.x
			)
		HandlePoints.RIGHT:
			offset = (
					Vector2.LEFT * fight_room_border
					+ (Vector2.UP/2.0 + Vector2.LEFT) * handle_size.x
			)
		HandlePoints.BOTTOM_RIGHT:
			offset = (
					Vector2.ONE * fight_room_border * -1
					+ Vector2.ONE * handle_size * -1
			)
		HandlePoints.BOTTOM:
			offset = (
					Vector2.UP * fight_room_border + Vector2.UP * handle_size.y 
					+ Vector2.LEFT/2.0 * handle_size.x
			)
		HandlePoints.BOTTOM_LEFT:
			offset = (
					(Vector2.UP + Vector2.RIGHT) * fight_room_border
					+ Vector2.UP * handle_size.y
			)
		HandlePoints.LEFT:
			offset = (
					Vector2.RIGHT * fight_room_border
					+ Vector2.UP/2.0 * handle_size.y
			)
	
	return offset


func _calculate_after_fight_room_in_editor() -> Rect2:
	var editor_transform := \
			_fight_room.get_viewport_transform() * _fight_room.get_canvas_transform()
	
	var begin := editor_transform * Vector2(
			_fight_room.after_fight_limit_left, 
			_fight_room.after_fight_limit_top
	)
	var end := editor_transform * Vector2(
			_fight_room.after_fight_limit_right, 
			_fight_room.after_fight_limit_bottom
	)
	var editor_rect := Rect2(begin, end - begin)
	
	return editor_rect

### -----------------------------------------------------------------------------------------------
