class_name QuiverEnemySpawner
extends Marker2D

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export_node_path(Node2D) var path_spawn_parent := ^"../../Characters"
@export var possible_positions: Array[NodePath] = []
@export var possible_enemies: Array[PackedScene] = []

#--- private variables - order: export > normal var > onready -------------------------------------

@onready var _spawn_parent := get_node_or_null(path_spawn_parent) as Node2D

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	pass

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func spawn_enemies(amount := 1) -> void:
	var pool_position := []
	var pool_enemies := []
	for _index in amount:
		if pool_position.is_empty():
			pool_position = possible_positions.duplicate()
		
		if pool_enemies.is_empty():
			pool_enemies = possible_enemies.duplicate()
		
		var index_position = randi() % pool_position.size()
		var index_enemy = randi() % pool_enemies.size()
		var enemy := pool_enemies[index_enemy].instantiate() as QuiverEnemyCharacter
		var reference_node := get_node(pool_position[index_position]) as Node2D
		
		enemy.global_position = global_position
		_spawn_parent.add_child(enemy, true)
		enemy.spawn_ground_to_position(reference_node.global_position)
		
		pool_position.remove_at(index_position)
		pool_enemies.remove_at(index_enemy)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------

