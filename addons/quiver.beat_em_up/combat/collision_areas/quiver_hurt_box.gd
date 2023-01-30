@tool
class_name QuiverHurtBox
extends Area2D

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export var character_type: CombatSystem.CharacterTypes = \
		CombatSystem.CharacterTypes.PLAYERS:
	set(value):
		character_type = value 
		if Engine.is_editor_hint():
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
	
	QuiverEditorHelper.connect_between(area_entered, _on_area_entered)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	
	var collision_type := get_meta(QuiverCollisionTypes.META_KEY, "default") as String
	if collision_type.find("hurt_box") == -1 and collision_type != "custom":
		warnings.append("hurt box area is using an invalid presset")
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_area_entered(area: Area2D) -> void:
	if area is WallHitBox:
		_handle_wall_hit_box(area)
	elif area is QuiverHitBox:
		_handle_hit_box(area)
	elif area is QuiverGrabBox:
		_handle_grab_box(area)
	else:
		push_error("Unrecognized collision between: %s and %s"%[self, area])
		return


func _can_be_attacked_by(attacker: QuiverAttributes) -> bool:
	var value := false
	
	if not character_attributes.is_invulnerable:
		value = CombatSystem.is_in_same_lane_as(character_attributes, attacker)
	
	return value


func _can_be_grabbed_by(grabber: QuiverAttributes) -> bool:
	var value := false
	
	if (
		not character_attributes.is_invulnerable 
		and not character_attributes.has_superarmor
		and character_attributes.can_be_grabbed
	):
		value = CombatSystem.is_in_same_lane_as(character_attributes, grabber)
	
	return value


func _handle_hit_box(hit_box: QuiverHitBox) -> void:
	if _can_be_attacked_by(hit_box.character_attributes):
#		print("hit_box: %s"%[hit_box.get_path()])
		CombatSystem.apply_damage(hit_box.attack_data, character_attributes)
		var knockback: QuiverKnockback = QuiverKnockback.new(
				hit_box.attack_data.knockback,
				hit_box.attack_data.hurt_type,
				_get_treated_launch_vector(hit_box)
		)
		CombatSystem.apply_knockback(knockback, character_attributes)
		
		if hit_box.character_type == CombatSystem.CharacterTypes.PLAYERS:
			Events.enemy_data_sent.emit(character_attributes, hit_box.character_attributes)


func _handle_wall_hit_box(wall_hit_box: WallHitBox) -> void: 
	CombatSystem.apply_damage(wall_hit_box.attack_data, character_attributes)
	character_attributes.wall_bounced.emit()


func _handle_grab_box(grab_box: QuiverGrabBox) -> void:
	if _can_be_grabbed_by(grab_box.character_attributes):
		grab_box.character_attributes.grab_requested.emit(character_attributes)


func _get_treated_launch_vector(hit_box: QuiverHitBox) -> Vector2:
	var launch_vector := hit_box.attack_data.launch_vector
	if _attack_is_coming_from_right(hit_box):
		launch_vector = launch_vector.reflect(Vector2.UP)
	return launch_vector


func _attack_is_coming_from_right(hit_box: QuiverHitBox) -> bool:
	return hit_box.global_position.x > global_position.x


func _disable_wall_bounce_collisions() -> void:
	set_collision_mask_value(QuiverCollisionTypes.COLLISION_LAYER_WORLD_HIT_BOX, false)


func _enable_wall_bounce_collisions() -> void:
	set_collision_mask_value(QuiverCollisionTypes.COLLISION_LAYER_WORLD_HIT_BOX, true)


func _handle_character_type_presets() -> void:
	var collision_type := get_meta(QuiverCollisionTypes.META_KEY, "default") as String
	if collision_type == "custom":
		return
	
	var target_collision_type := ""
	match character_type:
		CombatSystem.CharacterTypes.PLAYERS:
			target_collision_type = "player_hurt_box"
		CombatSystem.CharacterTypes.ENEMIES:
			target_collision_type = "enemy_hurt_box"
		CombatSystem.CharacterTypes.BOUNCE_OBSTACLE:
			push_error("Bounce Obstacles is currently icompatible with hurt boxes")
		_:
			push_error("Unimplemented CharacterType: %s. Possible types: %s"%[
					character_type,
					CombatSystem.CharacterTypes.keys()
			])
			return
	
	if target_collision_type != collision_type:
		QuiverCollisionTypes.apply_preset_to(
				QuiverCollisionTypes.PRESETS[target_collision_type], self
		)

### -----------------------------------------------------------------------------------------------
