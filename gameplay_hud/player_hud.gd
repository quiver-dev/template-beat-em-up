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
	QuiverEditorHelper.connect_between(Events.enemy_data_sent, _on_Events_enemy_data_sent)
	_enemy_block.hide()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func set_player_attributes(p_attributes: QuiverAttributes) -> void:
	_attributes_player_character = p_attributes
	_player_character_name.text = _attributes_player_character.display_name.to_upper()
	_player_life_bar.value = _attributes_player_character.get_health_as_percentage()
	
	QuiverEditorHelper.connect_between(
			_attributes_player_character.health_changed, _on_player_health_changed
	)
	
	QuiverEditorHelper.connect_between(
			_attributes_player_character.health_depleted, 
			_on_player_health_depleted
	)


func set_enemy_attribute(p_attributes: QuiverAttributes) -> void:
	if _attributes_current_enemy == p_attributes:
		return
	
	_disconnect_enemy_attribute_signals()
	
	_attributes_current_enemy = p_attributes
	_enemy_name.text = _attributes_current_enemy.display_name.to_upper()
	_enemy_life_bar.value = _attributes_current_enemy.get_health_as_percentage()
	_enemy_block.show()
	
	_connect_enemy_attribute_signals()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _disconnect_enemy_attribute_signals() -> void:
	if is_instance_valid(_attributes_current_enemy):
		QuiverEditorHelper.disconnect_between(
				_attributes_current_enemy.health_changed, _on_enemy_health_changed
		)
		
		QuiverEditorHelper.disconnect_between(
				_attributes_current_enemy.health_depleted, _on_enemy_health_depleted
		)


func _connect_enemy_attribute_signals() -> void:
	QuiverEditorHelper.connect_between(
			_attributes_current_enemy.health_changed, _on_enemy_health_changed
	)
	
	QuiverEditorHelper.connect_between(
			_attributes_current_enemy.health_depleted, _on_enemy_health_depleted
	)


func _on_player_health_changed() -> void:
	_player_life_bar.value = _attributes_player_character.get_health_as_percentage()


func _on_player_health_depleted() -> void:
	_player_life_bar.value = 0


func _on_enemy_health_changed() -> void:
	if is_instance_valid(_attributes_current_enemy):
		_enemy_life_bar.value = _attributes_current_enemy.get_health_as_percentage()


func _on_enemy_health_depleted() -> void:
	_enemy_life_bar.value = 0
	_attributes_current_enemy = null
	_enemy_block.hide()


func _on_Events_enemy_data_sent(p_enemy: QuiverAttributes, p_player: QuiverAttributes) -> void:
	if p_player != _attributes_player_character:
		return
	
	set_enemy_attribute(p_enemy)

### -----------------------------------------------------------------------------------------------

