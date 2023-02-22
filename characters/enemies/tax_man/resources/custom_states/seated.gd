@tool
extends QuiverCharacterAction

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const INVALID_POSITION = Vector2.ONE * INF

@onready var ONE_SHOT_TIMER = load("res://addons/quiver.beat_em_up/utilities/OneShotTimer.tscn")

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _swirl_max := 8:
	set(value):
		_swirl_max = max(value, _swirl_min)
var _swirl_min := 3:
	set(value):
		_swirl_min = min(value, _swirl_max)
var _swirld_duration := 0

var _path_idle := "Ground/Move/IdleAi"

var _skin_reveal := &"seated_reveal"
var _skin_swirl := &"seated_swirl"
var _skin_drink := &"seated_drink"
var _skin_laugh := &"seated_laugh"
var _skin_engage := &"seated_engage"
var _current_animation: StringName:
	set(value):
		_current_animation = value
		if is_instance_valid(_skin):
			_skin.transition_to(_current_animation)

var _engage_position := INVALID_POSITION
var _swirl_timer: Timer

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return
	
	if not has_node("Timer"):
		_swirl_timer = ONE_SHOT_TIMER.instantiate()
		add_child(_swirl_timer, true)
	
	var reference_nodes := get_tree().get_nodes_in_group("tax_man_engage_position")
	if not reference_nodes.is_empty():
		if reference_nodes.size() > 1:
			push_warning(
					"Tax Man only expects one engage position." 
					+ "Taking first one and ingonring the rest."
					+ "Nodes found: %s"%[reference_nodes]
			)
		
		if reference_nodes[0] is Node2D:
			_engage_position = reference_nodes[0].global_position
		else:
			push_error("Expected a Node2D as reference for Tax Man's enagage position.")


### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	_character._disable_collisions()
	await _character.tax_man_revealed
	_current_animation = _skin_reveal


func exit() -> void:
	super()
	if not _engage_position == INVALID_POSITION:
		_character.global_position = _engage_position
	_character._enable_collisions()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _connect_signals() -> void:
	super()
	QuiverEditorHelper.connect_between(_skin.skin_animation_finished, _on_skin_animation_finished)


func _disconnect_signals() -> void:
	super()
	if _skin != null:
		QuiverEditorHelper.disconnect_between(
			_skin.skin_animation_finished, _on_skin_animation_finished
		)
	
	if _character != null:
		QuiverEditorHelper.disconnect_between(_character.tax_man_laughed, _on_tax_man_laughed)
		QuiverEditorHelper.disconnect_between(_character.tax_man_engaged, _on_tax_man_engaged)
	
	if _swirl_timer != null:
		QuiverEditorHelper.disconnect_between(_swirl_timer.timeout, _on_swirl_timer_timeout)


func _reset_swirl_duration() -> void:
	_swirld_duration = randi_range(_swirl_min, _swirl_max)
	_swirl_timer.start(_swirld_duration)


func _on_tax_man_laughed() -> void:
	_current_animation = _skin_laugh
	_swirl_timer.stop()


func _on_tax_man_engaged() -> void:
	_current_animation = _skin_engage
	_swirl_timer.stop()


func _on_skin_animation_finished() -> void:
	if _current_animation == _skin_reveal:
		QuiverEditorHelper.connect_between(_character.tax_man_laughed, _on_tax_man_laughed)
		QuiverEditorHelper.connect_between(_character.tax_man_engaged, _on_tax_man_engaged)
		QuiverEditorHelper.connect_between(_swirl_timer.timeout, _on_swirl_timer_timeout)
		_current_animation = _skin_swirl
		_reset_swirl_duration()
	elif _current_animation in [_skin_drink, _skin_laugh]:
		_current_animation = _skin_swirl
		_reset_swirl_duration()
	elif _current_animation == _skin_engage:
		_state_machine.transition_to(_path_idle)
	else:
		if _current_animation != _skin_swirl:
			push_error("Unknown animation: %s"%[_current_animation])


func _on_swirl_timer_timeout() -> void:
	_current_animation = _skin_drink
	_reset_swirl_duration()

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

func _get_custom_properties() -> Dictionary:
	return {
		"Seated State":{
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_CATEGORY,
			hint = PROPERTY_HINT_NONE,
		},
		"_path_idle": {
			default_value = "Ground/Move/IdleAi",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_NONE,
			hint_string = QuiverState.HINT_STATE_LIST,
		},
		"_swirl_max": {
			default_value = 8,
			type = TYPE_INT,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		},
		"_swirl_min": {
			default_value = 3,
			type = TYPE_INT,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		},
		"Animations":{
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_GROUP,
			hint_string = "_skin_",
		},
		"_skin_reveal": {
			default_value = &"seated_reveal",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_ENUM,
			hint_string = \
					'ExternalEnum{"property": "_skin", "property_name": "_animation_list"}'
		},
		"_skin_swirl": {
			default_value = &"seated_swirl",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_ENUM,
			hint_string = \
					'ExternalEnum{"property": "_skin", "property_name": "_animation_list"}'
		},
		"_skin_drink": {
			default_value = &"seated_drink",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_ENUM,
			hint_string = \
					'ExternalEnum{"property": "_skin", "property_name": "_animation_list"}'
		},
		"_skin_laugh": {
			default_value = &"seated_laugh",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_ENUM,
			hint_string = \
					'ExternalEnum{"property": "_skin", "property_name": "_animation_list"}'
		},
		"_skin_engage": {
			default_value = &"seated_engage",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_ENUM,
			hint_string = \
					'ExternalEnum{"property": "_skin", "property_name": "_animation_list"}'
		},
#		"": {
#			backing_field = "", # use if dict key and variable name are different
#			default_value = "", # use if you want property to have a default value
#			type = TYPE_NIL,
#			usage = PROPERTY_USAGE_DEFAULT,
#			hint = PROPERTY_HINT_NONE,
#			hint_string = "",
#		},
	}

### Custom Inspector built in functions -----------------------------------------------------------

func _get_property_list() -> Array:
	var properties: = []
	
	var custom_properties := _get_custom_properties()
	for key in custom_properties:
		var dict: Dictionary = custom_properties[key]
		if not dict.has("name"):
			dict.name = key
		properties.append(dict)
	
	return properties


func _property_can_revert(property: StringName) -> bool:
	var custom_properties := _get_custom_properties()
	if property in custom_properties and custom_properties[property].has("default_value"):
		return true
	else:
		return false


func _property_get_revert(property: StringName):
	var value
	
	var custom_properties := _get_custom_properties()
	if property in custom_properties and custom_properties[property].has("default_value"):
		value = custom_properties[property]["default_value"]
	
	return value


func _get(property: StringName):
	var value
	
	var custom_properties := _get_custom_properties()
	if property in custom_properties and custom_properties[property].has("backing_field"):
		value = get(custom_properties[property]["backing_field"])
	
	return value


func _set(property: StringName, value) -> bool:
	var has_handled: = false
	
	var custom_properties := _get_custom_properties()
	if property in custom_properties and custom_properties[property].has("backing_field"):
		set(custom_properties[property]["backing_field"], value)
		has_handled = true
	
	return has_handled

### -----------------------------------------------------------------------------------------------
