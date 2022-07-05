@tool
extends QuiverAiStateMachine

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _character: QuiverCharacter = null
var _actions: QuiverStateMachine = null
var _attributes: QuiverAttributes = null

var _state_to_resume := NodePath()

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()
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


func _decide_next_action(last_state: StringName) -> void:
	match last_state:
		&"ChaseClosestPlayer":
			transition_to(^"Attack")
		&"Attack":
			transition_to(^"Wait")
		&"Wait":
			transition_to(^"ChaseClosestPlayer")
		&"Stunned":
			transition_to(_state_to_resume)


func _ai_interrupted(_knockback: QuiverKnockback) -> void:
	_state_to_resume = get_path_to(state)
	transition_to(^"Stunned")


func _ai_reset(_knockback: QuiverKnockback) -> void:
	if _state_to_resume.is_empty():
		_ai_interrupted(null)
	_state_to_resume = ^"Wait"

### -----------------------------------------------------------------------------------------------

