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

@onready var _title := $PanelContainer/Control/Title as Label
@onready var _animator := $AnimationPlayer as AnimationPlayer

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	if QuiverEditorHelper.is_standalone_run(self):
		var is_victory = randi() % 2 as bool
		_title.text = TITLE_VICTORY if is_victory else TITLE_GAMEOVER
		_animator.play("open")

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func open_end_screen(is_victory: bool) -> void:
	if is_inside_tree():
		get_tree().paused = true
		_title.text = TITLE_VICTORY if is_victory else TITLE_GAMEOVER
		_animator.play("open")

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_replay_pressed() -> void:
	Events.characters_reseted.emit()
	var error := get_tree().reload_current_scene()
	if error == OK:
		get_tree().paused = false
	else:
		push_error("Failed to reload current scene. Error %s"%[error])


func _on_quit_pressed() -> void:
	get_tree().quit()

### -----------------------------------------------------------------------------------------------
