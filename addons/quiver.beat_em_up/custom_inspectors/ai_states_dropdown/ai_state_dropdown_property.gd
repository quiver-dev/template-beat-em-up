extends EditorProperty

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _node: Node = null
var _options: OptionButton = null

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	_node = get_edited_object() as Node
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
	add_child(_options, true)
	_options.item_selected.connect(_on_options_item_selected)
	add_focusable(_options)


func _inititalize_property() -> void:
	var current_value := _node.get(get_edited_property()) as String
	var list := _get_ai_state_list()
	var item_id := 0
	_options.clear()
	_options.add_item("Choose State")
	for path in list:
		item_id += 1
		_options.add_item(path)
		if (path as String) == current_value:
			_options.set_item_disabled(0, true)
			_options.selected = item_id


func _get_ai_state_list() -> Array:
	var value = []
	if _node.has_method("get_list_of_ai_states"):
		value = _node.get_list_of_ai_states()
	elif _node is QuiverStateSequence and _node._state_machine is QuiverAiStateMachine:
		value = _node.get_list_of_ai_states()
	return value

func _on_options_item_selected(index: int) -> void:
	if index != 0:
		var new_value := _options.get_item_text(index)
		emit_changed(get_edited_property(), new_value)

### -----------------------------------------------------------------------------------------------
