class_name EndScreen
extends Control

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const TITLE_GAMEOVER = "GAME OVER!"
const TITLE_VICTORY = "CONGRATULATIONS!"

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

@onready var _button_restart := $PanelContainer/Buttons/MarginContainer/Replay as TextureButton
@onready var _title := $PanelContainer/Control/Title as Label
@onready var _animator := $AnimationPlayer as AnimationPlayer

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	if QuiverEditorHelper.is_standalone_run(self):
		var is_victory = randi() % 2 as bool
		_title.text = TITLE_VICTORY if is_victory else TITLE_GAMEOVER
		_animator.play("open")
		_button_restart.grab_focus()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func open_end_screen(is_victory: bool) -> void:
	get_tree().paused = true
	_title.text = TITLE_VICTORY if is_victory else TITLE_GAMEOVER
	_animator.play("open")
	_button_restart.grab_focus()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_replay_pressed() -> void:
	Events.characters_reseted.emit()
	get_tree().reload_current_scene()
	get_tree().paused = false


func _on_quit_pressed() -> void:
	get_tree().quit()

### -----------------------------------------------------------------------------------------------
