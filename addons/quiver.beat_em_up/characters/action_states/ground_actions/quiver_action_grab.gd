@tool
extends QuiverCharacterState

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const GroundState = preload(
		"res://addons/quiver.beat_em_up/characters/action_states/quiver_action_ground.gd"
)

#--- public variables - order: export > normal var > onready --------------------------------------

var grab_target: QuiverAttributes = null
var grab_target_node: QuiverCharacter = null
var grab_pivot: Marker2D = null
var original_parent: Node = null

#--- private variables - order: export > normal var > onready -------------------------------------

var _path_no_grab_target := "Ground/Move/Idle"

var _original_transform: Transform2D

@onready var _ground_state := get_parent() as GroundState

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
	
	if not get_parent() is GroundState:
		warnings.append(
				"This ActionState must be a child of Action GroundState or a state " 
				+ "inheriting from it."
		)
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	_ground_state.enter(msg)
	super(msg)
	
	if not "target" in msg:
		_state_machine.transition_to(_path_no_grab_target)
		return
	
	grab_target = msg.target
	grab_target_node = grab_target.character_node
	original_parent = grab_target_node.get_parent()
	_original_transform = grab_target_node.transform


func exit() -> void:
	super()
	_ground_state.exit()
	
	if is_instance_valid(grab_target_node) and grab_target_node.get_parent() != original_parent:
		reparent_target_node_to(original_parent)
		grab_target_node.transform.x = _original_transform.x
		grab_target_node.transform.y = _original_transform.y
	
	original_parent = null
	grab_target = null
	grab_target_node = null


func reparent_target_node_to(new_parent: Node2D) -> void:
	var global_position = grab_target_node.global_position
	grab_target_node.get_parent().remove_child(grab_target_node)
	new_parent.add_child(grab_target_node)
	grab_target_node.global_position = global_position

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _force_exit_state() -> void:
	# We don't need to change states because ground will do it for us, we just need to force
	# exit the Grab parent state as not all its children call its exit.
	grab_target.grab_released.emit()
	call_deferred("exit")


func _connect_signals() -> void:
	super()
	
	QuiverEditorHelper.connect_between(_attributes.hurt_requested, _on_hurt_requested)
	QuiverEditorHelper.connect_between(_attributes.knockout_requested, _on_knockout_requested)


func _disconnect_signals() -> void:
	super()
	
	if _attributes != null:
		QuiverEditorHelper.disconnect_between(_attributes.hurt_requested, _on_hurt_requested)
		QuiverEditorHelper.disconnect_between(
				_attributes.knockout_requested, _on_knockout_requested
		)


func _on_hurt_requested(knockback: QuiverKnockback) -> void:
	_force_exit_state()


func _on_knockout_requested(knockback: QuiverKnockback) -> void:
	_force_exit_state()

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

func _get_custom_properties() -> Dictionary:
	return {
		"Grab State":{
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_CATEGORY,
			hint = PROPERTY_HINT_NONE,
		},
		"path_no_grab_target": {
			backing_field = "_path_no_grab_target",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_NONE,
			hint_string = QuiverState.HINT_STATE_LIST,
		},
#		"": {
#			backing_field = "",
#			name = "",
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
		var add_property := true
		var dict: Dictionary = custom_properties[key]
		if not dict.has("name"):
			dict.name = key
		
		if add_property:
			properties.append(dict)
	
	return properties


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
