class_name BaseStage
extends Node2D

## Class that is the base script for all stages. Connects the player attributes to the hud and 
## handles game over.

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

@onready var _main_player := $Level/Characters/Chad as QuiverCharacter
@onready var _player_hud := $HudLayer/PlayerHud
@onready var _end_screen := $HudLayer/EndScreen as EndScreen

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	randomize()
	_player_hud.set_player_attributes(_main_player.attributes)
	QuiverEditorHelper.connect_between(Events.player_died, _on_Events_player_died)


func _unhandled_input(event: InputEvent) -> void:
	if OS.has_feature("debug") and event.is_action_pressed("debug_restart"):
		reload_prototype()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

## Properly resets all characters and reloads game scene.
func reload_prototype() -> void:
	Events.characters_reseted.emit()
	var error := get_tree().reload_current_scene()
	if error != OK:
		push_error("Failed to reload current scene. Error %s"%[error])

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_Events_player_died() -> void:
	_end_screen.open_end_screen(false)

### -----------------------------------------------------------------------------------------------
