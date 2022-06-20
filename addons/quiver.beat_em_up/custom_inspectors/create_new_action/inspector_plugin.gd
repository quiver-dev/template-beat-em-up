extends EditorInspectorPlugin

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const CreateNewActionWidget = preload(
		"res://addons/quiver.beat_em_up/custom_inspectors/create_new_action/"
		+"create_new_action_widget.gd"
)
const SCENE_WIDGET = preload(
		"res://addons/quiver.beat_em_up/custom_inspectors/create_new_action/"
		+"create_new_action_widget.tscn"
)

#--- public variables - order: export > normal var > onready --------------------------------------

var editor_plugin: EditorPlugin = null
var undo_redo: UndoRedo = null

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _can_handle(object) -> bool:
	var value = false
	var is_valid_state_machine: bool = (
			object is QuiverStateMachine
			and not object is QuiverAiStateMachine
	)
	var is_valid_state: bool = (
			object is QuiverState and 
			not object is QuiverAiState
			and not (
				object is QuiverStateSequence 
				and object._state_machine is QuiverAiStateMachine
			)
	)
	
	if (is_valid_state_machine or is_valid_state):
		var is_owner_character: bool = (
				"owner" in object 
				and object.owner != null 
				and object.owner is QuiverCharacter
		)
		value = is_owner_character
	
	return value


func _parse_begin(object: Object) -> void:
	var widget: = SCENE_WIDGET.instantiate() as CreateNewActionWidget
	widget.selected_node = object
	widget.add_node_to.connect(_on_widget_add_node_to)
	add_custom_control(widget)

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _add_node_to(node_to_add: Node, parent_node: Node) -> void:
	parent_node.add_child(node_to_add, true)
	if is_instance_valid(parent_node.owner):
		node_to_add.owner = parent_node.owner
	else:
		node_to_add.owner = parent_node


func _remove_node_from(node_to_remove: Node, parent_node: Node) -> void:
	parent_node.remove_child(node_to_remove)


func _on_widget_add_node_to(node_to_add: Node, parent_node: Node) -> void:
	undo_redo.create_action("Add %s to %s"%[node_to_add.name, parent_node.name])
	undo_redo.add_do_reference(node_to_add)
	undo_redo.add_do_method(self, "_add_node_to", node_to_add, parent_node)
	undo_redo.add_undo_method(self, "_remove_node_from", node_to_add, parent_node)
	undo_redo.commit_action()

### -----------------------------------------------------------------------------------------------

