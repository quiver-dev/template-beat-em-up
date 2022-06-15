@tool
class_name QuiverStateMachine
extends Node

## Based on GDQuest's StateMachine but with some modifications to make it a 
## [code]@tool[/code] script and convert to GDScript 2.0.
##
## Generic State Machine that can be used for handling States as nodes. It has a signal to notify 
## about transitions.
## [br][br]
## It also has a read-only [member state_name] property to help with debugging or checking 
## current state.

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

## Emitted whenever there is a state transtion.
signal transitioned(state_path)

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

## Value returned by [member state_name] when [member state] is [code]null[/code].
const INVALID_NODEPATH = ^"invalid"

#--- public variables - order: export > normal var > onready --------------------------------------

## [NodePath] to initial state, should be defined in the inspector.
@export var initial_state := NodePath(""):
	set(value):
		initial_state = value
		update_configuration_warnings()

@export var should_process_input := true

## Current state.
var state: QuiverState = null:
	set(value):
		state = value
		if is_inside_tree() and is_instance_valid(state):
			state_name = get_path_to(state)
## Current state name.
var state_name: NodePath = INVALID_NODEPATH

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return
	
	await owner.ready
	
	state = get_node(initial_state) as QuiverState
	state.enter()
	emit_signal("transitioned", get_path_to(state))


func _unhandled_input(event: InputEvent) -> void:
	if should_process_input:
		state.unhandled_input(event)


func _process(delta: float) -> void:
	state.process(delta)


func _physics_process(delta: float) -> void:
	state.physics_process(delta)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	
	if initial_state.is_empty():
		warnings.append("An initial state node must be defined.")
	else:
		var quiver_state := get_node(initial_state) as QuiverState
		if quiver_state == null:
			warnings.append("initial_state must point to a valid QuiverState node.")
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

## Takes a [NodePath] to the next state node, and transitions to it. Can optionally receive a 
## dictionary to be passed to the [method QuiverState.enter] method of the new state.
func transition_to(target_state_path: NodePath, msg: = {}) -> void:
	if not has_node(target_state_path):
		return
	
	var target_state := get_node(target_state_path) as QuiverState
	if target_state == null:
		push_error("%s is not a QuiverState type node"%[target_state_path])
		return
	
	state.exit()
	state = target_state
	state.enter(msg)
	emit_signal("transitioned", target_state_path)


func get_leaf_nodes_path_list(start_node: Node = self, node_list := []) -> Array:
	var child_state_count: = 0
	
	for child in start_node.get_children():
		# Bring this line back IF Cyclic Errors get fully fixed
		#if not child is QuiverState or child is QuiverStateSequence:
		if (
				not QuiverCyclicHelper.is_quiver_state(child) 
				or QuiverCyclicHelper.is_quiver_state_sequence(child)
		):
			continue
		child_state_count += 1
		# warning-ignore:return_value_discarded
		get_leaf_nodes_path_list(child, node_list)
	
	if child_state_count == 0:
		node_list.append(get_path_to(start_node))
	
	return node_list

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
