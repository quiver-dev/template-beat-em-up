class_name EndScreen
extends Control

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const TITLE_GAMEOVER = "Game Over"
const TITLE_VICTORY = "Congratulations!"

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

@onready var _title := $Title as Label
@onready var _animator := $AnimationPlayer as AnimationPlayer

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func open_end_screen(is_victory: bool) -> void:
	get_tree().paused = true
	_title.text = TITLE_VICTORY if is_victory else TITLE_GAMEOVER
	_animator.play("open")

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_replay_pressed() -> void:
	Events.characters_reseted.emit()
	get_tree().reload_current_scene()
	get_tree().paused = false


func _on_quit_pressed() -> void:
	get_tree().quit()

### -----------------------------------------------------------------------------------------------
