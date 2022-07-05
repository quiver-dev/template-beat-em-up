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

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	_player_hud.set_player_attributes(_main_player.attributes)
	if not Events.player_died.is_connected(reload_prototype):
		Events.player_died.connect(reload_prototype)


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

### -----------------------------------------------------------------------------------------------

