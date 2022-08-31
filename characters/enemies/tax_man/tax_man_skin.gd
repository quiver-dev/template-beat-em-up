@tool
extends QuiverCharacterSkin

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

signal dash_attack_succeeded
signal dash_attack_failed

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const LAYER_PLAYER = 1
const LAYER_OBSTACLES = 2
const LAYER_WALLS = 3

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

func _on_dash_obstacle_detector_body_entered(body: Node2D) -> void:
	if body is PhysicsBody2D:
		if _body_is_player(body):
			dash_attack_succeeded.emit()
		else:
			dash_attack_failed.emit()


func _body_is_player(body: PhysicsBody2D):
	var value := body is QuiverCharacter and body.get_collision_layer_value(LAYER_PLAYER)
	return value

### -----------------------------------------------------------------------------------------------
