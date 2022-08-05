@tool
extends "res://addons/quiver.beat_em_up/characters/action_states/quiver_action_attack.gd"

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const GrabState = preload(
		"res://addons/quiver.beat_em_up/characters/action_states/ground_actions/"
		+"quiver_action_grab.gd"
)

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _skin_state_alt: StringName
var _skin_state_backup: StringName

@onready var _grab_state := get_parent() as GrabState

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()
	update_configuration_warnings()
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return
	
	QuiverEditorHelper.connect_between(
			Events.debug_throw_change_requested, 
			_on_Events_debug_throw_change_requested
	)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	
	if not get_parent() is GrabState:
		warnings.append(
				"This ActionState must be a child of Action GrabState or a state " 
				+ "inheriting from it."
		)
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)


func exit() -> void:
	super()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _connect_signals() -> void:
	super()
	
	QuiverEditorHelper.connect_between(_skin.suplex_landed, _on_skin_suplex_landed)


func _disconnect_signals() -> void:
	super()
	
	if is_instance_valid(_skin):
		QuiverEditorHelper.disconnect_between(_skin.suplex_landed, _on_skin_suplex_landed)


func _on_skin_suplex_landed() -> void:
	_grab_state.reparent_target_node_to(_grab_state.original_parent)
	_grab_state.grab_target_node.global_position = Vector2(
			_grab_state.grab_pivot.global_position.x,
			_character.global_position.y
	)
	_grab_state.grab_target_node.rotation = 0


func _on_Events_debug_throw_change_requested(is_slow: bool) -> void:
	if _skin_state_backup == "":
		_skin_state_backup = _skin_state
	
	if is_slow:
		_skin_state = _skin_state_alt
	else:
		_skin_state = _skin_state_backup

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

const CUSTOM_PROPERTIES_LOCAL = {
	"Attack State":{
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY,
		hint = PROPERTY_HINT_NONE,
	},
	"alt_skin_state": {
		backing_field = "_skin_state_alt",
		type = TYPE_INT,
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
	
	for key in CUSTOM_PROPERTIES_LOCAL:
		var add_property := true
		var dict: Dictionary = CUSTOM_PROPERTIES_LOCAL[key]
		if not dict.has("name"):
			dict.name = key
		
		match key:
			"path_combo_state":
				add_property = _can_combo
		
		if add_property:
			properties.append(dict)
	
	return properties


func _get(property: StringName):
	var value
	
	if property in CUSTOM_PROPERTIES_LOCAL and CUSTOM_PROPERTIES_LOCAL[property].has("backing_field"):
		value = get(CUSTOM_PROPERTIES_LOCAL[property]["backing_field"])
	
	return value


func _set(property: StringName, value) -> bool:
	var has_handled: = false
	
	if property in CUSTOM_PROPERTIES_LOCAL and CUSTOM_PROPERTIES_LOCAL[property].has("backing_field"):
		set(CUSTOM_PROPERTIES_LOCAL[property]["backing_field"], value)
		has_handled = true
	
	return has_handled

### -----------------------------------------------------------------------------------------------
