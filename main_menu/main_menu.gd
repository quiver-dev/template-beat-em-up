extends Control

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

signal transition_started

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const GAMEPLAY_SCENE = "res://stages/stage_01/stage_01.tscn"

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

@onready var _how_to_play := $HowToPlay as HowToPlay
@onready var _animator := $AnimationPlayer as AnimationPlayer
@onready var _start_button := $MenuButtons/Start as Button

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	BackgroundLoader.load_resource(GAMEPLAY_SCENE)
	ScreenTransitions.fade_out_transition()
	_start_button.grab_focus()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_start_pressed() -> void:
	_animator.play("game_started")
	await transition_started
	ScreenTransitions.transition_to_scene(GAMEPLAY_SCENE)


func _start_transition() -> void:
	transition_started.emit()


func _on_how_to_play_pressed() -> void:
	_how_to_play.open_how_to_play()


func _on_quit_pressed() -> void:
	get_tree().quit()

### -----------------------------------------------------------------------------------------------
