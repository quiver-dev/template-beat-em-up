extends EditorProperty

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

var external_enum: ExternalEnum

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

func create_external_enum(object: Object, p_name: String, p_enum: String) -> void:
	external_enum = ExternalEnum.new(object, p_name, p_enum)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _add_property_scene() -> void:
	_options = OptionButton.new()
	add_child(_options, true)
	_options.item_selected.connect(_on_options_item_selected)
	add_focusable(_options)


func _inititalize_property() -> void:
	var current_value := _edited.get(get_edited_property()) as int
	var item_id := 0
	_options.clear()
	_options.add_item("Choose enum value")
	_options.set_item_metadata(item_id, -1)
	for key in external_enum.get_enum_keys():
		item_id += 1
		var enum_value := external_enum.get_value_at(item_id-1)
		_options.add_item(key)
		_options.set_item_metadata(item_id, enum_value)
		if enum_value == current_value:
			_options.set_item_disabled(0, true)
			_options.selected = item_id


func _on_options_item_selected(index: int) -> void:
	if index != 0:
		var new_value := _options.get_item_metadata(index) as int
		emit_changed(get_edited_property(), new_value)

### -----------------------------------------------------------------------------------------------


class ExternalEnum:
	var ref_enum
	
	func _init(object: Object, p_name: String, p_enum_name: String) -> void:
		ref_enum = object.get(p_name).get(p_enum_name)
	
	func get_enum_keys() -> Array:
		return ref_enum.keys()
	
	func get_enum_values() -> Array:
		return ref_enum.values()
	
	func get_key_at(index: int) -> String:
		return ref_enum.keys()[index]
	
	func get_value_at(index: int) -> int:
		return ref_enum.values()[index]
