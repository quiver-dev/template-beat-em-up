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

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	if not has_meta(QuiverCollisionTypes.META_KEY):
		_handle_character_type_presets()
	
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return
	
	var owner_path := owner.get_path()
	add_to_group(StringName(owner_path))
	
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
	
	if QuiverCombatSystem.is_in_same_lane_as(character_attributes, hit_box.character_attributes):
		QuiverCombatSystem.apply_damage(hit_box.attack_data, character_attributes)
		var knockback: QuiverKnockback = QuiverKnockback.new(
				hit_box.attack_data.knockback,
				hit_box.attack_data.hurt_type,
				_get_treated_launch_vector(hit_box)
		)
		QuiverCombatSystem.apply_knockback(knockback, character_attributes)
		
		if hit_box.character_type == QuiverCombatSystem.CharacterTypes.PLAYERS:
			Events.enemy_data_sent.emit(character_attributes, hit_box.character_attributes)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _get_treated_launch_vector(hit_box: QuiverHitBox) -> Vector2:
	var launch_vector := hit_box.attack_data.launch_vector
	if _attack_is_coming_from_right(hit_box):
		launch_vector = launch_vector.reflect(Vector2.UP)
	return launch_vector


func _attack_is_coming_from_right(hit_box: QuiverHitBox) -> bool:
	return hit_box.global_position.x > global_position.x

### -----------------------------------------------------------------------------------------------
