@tool
class_name QuiverCustomOverlay
extends RefCounted

## Base class to help create custom editor gizmos. It has public functions for all the
## built in functions the main plugin will have to delegate to it, and should be overridden 
## accodingly to being 2D overlays or 3D gizmos by a script that extends this one.
## Expects to receive a reference to the main plugin after initialization and before use.

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

var main_plugin: EditorPlugin = null

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func handles(object) -> bool:
	_push_override_error("handles", get_script().resource_path)
	return false


func edit(object) -> void:
	_push_override_error("edit", get_script().resource_path)
	pass


func make_visible(visible: bool) -> void:
	_push_override_error("make_visible", get_script().resource_path)
	pass


func forward_canvas_draw_over_viewport(viewport_control: Control) -> void:
	_push_override_error("forward_canvas_draw_over_viewport", get_script().resource_path)
	pass


func forward_canvas_gui_input(event: InputEvent) -> bool:
	_push_override_error("forward_canvas_gui_input", get_script().resource_path)
	return false


func forward_canvas_force_draw_over_viewport(viewport_control: Control) -> void:
	_push_override_error("forward_canvas_force_draw_over_viewport", get_script().resource_path)
	pass


func forward_3d_draw_over_viewport(viewport_control: Control) -> void:
	_push_override_error("_forward_3d_draw_over_viewport", get_script().resource_path)
	pass


func forward_3d_force_draw_over_viewport(viewport_control: Control) -> void:
	_push_override_error("_forward_3d_force_draw_over_viewport", get_script().resource_path)
	pass


func forward_3d_gui_input(viewport_camera: Camera3D, event: InputEvent) -> int:
	_push_override_error("_forward_3d_gui_input", get_script().resource_path)
	return int(false)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _push_override_error(method_name: String, script_path: String) -> void:
	var msg := "%s at %s expects to be overriden by a child class. It doesn nothing on its own"%[
		method_name, script_path
	]
	push_warning(msg)

### -----------------------------------------------------------------------------------------------
