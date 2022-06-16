@tool
class_name QuiverState
extends Node

## Based on GDQuest's State, but converted to GDScript 2.0 and modified with a few extra features.
## 
## This State is compatible with Sequence States as well as Hierarchichal States. It has some 
## validation on the editor to warn the user if they are placing it as child of wrong nodes and 
## also handles signal connections through the editor automatically.
## [br][br]
## You can connect any signal to it through the editor. When the game is running, on the 
## [method _ready] method, the State will register all existing connections into a private 
## array, and disconnect all signals. Then it will automatically connect and disconnect the saved 
## signals on [method enter] and [method exit] respectivelly.
## [br][br]
## Because of this, when inheriting from this Class, always make sure the parent class 
## [method _ready] is executed if you override it by calling [code]super()[/code] inside your override, and 
## also do that for your overrides of [method enter] and [method exit]. Or alternatively, use the 
## private methods [method _register_incomming_connections], [method _connect_signals] and 
## [method _disconnect_signals] wherever the most convenient for your state's requirements.

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

## Optionally emitted whenever a state finishes it's task. Useful for Sequence States.
signal state_finished

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const HINT_STATE_LIST = "QuiverStateList"

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

# Array of Dicts in the format: {source: Object, signal_name: String, method_name: String}
var _incoming_connections: Array

var _state_machine: QuiverStateMachine = null

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _enter_tree() -> void:
	_state_machine = _get_state_machine(self) as QuiverStateMachine
#	print("_state_machine: %s"%[_state_machine])
	update_configuration_warnings()


func _ready() -> void:
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return
	
	_register_incomming_connections()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	
	if not is_instance_valid(_state_machine):
		warnings.append("QuiverState nodes must be descendants of a QuiverStateMachine Node.")
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

## Executed when the state machines transitions into this state. [br]
## To be overriden by scripts that inherit this class, but be careful to preserve the call to 
## [method _connect_signals] if you are connecting any signals to the state using the editor.
func enter(_msg: = {}) -> void:
	_connect_signals()

## Handles input events the state machine defers to this state. Equivalent of 
## [method Node._unhandeled_input]. [br]
## Virtual function to be overriden by inheriting classes, if needed.
func unhandled_input(_event: InputEvent) -> void:
	return

## Handles processing the state machine defers to this state. Equivalent of 
## [method Node._process].[br]
## Virtual function to be overriden by inheriting classes, if needed.
func process(_delta: float) -> void:
	return

## Handles physics processing the state machine defers to this state. Equivalent of 
## [method Node._physics_process].[br]
## Virtual function to be overriden by inheriting classes, if needed.
func physics_process(_delta: float) -> void:
	return

## Executed when the state machine transitions out of this state. [br]
## To be overriden by scripts that inherit this class, but be careful to preserve the call to 
## [method _disconnect_signals] if you are connecting any signals to the state using the editor.
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


func _get_state_machine(node: Node) -> Node:
	if node == null or node.get_parent() == null:
		push_error("Couldn't find a StateMachine in this scene tree. State name: %s"%[name])
	else:
#		print("node: %s"%[node.name])
		var found_state_machine = QuiverCyclicHelper.is_quiver_state_machine(node)
		if not found_state_machine:
			node = _get_state_machine(node.get_parent())
		else:
#			print("STATE MACHINE FOUND")
			pass
		
	return node


## Registers any signals connected to this node by the editor and stores them into 
## [member _incoming_connection]. Then immediatly disconnects them, so that they will only be 
## "active" when the state is also "active".
func _register_incomming_connections() -> void:
	_incoming_connections = get_incoming_connections()
	_disconnect_signals()


## Connects all signals saved in [member _incoming_connection]. Usually called in the 
## [method enter] method.
func _connect_signals() -> void:
	for dict in _incoming_connections:
		if not dict.has_all(["signal", "callable", "flags", "binds"]):
			push_error("Invalid source in dict: %s"%[dict])
			continue
		
		if dict["binds"].is_empty():
			dict["signal"].connect(dict["callable"], dict.flags)
		else:
			dict["signal"].connect(dict["callable"].bind(dict["binds"]), dict.flags)


## Disconnects all signals saved in [member _incoming_connection]. Usually called in the 
## [method exit] method.
func _disconnect_signals() -> void:
	for dict in _incoming_connections:
		if not dict.has_all(["signal", "callable"]):
			push_error("Invalid source in dict: %s"%[dict])
			continue
		
		dict["signal"].disconnect(dict["callable"])

### -----------------------------------------------------------------------------------------------
