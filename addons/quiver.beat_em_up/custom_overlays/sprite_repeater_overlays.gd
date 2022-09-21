extends QuiverCustomOverlay

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

#--- private variables - order: export > normal var > onready -------------------------------------

var _sprite_repeater: SpriteRepeater = null
var _rect := Rect2()
var _handles: = {} 
var _dragged_handle := INVALID_HANDLE

var _all_sprite_repeaters: Array[SpriteRepeater] = []

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func handles(object) -> bool:
	return object is SpriteRepeater or not _all_sprite_repeaters.is_empty()


func edit(object) -> void:
	_sprite_repeater = object as SpriteRepeater


func make_visible(visible: bool) -> void:
	if not visible:
		_sprite_repeater = null
	main_plugin.update_overlays()


func forward_canvas_draw_over_viewport(viewport_control: Control) -> void:
	if not (is_instance_valid(_sprite_repeater) and _sprite_repeater.is_inside_tree()):
		return
	
	_rect = _calculate_sprite_repeater_rect(_sprite_repeater)
	viewport_control.draw_rect(_rect, COLOR_GODOT_ORANGE, false, 1.0)
	
	_handles = _calculate_sprite_repeater_handles()
	for handle in _handles.values():
		viewport_control.draw_rect(handle, COLOR_GODOT_ORANGE, true, 1.0)
		viewport_control.draw_rect(handle, Color.WHITE, false, 1.0)


func forward_canvas_gui_input(event: InputEvent) -> bool:
	var has_handled := false
	if is_instance_valid(_sprite_repeater) and _sprite_repeater.visible:
		has_handled = _handle_drag_handles(event)
	
	if not has_handled and event is InputEventMouseButton:
		has_handled = _handle_select_click(event)
	
	return has_handled

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _handle_drag_handles(event: InputEvent) -> bool:
	var has_handled := false
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if _dragged_handle == INVALID_HANDLE and event.is_pressed():
			for key in _handles:
				var handle := _handles[key] as Rect2
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
		main_plugin.update_overlays()
		has_handled = true
	
	if event.is_action_pressed("ui_cancel"):
		_dragged_handle = INVALID_HANDLE
		has_handled = true
	
	return has_handled


func _handle_select_click(event: InputEventMouseButton) -> bool:
	var has_handled := false
	
	if event != null and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		for node in _all_sprite_repeaters:
			if not node.visible:
				continue
			
			var rect = _calculate_sprite_repeater_rect(node)
			if rect.has_point(event.position):
				main_plugin.get_editor_interface().edit_node(node)
				has_handled = true
				break
	
	return has_handled


func _on_main_plugin_set() -> void:
	main_plugin.get_tree().node_added.connect(_on_node_added)
	main_plugin.get_tree().node_removed.connect(_on_node_removed)


func _on_node_added(node: Node) -> void:
	if not node is SpriteRepeater:
		return
	
	_all_sprite_repeaters.append(node)
	_all_sprite_repeaters.sort_custom(_sort_nodes_by_greater)
	


func _sort_nodes_by_greater(a: Node, b: Node) -> bool:
	return a.is_greater_than(b)


func _on_node_removed(node: Node) -> void:
	if not node is SpriteRepeater:
		return
	
	_all_sprite_repeaters.erase(node)


func _calculate_sprite_repeater_rect(node: SpriteRepeater) -> Rect2:
	var rect := Rect2()
	var editor_transform := node.get_viewport_transform() * node.get_canvas_transform()
	
	rect.position = editor_transform * (node.position + node.offset)
	
	var total_size_x = node.main_texture.get_size().x * node.length
	var total_separation = node.separation * (node.length - 1)
	rect.size = editor_transform.get_scale() * Vector2(
			total_size_x + total_separation,
			node.main_texture.get_size().y
	)
	
	return rect


func _calculate_sprite_repeater_handles() -> Dictionary:
	var editor_transform := \
			_sprite_repeater.get_viewport_transform() * _sprite_repeater.get_canvas_transform()
	
	var handle_size := Vector2(10, _rect.size.y)
	var left_handle_start := _rect.position - Vector2.RIGHT * handle_size.x
	var right_handle_start := \
			_rect.position + Vector2(_rect.size.x, 0)
	
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
	
	var handle := _handles[_dragged_handle] as Rect2
	if _dragged_handle == HandleSides.RIGHT:
		var distance := event.position.x - _rect.position.x
		var base_distance := _rect.size.x / float(_sprite_repeater.length)
		var value := round(distance / base_distance) as float
		_sprite_repeater.length = max(1, value)
	elif _dragged_handle == HandleSides.LEFT:
		var distance := _rect.end.x - event.position.x
		var base_distance := _rect.size.x / float(_sprite_repeater.length)
		var value := max(1, round(distance / base_distance)) as float
		
		var local_end := editor_transform.affine_inverse() * _rect.end
		var local_size := (
				_sprite_repeater.main_texture.get_size().x * value 
				+ _sprite_repeater.separation * (value-1)
		)
		_sprite_repeater.length = value
		_sprite_repeater.position.x = local_end.x - local_size

### -----------------------------------------------------------------------------------------------
