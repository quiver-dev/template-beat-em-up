extends VBoxContainer

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _attributes_player_character: QuiverAttributes = null
var _attributes_current_enemy: QuiverAttributes = null

@onready var _player_character_name := $CharacterName as Label
@onready var _player_life_bar := $LifeBar as ProgressBar
@onready var _enemy_block := $EnemyContainer as MarginContainer
@onready var _enemy_name := $EnemyContainer/Column/EnemyName as Label
@onready var _enemy_life_bar := $EnemyContainer/Column/LifeBar as ProgressBar

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	pass

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func set_player_attributes(p_attributes: QuiverAttributes) -> void:
	_attributes_player_character = p_attributes
	_player_character_name.text = _attributes_player_character.display_name
	_player_life_bar.value = _attributes_player_character.get_health_as_percentage()
	
	if not _attributes_player_character.health_changed.is_connected(_on_player_health_changed):
		_attributes_player_character.health_changed.connect(_on_player_health_changed)
	
	if not _attributes_player_character.health_depleted.is_connected(_on_player_health_depleted):
		_attributes_player_character.health_depleted.connect(_on_player_health_depleted)


func set_enemy_attribute(p_attributes: QuiverAttributes) -> void:
	_attributes_current_enemy = p_attributes
	_enemy_name.text = _attributes_current_enemy.display_name
	_enemy_life_bar.value = _attributes_current_enemy.get_health_as_percentage()
	_enemy_block.show()
	
	if not _attributes_current_enemy.health_changed.is_connected(_on_player_health_changed):
		_attributes_current_enemy.health_changed.connect(_on_player_health_changed)
	
	if not _attributes_current_enemy.health_depleted.is_connected(_on_player_health_depleted):
		_attributes_current_enemy.health_depleted.connect(_on_player_health_depleted)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_player_health_changed() -> void:
	_player_life_bar.value = _attributes_player_character.get_health_as_percentage()


func _on_player_health_depleted() -> void:
	_player_life_bar.value = 0


func _on_enemy_health_changed() -> void:
	_enemy_life_bar.value = _attributes_current_enemy.get_health_as_percentage()


func _on_enemy_health_depleted() -> void:
	_attributes_current_enemy = null
	_enemy_block.hide()

### -----------------------------------------------------------------------------------------------

