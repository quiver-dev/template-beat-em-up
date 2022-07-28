@tool
class_name QuiverStateSequence
extends QuiverState

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _current_state: QuiverState = null

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	
	if get_child_count() == 0:
		warnings.append(
				"QuiverSequenceState does nothing by itself, it needs QuiverStates as children."
		)
	for child in get_children():
		if not child is QuiverState:
			warnings.append("%s is not a node of type QuiverState"%[child.name])
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	_enter_child_state(0)


func unhandled_input(event: InputEvent) -> void:
	_current_state.unhandled_input(event)


func process(delta: float) -> void:
	_current_state.process(delta)


func physics_process(delta: float) -> void:
	_current_state.physics_process(delta)


func exit() -> void:
	super()
	
	for child in get_children():
		var state = child as QuiverState
		if state == null:
			continue
		
		if state.state_finished.is_connected(_on_current_state_state_finished):
			state.state_finished.disconnect(_on_current_state_state_finished)
	
	_current_state = null


func get_list_of_ai_states() -> Array:
	var list := ["Node not ready yet"]
	if _state_machine != null:
		return list
	
	list = _state_machine.get_list_of_ai_states()
	return list

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _enter_child_state(index: int) -> void:
	_current_state = get_child(index)
	_current_state.state_finished.connect(_on_current_state_state_finished)
	_current_state.enter()


func _on_current_state_state_finished() -> void:
	if not _is_active_state():
		return
	
	_current_state.exit()
	_current_state.state_finished.disconnect(_on_current_state_state_finished)
	
	var next_index = _current_state.get_index() + 1
	if next_index < get_child_count():
		_enter_child_state(next_index)
	else:
		state_finished.emit()


func _is_active_state() -> bool:
	var value := (_state_machine.state.get_path() as String).begins_with(get_path())
	return value

### -----------------------------------------------------------------------------------------------
