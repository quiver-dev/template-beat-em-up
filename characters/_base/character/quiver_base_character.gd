@tool
class_name QuiverCharacter
extends CharacterBody2D

## Base class for characters, either player characters or enemies.
##
## It is recomended to use this class by inheriting from the base scene at
## [code]res://characters/_base/character/base_character.tscn[/code].
## [br][br]It has a [QuiverCharacterSkin], and a collision dependency, that must be added in the 
## inherited scene and configured in their respective properties in the editor.
## [br][br]It also has an internal dependencie for a state machine, which in the base scene has no
## states in it, as this is also something that must be added per character, according to the
## character's requirements.

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

var attributes: QuiverAttributes = null:
	set(value):
		attributes = value
		if is_instance_valid(_skin):
			_skin.attributes = attributes

var is_on_air := false

#--- private variables - order: export > normal var > onready -------------------------------------

## This is also here as a "hack" for the lack of custom typed exports. It is private because I don't 
## want to deal with this in code, it's just an editor field to populate the real property which
## is the public [member attributes]. Once custom typed exports exist this will be converted
## to it.
@export var _attributes: Resource:
	set(value):
		attributes = value as QuiverAttributes
	get:
		return attributes

## Must point to a valid skin node. 
## [br][br]This is a "private" exported property just as reminder that this property 
## shouldn't be changed outside of it's own scene neither point to a Node that
## is outside the Scene.
@export_node_path(Node2D) var _path_skin := NodePath("Skin"):
	set(value):
		_path_skin = value
		if is_inside_tree():
			_skin = get_node_or_null(_path_skin) as QuiverCharacterSkin
		update_configuration_warnings()

## Must point to a valid collision node, either a CollisionPolygon2D or CollisionShape2D.
## [br][br]This is a "private" exported property just as reminder that this property 
## shouldn't be changed outside of it's own scene neither point to a Node that
## is outside the Scene.
@export_node_path(CollisionPolygon2D, CollisionShape2D) 
var _path_collision := NodePath("Collision"):
	set(value):
		_path_collision = value
		if is_inside_tree():
			_collision = get_node_or_null(_path_collision)
		update_configuration_warnings()

@onready var _skin := get_node_or_null(_path_skin) as QuiverCharacterSkin
@onready var _collision := get_node_or_null(_path_collision) as Node2D
@warning_ignore(unused_private_class_variable)
@onready var _state_machine := $StateMachine as QuiverStateMachine

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return
	
	const ERROR_BASE_SCENE_USED_DIRECTLY = (
		"You should not use this scene directly, inherit from it to create your characters"
	)
	var is_not_base_scene = \
			scene_file_path != "res://characters/_base/character/quiver_base_character.tscn"
	assert(is_not_base_scene, ERROR_BASE_SCENE_USED_DIRECTLY)
	
	if attributes != null:
		attributes.character_node = self


func _get_configuration_warnings() -> PackedStringArray:
	const INVALID_SKIN = "_path_skin must point to a valid QuiverCharacterSkin Node." 
	const INVALID_COLLISION = \
			"_path_collision must point to a valid CollisionShape2D or CollisionPolygon2D Node."
	const INVALID_ATTRIBUTES = "attributes must have a valid CharacterAttributes resource."
	var warnings := PackedStringArray()
	
	if _attributes == null:
		warnings.append(INVALID_ATTRIBUTES)
	
	if _path_skin.is_empty() or _skin == null:
		warnings.append(INVALID_SKIN)
	
	if _path_collision.is_empty() or _collision == null:
		warnings.append(INVALID_COLLISION)
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _disable_ceiling_collisions() -> void:
	set_collision_mask_value(QuiverCollisionTypes.COLLISION_LAYER_CEILING, false)


func _enable_ceiling_collisions() -> void:
	set_collision_mask_value(QuiverCollisionTypes.COLLISION_LAYER_CEILING, true)


func _disable_collisions() -> void:
	_collision.set_deferred("disabled", true)


func _enable_collisions() -> void:
	_collision.set_deferred("disabled", false)

### -----------------------------------------------------------------------------------------------
