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

#--- private variables - order: export > normal var > onready -------------------------------------

@export var _path_move_idle := "Ground/Move/Idle"

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


func exit() -> void:
	super()
	_ground_state.exit()
	grab_target = null

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
