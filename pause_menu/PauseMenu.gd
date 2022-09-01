extends Control

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

@onready var _animator := $AnimationPlayer as AnimationPlayer
@onready var _timescale_value := $PanelContainer/Content/TimeScaleLine/Value as Label

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	pass


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
	_animator.play("open")


func close_pause_menu() -> void:
	_animator.play("close")

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------


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
	_timescale_value.text = "%0.2f"%[value]


func _on_throw_variation_toggled(button_pressed: bool) -> void:
	Events.debug_throw_change_requested.emit(button_pressed)

### -----------------------------------------------------------------------------------------------
