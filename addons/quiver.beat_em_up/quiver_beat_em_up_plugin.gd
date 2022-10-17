@tool
extends EditorPlugin
## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const COLOR_GODOT_ORANGE = Color("ff786b")
const INVALID_HANDLE = -1

#--- public variables - order: export > normal var > onready --------------------------------------

const PATH_CUSTOM_INSPECTORS = "res://addons/quiver.beat_em_up/custom_inspectors/"
const PATH_CUSTOM_OVERLAYS = "res://addons/quiver.beat_em_up/custom_overlays/"

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
	QuiverCyclicHelper.SETTINGS_DISABLE_PLAYER_DETECTOR: {
			value = false,
			type = TYPE_BOOL,
			hint = PROPERTY_HINT_NONE,
			hint_string = "",
	}
}

#--- private variables - order: export > normal var > onready -------------------------------------

var _loaded_inspectors := {}
var _loaded_overlays := []

var _current_overlay_handler: QuiverCustomOverlay = null

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _enter_tree() -> void:
	_add_custom_inspectors()
	_add_custom_overlays()


func _exit_tree() -> void:
	_remove_custom_inspectors()


func _enable_plugin() -> void:
	_add_plugin_settings()
	_add_autoloads()


func _disable_plugin() -> void:
	_remove_plugin_settings()
	_remove_autoloads()


func _handles(object) -> bool:
	var value := false
	
	for overlay in _loaded_overlays:
		
		value = (overlay as QuiverCustomOverlay).handles(object)
		if value:
			if _current_overlay_handler != null and _current_overlay_handler != overlay:
				_current_overlay_handler.make_visible(false)
			
			_current_overlay_handler = overlay
			break
	
	if not value and _current_overlay_handler != null:
		_current_overlay_handler.make_visible(false)
		_current_overlay_handler = null
	
	return value


func _edit(object) -> void:
	if _current_overlay_handler == null:
		return
	
	_current_overlay_handler.edit(object)


func _make_visible(visible: bool) -> void:
	if _current_overlay_handler == null:
		return
	
	_current_overlay_handler.make_visible(visible)


func _forward_canvas_draw_over_viewport(viewport_control: Control) -> void:
	if _current_overlay_handler == null:
		return
	
	_current_overlay_handler.forward_canvas_draw_over_viewport(viewport_control)


func _forward_canvas_gui_input(event: InputEvent) -> bool:
	var has_handled := false
	
	if _current_overlay_handler != null:
		has_handled = _current_overlay_handler.forward_canvas_gui_input(event)
	
	return has_handled

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _add_custom_inspectors() -> void:
	var dir := DirAccess.open(PATH_CUSTOM_INSPECTORS)
	
	if dir != null:
		dir.list_dir_begin()
		var folder_name := dir.get_next()
		while not folder_name.is_empty():
			if dir.current_is_dir(): 
				_load_custom_inspector_from(folder_name)
			folder_name = dir.get_next()
	else:
		var error_msg = "Error code: %s | Something went wrong trying to open %s"%[
			DirAccess.get_open_error(), PATH_CUSTOM_INSPECTORS
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


func _add_custom_overlays() -> void:
	var dir := DirAccess.open(PATH_CUSTOM_OVERLAYS)
	
	if dir != null:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while not file_name.is_empty():
			if file_name.ends_with(".gd"): 
				var script := load(PATH_CUSTOM_OVERLAYS.path_join(file_name)) as GDScript
				var object := script.new() as QuiverCustomOverlay
				if object != null:
					object.main_plugin = self
					_loaded_overlays.append(object)
				
			file_name = dir.get_next()
	else:
		var error_msg = "Error code: %s | Something went wrong trying to open %s"%[
			DirAccess.get_open_error(), PATH_CUSTOM_INSPECTORS
		]
		push_error(error_msg)



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
