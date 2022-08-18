@tool
extends Control

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const META_MIRRORED_NAME = "mirrored_name"
const META_OVERWRITE = "should_overwrite"

const ERROR_NO_TRACK_FOUND = "No position, rotation or flip_h tracks found to be mirrored."

#--- public variables - order: export > normal var > onready --------------------------------------

var animation: Animation = null:
	set(value):
		animation = value
		_configure_animation_properties()

#--- private variables - order: export > normal var > onready -------------------------------------

var _changed_report := ""

@onready var _line_edit := $NameLine/LineEdit as LineEdit
@onready var _check_box := $OverwriteLine/CheckBox as CheckBox
@onready var _finished_popup := $AcceptDialog as AcceptDialog
@onready var _report_label := $AcceptDialog/RichTextLabel as RichTextLabel

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	pass

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_button_pressed() -> void:
	_changed_report = ERROR_NO_TRACK_FOUND
	var new_animation := animation.duplicate() as Animation
	var total_tracks := new_animation.get_track_count()
	for track_index in total_tracks:
		var path := new_animation.track_get_path(track_index)
		var property_subpath := path.get_concatenated_subnames()
		if _is_mirrorable_property(property_subpath):
			if _changed_report == ERROR_NO_TRACK_FOUND:
				_changed_report = "Track: %s "%[path]
			else:
				_changed_report += "\nTrack: %s "%[path]
			_mirror_track_values(new_animation, track_index, property_subpath)
	
	if _changed_report != ERROR_NO_TRACK_FOUND:
		var folder := animation.resource_path.get_base_dir()
		var file_name := animation.get_meta(META_MIRRORED_NAME) as String
		var new_path := folder.plus_file(file_name)
		new_animation.resource_name = file_name.get_basename()
		ResourceSaver.save(new_animation, new_path, ResourceSaver.FLAG_CHANGE_PATH)
	
	_report_label.text = _changed_report
	_finished_popup.popup_centered(_finished_popup.min_size)
	print("report: %s"%[_changed_report])


func _is_mirrorable_property(property_name: String) -> bool:
	const VALID_PROPERTIES = [
		"flip_h",
		"position",
		"position:x",
		"rotation",
	]
	var value = property_name in VALID_PROPERTIES
	return value


func _mirror_track_values(p_animation: Animation, track_index: int, subpath: String) -> void:
	var key_count := p_animation.track_get_key_count(track_index)
	for key_index in key_count:
		var value = p_animation.track_get_key_value(track_index, key_index)
		var mirrored_value
		match subpath:
			"flip_h":
				mirrored_value = not value
			"position":
				mirrored_value = Vector2(value.x * -1, value.y)
			"position:x", "rotation":
				mirrored_value = value * -1
		
		p_animation.track_set_key_value(track_index, key_index, mirrored_value)
		_changed_report += "\n\t value: %s ------> %s"%[value, mirrored_value]


func _configure_animation_properties() -> void:
	if animation == null:
		return
	
	if not is_inside_tree():
		await ready
	
	if not animation.has_meta(META_MIRRORED_NAME):
		var file_name = animation.resource_path.get_file()
		var extension = ".%s"%[animation.resource_path.get_extension()]
		var anim_name = file_name.replace(extension, "")
		var mirrored_name := _get_mirrored_name(anim_name) + extension
		animation.set_meta(META_MIRRORED_NAME, mirrored_name)
	
	_line_edit.text = animation.get_meta(META_MIRRORED_NAME)
	
	if not animation.has_meta(META_OVERWRITE):
		animation.set_meta(META_OVERWRITE, _check_box.button_pressed)
	
	_check_box.button_pressed = animation.get_meta(META_OVERWRITE)


func _get_mirrored_name(anim_name: String) -> String:
	var new_name = "%s_mirrored"%[anim_name]
	if anim_name.ends_with("left"):
		new_name = anim_name.replace("left", "right")
	elif anim_name.ends_with("right"):
		new_name = anim_name.replace("right", "left")
	
	return new_name


func _on_line_edit_text_changed(new_text: String) -> void:
	animation.set_meta(META_MIRRORED_NAME, new_text)


func _on_check_box_toggled(button_pressed: bool) -> void:
	animation.set_meta(META_OVERWRITE, button_pressed)

### -----------------------------------------------------------------------------------------------
