class_name QuiverCyclicHelper
extends RefCounted

## Static Helper to get out of Cyclic Errors.
##
## I don't think I should need this, as Cyclic References are supposed to be fixed in GDScript 2.0
## but I get a Cyclic Reference when I try to use `is` to compare if a node is `QuiverStateMachine`
## on the `_state_machine` setter. There is an open issue for this already so I'm just checking
## the script path until it's fixed https://github.com/godotengine/godot/issues/21461

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const PATH_STATE_MACHINE = (
		"res://addons/quiver.beat_em_up/utilities/custom_nodes/state_machines/"
		+"quiver_state_machine.gd"
)
const PATH_QUIVER_STATE = (
		"res://addons/quiver.beat_em_up/utilities/custom_nodes/state_machines/quiver_state.gd"
)
const PATH_QUIVER_STATE_SEQUENCE = (
		"res://addons/quiver.beat_em_up/utilities/custom_nodes/state_machines/"
		+"quiver_state_sequence.gd"
)

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------


static func is_quiver_state_machine(node: Node) -> bool:
	var value := _is_instance_of_script(node.get_script(), PATH_STATE_MACHINE)
	return value 


static func is_quiver_state(node: Node) -> bool:
	var value := _is_instance_of_script(node.get_script(), PATH_QUIVER_STATE)
	return value 


static func is_quiver_state_sequence(node: Node) -> bool:
	var value := _is_instance_of_script(node.get_script(), PATH_QUIVER_STATE_SEQUENCE)
	return value

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

static func _is_instance_of_script(script: Script, path: String) -> bool:
	var value = false
	
	if script != null:
		if script.resource_path == path:
			value = true
		elif script.get_base_script() != null:
			value = _is_instance_of_script(script.get_base_script(), path)
	
	return value 

### -----------------------------------------------------------------------------------------------

