@tool
class_name QuiverAiStateMachine
extends QuiverStateMachine

## State Machine for AIs
##
## It will automatically connect all direct child states [signal QuiverState.state_finished] 
## signal to the [method _decide_next_behavior] virtual method. Then the user can extend this class 
## and override that method with the required logic.
## [br][br]
## The Ai State Machine should only take [QuiverAiState], [QuiverAiStateGroup and 
## [QuiverStateSequence] as children.


### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

## Useful to disable AI decision making, be it for testing or cutscenes, or anything else.
@export var disabled := false:
	set(value):
		disabled = value

## Attributes for the current character. If this node is inside a QuiverCharacter, it will automatically get the correct attributes resource on [method _ready].
var character_attributes: QuiverAttributes = null:
	set(value):
		character_attributes = value
		_connect_attributes_signals()

#--- private variables - order: export > normal var > onready -------------------------------------

## AI State to use while character is in "Hurt" Action.
var _ai_state_hurt := "WaitForIdle"
## AI State to use after the character get's up from being knocked down.
var _ai_state_after_reset := "Wait"

var _state_to_resume := NodePath()

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return
	
	var owner_path := owner.get_path()
	add_to_group(StringName(owner_path))
	
	if is_instance_valid(owner):
		await owner.ready
	
	_connect_child_ai_states()
	
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
				and not child is QuiverAiStateGroup
			):
			warnings.append(
					"%s is not a QuiverAiState, QuiverAiStateGroup or QuiverSequenceState"
					%[child.name]
			)
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

## Takes a [NodePath] to the next state node, and transitions to it. Can optionally receive a 
## dictionary to be passed to the [method QuiverState.enter] method of the new state. Will do 
## nothing if [member QuiverAiStateMachine.disabled] is true.
func transition_to(target_state_path: NodePath, msg: = {}) -> void:
	if disabled:
		return
	else:
		super(target_state_path, msg)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _connect_child_ai_states(starting_node: Node = self) -> void:
	for child in starting_node.get_children():
		if child is QuiverAiStateGroup:
			_connect_child_ai_states(child)
		elif child is QuiverState:
			QuiverEditorHelper.connect_between(
					child.state_finished, _decide_next_behavior.bind(child.name)
			)
		else:
			push_warning(
					"%s is a child of AiStateMachine but it is "%[child]
					+"not any of its recognized nodes"
			)
			continue


## Virtual method that is executed whenever a state emits the [signal QuiverState.state_finished] 
## signal
func _decide_next_behavior(_last_state: StringName) -> void:
	push_warning("This is a virtual function and should not be used directly, but overriden.")


func _connect_attributes_signals() -> void:
	QuiverEditorHelper.connect_between(character_attributes.hurt_requested, _ai_interrupted)
	QuiverEditorHelper.connect_between(character_attributes.knockout_requested, _ai_reset)
	QuiverEditorHelper.connect_between(character_attributes.grabbed, _ai_grabbed)


func _ai_grabbed(_ground_level: float) -> void:
	_interrupt_current_state(get_path_to(state))


func _ai_interrupted(_knockback: QuiverKnockbackData = null) -> void:
	_interrupt_current_state(get_path_to(state))


func _ai_reset(_knockback: QuiverKnockbackData) -> void:
	_interrupt_current_state(_ai_state_after_reset)


func _interrupt_current_state(p_next_path: String) -> void:
	if disabled:
		return
	
	if state.has_method("interrupt_state"):
		state.interrupt_state()
	
	if p_next_path != _ai_state_hurt:
		_state_to_resume = p_next_path
	transition_to(_ai_state_hurt)

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

static func _get_custom_properties() -> Dictionary:
	return {
		"_ai_state_hurt": {
			default_value = "WaitForIdle",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_NONE,
			hint_string = QuiverState.HINT_AI_STATE_LIST,
		},
		"_ai_state_after_reset": {
			default_value = "Wait",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_NONE,
			hint_string = QuiverState.HINT_AI_STATE_LIST,
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
