extends EditorProperty

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _state: QuiverState = null
var _options: OptionButton = null

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	_state = get_edited_object() as QuiverState
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
	var current_value := _state.get(get_edited_property()) as String
	var list := _state.get_list_of_action_states()
	var item_id := 0
	_options.clear()
	_options.add_item("Choose State")
	for path in list:
		item_id += 1
		_options.add_item(path)
		if path == current_value:
			_options.set_item_disabled(0, true)
			_options.selected = item_id


func _on_options_item_selected(index: int) -> void:
	if index != 0:
		var new_value := _options.get_item_text(index) as NodePath
		emit_changed(get_edited_property(), new_value)

### -----------------------------------------------------------------------------------------------
