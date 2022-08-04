extends EditorProperty

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

var external_property:
	set(value):
		if value is Array or value is Dictionary:
			external_property = value
		else:
			external_property = null

#--- private variables - order: export > normal var > onready -------------------------------------

var _edited: Object = null
var _options: OptionButton = null

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	_edited = get_edited_object() 
	_add_property_scene()


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
	_options.item_selected.connect(_on_options_item_selected)
	add_focusable(_options)


func _inititalize_property() -> void:
	if external_property == null or external_property.is_empty():
		print("EXTERNAL IS NULL")
		return
	
	var current_value := StringName()
	if _edited.get(get_edited_property()) != null:
		current_value = _edited.get(get_edited_property()) as StringName
	var item_id := 0
	_options.clear()
	_options.add_item("Choose enum value")
	_options.set_item_metadata(item_id, -1)
	
	var properties := []
	if external_property is Dictionary:
		properties = external_property.keys()
	else:
		properties = external_property
	
	for key in properties:
		item_id += 1
		_options.add_item(key)
		if (key as StringName) == current_value:
			_options.set_item_disabled(0, true)
			_options.selected = item_id


func _on_options_item_selected(index: int) -> void:
	if index != 0:
		var new_value := _options.get_item_text(index) as StringName
		emit_changed(get_edited_property(), new_value)

### -----------------------------------------------------------------------------------------------
