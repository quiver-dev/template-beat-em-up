class_name QuiverCharacterHelper
extends RefCounted

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

static func find_closest_player_to(node_2d: Node2D) -> QuiverCharacter:
	var value: QuiverCharacter = null
	var players: Array = node_2d.get_tree().get_nodes_in_group("players")
	
	if players.size() == 1:
		value = players.front()
	elif players.size() > 1:
		var min_distance := INF
		for player in players:
			var distance = node_2d.global_position.distance_squared_to(player.global_position)
			if distance < min_distance:
				min_distance = distance
				value = player
	
	return value

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------

