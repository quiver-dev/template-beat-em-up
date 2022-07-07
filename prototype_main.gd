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

var _wave_enemies := 0

@onready var _enemy_spawner_right := $Utilities/EnemySpawner as QuiverEnemySpawner
@onready var _enemy_spawner_left := $Utilities/EnemySpawner2 as QuiverEnemySpawner

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	_player_hud.set_player_attributes(_main_player.attributes)
	if not Events.player_died.is_connected(reload_prototype):
		Events.player_died.connect(reload_prototype)
	
	if not Events.enemy_defeated.is_connected(_spawn_next_wave):
		Events.enemy_defeated.connect(_spawn_next_wave, CONNECT_DEFERRED)
	
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
	var current_enemies := get_tree().get_nodes_in_group("enemies")
	
	if current_enemies.is_empty():
		_wave_enemies = min(_wave_enemies + 1, 6)
		if _wave_enemies > 1:
			var enemies_right = max(1, _wave_enemies / 2)
			var enemies_left = _wave_enemies - enemies_right
			_enemy_spawner_right.spawn_enemies(enemies_right)
			if enemies_left > 0:
				_enemy_spawner_left.spawn_enemies(enemies_left)
		else:
			_enemy_spawner_right.spawn_enemies(_wave_enemies)

### -----------------------------------------------------------------------------------------------

