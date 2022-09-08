@tool
class_name QuiverAiStateMachine
extends QuiverStateMachine

## State Machine for AIs
##
## It will automatically connect all direct child states [signal QuiverState.state_finished] 
## signal to the [method _decide_next_action] virtual method. Then the user can extend this class 
## and override that method with the required logic.
## [br][br]
## The Ai State Machine should only take [QuiverAiState] and [QuiverStateSequence] as children.


### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export var disabled := false:
	set(value):
		disabled = value


var character_attributes: QuiverAttributes = null:
	set(value):
		character_attributes = value
		_connect_attributes_signals()

#--- private variables - order: export > normal var > onready -------------------------------------

var _ai_state_hurt := "WaitTillIdle"
var _ai_state_after_reset := "Wait"

var _state_to_resume := NodePath()

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return
	
	if is_instance_valid(owner):
		await owner.ready
	
	var owner_path := owner.get_path()
	add_to_group(StringName(owner_path))
	
	for child in get_children():
		var child_state := child as QuiverState
		if not is_instance_valid(child_state):
			continue
		
		QuiverEditorHelper.connect_between(
				child_state.state_finished, _decide_next_action.bind(child_state.name)
		)
	
	if disabled:
		QuiverEditorHelper.disable_all_processing(self)
	else:
		state = get_node(initial_state) as QuiverState
		state.enter()
		emit_signal("transitioned", get_path_to(state))


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	
	for child in get_children():
		if (
				not child is QuiverAiState 
				and not child is QuiverStateSequence
				and not (child is Node and child.get_script() == null)
			):
			warnings.append("%s is not a QuiverAiState or QuiverSequenceState"%[child.name])
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func transition_to(target_state_path: NodePath, msg: = {}) -> void:
	if disabled:
		return
	else:
		super(target_state_path, msg)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

## Virtual method that is executed whenever a state emits the [signal QuiverState.state_finished] 
## signal
func _decide_next_action(_last_state: StringName) -> void:
	push_warning("This is a virtual function and should not be used directly, but overriden.")


func _connect_attributes_signals() -> void:
	QuiverEditorHelper.connect_between(character_attributes.hurt_requested, _ai_interrupted)
	QuiverEditorHelper.connect_between(character_attributes.knockout_requested, _ai_reset)
	QuiverEditorHelper.connect_between(character_attributes.grabbed, _ai_grabbed)


func _ai_grabbed(_ground_level: float) -> void:
	_interrupt_current_state(get_path_to(state))


func _ai_interrupted(_knockback: QuiverKnockback = null) -> void:
	_interrupt_current_state(get_path_to(state))


func _ai_reset(_knockback: QuiverKnockback) -> void:
	_interrupt_current_state(_ai_state_after_reset)


func _interrupt_current_state(p_next_path: String) -> void:
	if state.has_method("interrupt_state"):
		state.interrupt_state()
	
	_state_to_resume = p_next_path
	transition_to(_ai_state_hurt)

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

const CUSTOM_PROPERTIES = {
	"AI State Machine":{
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY,
		hint = PROPERTY_HINT_NONE,
	},
	"ai_state_hurt": {
		backing_field = "_ai_state_hurt",
		type = TYPE_STRING,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_NONE,
		hint_string = QuiverState.HINT_AI_STATE_LIST,
	},
	"ai_state_after_reset": {
		backing_field = "_ai_state_after_reset",
		type = TYPE_STRING,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_NONE,
		hint_string = QuiverState.HINT_AI_STATE_LIST,
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
