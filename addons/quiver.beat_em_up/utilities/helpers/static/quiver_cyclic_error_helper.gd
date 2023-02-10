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

# I have to leave this here because if I try to move it to the plugin script I get an error
# when trying to use it in the subclass inside the attributes script
const SETTINGS_DEFAULT_HIT_LANE_SIZE = "quiver/beat_em_up/gameplay/default_hit_lane_size"
const SETTINGS_FALL_GRAVITY_MODIFIER = "quiver/beat_em_up/gameplay/fall_gravity_modifier"
const SETTINGS_LOGGING = "quiver/beat_em_up/debug/logging_enabled"
const SETTINGS_DISABLE_PLAYER_DETECTOR = "quiver/beat_em_up/debug/disable_player_detector_on_editor"
const SETTINGS_PATH_CUSTOM_ACTIONS = "quiver/beat_em_up/paths/custom_actions_folder"
const SETTINGS_PATH_CUSTOM_BEHAVIORS = "quiver/beat_em_up/paths/custom_ai_folder"

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

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------

