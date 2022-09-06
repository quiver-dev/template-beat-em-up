@tool
extends HBoxContainer

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

signal add_node_to(node_to_add: Node, parent_node: Node)

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const BASE_FOLDER = "res://addons/quiver.beat_em_up/characters/action_states/"
const DEFAULT_TEXT = "Choose Character Action"

#--- public variables - order: export > normal var > onready --------------------------------------

var selected_node: Node = null

#--- private variables - order: export > normal var > onready -------------------------------------

var _actions_by_folders := {}
var _selected_script := ""
var _selected_script_name := ""

@onready var _options := $OptionButton as OptionButton
@onready var _confirm := $Confirm as Button

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	_options.clear()
	QuiverEditorHelper.disable_all_processing(self)
	_scrap_action_names(_actions_by_folders)
	_populate_options_from(_actions_by_folders)
	_confirm.disabled = true

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _scrap_action_names(target_dictionary: Dictionary, path := BASE_FOLDER) -> void:
	var dir := Directory.new()
	var error := dir.open(path)
	if error == OK:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while not file_name.is_empty():
			if dir.current_is_dir(): 
				target_dictionary[file_name] = {}
				_scrap_action_names(target_dictionary[file_name], path.path_join(file_name))
			elif file_name.ends_with(".gd"):
				var key := file_name.trim_suffix(".gd")
				target_dictionary[key] = path.path_join(file_name)
			file_name = dir.get_next()
	else:
		var error_msg = "Error code: %s | Something went wrong trying to open %s"%[
			error, BASE_FOLDER
		]
		push_error(path)


func _populate_options_from(dict: Dictionary, starting_index := 0) -> int:
	var index := starting_index
	if index == 0:
		_options.add_item(DEFAULT_TEXT)
	
	var ordered_keys = dict.keys()
	ordered_keys.sort_custom(_sort_categories)
	for key in ordered_keys:
		index += 1
		if key.begins_with("quiver_"):
			_options.add_item(key)
			_options.set_item_metadata(index, dict[key])
		else:
			_options.add_separator(key)
			index = _populate_options_from(dict[key], index)
	
	return index


func _sort_categories(a: String, b: String) -> bool:
	var a_before_b := a < b
	
	if a.begins_with("quiver_") and not b.begins_with("quiver_"):
		a_before_b = true
	elif not a.begins_with("quiver_") and b.begins_with("quiver_"):
		a_before_b = false
	
	return a_before_b


func _on_option_button_item_selected(index: int) -> void:
	if index > 0:
		_confirm.disabled = false
		_selected_script = _options.get_item_metadata(index)
		_selected_script_name = (
				_options.get_item_text(index)
					.capitalize()
					.replace(" ", "")
					.replace("QuiverAction", "")
		)
	else:
		_confirm.disabled = true


func _on_confirm_pressed() -> void:
	var node = load(_selected_script).new()
	node.name = _selected_script_name
	
	add_node_to.emit(node, selected_node)

### -----------------------------------------------------------------------------------------------
