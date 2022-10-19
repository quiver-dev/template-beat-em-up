extends QuiverCustomOverlay

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

enum HandleSides {
	LEFT,
	RIGHT,
	TOP,
	BOTTOM,
}

#--- constants ------------------------------------------------------------------------------------

const INVALID_HANDLE = -1
const INVALID_VECTOR = Vector2(INF, INF)

const HANDLE_THICKNESS = 10

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _sprite_repeater: QuiverSpriteRepeater = null
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
	return object is QuiverSpriteRepeater


func edit(object) -> void:
	_sprite_repeater = object as QuiverSpriteRepeater


func make_visible(visible: bool) -> void:
	if not visible:
		_sprite_repeater = null
	main_plugin.update_overlays()


func forward_canvas_draw_over_viewport(viewport_control: Control) -> void:
	if not (is_instance_valid(_sprite_repeater) and _sprite_repeater.is_inside_tree()):
		return
	
	_rect = _sprite_repeater.get_global_rect_on_editor()
	viewport_control.draw_rect(_rect, COLOR_GODOT_ORANGE, false, 1.0)
	
	_handles = _calculate_sprite_repeater_handles()
	for handle in _handles.values():
		viewport_control.draw_rect(handle, COLOR_GODOT_ORANGE, true, 1.0)
		viewport_control.draw_rect(handle, Color.WHITE, false, 1.0)


func forward_canvas_gui_input(event: InputEvent) -> bool:
	var has_handled := false
	
	if is_instance_valid(_sprite_repeater) and _sprite_repeater.visible:
		has_handled = _drag_handles(event)
	
	return has_handled

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_main_plugin_set() -> void:
	_undo_redo = main_plugin.get_undo_redo()
	pass


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
		var undo_redo_id = _undo_redo.get_object_history_id(_sprite_repeater)
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
			if _dragged_handle == HandleSides.LEFT or _dragged_handle == HandleSides.TOP:
				_starting_local_end = _sprite_repeater.get_global_rect().end
			else:
				_starting_local_end = INVALID_VECTOR
			
			_undo_redo.create_action(
					"Move QuiverSpriteRepeater Handle", UndoRedo.MERGE_DISABLE, _sprite_repeater
			)
			_undo_redo.add_undo_property(_sprite_repeater, "length", _sprite_repeater.length)
			_undo_redo.add_undo_property(_sprite_repeater, "position", _sprite_repeater.position)
			_undo_redo.add_undo_method(main_plugin, "update_overlays")
			
			has_handled = true
			break
	
	return has_handled


func _stop_dragging_released_handle(event: InputEventMouseButton) -> void:
	_drag_to(event)
	_undo_redo.add_do_property(_sprite_repeater, "length", _sprite_repeater.length)
	_undo_redo.add_do_property(_sprite_repeater, "position", _sprite_repeater.position)
	_undo_redo.add_do_method(main_plugin, "update_overlays")
	_undo_redo.commit_action(false)
	_dragged_handle = INVALID_HANDLE


func _calculate_sprite_repeater_handles() -> Dictionary:
	var editor_transform := \
			_sprite_repeater.get_viewport_transform() * _sprite_repeater.get_canvas_transform()
	
	var handles := {}
	
	if _sprite_repeater.is_vertical:
		var handle_size := Vector2(_rect.size.x, HANDLE_THICKNESS)
		var top_handle_start := _rect.position + Vector2.UP * handle_size.y
		var bottom_handle_start := _rect.position + Vector2.DOWN * _rect.size.y
		handles = {
				HandleSides.TOP: Rect2(top_handle_start, handle_size),
				HandleSides.BOTTOM: Rect2(bottom_handle_start, handle_size)
		}
	else:
		var handle_size := Vector2(HANDLE_THICKNESS, _rect.size.y)
		var left_handle_start := _rect.position + Vector2.LEFT * handle_size.x
		var right_handle_start := \
				_rect.position + Vector2(_rect.size.x, 0)
		handles = {
				HandleSides.LEFT: Rect2(left_handle_start, handle_size),
				HandleSides.RIGHT: Rect2(right_handle_start, handle_size)
		}
		
	return handles


func _drag_to(event: InputEventMouse) -> void:
	if _dragged_handle == INVALID_HANDLE:
		return
	
	_calculate_dragged_length(event)
	_calculate_dragged_position()


func _calculate_dragged_length(event: InputEventMouse) -> void:
	var distance := 0.0
	var base_distance := _rect.size / float(_sprite_repeater.length)
	var value := 1.0
	match _dragged_handle:
		HandleSides.RIGHT:
			distance = event.position.x - _rect.position.x
			value = round(distance / base_distance.x)
		HandleSides.LEFT:
			distance = _rect.end.x - event.position.x
			value = round(distance / base_distance.x)
		HandleSides.TOP:
			distance = _rect.end.y - event.position.y
			value = round(distance / base_distance.y)
		HandleSides.BOTTOM:
			distance = event.position.y - _rect.position.y
			value = round(distance / base_distance.y)
		_:
			push_error("Undefined handle: %s. Possible values: %s"%[
					_dragged_handle, HandleSides.keys()
			])
	
	_sprite_repeater.length = max(1, value)


func _calculate_dragged_position() -> void:
	if _starting_local_end != INVALID_VECTOR:
		var current_size := _sprite_repeater.get_global_rect().size
		match _dragged_handle:
			HandleSides.LEFT:
				_sprite_repeater.global_position.x = _starting_local_end.x - current_size.x
			HandleSides.TOP:
				_sprite_repeater.global_position.y = _starting_local_end.y - current_size.y
			_:
				push_error(
						"Either an unimplemented Handle or _starting_local_end is not invalid " 
						+ "when it should be. _dragged_handle: %s _starting_local_end: %s"
						%[_dragged_handle, _starting_local_end]
				)

### -----------------------------------------------------------------------------------------------
