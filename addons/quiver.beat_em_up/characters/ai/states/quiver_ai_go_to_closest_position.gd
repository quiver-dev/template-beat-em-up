@tool
extends "res://addons/quiver.beat_em_up/characters/ai/states/quiver_ai_go_to_position.gd"

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

@export_category("Go To Closest Position")
@export var _pool_positions: Array[Vector2] = []
@export var _pool_nodes: Array[NodePath] = []

var _pool := []

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	if msg.has("custom_pool"):
		_pool = msg.custom_pool
	else:
		_pool.append_array(_pool_positions)
		_pool.append_array(_pool_nodes)
	
	if not _pool.is_empty():
		msg = _find_closest_target()
	super(msg)


func exit() -> void:
	_pool.clear()
	super()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _find_closest_target() -> Dictionary:
	var value := {}
	
	var min_distance := INF
	# can be either a Vector 2 or a Node2D
	var target_value = null
	
	for entry in _pool:
		var position_to_compare := Vector2.ONE * INF
		if entry is Vector2:
			position_to_compare = entry
		elif entry is Node2D or entry is Control:
			position_to_compare = entry.global_position
		else:
			push_error(
					"invalid item in pool to find closest position: %s."%[entry]
					+ "It should be either a Vector2, Node2D or a Control."
			)
			continue
		
		var distance = _character.global_position.distance_squared_to(position_to_compare)
		if distance < min_distance:
			min_distance = distance
			target_value = entry if entry is Node2D else position_to_compare
	
	if target_value is Node2D:
		value["node"] = target_value
	elif target_value is Vector2:
		value["position"] = target_value
	else:
		push_error("Could not find closest targe, or found invalid target: %s"%[target_value])
	
	return value

### -----------------------------------------------------------------------------------------------
