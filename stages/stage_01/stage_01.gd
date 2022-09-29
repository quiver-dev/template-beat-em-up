extends BaseStage

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

@onready var _fight_room_2 := $Utilities/FightRoom2 as QuiverFightRoom

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()
	pass

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_fight_2_spawner_all_waves_completed() -> void:
	var has_completed_all_waves := true
	
	for spawner in get_tree().get_nodes_in_group("fight_2_spawner"):
		if not (spawner as QuiverEnemySpawner).is_completed:
			has_completed_all_waves = false
			break
	
	if has_completed_all_waves:
		_fight_room_2.setup_after_fight_room()


func _on_boss_spawner_all_waves_completed() -> void:
	_end_screen.open_end_screen(true)

### -----------------------------------------------------------------------------------------------
