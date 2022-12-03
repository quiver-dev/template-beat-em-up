@tool
class_name QuiverPlayerDetector
extends Area2D

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

signal player_detected

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

## If `true` player detector will remove itself once it detects a player.
@export var is_one_shot := true

@export_node_path var path_fight_room := NodePath()
@export var paths_enemy_spawners: Array[NodePath] = []

@onready var fight_room: QuiverFightRoom = get_node(path_fight_room) \
		if not path_fight_room.is_empty() else null

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		QuiverCollisionTypes.apply_preset_to(QuiverCollisionTypes.PRESETS.player_detector, self)
		return
	elif (
			OS.has_feature("editor") 
			and ProjectSettings.has_setting(QuiverCyclicHelper.SETTINGS_DISABLE_PLAYER_DETECTOR)
			and ProjectSettings.get_setting(QuiverCyclicHelper.SETTINGS_DISABLE_PLAYER_DETECTOR)
		):
		monitoring = false
		return
	
	if is_instance_valid(fight_room):
		QuiverEditorHelper.connect_between(player_detected, fight_room.setup_fight_room)
	
	for path in paths_enemy_spawners:
		var spawner := get_node(path) as QuiverEnemySpawner
		QuiverEditorHelper.connect_between(player_detected, spawner.spawn_current_wave)
	
	QuiverEditorHelper.connect_between(body_entered, _on_body_entered)

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_body_entered(body: QuiverCharacter) -> void:
	if body != null and body.is_in_group("players"):
		call_deferred("emit_signal", "player_detected")
		if is_one_shot:
			queue_free()

### -----------------------------------------------------------------------------------------------
