extends EditorProperty

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _state: QuiverState = null
var _state_machine:QuiverStateMachine = null
var _options: OptionButton = null

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	_state = get_edited_object()
	_state_machine = _state._actions if _state is QuiverAiState else _state._state_machine
	_add_property_scene()
	_inititalize_property()


func _update_property() -> void:
	_inititalize_property()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _add_property_scene() -> void:
	_options = OptionButton.new()
	_options.clip_text = true
	add_child(_options, true)
	QuiverEditorHelper.connect_between(_options.item_selected, _on_options_item_selected)
	add_focusable(_options)


func _inititalize_property() -> void:
	var current_value := _state.get(get_edited_property()) as NodePath
	var list := _get_list_of_action_states()
	var item_id := 0
	_options.clear()
	_options.add_item("Choose State")
	for path in list:
		item_id += 1
		_options.add_item(path)
		if path == current_value:
			_options.set_item_disabled(0, true) # Disables "Choose State" option
			_options.selected = item_id


func _get_list_of_action_states() -> Array:
	var list := ["Node not ready yet"]
	if _state_machine == null:
		return list
	
	list = _get_leaf_nodes_path_list(_state_machine)
	return list


func _get_leaf_nodes_path_list(start_node: Node, node_list := []) -> Array:
	if start_node.get_child_count() == 0 or start_node is QuiverStateSequence:
		if _should_add_leaf_node_to_list(start_node):
			node_list.append(_state_machine.get_path_to(start_node))
	else:
		for child in start_node.get_children():
			if _should_skip_child_nodes(child):
				continue
			
			_get_leaf_nodes_path_list(child, node_list)
	
	return node_list


func _should_add_leaf_node_to_list(node: Node) -> bool:
	return node is QuiverState


func _should_skip_child_nodes(node: Node) -> bool:
	return not node is QuiverState or node is QuiverStateSequence


func _on_options_item_selected(index: int) -> void:
	if index != 0:
		var new_value := _options.get_item_text(index)
		emit_changed(get_edited_property(), new_value)

### -----------------------------------------------------------------------------------------------
