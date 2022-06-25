@tool
extends HBoxContainer

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

var edited_node: Node2D = null

@onready var _options := $OptionButton as OptionButton

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() ->void:
	if not edited_node.has_meta(QuiverCollisionTypes.META_KEY):
		_add_collision_preset_meta()
	
	_populate_options_preset()
	_select_current_preset()
	
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _add_collision_preset_meta() -> void:
	var parent = edited_node.get_parent()
	var preset_dict := QuiverCollisionTypes.PRESETS.default as Dictionary
	
	if parent != null and parent.has_meta(QuiverCollisionTypes.META_KEY):
		var parents_type = parent.get_meta(QuiverCollisionTypes.META_KEY)
		preset_dict = QuiverCollisionTypes.PRESETS[parents_type]
	
	QuiverCollisionTypes.apply_preset_to(preset_dict, edited_node)


func _populate_options_preset() -> void:
	for key in QuiverCollisionTypes.PRESETS.keys():
		_options.add_item(key)


func _select_current_preset() -> void:
	var current_type := edited_node.get_meta(QuiverCollisionTypes.META_KEY) as StringName
	for index in _options.item_count:
		if _options.get_item_text(index) == current_type:
			_options.selected = index
			break


func _on_option_button_item_selected(index: int) -> void:
	var value := _options.get_item_text(index)
	QuiverCollisionTypes.apply_preset_to(QuiverCollisionTypes.PRESETS[value], edited_node)

### -----------------------------------------------------------------------------------------------
