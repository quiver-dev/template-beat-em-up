@tool
class_name QuiverEnemyCharacter
extends QuiverCharacter

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

@export_node_path(Node) var _path_ai_state_machine := ^"AiStateMachine":
	set(value):
		_path_ai_state_machine = value
		if is_inside_tree():
			_ai_state_machine = get_node_or_null(_path_ai_state_machine) as QuiverAiStateMachine
		update_configuration_warnings()

@export var _debug_draw_lane_limits := false

@onready var _ai_state_machine := get_node_or_null(_path_ai_state_machine) as QuiverAiStateMachine

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return
	
	attributes = attributes.duplicate()
	attributes.reset()
	super()


func _draw() -> void:
	if _debug_draw_lane_limits:
		var lane_limits = attributes.get_hit_lane_limits()
		var half_lane_size = (lane_limits.lower_limit - lane_limits.upper_limit)/2.0
		draw_dashed_line(
				Vector2(-500.0, -half_lane_size),
				Vector2(500.0, -half_lane_size),
				Color.BROWN,
				2.0
		)
		draw_dashed_line(
				Vector2(-500.0, half_lane_size),
				Vector2(500.0, half_lane_size),
				Color.DARK_ORANGE,
				2.0)


func _process(delta: float) -> void:
	queue_redraw()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	
	if _path_ai_state_machine.is_empty() or _ai_state_machine == null:
		warnings.append("_path_ai_state_machine must point to a valid QuiverAiStateMachine node.")
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func spawn_ground_to_position(target_position := Vector2.ONE * INF) -> void:
	if target_position == Vector2.ONE * INF:
		_ai_state_machine.transition_to(^"ChaseClosestPlayer")
	else:
		_ai_state_machine.transition_to(
				^"GoToPosition", {
					"position": target_position
				}
		)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------

