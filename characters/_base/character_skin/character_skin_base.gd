@tool
class_name QuiverCharacterSkin
extends Node2D
## Base class for any kind of character, either playable or npc.
##
## The skin is based on an [AnimationPlayer] and an [AnimationTree]. There is a base scene you 
## can inherit on [code]res://characters/_base/[/code], but you can use this script on your own
## scene as long as it has a AnimationTree with a state machine in it.
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

## emited by calling [method grab_notify] in grab animations, at the point the grab should 
## connect and link character who is grabbing to grabbed character
signal grab_frame_reached(ref_position: Marker2D)

signal attack_movement_started(direction: Vector2, speed: float)
signal attack_movement_ended

#--- enums ----------------------------------------------------------------------------------------

enum SkinDirection { LEFT = -1, RIGHT = 1}

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

var attributes: QuiverAttributes = null:
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
		skin_direction = value
		if not _blend_positions.is_empty():
			_update_blend_directions()

#--- private variables - order: export > normal var > onready -------------------------------------

## Path to animation tree. [br][br]
## Kept the underscore to make it "private" because it's not suposed to be changed
## from outside of the scene, to point to an external [AnimationTree] for example.
@export_node_path(AnimationTree) var _path_animation_tree := ^"AnimationTree"

## Path to [AnimationNodeStateMachinePlayback]. Usually I create an [AnimationNodeBlendTree] as the
## root for the [AnimationTree] and the [AnimationNodeStateMachine] inside it, so I can do anything 
## with the output of the state machine playback, like changing the time scale for example. 
## Use this to point to the correct path if you structure your [AnimationTree] in a different way. 
## [br][br]
## See [member _path_animation_tree] for "private" reasoning.
@export var _path_playback := "parameters/StateMachine/playback"

## This is also here as a "hack" for the lack of custom typed exports. It is private because I don't 
## want to deal with this in code, it's just an editor field to populate the real property which
## is the public [member attributes]. Once custom typed exports exist this will be converted
## to it.
@warning_ignore(unused_private_class_variable)
@export var _attributes: Resource:
	set(value):
		attributes = value as QuiverAttributes
	get:
		return attributes

@export var debug_prints := false

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

var _blend_positions := []
var _animation_list := []

@onready var _animation_tree := get_node(_path_animation_tree) as AnimationTree
@onready var _playback := _animation_tree.get(_path_playback) as AnimationNodeStateMachinePlayback
@onready var _grab_pivot := get_node(_path_grab_pivot) as Marker2D if _has_grab else null
@onready var _grabbed_pivot := get_node(_path_grabbed_pivot) as Marker2D if _has_grabbed else null

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	_find_all_animation_nodes_from()
	_blend_positions = _get_blend_position_paths_from(_animation_tree)
	
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		_animation_tree.set_deferred("active", false)
		return
	elif QuiverEditorHelper.is_standalone_run(self):
		QuiverEditorHelper.add_debug_camera2D_to(self, Vector2(0,-0.8))
	
	_update_blend_directions()
	_animation_tree.active = true

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

## Main public method for the skin, it will check if the parameter is valid and push an 
## error if it's not. You can also override this method if you need special behavior 
## before playing any specific state.
func transition_to(anim_state: StringName) -> void:
	var value_returned := _is_valid_state(anim_state)
	if not value_returned:
		push_error("%s is not a valid animation state."%[anim_state])
		return
	
	_playback.travel(anim_state)


## Use this method in your character's attack animations as a shortcut to emitting
## [signal attack_input_frames_finished]
func end_of_input_frames() -> void:
	attack_input_frames_finished.emit()


## Ese this method in character's grab animations to emit the signal [signal grab_frame_reached].
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
	if debug_prints and not _animation_name.is_empty():
		print("anim name: %s"%[_animation_name])
	
	if not _playback.get_travel_path().is_empty():
		return
	
	skin_animation_finished.emit()


func start_attack_movement(p_direction: Vector2, p_speed: float) -> void:
	attack_movement_started.emit(p_direction, p_speed)


func stop_attack_movement() -> void:
	attack_movement_ended.emit()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

## Virtual function to be overriden and check for valid states. The parameter is an [int] because
## it expected to use enums or constants for tracking animation states and for autocomplete.
func _is_valid_state(anim_state: StringName) -> bool:
	var value = anim_state in _animation_list
#	print("value: %s | anim_state: %s | Possible states: %s"%[
#			value, anim_state, SkinStates.values()
#	])
	return value


## Helper to create getters for public condition properties.
func _get_animation_tree_condition(path: StringName) -> bool:
	if not is_inside_tree() or not path in _animation_tree:
		return false
	return _animation_tree.get(path)


## Helper to create setters for public condition properties.
func _set_animation_tree_condition(path: StringName, value: bool) -> void:
	if not is_inside_tree():
		await ready
	
	if not path in _animation_tree:
		return
	
	_animation_tree.set(path, value)


