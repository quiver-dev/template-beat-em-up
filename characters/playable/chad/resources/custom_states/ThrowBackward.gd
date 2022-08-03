@tool
extends "res://addons/quiver.beat_em_up/characters/action_states/quiver_action_attack.gd"

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const GrabState = preload(
		"res://addons/quiver.beat_em_up/characters/action_states/ground_actions/"
		+"quiver_action_grab.gd"
)

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

@onready var _grab_state := get_parent() as GrabState

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
	
	if not get_parent() is GrabState:
		warnings.append(
				"This ActionState must be a child of Action GrabState or a state " 
				+ "inheriting from it."
		)
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)


func exit() -> void:
	super()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _connect_signals() -> void:
	super()
	
	if not _skin.suplex_landed.is_connected(_on_skin_suplex_landed):
		_skin.suplex_landed.connect(_on_skin_suplex_landed)


func _disconnect_signals() -> void:
	super()
	
	if is_instance_valid(_skin):
		if _skin.suplex_landed.is_connected(_on_skin_suplex_landed):
			_skin.suplex_landed.disconnect(_on_skin_suplex_landed)


func _on_skin_suplex_landed() -> void:
	_grab_state.reparent_target_node_to(_grab_state.original_parent)
	_grab_state.grab_target_node.global_position = Vector2(
			_grab_state.grab_pivot.global_position.x,
			_character.global_position.y
	)
	_grab_state.grab_target_node.rotation = 0

### -----------------------------------------------------------------------------------------------
