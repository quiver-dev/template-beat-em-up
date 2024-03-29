@tool
class_name QuiverActionDieAi
extends QuiverActionDie

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_skin_animation_finished() -> void:
	_character.queue_free()
	var enemy_defeated_event = Callable(Events, "emit_signal").bind("enemy_defeated")
	QuiverEditorHelper.connect_between(tree_exited, enemy_defeated_event, CONNECT_ONE_SHOT)

### -----------------------------------------------------------------------------------------------
