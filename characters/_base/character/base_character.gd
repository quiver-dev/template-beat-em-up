@tool
class_name QuiverCharacter
extends CharacterBody2D
# Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

@export_node_path(QuiverCharacterSkin) var _path_skin := NodePath("Skin"):
	set(value):
		_path_skin = value
		if is_inside_tree():
			_skin = get_node_or_null(_path_skin) as QuiverCharacterSkin
		update_configuration_warnings()

@onready var _skin := get_node_or_null(_path_skin) as QuiverCharacterSkin
@onready var _state_machine := $StateMachine as QuiverStateMachine

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	pass


func _get_configuration_warnings() -> PackedStringArray:
	const INVALID_SKIN = "_path_skin must point to a valid QuiverCharacterSkin Node." 
	var warnings := PackedStringArray()
	
	if _path_skin.is_empty():
		warnings.append(INVALID_SKIN)
	elif _skin == null:
		warnings.append(INVALID_SKIN)
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------

