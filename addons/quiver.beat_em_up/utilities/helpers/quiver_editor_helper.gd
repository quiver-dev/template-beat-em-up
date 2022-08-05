class_name QuiverEditorHelper
extends RefCounted
## Static Helper for calling functions in the editor, usually on [code]@tool[/code] scripts


## Disables all processing for the node. Usefull when you need setter or getters to work on
## a [code]@tool[/code] script, but don't want game logic to run.
static func disable_all_processing(node: Node) -> void:
	node.set_process_input(false)
	node.set_process_unhandled_input(false)
	node.set_process(false)
	node.set_physics_process(false)


## Check if the node is the [code]current_scene[/code]. This is useful for having special 
## logic to test a scene running it on F6.
static func is_standalone_run(node: Node) -> bool:
	return node.is_inside_tree() and node.get_tree().current_scene == node


## Gets reverse range for any array. Usefull for loops that remove array items.
static func get_reverse_range_for(p_array: Array) -> Array:
	return range(p_array.size()-1, -1, -1)


## Adds a camera as a child of the node that was passed. Very usefull for testing scenes with
## F6 when there are nodes on negative position values, for example, when setting the origin
## of a character scene to it's feet.
## [br][br]
## The Camera will center around the node, but you can give it an offset in any direction in 
## relation to the centered camera and adjust zoom level through optional parameters.[br]
static func add_debug_camera2D_to(
		node2D: Node2D, 
		percent_offset := Vector2(INF, INF), 
		zoom_level := Vector2.ONE
) -> void:
	var camera: = Camera2D.new()
	camera.name = "DebugCamera2D"
	camera.current = true
	camera.zoom = zoom_level
	if percent_offset != Vector2(INF, INF):
		var viewport_size = node2D.get_viewport_rect().size
		var total_offset = viewport_size * percent_offset
		var centered_offset = total_offset / 2.0
		camera.offset = centered_offset
	
	node2D.add_child(camera, true)


## Helps to print lonf dictionaries in a more readable format.
static func _json_print(value) -> void:
	var json := JSON.new()
	print(json.stringify(value, "\t"))


## Helper to connect signals with proper checking if it's not already connected.
static func connect_between(signal_object: Signal, callable: Callable, type := 0) -> void:
	if not signal_object.is_connected(callable):
		signal_object.connect(callable, type)


## Helper to disconnect signals with proper checking if a connection actually exists.
static func disconnect_between(signal_object: Signal, callable: Callable) -> void:
	if signal_object.is_connected(callable):
		signal_object.disconnect(callable)
