extends "res://characters/playable/chad/states/chad_state.gd"

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

@export var JUMP_FORCE := -1200
@export var path_air_attack := NodePath("../Attack")

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _air_attack_count := 0
var _treated_air_attack_path := NodePath()

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(msg: = {}) -> void:
	super(msg)
	get_parent().enter(msg)
	_skin.transition_to(_skin.SkinStates.JUMP)
	if msg.has("velocity"):
		_character.velocity = msg.velocity
	
	if msg.has("air_attack_count"):
		_air_attack_count = msg.air_attack_count
	else:
		_air_attack_count = 0
	
	if msg.has("ignore_jump") and msg.ignore_jump:
		return
		
	
	_state_machine.set_physics_process(false)
	await get_tree().process_frame
	_character.velocity.y = JUMP_FORCE
	await get_tree().process_frame
	_state_machine.set_physics_process(true)


func unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		attack()


func physics_process(delta: float) -> void:
	get_parent().physics_process(delta)


func exit() -> void:
	_air_attack_count = 0
	get_parent().exit()
	super()


func attack() -> void:
	if _has_air_attack():
		_air_attack_count += 1
		_state_machine.transition_to(_treated_air_attack_path)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _has_air_attack() -> bool:
	var state_path_is_valid := not _treated_air_attack_path.is_empty()
	return state_path_is_valid and _air_attack_count == 0


func _on_owner_ready() -> void:
	super()
	
	if not path_air_attack.is_empty():
		var attack_state := get_node_or_null(path_air_attack) as QuiverState
		if attack_state != null:
			_treated_air_attack_path = _state_machine.get_path_to(attack_state)

### -----------------------------------------------------------------------------------------------