func _update_blend_directions() -> void:
	for path in _blend_positions:
		_animation_tree[path] = skin_direction


func _get_blend_position_paths_from(animation_tree: AnimationTree) -> Array:
	var blend_positions = []
	
	for property in animation_tree.get_property_list():
		if property.usage >= PROPERTY_USAGE_DEFAULT and property.name.ends_with("blend_position"):
			blend_positions.append(property.name)
	
	return blend_positions


func _find_all_animation_nodes_from(
		animation_node: AnimationNode = null, 
		property_path := "parameters"
) -> void:
	if property_path == "parameters":
		animation_node = _animation_tree.tree_root
	
	if animation_node == null:
		return
	
	var should_ignore_child_state_machines := true
	if animation_node is AnimationNodeStateMachine:
		should_ignore_child_state_machines = false
	
	var properties := animation_node.get_property_list()
	for property_dict in properties:
		match property_dict:
			{"hint_string": "AnimationNode", ..}:
				_handle_animation_node(
						animation_node.get(property_dict.name), 
						property_dict.name,
						property_path,
						should_ignore_child_state_machines
				)


func _handle_animation_node(
		node: AnimationNode, 
		property_name: String, 
		property_path: String,
		ignore_groups := false
) -> void:
	if node == null:
		if property_name.find("Start") == -1 and property_name.find("End") == -1:
			push_warning("%s is null"%[property_name])
		return
	
	var node_class := node.get_class()
	match node_class:
		"AnimationNodeAnimation", "AnimationNodeBlendSpace1D", \
		"AnimationNodeBlendSpace2D", "AnimationNodeBlendTree":
			var animation_name := _filter_main_playback_path(property_name, property_path) 
			_animation_list.append(animation_name)
		"AnimationNodeStateMachine":
			if not ignore_groups :
				var animation_name := _filter_main_playback_path(property_name, property_path) 
				_animation_list.append(animation_name)
			
			var parameter_name = _get_actual_parameter_name(property_name)
			property_path = property_path.plus_file(parameter_name)
			_find_all_animation_nodes_from(node, property_path)
		_:
			if node is AnimationRootNode:
				push_error("Unknown animation node: %s"%[node_class])


func _filter_main_playback_path(animation_name: String, path: String) -> StringName:
	var parameter_name = _get_actual_parameter_name(animation_name)
	var full_path = path.plus_file(parameter_name)
	var path_to_main_playback = _path_playback.replace("playback", "")
	var value = full_path.replace(path_to_main_playback, "") as StringName
	return value


## property names for these AnimationNodes are in the format "nodes/name/node" 
## or "states/name/node" so this is to get the middle part of that name
func _get_actual_parameter_name(property_name: String) -> String:
	var parameter_name = property_name.split("/")[1]
	return parameter_name

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

const CUSTOM_PROPERTIES = {
	"Grab Options": {
		backing_field = "",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY,
	},
	"has_grab": {
		backing_field = "_has_grab",
		type = TYPE_BOOL,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_NONE,
		hint_string = "",
	},
	"path_grab_pivot": {
		backing_field = "_path_grab_pivot",
		type = TYPE_NODE_PATH,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_NODE_PATH_VALID_TYPES,
		hint_string = "Marker2D",
	},
	"has_grabbed": {
		backing_field = "_has_grabbed",
		type = TYPE_BOOL,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_NONE,
		hint_string = "",
	},
	"path_grabbed_pivot": {
		backing_field = "_path_grabbed_pivot",
		type = TYPE_NODE_PATH,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_NODE_PATH_VALID_TYPES,
		hint_string = "Marker2D",
	},
#	"": {
#		backing_field = "",
#		name = "",
#		type = TYPE_NIL,
#		usage = usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
#		hint = PROPERTY_HINT_NONE,
#		hint_string = "",
#	},
}

### Custom Inspector built in functions -----------------------------------------------------------

func _get_property_list() -> Array:
	var properties: = []
	
	for key in CUSTOM_PROPERTIES:
		var add_property := true
		var dict: Dictionary = CUSTOM_PROPERTIES[key].duplicate()
		if not dict.has("name"):
			dict.name = key
		
		match key:
			"path_grab_pivot":
				if not _has_grab:
					add_property = false
			"path_grabbed_pivot":
				if not _has_grabbed:
					add_property = false
		
		if add_property:
			properties.append(dict)
	
	return properties


func _get(property: StringName):
	var value
	
	if property in CUSTOM_PROPERTIES and CUSTOM_PROPERTIES[property].has("backing_field"):
		value = get(CUSTOM_PROPERTIES[property]["backing_field"])
	
	return value


func _set(property: StringName, value) -> bool:
	var has_handled: = false
	if property in CUSTOM_PROPERTIES and CUSTOM_PROPERTIES[property].has("backing_field"):
		set(CUSTOM_PROPERTIES[property]["backing_field"], value)
		has_handled = true

	return has_handled

### -----------------------------------------------------------------------------------------------
