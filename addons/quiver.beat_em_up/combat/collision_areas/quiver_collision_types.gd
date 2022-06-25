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
	"hit_box": { 
		META_KEY: "hit_box",
		"modulate": Color("ff331a"),
		"monitoring": false,
		"monitorable": true,
		"collision_layer": 256,
		"collision_mask": 0,
	},
	"hurt_box": { 
		META_KEY: "hurt_box",
		"modulate": Color("0011b3"),
		"monitoring": true,
		"monitorable": false,
		"collision_layer": 0,
		"collision_mask": 256,
	},
	"custom": {
		META_KEY: "custom",
		"modulate": Color("0099b3"),
	}
}

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
			else:
				node.set(key, dict[key])
		
		for child in node.get_children():
			if child is CollisionShape2D:
				QuiverCollisionTypes.apply_preset_to(dict, child)
	
	node.update_configuration_warnings()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------

