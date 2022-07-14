extends Node2D
# Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

@onready var _main_player := $Characters/Chad as QuiverCharacter
@onready var _player_hud := $HudLayer/PlayerHud

var _wave_count := 0
var _debug_logger := QuiverDebugLogger.get_logger()

@onready var _enemy_spawner_right := $Utilities/EnemySpawner as QuiverEnemySpawner
@onready var _enemy_spawner_left := $Utilities/EnemySpawner2 as QuiverEnemySpawner

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	_player_hud.set_player_attributes(_main_player.attributes)
	if not Events.player_died.is_connected(reload_prototype):
		Events.player_died.connect(reload_prototype)
	
	if not Events.enemy_defeated.is_connected(_on_enemy_defeated):
		Events.enemy_defeated.connect(_on_enemy_defeated, CONNECT_DEFERRED)
	
	_debug_logger.start_new_log()
	_spawn_next_wave()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_restart"):
		reload_prototype()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func reload_prototype() -> void:
	Events.characters_reseted.emit()
	get_tree().reload_current_scene()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _spawn_next_wave() -> void:
	_debug_logger.log_message([get_path(), "Wave Starting", _wave_count])
		
	var wave_enemies = min(_wave_count + 1, 6)
	if wave_enemies > 1:
		var enemies_right = max(1, wave_enemies / 2)
		var enemies_left = wave_enemies - enemies_right
		_enemy_spawner_right.spawn_enemies(enemies_right)
		if enemies_left > 0:
			_enemy_spawner_left.spawn_enemies(enemies_left)
	else:
		_enemy_spawner_right.spawn_enemies(wave_enemies)
	
	_wave_count += 1


func _on_enemy_defeated() -> void:
	var current_enemies := get_tree().get_nodes_in_group("enemies")
	if current_enemies.is_empty():
		_spawn_next_wave()

### -----------------------------------------------------------------------------------------------

