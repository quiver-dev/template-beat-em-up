class_name QuiverCharacterSkin
extends Node2D
## Base class for any kind of character, either playable or npc.
##
## The skin is based on an [AnimationPlayer] and an [AnimationTree]. There is a base scene you 
## can inherit on [code]res://characters/_base/[/code], but you can use this script on your own
## scene as long as it has a AnimationTree with a state machine in it.
## [br][br]
## If you do use it on another scene, just configure the exported variables accordingly.
## [br][br]
## Regardless of using the base scene or not, you're never expected to use this script directly.
## You should extend this script in the specific Character Skin scene, and declare an enum or
## constants for that character's animation states, and use it to override the virtual methods
## [method _is_valid_state] and [method _get_anim_name].
## [br][br]
## With both of those virtual methods defined in the inherited class, [method transition_to]
## should work for most cases, but can be overriden if a character needs special behavior for
## any given animation.


### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

## called by attack animations at the point where they stop accepting input for combos
signal attack_input_frames_finished
## called by attack animation at their last frame. This is a workaround for [AnimationPlayer] 
## not emitting any of it's signals when it's controlled by an [AnimationTree].
signal attack_animation_finished
signal jump_impulse_reached
signal landing_finished

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

## Path to animation tree. [br][br]
## Kept the underscore to make it "private" because it's not suposed to be changed
## from outside of the scene, to point to an external [AnimationTree] for example.
@export_node_path(AnimationTree) var _path_animation_tree := ^"AnimationTree"

## Path to [AnimationNodeStateMachinePlayback]. Usually I create an [AnimationNodeBlendTree] as the
## root for the [AnimtionTree] and the [AnimationNodeStateMachine] inside it, so I can do anything 
## with the output of the state machine playback, like changing the time scale for example. Use this
## to point to the correct path if you structure your [AnimationTree] in a different way. [br][br]
## See [member _path_animation_tree] for "private" reasoning.
@export var _path_playback := "parameters/StateMachine/playback"

@onready var _animation_tree := get_node(_path_animation_tree) as AnimationTree
@onready var _playback := _animation_tree.get(_path_playback) as AnimationNodeStateMachinePlayback

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	pass

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

## Main public method for the skin, it will check if the parameter is valid using the virtual
## [method _is_valid_state] method and push an error if it's not. If it is it will get the
## animation name using the virtual [method _get_anim_name] method and travel to it. [br]
## You can also override this method if you need special behavior before playing
## any specific state.
func transition_to(anim_state: int) -> void:
	var value_returned := _is_valid_state(anim_state)
#	print("value returned: %s"%[value_returned])
	if not value_returned:
		push_error("%s is not a valid animation state."%[anim_state])
		return
	
	var anim_name := _get_anim_name(anim_state)
	_playback.travel(anim_name)


## Use this method in your character's attack animations as a shortcut to emitting
## [signal attack_input_frames_finished]
func end_of_input_frames() -> void:
	attack_input_frames_finished.emit()


## Use this method at the end of your character's attack animations as a shortcut to emitting
## [signal attack_animation_finished.emit()]
func end_of_attack_animation() -> void:
	attack_animation_finished.emit()


## Use this method at the end of your "jumping" animation. This will emit the 
## [signal jump_impulse_reached] and the character's state machine will handle the actual 
## jump and transitioning to the "rising" animation state.
func jump_impulse() -> void:
	jump_impulse_reached.emit()


## Use this method at the end of your "landing" animation. This will emit the 
## [signal landing_finished] and the character's state machine will handle the actual 
## transitioning to the "idle" animation state.
func landed() -> void:
	landing_finished.emit()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

## Virtual function to be overriden and check for valid states. The parameter is an [int] because
## it expected to use enums or constants for tracking animation states and for autocomplete.
func _is_valid_state(_anim_state: int) -> bool:
	var value = false
	push_warning("This is a virtual function and should not be used directly, but overriden.")
	return value


## Virtual function to be overriden and translate enum states into animation node names.
func _get_anim_name(_anim_state: int) -> StringName:
	var value := StringName()
	push_warning("This is a virtual function and should not be used directly, but overriden.")
	return value


## Helper to create getters for public condition properties.
func _get_animation_tree_condition(path: StringName) -> bool:
	if not is_inside_tree() or not path in _animation_tree:
		return false
	return _animation_tree.get(path)


## Helper to create setters for public condition properties.
func _set_animation_tree_condition(path: StringName, value: bool) -> void:
	if not is_inside_tree():
		await ready
	
	if not path in _animation_tree:
		return
	
	_animation_tree.set(path, value)

### -----------------------------------------------------------------------------------------------
