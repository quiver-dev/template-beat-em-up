class_name QuiverAiStateGroup
extends Node

## This is not actually a state, just a node to Group AI States without breaking or setting off
## warnings in the AiStateMachine. It's usefull to group behaviors/states by boss phase, for
## example.

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _state_machine: QuiverStateMachine = null

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _enter_tree() -> void:
	_state_machine = _get_state_machine(self) as QuiverStateMachine


func _ready() -> void:
	pass

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

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

### -----------------------------------------------------------------------------------------------
