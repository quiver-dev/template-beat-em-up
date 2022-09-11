@tool
class_name QuiverEnemySpawner
extends Marker2D

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

signal wave_started(wave_index: int)
signal wave_ended(wave_index: int)
signal all_waves_completed

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export_node_path(Node2D) var path_spawn_parent := ^"../../Characters"

var is_completed := false

#--- private variables - order: export > normal var > onready -------------------------------------

var _spawn_waves: Array = []

var _current_wave := 0
var _spawned_enemies := {}

var _marker_nodes := {}

@onready var _spawn_parent := get_node_or_null(path_spawn_parent) as Node2D

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return
	
	_populate_marker_nodes()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func spawn_current_wave() -> void:
	if _spawn_waves.is_empty() or _current_wave >= _spawn_waves.size():
		return
	
	for item in _spawn_waves[_current_wave]:
		var spawn_data := item as SpawnData
		var enemy := spawn_data.enemy_scene.instantiate() as QuiverEnemyCharacter
		_spawn_enemy(enemy)
		
		if spawn_data.spawn_mode == SpawnData.SpawnMode.WALK_TO_POSITION:
			var target_position = _marker_nodes[spawn_data.target_node_path].global_position
			if spawn_data.use_vector2:
				target_position = spawn_data.target_position
			enemy.spawn_ground_to_position(target_position)
	
	wave_started.emit(_current_wave)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _populate_marker_nodes() -> void:
	for wave in _spawn_waves:
		for item in wave:
			var spawn_data := item as SpawnData
			if spawn_data.spawn_mode == SpawnData.SpawnMode.WALK_TO_POSITION:
				_marker_nodes[spawn_data.target_node_path] = get_node(spawn_data.target_node_path)


func _spawn_enemy(enemy: QuiverEnemyCharacter) -> void:
	enemy.global_position = global_position
	_spawn_parent.add_child(enemy, true)
	
	var instance_id := enemy.get_instance_id()
	_spawned_enemies[instance_id] = enemy
	# can't use tree_exited because grab reparent's enemy and triggers tree_exited.
	QuiverEditorHelper.connect_between(
			enemy.attributes.health_depleted, 
			_on_enemy_died.bind(instance_id)
	)


func _on_enemy_died(p_instance_id: int) -> void:
	if _spawned_enemies.has(p_instance_id):
		var enemy := _spawned_enemies[p_instance_id] as QuiverEnemyCharacter
		QuiverEditorHelper.disconnect_between(
				enemy.attributes.health_depleted,
				_on_enemy_died
		)
		var success := _spawned_enemies.erase(p_instance_id)
		if not success:
			push_error("Failed to remove %s from %s"%[p_instance_id, _spawned_enemies])
	
	if _spawned_enemies.is_empty():
		wave_ended.emit(_current_wave)
		_current_wave += 1
		if _current_wave < _spawn_waves.size():
			spawn_current_wave()
		else:
			is_completed = true
			all_waves_completed.emit()

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

func _get_custom_properties() -> Dictionary:
	return {
		"Waves": {
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_CATEGORY
		},
		"waves_model": {
			name = "wave_%s",
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_GROUP,
			hint_string = "wave_%s_",
		},
		"wave_enemy_model": {
			name = "wave_%s_%s",
			type = TYPE_OBJECT,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		},
#		"": {
#			backing_field = "",
#			name = "",
#			type = TYPE_NIL,
#			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
#			hint = PROPERTY_HINT_NONE,
#			hint_string = "",
#		},
}

### Custom Inspector built in functions -----------------------------------------------------------

func _get_property_list() -> Array:
	var properties: = []
	
	properties.append({
		name = "Waves",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY
	})
	properties.append({
		name = "spawn_waves",
		type = TYPE_ARRAY,
		usage = PROPERTY_USAGE_STORAGE,
	})
	properties.append({
		name = "wave_count",
		type = TYPE_INT,
		usage = PROPERTY_USAGE_EDITOR,
		hint = PROPERTY_HINT_RANGE,
		hint_string = "0,1,1,or_greater",
	})
	
	for wave_index in _spawn_waves.size():
		properties.append({
				name = "wave_%s"%[wave_index],
				type = TYPE_ARRAY,
				usage = PROPERTY_USAGE_EDITOR,
		})
	
	return properties


func _get(property: StringName):
	var value
	
	if property == "spawn_waves":
		value = _spawn_waves
	elif property == "wave_count":
		value = _spawn_waves.size()
	elif (property as String).match("wave_*"):
		value = _get_wave_property(property)
	
	return value


func _set(property: StringName, value) -> bool:
	var has_handled: = true
	
	if property == "spawn_waves":
		_set_spawn_waves(value)
	elif property == "wave_count":
		_spawn_waves.resize(value)
		_set_spawn_waves(_spawn_waves)
		notify_property_list_changed()
	elif (property as String).match("wave_*"):
		_set_wave_property(property, value)
	else:
		has_handled = false
	
	return has_handled

### -----------------------------------------------------------------------------------------------


### Custom Inspector Private Methods --------------------------------------------------------------


func _set_spawn_waves(value: Array) -> void:
	_spawn_waves = value
	for wave in _spawn_waves.size():
		if _spawn_waves[wave] == null:
			_spawn_waves[wave] = []
		for index in _spawn_waves[wave].size():
			var spawn_data := _spawn_waves[wave][index] as SpawnData
			if spawn_data == null:
				_spawn_waves[wave][index] = SpawnData.new()


func _set_wave_property(p_name: String, value: Array) -> void:
	var index := _get_wave_index(p_name)
	if index == -1:
		return
	
	_spawn_waves[index] = value
	for enemy_index in _spawn_waves[index].size():
		var spawn_data := _spawn_waves[index][enemy_index] as SpawnData
		if spawn_data == null:
			_spawn_waves[index][enemy_index] = SpawnData.new()


func _get_wave_property(p_name: String) -> Array:
	var value := []
	var index := _get_wave_index(p_name)
	
	if index > -1 and index < _spawn_waves.size():
		value = _spawn_waves[index]
	
	return value


func _get_wave_index(p_name) -> int:
	var split_property = p_name.split("_") 
	# should be ["wave", "wave_index"]
	if split_property.size() < 2:
		push_error("Invalid property name split: %s %s"%[p_name, split_property])
		return -1
	else:
		return (split_property[1] as String).to_int()

### -----------------------------------------------------------------------------------------------
