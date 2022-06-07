@tool
class_name QuiverCharacter
extends CharacterBody2D

## Base class for characters, either player characters or enemies.
##
## It is recomended to use this class by inheriting from the base scene at
## [code]res://characters/_base/character/base_character.tscn[/code].
## [br][br]It has a [QuiverCharacterSkin] dependency, that must be added in the inherited scene and 
## configured in the [member _path_skin] property in the editor. This is a "private" property 
## because it is not intended to be modified outside the scene, or to point to a node outside the ## scene.
## [br][br]It also has an internal dependent for a state machine, which in the base scene has no
## states in it, as this is also something that must be added per character, according to the
## character's requirements.

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

var is_on_air := false
var ground_level := 0.0

#--- private variables - order: export > normal var > onready -------------------------------------

## Must point to a valid skin node. This is a "private" exported property just as reminder that 
## this property shouldn't be changed outside of it's own scene neither point to a Node that
## is outside the Scene.
@export_node_path(Node2D) var _path_skin := NodePath("Skin"):
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

