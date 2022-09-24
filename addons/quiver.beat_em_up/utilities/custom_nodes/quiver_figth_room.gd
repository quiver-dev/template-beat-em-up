@tool
class_name QuiverFightRoom
extends ReferenceRect

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export_group("Fight Room")
@export var limit_left := 0
@export var limit_top := 0
@export var limit_right := 0
@export var limit_bottom := 0

@export_range(0.1, 3.0, 0.01, "or_greater") var zoom := 1.0
@export_range(0.0, 3.0, 0.01, "or_greater") var zoom_duration := 0.3

var after_fight_use_new_room := false:
	set(value):
		after_fight_use_new_room = value
		notify_property_list_changed()
var after_fight_limit_left := 0
var after_fight_limit_top := 0
var after_fight_limit_right := 0
var after_fight_limit_bottom := 0
var after_fight_zoom := 1.0
var after_fight_zoom_duration := 0.3

#--- private variables - order: export > normal var > onready -------------------------------------

var _preview_camera := false:
	set(value):
		_preview_camera = value
		notify_property_list_changed()
var _preview_after_room := false:
	set(value):
		_preview_after_room = value
		notify_property_list_changed()

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func setup_fight_room() -> void:
	var camera2D := get_viewport().get_camera_2d() as QuiverLevelCamera
	if camera2D == null:
		_push_no_valid_camera_error()
		return
	
	camera2D.delimitate_room(limit_left, limit_top, limit_right, limit_bottom, zoom, zoom_duration)


func setup_after_fight_room() -> void:
	var camera2D := get_viewport().get_camera_2d() as QuiverLevelCamera
	if camera2D == null:
		_push_no_valid_camera_error()
		return
	
	camera2D.delimitate_room(
			after_fight_limit_left, after_fight_limit_top, 
			after_fight_limit_right, after_fight_limit_bottom, 
			after_fight_zoom, after_fight_zoom_duration
	)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _push_no_valid_camera_error() -> void:
	push_error("Did not find a valid QuiverLevelCamera to delimitate room.")

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

func _get_custom_properties() -> Dictionary:
	return {
		"After Fight Room": {
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_GROUP,
			hint_string = "_after_fight_",
		},
		"_after_fight_use_new_room": {
			backing_field = "after_fight_use_new_room",
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		},
		"_after_fight_limit_left": {
			backing_field = "after_fight_limit_left",
			type = TYPE_INT,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		},
		"_after_fight_limit_top": {
			backing_field = "after_fight_limit_top",
			type = TYPE_INT,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		},
		"_after_fight_limit_right": {
			backing_field = "after_fight_limit_right",
			type = TYPE_INT,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		},
		"_after_fight_limit_bottom": {
			backing_field = "after_fight_limit_bottom",
			type = TYPE_INT,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		},
		"_after_fight_zoom": {
			backing_field = "after_fight_zoom",
			type = TYPE_FLOAT,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0.0,3.0,0.01,or_greater",
		},
		"_after_fight_zoom_duration": {
			backing_field = "after_fight_zoom_duration",
			type = TYPE_FLOAT,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0.0,3.0,0.01,or_greater",
		},
		"Editor Previews": {
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_GROUP,
			hint_string = "preview_",
		},
		"preview_camera": {
			backing_field = "_preview_camera",
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		},
		"preview_after_room": {
			backing_field = "_preview_after_room",
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		},
#		"": {
#			backing_field = "",
#			name = "",
#			type = TYPE_NIL,
#			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
#			hint = PROPERTY_HINT_NONE,
#			hint_string = "",
#		},
}

### Custom Inspector built in functions -----------------------------------------------------------

func _get_property_list() -> Array:
	var properties: = []
	
	var custom_properties := _get_custom_properties()
	for key in custom_properties:
		var add_property := true
		var dict: Dictionary = custom_properties[key]
		if not dict.has("name"):
			dict.name = key
		
		if key.begins_with("_after_fight_limit_") or key.begins_with("_after_fight_zoom"):
			add_property = after_fight_use_new_room
		
		if add_property:
			properties.append(dict)
	
	return properties


func _get(property: StringName):
	var value
	
	var custom_properties := _get_custom_properties()
	if property in custom_properties and custom_properties[property].has("backing_field"):
		value = get(custom_properties[property]["backing_field"])
	
	return value


func _set(property: StringName, value) -> bool:
	var has_handled: = false
	
	var custom_properties := _get_custom_properties()
	if property in custom_properties and custom_properties[property].has("backing_field"):
		set(custom_properties[property]["backing_field"], value)
		has_handled = true
	
	return has_handled

### -----------------------------------------------------------------------------------------------
