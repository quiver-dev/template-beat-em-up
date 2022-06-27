@tool
class_name QuiverHurtBox
extends Area2D

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export var character_type: QuiverCombatSystem.CharacterTypes = \
		QuiverCombatSystem.CharacterTypes.PLAYERS:
	set(value):
		character_type = value 
		_handle_character_type_presets()
		notify_property_list_changed()
		update_configuration_warnings()

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
		_handle_character_type_presets()
	
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return
	
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	
	var collision_type := get_meta(QuiverCollisionTypes.META_KEY, "default") as String
	if collision_type.find("hurt_box") == -1 and collision_type != "custom":
		warnings.append("hurt box area is using an invalid presset")
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func _handle_character_type_presets() -> void:
	var collision_type := get_meta(QuiverCollisionTypes.META_KEY, "default") as String
	if collision_type == "custom":
		return
	
	var target_collision_type := ""
	match character_type:
		QuiverCombatSystem.CharacterTypes.PLAYERS:
			target_collision_type = "player_hurt_box"
		QuiverCombatSystem.CharacterTypes.ENEMIES:
			target_collision_type = "enemy_hurt_box"
		_:
			push_error("Unimplemented CharacterType: %s. Possible types: %s"%[
					character_type,
					QuiverCombatSystem.CharacterTypes.keys()
			])
			return
	
	if target_collision_type != collision_type:
		QuiverCollisionTypes.apply_preset_to(
				QuiverCollisionTypes.PRESETS[target_collision_type], self
		)


func _on_area_entered(area: Area2D) -> void:
	var hit_box := area as QuiverHitBox
	if hit_box == null:
		push_error("Unrecognized collision between: %s and %s"%[self, area])
		return
	
	print("collided with: %s"%[hit_box.character_attributes.resource_path])

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
