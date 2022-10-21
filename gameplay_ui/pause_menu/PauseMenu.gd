extends Control

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const PATH_MAIN_MENU = "res://main_menu/main_menu.tscn"
const TEXT_TIMESCALE_VALUE = "%0.2f"

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _main_menu: PackedScene = null

@onready var _button_resume := $PanelContainer/Content/Resume as Button
@onready var _how_to_play := $HowToPlay as HowToPlay
@onready var _animator := $AnimationPlayer as AnimationPlayer
@onready var _timescale_slider := $PanelContainer/Content/TimeScaleLine/Slider as HSlider
@onready var _timescale_value := $PanelContainer/Content/TimeScaleLine/Value as Label

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	BackgroundLoader.load_resource(PATH_MAIN_MENU)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if not visible:
			open_pause_menu()
		else:
			close_pause_menu()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func open_pause_menu() -> void:
	get_tree().paused = true
	_button_resume.grab_focus()
	_animator.play("open")


func close_pause_menu() -> void:
	_animator.play("close")

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

# called by open animation
func _update_time_scale_value() -> void:
	_timescale_slider.value = Engine.time_scale
	_timescale_value.text = TEXT_TIMESCALE_VALUE%[Engine.time_scale]


# Called by close animation
func _unpause() -> void:
	get_tree().paused = false


func _on_resume_pressed() -> void:
	close_pause_menu()


func _on_restart_pressed() -> void:
	Events.characters_reseted.emit()
	get_tree().reload_current_scene()
	get_tree().paused = false


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_slider_value_changed(value: float) -> void:
	Engine.time_scale = value
	_timescale_value.text = TEXT_TIMESCALE_VALUE%[value]


func _on_quit_to_main_menu_pressed() -> void:
	ScreenTransitions.transition_to_scene(PATH_MAIN_MENU)
	get_tree().paused = false


func _on_how_to_play_pressed() -> void:
	_how_to_play.open_how_to_play()


func _on_how_to_play_how_to_play_closed() -> void:
	_button_resume.grab_focus()

### -----------------------------------------------------------------------------------------------
