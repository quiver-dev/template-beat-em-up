extends QuiverCharacterState

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const GroundState = preload(
		"res://addons/quiver.beat_em_up/characters/action_states/quiver_action_ground.gd"
)

#--- public variables - order: export > normal var > onready --------------------------------------

var grab_target: QuiverAttributes = null
var grab_target_node: QuiverCharacter = null
var grab_pivot: Position2D = null
var original_parent: Node = null

#--- private variables - order: export > normal var > onready -------------------------------------

@export var _path_move_idle := "Ground/Move/Idle"

var _original_transform: Transform2D

@onready var _ground_state := get_parent() as GroundState

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()
	update_configuration_warnings()
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	
	if not get_parent() is GroundState:
		warnings.append(
				"This ActionState must be a child of Action GroundState or a state " 
				+ "inheriting from it."
		)
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	_ground_state.enter(msg)
	
	if not "target" in msg:
		_state_machine.transition_to(_path_move_idle)
		return
	
	grab_target = msg.target
	grab_target_node = grab_target.character_node
	original_parent = grab_target_node.get_parent()
	_original_transform = grab_target_node.transform


func exit() -> void:
	super()
	_ground_state.exit()
	
	if is_instance_valid(grab_target_node) and grab_target_node.get_parent() != original_parent:
		reparent_target_node_to(original_parent)
		grab_target_node.transform.x = _original_transform.x
		grab_target_node.transform.y = _original_transform.y
	
	original_parent = null
	grab_target = null
	grab_target_node = null


func reparent_target_node_to(new_parent: Node2D) -> void:
	var global_transform = grab_target_node.get_global_transform()
	grab_target_node.get_parent().remove_child(grab_target_node)
	new_parent.add_child(grab_target_node)
	grab_target_node.global_transform = global_transform

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
