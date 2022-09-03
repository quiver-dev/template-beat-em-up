@tool
extends QuiverAiState

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

@export_category("Choose Random Behavior")
@export var _use_weights := true:
	set(value):
		_use_weights = value
		notify_property_list_changed()
var _allow_repeated := true

var _chosen_state: QuiverState = null

var _child_nodes := {}
var _weights_by_child := {}

var _simple_pool: Array[QuiverState] = []
var _weighted_pool := {}

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	QuiverEditorHelper.connect_between(child_entered_tree, _on_child_entered_tree)
	for child in get_children():
		_child_nodes[child.name] = child
		QuiverEditorHelper.connect_between(child.tree_exited, _build_behavior_pool)
	
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		_build_behavior_pool()
		return
	
	var results := {}
	for _index in range(100):
		var state = _get_random_behavior_weighted() if _use_weights else _get_random_behavior()
		if not results.has(state.name):
			results[state.name] = 1
		else:
			results[state.name] += 1
	
	print("results: %s"%[results])


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	
	if get_child_count() == 0:
		warnings.append(
				"Choose Random Behavior does nothing by itself, "
				+ "it needs QuiverAiStates as children."
		)
	for child in get_children():
		if not (child is QuiverAiState or child is QuiverStateSequence):
			warnings.append(
					"%s is not a node of type QuiverAiState or QuiverStateSequence"%[child.name]
			)
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	if _use_weights:
		_chosen_state = _get_random_behavior_weighted()
	else:
		_chosen_state = _get_random_behavior()
	
	QuiverEditorHelper.connect_between(
			_chosen_state.state_finished, _on_chosen_state_state_finished
	)
	_chosen_state.enter(msg)


func unhandled_input(event: InputEvent) -> void:
	_chosen_state.unhandled_input(event)


func process(delta: float) -> void:
	_chosen_state.process(delta)


func physics_process(delta: float) -> void:
	_chosen_state.physics_process(delta)


func exit() -> void:
	super()
	_chosen_state.exit()
	_chosen_state = null


func interrupt_state() -> void:
	QuiverEditorHelper.disconnect_between(
			_chosen_state.state_finished, _on_chosen_state_state_finished
	)
	
	if _chosen_state.has_method("interrupt_state"):
		_chosen_state.interrupt_state()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _get_random_behavior() -> QuiverState:
	var random_state: QuiverState = null
	var random_index := 0
	
	if _simple_pool.is_empty():
		_simple_pool = _child_nodes.values().duplicate()
	
	if _simple_pool.size() == 1:
		random_state = _simple_pool[random_index]
	else:
		random_index = randi() % _simple_pool.size()
		random_state = _simple_pool[random_index] as QuiverState
	
	if not _allow_repeated:
		_simple_pool.remove_at(random_index)
	
	return random_state


func _get_random_behavior_weighted() -> QuiverState:
	if _weighted_pool.is_empty():
		_weighted_pool = _weights_by_child.duplicate()
	
	var random_index := QuiverMathHelper.draw_random_weighted_index(_weighted_pool.values())
	var key := _weighted_pool.keys()[random_index] as String
	var random_state: QuiverState = _child_nodes[key]
	
	return random_state


func _build_behavior_pool() -> void:
	_child_nodes.clear()
	var missing_nodes := _weights_by_child.keys().duplicate()
	
	for child in get_children():
		if child is QuiverAiState or child is QuiverStateSequence:
			_child_nodes[child.name] = child
			
			if _weights_by_child.has(child.name):
				missing_nodes.erase(child.name as String)
			else:
				_weights_by_child[child.name] = 1.0
	
	for node_name in missing_nodes:
		_weights_by_child.erase(node_name)
	
	_normalize_weights()


func _normalize_weights() -> void:
	if _weights_by_child.is_empty():
		return
	
	var max_weight := float(get_child_count())
	var callable := Callable(QuiverMathHelper, "sum_array")
	var actual_weight := _weights_by_child.values().reduce(callable) as float
	
	for child_name in _weights_by_child:
		_weights_by_child[child_name] = _weights_by_child[child_name] / actual_weight * max_weight


func _on_child_entered_tree(_node: Node) -> void:
	_build_behavior_pool()
	notify_property_list_changed()


func _on_chosen_state_state_finished() -> void:
	QuiverEditorHelper.disconnect_between(
			_chosen_state.state_finished, _on_chosen_state_state_finished
	)
	state_finished.emit()

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

### Custom Inspector built in functions -----------------------------------------------------------

func _get_property_list() -> Array:
	var properties: = []
	
	properties.append({
		name = "_weights_by_child",
		type = TYPE_DICTIONARY,
		usage = PROPERTY_USAGE_STORAGE,
	})
	
	if _use_weights:
		properties.append({
			name = "allow_repeated",
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_STORAGE
		})
		
		properties.append({
			name = "Weight Settings",
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_GROUP,
			hint_string = "weight_for_"
		})
		
		for node_name in _weights_by_child:
			properties.append({
				name = "weight_for_%s"%[node_name],
				type = TYPE_FLOAT,
				usage = PROPERTY_USAGE_EDITOR,
				hint = PROPERTY_HINT_RANGE,
				hint_string = "0.01,0.99,0.01" if _weights_by_child.size() > 1 else "1.0,1.0,0.0"
			})
	else:
		properties.append({
			name = "allow_repeated",
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		})
		
	return properties


func _get(property: StringName):
	var value
	
	match property:
		&"allow_repeated":
			value = _allow_repeated
		_:
			var weight_property := _get_group_property(property, "weight_for_")
			if _weights_by_child.has(weight_property):
				value = _weights_by_child[weight_property] / _weights_by_child.size()
	
	return value


func _set(property: StringName, value) -> bool:
	var has_handled: = false
	
	match property:
		&"allow_repeated":
			_allow_repeated = value
			has_handled = true
		_:
			var weight_property := _get_group_property(property, "weight_for_")
			if _weights_by_child.has(weight_property):
				_weights_by_child[weight_property] = value * _weights_by_child.size()
				_normalize_weights()
				has_handled = true
			
	return has_handled


func _get_group_property(property: String, group_prefix: String) -> String:
	var value := ""
	if property.begins_with(group_prefix):
		value = property.replace(group_prefix, "")
	
	return value

### -----------------------------------------------------------------------------------------------
