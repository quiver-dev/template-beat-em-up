@tool
extends EditorPlugin
## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

const PATH_CUSTOM_INSPECTORS = "res://addons/quiver.beat_em_up/custom_inspectors/"

#--- private variables - order: export > normal var > onready -------------------------------------

var _loaded_inspectors := {}

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _enter_tree() -> void:
	_add_custom_inspectors()


func _exit_tree() -> void:
	_remove_custom_inspectors()

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
	var full_path := PATH_CUSTOM_INSPECTORS.plus_file(folder).plus_file(PATH_SCRIPT)
	if ResourceLoader.exists(full_path):
		var custom_inspector := load(full_path).new() as EditorInspectorPlugin
		add_inspector_plugin(custom_inspector)
		_loaded_inspectors[folder] = custom_inspector


func _remove_custom_inspectors() -> void:
	for inspector in _loaded_inspectors.values():
		remove_inspector_plugin(inspector)

### -----------------------------------------------------------------------------------------------
