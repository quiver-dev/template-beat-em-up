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


## Enables all processing for the node.
static func enable_all_processing(node: Node) -> void:
	node.set_process_input(true)
	node.set_process_unhandled_input(true)
	node.set_process(true)
	node.set_physics_process(true)


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


## Helper to connect signals with proper checking if it's not already connected.
static func connect_between(signal_object: Signal, callable: Callable, type := 0) -> void:
	if not signal_object.is_connected(callable):
		signal_object.connect(callable, type)


## Helper to disconnect signals with proper checking if a connection actually exists.
static func disconnect_between(signal_object: Signal, callable: Callable) -> void:
	if signal_object.is_connected(callable):
		signal_object.disconnect(callable)


# Advanced exports snippet below -------------------------------------------------------------------

####################################################################################################
## Custom Inspector ################################################################################
####################################################################################################
#
#func _get_custom_properties() -> Dictionary:
#	return {
##		"": {
##			backing_field = "",
##			name = "",
##			type = TYPE_NIL,
##			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
##			hint = PROPERTY_HINT_NONE,
##			hint_string = "",
##		},
#}
#
#### Custom Inspector built in functions -----------------------------------------------------------
#
#func _get_property_list() -> Array:
#	var properties: = []
#	
#	var custom_properties := _get_custom_properties()
#	for key in custom_properties:
#		var add_property := true
#		var dict: Dictionary = custom_properties[key]
#		if not dict.has("name"):
#			dict.name = key
#	
#		if add_property:
#			properties.append(dict)
#	
#	return properties
#
#
#func _get(property: StringName):
#	var value
#	
#	var custom_properties := _get_custom_properties()
#	if property in custom_properties and custom_properties[property].has("backing_field"):
#		value = get(custom_properties[property]["backing_field"])
#	
#	return value
#
#
#func _set(property: StringName, value) -> bool:
#	var has_handled: = false
#	
#	var custom_properties := _get_custom_properties()
#	if property in custom_properties and custom_properties[property].has("backing_field"):
#		set(custom_properties[property]["backing_field"], value)
#		has_handled = true
#	
#	return has_handled
#
#### -----------------------------------------------------------------------------------------------
