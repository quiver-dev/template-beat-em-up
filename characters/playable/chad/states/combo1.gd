extends "res://characters/playable/chad/states/chad_state.gd"

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	get_parent().enter(msg)
	_skin.transition_to(_skin.SkinStates.ATTACK_1)


func unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		_skin.should_combo_2 = true


func exit() -> void:
	super()
	get_parent().exit()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_chad_skin_attack_1_finished() -> void:
	if _skin.should_combo_2:
		_state_machine.transition_to("Ground/Attack/Combo2")
	else:
		_state_machine.transition_to("Ground/Move/Idle")

### -----------------------------------------------------------------------------------------------

