@tool
class_name TaxManBoss
extends QuiverEnemyCharacter

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

signal phase_changed_to(phase: int)
signal tax_man_revealed
signal tax_man_laughed
signal tax_man_engaged

#--- enums ----------------------------------------------------------------------------------------

enum TaxManPhases { PHASE_ONE, PHASE_TWO, PHASE_THREE, PHASE_DIE }

#--- constants ------------------------------------------------------------------------------------

const QuiverAiGoToClosestPosition := preload("res://addons/quiver.beat_em_up/characters/ai/states/quiver_ai_go_to_closest_position.gd")

#--- public variables - order: export > normal var > onready --------------------------------------

@export var should_start_seated := false:
	set(value):
		should_start_seated = value
		if not is_inside_tree():
			await ready
		
		if should_start_seated:
			get_tree().call_group("tax_man_preview", "set_seated_preview")
		else:
			get_tree().call_group("tax_man_preview", "set_standing_preview")

#--- private variables - order: export > normal var > onready -------------------------------------

var _phases_health_thresholds := {
	TaxManPhases.PHASE_ONE: 1.00,
	TaxManPhases.PHASE_TWO: 0.50,
	TaxManPhases.PHASE_THREE: 0.15,
	TaxManPhases.PHASE_DIE: 0.0,
}

# Used by tax man's hurt state
@warning_ignore("unused_private_class_variable")
var _max_damage_in_one_combo := 0.1

var _health_previous := 1.0
var _current_cumulated_damage := 0.0

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()
	
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return
	
	_health_previous = attributes.get_health_as_percentage()
	_populate_dash_positions_from_stage()
	
	var players := get_tree().get_nodes_in_group("players")
	for node in players:
		var player = node as QuiverCharacter
		player.attributes.health_changed.connect(_on_player_hurt)
		player.attributes.health_depleted.connect(_on_player_hurt)

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func can_deny_grabs() -> bool:
	return true

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _populate_dash_positions_from_stage() -> void:
	var possible_positions := get_tree().get_nodes_in_group("tax_man_dash_positions")
	assert(\
			not possible_positions.is_empty(), \
			"Found no dash marker nodes for taxman in current stage."\
			+ ' Add some nodes to the group "tax_man_dash_positions"'\
	)
	var dash_position_states := get_tree().get_nodes_in_group("tm_dash_position_states")
	for node in dash_position_states:
		var state := node as QuiverAiGoToClosestPosition
		if state != null:
			state.pool_nodes = possible_positions


func _update_cumulated_damage() -> void:
	_current_cumulated_damage += _health_previous - attributes.get_health_as_percentage()


func _reset_cumulated_damage() -> void:
	_current_cumulated_damage = 0.0
	_health_previous = attributes.get_health_as_percentage()


func _on_player_hurt() -> void:
	tax_man_laughed.emit()

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

### Custom Inspector built in functions -----------------------------------------------------------

func _get_property_list() -> Array:
	var properties: = []
	
	properties.append({
		name = "_max_damage_in_one_combo",
		type = TYPE_FLOAT,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_RANGE,
		hint_string = "0.0,1.0,0.01",
	})
	
	properties.append({
		name = "Boss Phases Health Thresholds",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_GROUP,
		hint_string = "health_threshold_",
	})
	
	for type in TaxManPhases.values():
		var new_dict = {
			name = "health_threshold_%s"%[TaxManPhases.keys()[type].to_lower()],
			type = TYPE_FLOAT,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0.0,1.0,0.01",
		}
		properties.append(new_dict)
	
	return properties


func _get(property: StringName):
	var value
	
	if (property as String).begins_with("health_threshold_"):
		var phase_type = (property as String).replace("health_threshold_", "").to_upper()
		if not _phases_health_thresholds.has(TaxManPhases[phase_type]):
			_phases_health_thresholds[TaxManPhases[phase_type]] = 0.0
		value = _phases_health_thresholds[TaxManPhases[phase_type]]
	
	return value


func _set(property: StringName, value) -> bool:
	var has_handled: = false
	
	if (property as String).begins_with("health_threshold_"):
		var phase_type = (property as String).replace("health_threshold_", "").to_upper()
		_phases_health_thresholds[TaxManPhases[phase_type]] = value
		has_handled = true
	
	return has_handled


func _property_can_revert(property: StringName) -> bool:
	if property == &"_max_damage_in_one_combo":
		return true
	else:
		return false


func _property_get_revert(property: StringName):
	var value
	
	if property == &"_max_damage_in_one_combo":
		value = 0.1
	
	return value

### -----------------------------------------------------------------------------------------------
