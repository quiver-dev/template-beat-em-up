@tool
class_name QuiverEnemySpawner
extends Marker2D

## Node for spawning waves of enemies. Works in conjuction with [QuiverSpawnData].
## [br][br]
## The Enemy Spawner node has a public [method spawn_current_wave] method, that will start spawning 
## the waves of [QuiverSpawnData]. It will spawn every enemy from a wave in sequence and keep 
## track of them. 
## [br][br]
## Once all of them are defeated it will start spawning the next wave or, if 
## there is no more waves, it will emit its [signal all_waves_completed] signal.

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

## Emitted after all enemies from a wave have been spawned.
signal wave_started(wave_index: int)
## Emitted when all enemies from a wave have been defeated.
signal wave_ended(wave_index: int)
## Emitted when all waves have been completed and there are no more enemies in this spawner.
signal all_waves_completed

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

## Path to parent node where enemies will be added to.
@export_node_path("Node2D") var path_spawn_parent := ^"../../Characters"

## Keeps track of Enemy Spanwer state. Once all enemies in all waves are defeated, will be marked 
## as true.
var is_completed := false

#--- private variables - order: export > normal var > onready -------------------------------------

var _spawn_waves: Array = []

var _current_wave := 0
var _spawned_enemies := {}

@onready var _spawn_parent := get_node_or_null(path_spawn_parent) as Node2D

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

## Public method to start spawning. Only needs to be called once per spawner, as after it starts
## it will auto-spawn the next wave once the previous one is finished.
func spawn_current_wave() -> void:
	if _spawn_waves.is_empty() or _current_wave >= _spawn_waves.size():
		return
	
	for item in _spawn_waves[_current_wave]:
		var spawn_data := item as QuiverSpawnData
		var enemy := spawn_data.enemy_scene.instantiate() as QuiverEnemyCharacter
		var enemy_position := spawn_data.get_spawn_position(self)
		
		match spawn_data.spawn_mode:
			QuiverSpawnData.SpawnMode.IN_PLACE:
				_spawn_enemy(enemy, enemy_position)
			QuiverSpawnData.SpawnMode.WALK_TO_POSITION:
				_spawn_enemy(enemy, global_position)
				enemy.spawn_ground_to_position(enemy_position)
			_:
				push_error("Unknown spawn_mode: %s | Possible modes: %s"%[
					spawn_data.spawn_mode, QuiverSpawnData.SpawnMode.keys()
				])
	
	wave_started.emit(_current_wave)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _spawn_enemy(enemy: QuiverEnemyCharacter, p_position: Vector2) -> void:
	enemy.global_position = p_position
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
		
		await enemy.tree_exited
		
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
				hint = PROPERTY_HINT_TYPE_STRING,
				hint_string = "%s/%s:QuiverSpawnData"%[TYPE_OBJECT, PROPERTY_HINT_RESOURCE_TYPE],
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


func _set_wave_property(p_name: String, value: Array) -> void:
	var index := _get_wave_index(p_name)
	if index == -1:
		return
	
	_spawn_waves[index] = value


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
