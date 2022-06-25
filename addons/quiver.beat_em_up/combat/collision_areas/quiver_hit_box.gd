@tool
class_name QuiverHitBox
extends Area2D

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

var character_attributes: QuiverAttributes = null

#--- private variables - order: export > normal var > onready -------------------------------------

## This is also here as a "hack" for the lack of advanced exports. It is private because I don't 
## want to deal with this in code, it's just an editor field to populate the real property which
## is the public [member character_attributes]. Once advanced exportes exist this will be converted
## to it.
@export var _attributes: Resource:
	set(value):
		character_attributes = value as QuiverAttributes
	get:
		return character_attributes


### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	if not has_meta(QuiverCollisionTypes.META_KEY):
		QuiverCollisionTypes.apply_preset_to(QuiverCollisionTypes.PRESETS.hit_box, self)
	
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	
	var collision_type := get_meta(QuiverCollisionTypes.META_KEY, "default") as String
	if collision_type != "hit_box" and collision_type != "custom":
		warnings.append("hit box area is using an invalid presset")
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------

