@tool
extends QuiverCharacterSkin
# Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

enum SkinStates {
	IDLE,
	WALK,
	ATTACK_1,
	ATTACK_2,
	JUMP,
}

#--- constants ------------------------------------------------------------------------------------

const ANIM_NODE_NAMES := {
	SkinStates.IDLE: &"idle",
	SkinStates.WALK: &"walk",
	SkinStates.JUMP: &"jump",
	SkinStates.ATTACK_1: &"attack1",
	SkinStates.ATTACK_2: &"attack2",
}

const CONDITIONS := {
	should_not_combo = &"parameters/state_machine/conditions/shoud_not_combo",
	should_combo_2 = &"parameters/state_machine/conditions/should_combo_2",
}

#--- public variables - order: export > normal var > onready --------------------------------------

@export var should_combo_2: bool :
	get:
		return _get_animation_tree_condition(CONDITIONS.should_combo_2)
	set(value):
		_set_animation_tree_condition(CONDITIONS.should_combo_2, value)

#--- private variables - order: export > normal var > onready -------------------------------------

## Just an exported property to make it easier to test the skin on the editor. 
## Doesn't work on runtime, unless you're running the skin scene by itself.
@export var _debug_skin_state: SkinStates = SkinStates.IDLE:
	get = _get_debug_skin_state, set = _set_debug_skin_state

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()
	
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return
	elif QuiverEditorHelper.is_standalone_run(self):
		QuiverEditorHelper.add_debug_camera2D_to(self, Vector2(0,-0.8))
	
	_animation_tree.active = true


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up") and QuiverEditorHelper.is_standalone_run(self):
		_attack_test_routine()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _is_valid_state(anim_state: int) -> bool:
	var value = anim_state in SkinStates.values()
	return value


func _get_anim_name(anim_state: int) -> StringName:
	var value := ANIM_NODE_NAMES[anim_state] as StringName
	return value


func _get_debug_skin_state() -> int:
	return _debug_skin_state


func _set_debug_skin_state(value: SkinStates) -> void:
	_debug_skin_state = value
	if Engine.is_editor_hint() or QuiverEditorHelper.is_standalone_run(self):
		if not is_inside_tree():
			await ready
		
		if not is_instance_valid(_animation_tree):
			_animation_tree = get_node_or_null("AnimationTree")
		
		if not is_instance_valid(_animation_tree):
			return
		
		if not _animation_tree.active:
			_animation_tree.active = true
		transition_to(_debug_skin_state)


func _attack_test_routine() -> void:
	print("Should Attack and go to idle")
	should_combo_2 = false
	_debug_skin_state = SkinStates.ATTACK_1
	await get_tree().create_timer(1.5).timeout
	print("Should Combo and go to idle")
	should_combo_2 = true
	_debug_skin_state = SkinStates.ATTACK_1

### -----------------------------------------------------------------------------------------------
