@tool
extends QuiverCharacterState

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
	QuiverEditorHelper.connect_between(_character.tax_man_laughed, _on_tax_man_laughed)
	QuiverEditorHelper.connect_between(_character.tax_man_engaged, _on_tax_man_engaged)
	QuiverEditorHelper.connect_between(_swirl_timer.timeout, _on_swirl_timer_timeout)


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

const CUSTOM_PROPERTIES = {
	"Seated State":{
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY,
		hint = PROPERTY_HINT_NONE,
	},
	"path_idle_state": {
		backing_field = "_path_idle",
		type = TYPE_STRING,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_NONE,
		hint_string = QuiverState.HINT_STATE_LIST,
	},
	"swirl_max": {
		backing_field = "_swirl_max",
		type = TYPE_INT,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
	},
	"swirl_min": {
		backing_field = "_swirl_min",
		type = TYPE_INT,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
	},
	"Animations":{
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_GROUP,
		hint_string = "skin_",
	},
	"skin_reveal": {
		backing_field = "_skin_reveal",
		type = TYPE_STRING,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_ENUM,
		hint_string = \
				'ExternalEnum{"property": "_skin", "property_name": "_animation_list"}'
	},
	"skin_swirl": {
		backing_field = "_skin_swirl",
		type = TYPE_STRING,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_ENUM,
		hint_string = \
				'ExternalEnum{"property": "_skin", "property_name": "_animation_list"}'
	},
	"skin_drink": {
		backing_field = "_skin_drink",
		type = TYPE_STRING,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_ENUM,
		hint_string = \
				'ExternalEnum{"property": "_skin", "property_name": "_animation_list"}'
	},
	"skin_laugh": {
		backing_field = "_skin_laugh",
		type = TYPE_STRING,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_ENUM,
		hint_string = \
				'ExternalEnum{"property": "_skin", "property_name": "_animation_list"}'
	},
	"skin_engage": {
		backing_field = "_skin_engage",
		type = TYPE_STRING,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_ENUM,
		hint_string = \
				'ExternalEnum{"property": "_skin", "property_name": "_animation_list"}'
	},
#	"": {
#		backing_field = "",
#		name = "",
#		type = TYPE_NIL,
#		usage = PROPERTY_USAGE_DEFAULT,
#		hint = PROPERTY_HINT_NONE,
#		hint_string = "",
#	},
}

### Custom Inspector built in functions -----------------------------------------------------------

func _get_property_list() -> Array:
	var properties: = []
	
	for key in CUSTOM_PROPERTIES:
		var add_property := true
		var dict: Dictionary = CUSTOM_PROPERTIES[key]
		if not dict.has("name"):
			dict.name = key
		
		if add_property:
			properties.append(dict)
	
	return properties


func _get(property: StringName):
	var value
	
	if property in CUSTOM_PROPERTIES and CUSTOM_PROPERTIES[property].has("backing_field"):
		value = get(CUSTOM_PROPERTIES[property]["backing_field"])
	
	return value


func _set(property: StringName, value) -> bool:
	var has_handled: = false
	
	if property in CUSTOM_PROPERTIES and CUSTOM_PROPERTIES[property].has("backing_field"):
		set(CUSTOM_PROPERTIES[property]["backing_field"], value)
		has_handled = true
	
	return has_handled

### -----------------------------------------------------------------------------------------------
