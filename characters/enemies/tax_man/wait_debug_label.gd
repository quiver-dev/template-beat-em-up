@tool
extends "res://addons/quiver.beat_em_up/utilities/custom_nodes/quiver_debug_property_label.gd"

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _paths_wait = {}

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return
	
	_paths_wait = {
		TaxManBoss.TaxManPhases.PHASE_ONE: $"../../AiStateMachine/Phase1/Wait/Timer",
		TaxManBoss.TaxManPhases.PHASE_TWO: $"../../AiStateMachine/Phase2/Wait/Timer",
		TaxManBoss.TaxManPhases.PHASE_THREE: $"../../AiStateMachine/Phase3/Wait/Timer",
	}
	_reference_node = _paths_wait[TaxManBoss.TaxManPhases.PHASE_ONE]


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	
	if properties.is_empty():
		warnings.append("properties array is empty, this Debug Label has nothing to show.")
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------


func _on_tax_man_phase_changed_to(phase) -> void:
	_reference_node = _paths_wait[phase]

### -----------------------------------------------------------------------------------------------
