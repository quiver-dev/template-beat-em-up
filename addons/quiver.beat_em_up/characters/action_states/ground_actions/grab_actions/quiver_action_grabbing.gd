@tool
extends QuiverCharacterState

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

var _skin_state: StringName
var _path_next_state := "Ground/Grab/Idle"

@onready var _grab_state := get_parent() as GrabState

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()
	update_configuration_warnings()
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return


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
	_grab_state.enter(msg)
	_skin.transition_to(_skin_state)


func exit() -> void:
	super()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _adjust_grabbed_target_position(ref_position: Position2D) -> void:
	var grab_target_offset = _grab_state.grab_target.grabbed_offset
	var new_position = ref_position.global_position
	if is_instance_valid(grab_target_offset):
		var local_offset = _grab_state.grab_target_node.to_local(grab_target_offset.global_position)
		new_position -= local_offset
	_grab_state.grab_target_node.global_position = new_position


func _connect_signals() -> void:
	get_parent()._connect_signals()
	super()
	
	QuiverEditorHelper.connect_between(_skin.skin_animation_finished, _on_skin_animation_finished)
	QuiverEditorHelper.connect_between(_skin.grab_frame_reached, _on_skin_grab_frame_reached)


func _disconnect_signals() -> void:
	super()
	if _skin != null:
		QuiverEditorHelper.disconnect_between(
			_skin.skin_animation_finished, _on_skin_animation_finished
		)
		
		QuiverEditorHelper.disconnect_between(_skin.grab_frame_reached, _on_skin_grab_frame_reached)


## Connect the signal that marks the end of the attack to this function.
func _on_skin_animation_finished() -> void:
	_state_machine.transition_to(_path_next_state)


func _on_skin_grab_frame_reached(ref_position: Position2D) -> void:
	_grab_state.grab_target.grabbed.emit(_grab_state.grab_target.ground_level)
	_grab_state.reparent_target_node_to(ref_position)
	_grab_state.grab_pivot = ref_position
	_adjust_grabbed_target_position(ref_position)

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

const CUSTOM_PROPERTIES = {
	"Grabbing State":{
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY,
		hint = PROPERTY_HINT_NONE,
	},
	"skin_state": {
		backing_field = "_skin_state",
		type = TYPE_INT,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_ENUM,
		hint_string = \
				'ExternalEnum{"property": "_skin", "property_name": "_animation_list"}'
	},
	"path_next_state": {
		backing_field = "_path_next_state",
		type = TYPE_STRING,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_NONE,
		hint_string = QuiverState.HINT_STATE_LIST,
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
