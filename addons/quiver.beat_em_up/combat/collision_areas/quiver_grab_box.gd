@tool
class_name QuiverGrabBox
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

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	if not has_meta(QuiverCollisionTypes.META_KEY):
		_handle_character_type_presets()
	
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return
	
	add_to_group(StringName(owner.get_path()))


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	
	var collision_type := get_meta(QuiverCollisionTypes.META_KEY, "default") as String
	if collision_type.find("grab_box") == -1 and collision_type != "custom":
		warnings.append("grab box area is using an invalid presset")
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _handle_character_type_presets() -> void:
	var collision_type := get_meta(QuiverCollisionTypes.META_KEY, "default") as String
	if collision_type == "custom":
		return
	
	var target_collision_type := ""
	match character_type:
		QuiverCombatSystem.CharacterTypes.PLAYERS:
			target_collision_type = "player_grab_box"
		QuiverCombatSystem.CharacterTypes.ENEMIES:
			target_collision_type = "enemy_grab_box"
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

### -----------------------------------------------------------------------------------------------

