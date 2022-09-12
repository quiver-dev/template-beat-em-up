extends Node2D
# Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _debug_logger := QuiverDebugLogger.get_logger()

@onready var _main_player := $Characters/Chad as QuiverCharacter
@onready var _player_hud := $HudLayer/PlayerHud

@onready var _enemy_spawner_right := $Utilities/EnemySpawner as QuiverEnemySpawner
@onready var _enemy_spawner_left := $Utilities/EnemySpawner2 as QuiverEnemySpawner
@onready var _boss_spawner := $Utilities/BossSpawner as QuiverEnemySpawner

@onready var _end_screen := $HudLayer/EndScreen as EndScreen

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	randomize()
	_player_hud.set_player_attributes(_main_player.attributes)
	QuiverEditorHelper.connect_between(Events.player_died, _on_Events_player_died)
	
	_debug_logger.start_new_log()
	_enemy_spawner_right.spawn_current_wave()


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

func _on_enemy_spawner_wave_ended(wave_index: int) -> void:
	if wave_index == 0:
		_enemy_spawner_left.spawn_current_wave()


func _on_enemy_spawner_all_waves_completed() -> void:
	var is_finished := true
	
	for spawner in [_enemy_spawner_right, _enemy_spawner_left]:
		if not (spawner as QuiverEnemySpawner).is_completed:
			is_finished = false
			break
	
	if is_finished:
		_boss_spawner.spawn_current_wave()


func _on_boss_spawner_all_waves_completed() -> void:
	_end_screen.open_end_screen(true)


func _on_Events_player_died() -> void:
	_end_screen.open_end_screen(false)

### -----------------------------------------------------------------------------------------------
