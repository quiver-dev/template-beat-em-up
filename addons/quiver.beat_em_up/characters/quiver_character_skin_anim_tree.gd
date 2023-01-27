@tool
class_name  QuiverCharacterSkinAnimTree 
extends QuiverCharacterSkin
## Extends base CharacterSkin class, for skins that use AnimationTree.

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

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

var _blend_positions := []

@onready var _animation_tree := get_node(_path_animation_tree) as AnimationTree
@onready var _playback := _animation_tree.get(_path_playback) as AnimationNodeStateMachinePlayback

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _get_configuration_warnings() -> PackedStringArray:
	var msgs := PackedStringArray()
	
	if not _animation_tree:
		msgs.append("Invalid _path_animation_tree: %s"%[_path_animation_tree])
	
	if not _playback:
		msgs.append(
				"Invalid _path_playback: %s. Could not find playback in AnimationTree"%[
					_path_playback
				]
		)
	
	return msgs

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

## Main public method for the skin, it will check if the parameter is valid and transition to it.
func transition_to(anim_state: StringName) -> void:
	if _is_valid_state(anim_state):
		_playback.travel(anim_state)


func end_of_skin_animation(_animation_name := "") -> void:
	# I really don't remember why this is here, or if it is still necessary. I think I added this
	# as a workaround for some AnimationTree bug, but really don't know it I need it. Maybe to help
	# with the method being triggered more than once??
	if not _playback.get_travel_path().is_empty():
		QuiverDebugLogger.log_message([get_path(), "end of skin animation", _animation_name])
		return
	
	super()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _populate_animation_list() -> void:
	_find_all_animation_nodes_from()
	_blend_positions = _get_blend_position_paths_from(_animation_tree)


func _skin_direction_updated() -> void:
	_update_blend_directions()


func _in_editor_ready() -> void:
	QuiverEditorHelper.disable_all_processing(self)
	_animation_tree.set_deferred("active", false)


func _runtime_ready() -> void:
	super()
	_animation_tree.active = true


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
			property_path = property_path.path_join(parameter_name)
			_find_all_animation_nodes_from(node, property_path)
		_:
			if node is AnimationRootNode:
				push_error("Unknown animation node: %s"%[node_class])


func _filter_main_playback_path(animation_name: String, path: String) -> StringName:
	var parameter_name = _get_actual_parameter_name(animation_name)
	var full_path = path.path_join(parameter_name)
	var path_to_main_playback = _path_playback.replace("playback", "")
	var value = full_path.replace(path_to_main_playback, "") as StringName
	return value


## property names for these AnimationNodes are in the format "nodes/name/node" 
## or "states/name/node" so this is to get the middle part of that name
func _get_actual_parameter_name(property_name: String) -> String:
	var parameter_name = property_name.split("/")[1]
	return parameter_name

### -----------------------------------------------------------------------------------------------
