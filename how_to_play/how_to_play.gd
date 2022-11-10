class_name HowToPlay
extends Control

## Write your doc string for this file here

signal how_to_play_closed

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const FADE_DURATION = 0.3

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _tween: Tween

@onready var _back := $Panel/MainColumn/Back as Button

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	hide()
	modulate.a = 0.0
	if QuiverEditorHelper.is_standalone_run(self):
		open_how_to_play()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func open_how_to_play() -> void:
	show()
	_back.grab_focus()
	if _tween:
		_tween.kill()
	_tween = create_tween()
	@warning_ignore(return_value_discarded)
	_tween.tween_property(self, "modulate:a", 1.0, FADE_DURATION)


func close_how_to_play() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	@warning_ignore(return_value_discarded)
	_tween.tween_property(self, "modulate:a", 0.0, FADE_DURATION)
	@warning_ignore(return_value_discarded)
	_tween.tween_callback(_on_close_finished)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_close_finished() -> void:
	hide()
	how_to_play_closed.emit()


func _on_back_pressed() -> void:
	close_how_to_play()

### -----------------------------------------------------------------------------------------------
