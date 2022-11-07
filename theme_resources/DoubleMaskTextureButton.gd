extends TextureButton

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export var mask_normal: BitMap = null
@export var mask_hover: BitMap = null

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	QuiverEditorHelper.connect_between(mouse_entered, _on_mouse_entered)
	QuiverEditorHelper.connect_between(mouse_exited, _on_mouse_exited)
	QuiverEditorHelper.connect_between(focus_entered, _set_mask_hover)
	QuiverEditorHelper.connect_between(focus_exited, _set_mask_normal)
	_toggled(button_pressed)


func _toggled(p_button_pressed: bool) -> void:
	if p_button_pressed:
		_set_mask_hover()
	else:
		_set_mask_normal()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _set_mask_hover() -> void:
	texture_click_mask = mask_hover


func _set_mask_normal() -> void:
	texture_click_mask = mask_normal


func _on_mouse_entered() -> void:
	grab_focus()


func _on_mouse_exited() -> void:
	release_focus()

### -----------------------------------------------------------------------------------------------
