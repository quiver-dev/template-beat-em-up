class_name QuiverCollisionTypes
extends RefCounted

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const META_KEY = "collision_type"

const PRESETS = { 
	"default": { 
		META_KEY: "default",
		"modulate": Color("0099b3"),
		"monitoring": true,
		"monitorable": true,
		"collision_layer": 1,
		"collision_mask": 1,
	},
	"player_hit_box": { 
		META_KEY: "player_hit_box",
		"modulate": Color("ff331a"),
		"monitoring": false,
		"monitorable": true,
		"collision_layer": 256,
		"collision_mask": 0,
		"character_type": CombatSystem.CharacterTypes.PLAYERS,
	},
	"player_hurt_box": { 
		META_KEY: "player_hurt_box",
		"modulate": Color("0011b3"),
		"monitoring": true,
		"monitorable": false,
		"collision_layer": 4096,
		"collision_mask": 512+2048,
		"character_type": CombatSystem.CharacterTypes.PLAYERS,
	},
	"player_grab_box": { 
		META_KEY: "player_grab_box",
		"modulate": Color("ff9f00"),
		"monitoring": false,
		"monitorable": true,
		"collision_layer": 1024,
		"collision_mask": 0,
		"character_type": CombatSystem.CharacterTypes.PLAYERS,
	},
	"enemy_hit_box": { 
		META_KEY: "enemy_hit_box",
		"modulate": Color("ff331a"),
		"monitoring": false,
		"monitorable": true,
		"collision_layer": 512,
		"collision_mask": 0,
		"character_type": CombatSystem.CharacterTypes.ENEMIES,
	},
	"enemy_hurt_box": { 
		META_KEY: "enemy_hurt_box",
		"modulate": Color("0011b3"),
		"monitoring": true,
		"monitorable": false,
		"collision_layer": 8192,
		"collision_mask": 256+1024,
		"character_type": CombatSystem.CharacterTypes.ENEMIES,
	},
	"enemy_grab_box": { 
		META_KEY: "enemy_grab_box",
		"modulate": Color("ff9f00"),
		"monitoring": false,
		"monitorable": true,
		"collision_layer": 2048,
		"collision_mask": 0,
		"character_type": CombatSystem.CharacterTypes.ENEMIES,
	},
	"world_hit_box": { 
		META_KEY: "world_hit_box",
		"modulate": Color("ff1167"),
		"monitoring": false,
		"monitorable": true,
		"collision_layer": 128,
		"collision_mask": 0,
		"character_type": CombatSystem.CharacterTypes.BOUNCE_OBSTACLE,
	},
	"player_detector": { 
		META_KEY: "player_detector",
		"modulate": Color("ffff00"),
		"monitoring": true,
		"monitorable": false,
		"collision_layer": 0,
		"collision_mask": 1,
	},
	"custom": {
		META_KEY: "custom",
		"modulate": Color("0099b3"),
	}
}

const COLLISION_LAYER_WORLD_HIT_BOX = 8

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

static func apply_preset_to(dict: Dictionary, node: Node2D) -> void:
	if node is CollisionShape2D:
		node.set_meta(META_KEY, dict[META_KEY])
		node.modulate = dict.modulate
	elif node is Area2D:
		for key in dict:
			if key == META_KEY:
				node.set_meta(META_KEY, dict[META_KEY])
			elif key == "modulate":
				continue
			else:
				node.set(key, dict[key])
		
		for child in node.get_children():
			if child is CollisionShape2D:
				QuiverCollisionTypes.apply_preset_to(dict, child)
	
	node.update_configuration_warnings()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------

