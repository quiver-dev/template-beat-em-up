@tool
extends QuiverAiStateMachine

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

@export var _ai_state_hurt := "WaitTillIdle"
@export var _ai_state_after_reset := "Wait"

var _character: QuiverCharacter = null
var _actions: QuiverStateMachine = null
var _attributes: QuiverAttributes = null

var _state_to_resume := NodePath()

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()
	
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return
	
	if is_instance_valid(owner):
		await owner.ready
		_on_owner_ready()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_owner_ready() -> void:
	_character = owner as QuiverCharacter
	_actions = _character._state_machine
	_attributes = _character.attributes
	
	_attributes.hurt_requested.connect(_ai_interrupted)
	_attributes.knockout_requested.connect(_ai_reset)
	
	if not _attributes.grabbed.is_connected(_ai_interrupted):
		_attributes.grabbed.connect(_ai_interrupted)


func _decide_next_action(last_state: StringName) -> void:
	match last_state:
		&"Chase":
			transition_to(^"Attack")
		&"GoToPosition":
			transition_to(^"Wait")
		&"Attack":
			transition_to(^"Wait")
		&"Wait":
			transition_to(^"Chase")
		&"WaitTillIdle":
			transition_to(_state_to_resume)


func _ai_interrupted(_knockback: QuiverKnockback = null) -> void:
	_state_to_resume = get_path_to(state)
	transition_to(_ai_state_hurt)


func _ai_reset(_knockback: QuiverKnockback) -> void:
	if _state_to_resume.is_empty():
		_ai_interrupted(null)
	_state_to_resume = _ai_state_after_reset

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

const CUSTOM_PROPERTIES = {
	"ai_state_hurt": {
		backing_field = "_ai_state_hurt",
		type = TYPE_STRING,
		usage = PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_NONE,
		hint_string = QuiverState.HINT_AI_STATE_LIST,
	},
	"ai_state_after_reset": {
		backing_field = "_ai_state_after_reset",
		type = TYPE_STRING,
		usage = PROPERTY_USAGE_SCRIPT_VARIABLE,
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
