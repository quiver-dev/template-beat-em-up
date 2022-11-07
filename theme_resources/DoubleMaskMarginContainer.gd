extends MarginContainer

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export var extra_margin_top := 0
@export var extra_margin_bottom := 0
@export_node_path var path_button: NodePath = NodePath()

#--- private variables - order: export > normal var > onready -------------------------------------

@onready var _button := get_node(path_button) as DoubleMaskTextureButton

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	QuiverEditorHelper.connect_between(_button.focus_entered, _expand_margins)
	QuiverEditorHelper.connect_between(_button.focus_exited, _collapse_margins)

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _expand_margins() -> void:
	if not is_instance_valid(_button):
		return
	
	var current_top_value := 0.0
	if has_theme_constant_override("margin_top"):
		current_top_value = get_theme_constant("margin_top")
	add_theme_constant_override("margin_top", current_top_value + extra_margin_top)
	
	var current_bottom_value := 0.0 
	if has_theme_constant_override("margin_bottom"):
		current_bottom_value = get_theme_constant("margin_bottom")
	add_theme_constant_override("margin_bottom", current_bottom_value + extra_margin_bottom)


func _collapse_margins() -> void:
	if not is_instance_valid(_button):
		return
	
	var current_top_value := 0.0
	if has_theme_constant_override(&"margin_top"):
		current_top_value = self["theme_override_constants/margin_top"]
	add_theme_constant_override(&"margin_top", current_top_value - extra_margin_top)
	
	var current_bottom_value := 0.0
	if has_theme_constant_override(&"margin_bottom"):
		current_bottom_value = self["theme_override_constants/margin_bottom"]
	add_theme_constant_override(&"margin_bottom", current_bottom_value - extra_margin_bottom)

### -----------------------------------------------------------------------------------------------
