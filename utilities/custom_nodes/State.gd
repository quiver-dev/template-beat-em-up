@tool
class_name QuiverState
extends Node

# Based on GDQuest's State

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

signal state_finished

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

# I don't think I should need this, as Cyclic References are supposed to be fixed in GDScript 2.0
# but I get a Cyclic Reference when I try to use `is` to compare if a node is `QuiverStateMachine`
# on the `_state_machine` setter. There is an open issue for this already so I'm just checking
# the script path until it's fixed https://github.com/godotengine/godot/issues/21461
const PATH_STATE_MACHINE_SCRIPT = "res://utilities/custom_nodes/StateMachine.gd"

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

# Array of Dicts in the format: {source: Object, signal_name: String, method_name: String}
var _incoming_connections: Array

var _state_machine: QuiverStateMachine = null

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _enter_tree() -> void:
	_state_machine = _get_state_machine(self) as QuiverStateMachine
	update_configuration_warnings()


func _ready() -> void:
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return
	
	_incoming_connections = get_incoming_connections()
	_disconnect_signals()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	
	if not is_instance_valid(_state_machine):
		warnings.append("QuiverState nodes must be descendants of a QuiverStateMachine Node.")
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(_msg: = {}) -> void:
	_connect_signals()


func unhandled_input(_event: InputEvent) -> void:
	return


func process(_delta: float) -> void:
	return


func physics_process(_delta: float) -> void:
	return


func exit() -> void:
	_disconnect_signals()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _is_active_state() -> bool:
	if Engine.is_editor_hint():
		return false
	
	var is_active: bool = _state_machine.state == self
	
	if not is_active:
		var active_nodepath: NodePath = _state_machine.get_path_to(_state_machine.state)
		for index in active_nodepath.get_name_count():
			var node_name = active_nodepath.get_name(index)
			is_active = node_name == name
			if is_active:
				break
	
	return is_active


func _get_state_machine(node: Node) -> QuiverStateMachine:
	if node == null or node.get_parent() == null:
		push_error("Couldn't find a StateMachine in this scene tree. State name: %s"%[name])
	else:
		var script := node.get_script() as Script
		if script != null and script.resource_path != PATH_STATE_MACHINE_SCRIPT:
			node = _get_state_machine(node.get_parent())
		
	return node as QuiverStateMachine


func _connect_signals() -> void:
	for dict in _incoming_connections:
		if dict.source == null or not is_instance_valid(dict.source):
			push_error("Invalid source in dict: %s"%[dict])
			continue
		
		var callable := Callable(self, dict.method_name)
		if not dict.source.is_connected(dict.signal_name, callable):
			dict.source.connect(dict.signal_name, callable)


func _disconnect_signals() -> void:
	for dict in _incoming_connections:
		if dict.source == null or not is_instance_valid(dict.source):
			push_error("Invalid source in dict: %s"%[dict])
			continue
		
		var callable := Callable(self, dict.method_name)
		if dict.source.is_connected(dict.signal_name, callable):
			dict.source.disconnect(dict.signal_name, callable)

### -----------------------------------------------------------------------------------------------
