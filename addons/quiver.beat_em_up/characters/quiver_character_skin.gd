@tool
class_name QuiverCharacterSkin
extends Node2D
## Base class for any kind of character, either playable or npc.
##
## The skin is based on an [AnimationPlayer] and an [AnimationTree]. There is a base scene you 
## can inherit on [code]res://addons/quiver.beat_em_up/characters/[/code], but you can use 
## this script on your own scene as long as it has a AnimationTree with a state machine in it.
## [br][br]
## If you do use it on another scene, just configure the exported variables accordingly.
## [br][br]
## [method transition_to] should work for most cases, but can be overriden if a character needs 
## special behavior for any given animation.


### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

## called by animations at their last frame. This is a workaround for [AnimationPlayer] 
## not emitting any of it's signals when it's controlled by an [AnimationTree].
signal skin_animation_finished

## called by attack animations at the point where they stop accepting input for combos
signal attack_input_frames_finished
## called by attack animations that make the character move, like a dash attack for example.
signal attack_movement_started(direction: Vector2, speed: float)
## called by attack animations when it should stop moving a character.
signal attack_movement_ended

## emited by calling [method grab_notify] in grab animations, at the point the grab should 
## connect and link the character who is grabbing to grabbed character
signal grab_frame_reached(ref_position: Marker2D)

#--- enums ----------------------------------------------------------------------------------------

enum SkinDirection { LEFT = -1, RIGHT = 1 }

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export var attributes: QuiverAttributes = null:
	set(value):
		attributes = value
		if not Engine.is_editor_hint():
			if not is_inside_tree():
				await ready
			if attributes != null:
				attributes.grabbed_offset = _grabbed_pivot
			
			get_tree().set_group(StringName(get_path()), "character_attributes", attributes)


@export var skin_direction: SkinDirection = SkinDirection.RIGHT:
	set(value):
		var has_changed := value != skin_direction
		skin_direction = value
		
		if has_changed:
			if not is_inside_tree():
				await ready
			_skin_direction_updated()

#--- private variables - order: export > normal var > onready -------------------------------------

# Grab Settings
var _has_grab := true:
	set(value):
		_has_grab = value
		notify_property_list_changed()
var _path_grab_pivot := ^"Positions/GrabPivot"
var _has_grabbed := true:
	set(value):
		_has_grabbed = value
		notify_property_list_changed()
var _path_grabbed_pivot := ^"Positions/GrabbedPivot"

var _animation_list: Array[StringName] = []

@onready var _grab_pivot := get_node(_path_grab_pivot) as Marker2D if _has_grab else null
@onready var _grabbed_pivot := get_node(_path_grabbed_pivot) as Marker2D if _has_grabbed else null

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	_populate_animation_list()
	
	if Engine.is_editor_hint():
		_in_editor_ready()
	elif QuiverEditorHelper.is_standalone_run(self):
		_standalone_run_ready()
	else:
		_runtime_ready()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

## Virtual function to be overriden. It's the main public method for the skin, where you should fill in the logic for your skin to play animations. Here is a suggestion of what your body should be like, but don't use this directly.
func transition_to(anim_state: StringName) -> void:
#	if _is_valid_state(anim_state):
#		# _is_valid_state already raises an error message if it's not valid
#		# do any setup if needed
#		# play animation
	push_warning(QuiverEditorHelper.WARNING_VIRTUAL_FUNC%["transition_to"])


## Use this method in your character's attack animations as a shortcut to emitting
## [signal attack_input_frames_finished]
func end_of_input_frames() -> void:
	attack_input_frames_finished.emit()


## Use this method in character's grab animations to emit the signal [signal grab_frame_reached].
## The variable [member _path_grab_pivot] must be correctly set for this to work.
func grab_notify() -> void:
	if _has_grab:
		if not is_instance_valid(_grab_pivot) and not _path_grab_pivot.is_empty():
			_grab_pivot = get_node_or_null(_path_grab_pivot)
		
		if not is_instance_valid(_grab_pivot):
			push_error("Could not get grab pivot Position 2D from path: %s"%[_path_grab_pivot])
			return
		
		grab_frame_reached.emit(_grab_pivot)


## Use this method at the end of your character's attack animations as a shortcut to emitting
## [signal skin_animation_finished)]
func end_of_skin_animation(_animation_name := "") -> void:
	# This usually helps a bit when debugging weird errors with AnimationTree, so leaving this here.
	QuiverDebugLogger.log_message([get_path(), "end of skin animation", _animation_name])
	skin_animation_finished.emit()


