extends BaseStage

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

@onready var _fight_room_2 := $Utilities/FightRoom2 as QuiverFightRoom
@onready var _tax_man := %TaxMan as TaxManBoss
@onready var _fight_5 := %FightRoom5 as QuiverFightRoom

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()
	QuiverEditorHelper.connect_between(_tax_man.tree_exited, _on_tax_man_tree_exited)

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


func _on_tax_man_tree_exited() -> void:
	_end_screen.open_end_screen(true)


func _on_fight_4_player_detector_player_detected() -> void:
	_tax_man.tax_man_revealed.emit()


func _on_fight_4_spawner_all_waves_completed() -> void:
	_tax_man.tax_man_engaged.emit()
	_fight_5.setup_fight_room()

### -----------------------------------------------------------------------------------------------
