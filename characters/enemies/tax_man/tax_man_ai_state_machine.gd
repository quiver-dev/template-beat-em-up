@tool
extends QuiverAiStateMachine

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

@export var _max_consecutive_hits := 10

var _consecutive_hits := 0
var _phase_path := "Phase1"

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()
	if not Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _decide_next_action(last_state: StringName) -> void:
	if _phase_path == "Dead":
		return
	
	match last_state:
		&"Wait":
			transition_to("%s/ChooseRandomAttack"%[_phase_path])
		&"ChooseRandomAttack":
			_consecutive_hits = 0
			transition_to("%s/Wait"%[_phase_path])
		&"GoToPosition":
			transition_to("%s/Wait"%[_phase_path])
		&"WaitForIdle":
			character_attributes.is_invulnerable = false
			transition_to(_state_to_resume)


func _on_tax_man_phase_changed_to(phase: int) -> void:
	match phase:
		TaxManBoss.TaxManPhases.PHASE_TWO:
			_phase_path = "Phase2"
		TaxManBoss.TaxManPhases.PHASE_THREE:
			_phase_path = "Phase3"
		TaxManBoss.TaxManPhases.PHASE_DIE:
			_phase_path = "Dead"
		_:
			_phase_path = "Phase1"
	
	_consecutive_hits = -1
	_interrupt_current_state("%s/Wait"%[_phase_path])


func _ai_reset(_knockback: QuiverKnockback) -> void:
	_interrupt_current_state(get_path_to(state))


func _interrupt_current_state(p_next_path: String) -> void:
	_consecutive_hits += 1
	if _consecutive_hits >= _max_consecutive_hits:
		character_attributes.is_invulnerable = true
		super("%s/ChooseRandomAttack"%[_phase_path])
	else:
		super(p_next_path)

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

static func _get_custom_properties() -> Dictionary:
	var dict := super()
	var success := dict.erase("ai_state_after_reset")
	if not success:
		push_error("Could not delete ai_state_after_reset from %s"%[dict])
	return dict

### -----------------------------------------------------------------------------------------------