func start_attack_movement(p_direction: Vector2, p_speed: float) -> void:
	attack_movement_started.emit(p_direction, p_speed)


func stop_attack_movement() -> void:
	attack_movement_ended.emit()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

## Virtual function to be overriden. Here you should populate the list of animations or 
## "skin states" that you have. This should not be used directly, as it does nothing by default.
func _populate_animation_list() -> void:
	push_warning(QuiverEditorHelper.WARNING_VIRTUAL_FUNC%["_populate_animation_list"])


## Virtual function to be overriden. This is called whenever the [member skin_direction] is 
## changed. 
func _skin_direction_updated() -> void:
	push_warning(QuiverEditorHelper.WARNING_VIRTUAL_FUNC%["_skin_direction_updated"])


## Virtual function to be overriden. This is called during ready, only when opening the scene 
## in the editor. Might be useful for guarding against unwanted tool execution and doing editor 
## only things
func _in_editor_ready() -> void:
	push_warning(QuiverEditorHelper.WARNING_VIRTUAL_FUNC%["_in_editor_ready"])


## Virtual function that can be overriden. This is called only when running the current scene in 
## isolation either using F6 or clicking the "Run Current Scene" or "Run Specific Scene" button 
## on the top right. This is useful to do any setup for testing the skin quickly. 
## [br][br]
## By default it sets a debug camera so that the skin is visible, but can be overriden 
## to do whatever you need.
func _standalone_run_ready() -> void:
	QuiverEditorHelper.add_debug_camera2D_to(self, Vector2(0,-0.8))


## Actual code that will be run on [method _ready] only when the game is actually running, 
## be exported or running through the editor. By default it updates the skin direction because 
## the setter for [member _skin_direction] might not trigger an update if it's the same as 
## the default value.
func _runtime_ready() -> void:
	_skin_direction_updated()


## Virtual function to be overriden and check for valid states. The parameter is an [StringName] 
## because it expects to use a populated [member _animation_list] for tracking animation states.
func _is_valid_state(anim_state: StringName) -> bool:
	var value = anim_state in _animation_list
	if not value:
		push_error("Skin: %s | %s is not a valid animation state."%[name, anim_state])
	return value

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

func _get_custom_properties() -> Dictionary:
	var custom_properties := {
		"Grab Options": {
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_CATEGORY,
		},
		"_has_grab": {
			default_value = true,
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_NONE,
			hint_string = "",
		},
		"_path_grab_pivot": {
			default_value = ^"Positions/GrabPivot",
			type = TYPE_NODE_PATH,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_NODE_PATH_VALID_TYPES,
			hint_string = "Marker2D",
		},
		"_has_grabbed": {
			default_value = true ,
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_NONE,
			hint_string = "",
		},
		"_path_grabbed_pivot": {
			default_value = ^"Positions/GrabbedPivot",
			type = TYPE_NODE_PATH,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_NODE_PATH_VALID_TYPES,
			hint_string = "Marker2D",
		},
#		"": {
#			backing_field = "", # use if dict key and variable name are different
#			default_value = "", # use if you want property to have a default value
#			type = TYPE_NIL,
#			usage = PROPERTY_USAGE_DEFAULT,
#			hint = PROPERTY_HINT_NONE,
#			hint_string = "",
#		},
	}
	
	if not _has_grab:
		custom_properties.erase("_path_grab_pivot")
	
	if not _has_grabbed:
		custom_properties.erase("_path_grabbed_pivot")
	
	return custom_properties

### Custom Inspector built in functions -----------------------------------------------------------

func _get_property_list() -> Array:
	var properties: = []
	
	var custom_properties := _get_custom_properties()
	for key in custom_properties:
		var dict: Dictionary = custom_properties[key]
		if not dict.has("name"):
			dict.name = key
		properties.append(dict)
	
	return properties


func _property_can_revert(property: StringName) -> bool:
	var custom_properties := _get_custom_properties()
	if property in custom_properties and custom_properties[property].has("default_value"):
		return true
	else:
		return false


func _property_get_revert(property: StringName):
	var value
	
	var custom_properties := _get_custom_properties()
	if property in custom_properties and custom_properties[property].has("default_value"):
		value = custom_properties[property]["default_value"]
	
	return value


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
