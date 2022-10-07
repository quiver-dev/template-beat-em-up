@tool
class_name GradientTransitioner
extends Resource

## Takes two gradients as "Snapshots" or "references" and use their values to animate a third 
## gradient, that is the one actually in use on wherever you want.

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

signal transition_finished

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export var from: Gradient = null:
	set(value):
		from = value
		QuiverEditorHelper.connect_between(from.changed, _update_target_gradient.bind(from))
		if is_setup_valid():
			_update_target_gradient(from)
@export var to: Gradient = null:
	set(value):
		to = value
		QuiverEditorHelper.connect_between(to.changed, _update_target_gradient.bind(to))
		if is_setup_valid():
			print("CHANGED FROM SETTER")
			_update_target_gradient(to)
@export_range(0.0,300.0,0.1,"or_greater") var duration := 1.0 
@export_range(0.0,1.0,0.01) var debug_preview := 0.0:
	set(value):
		debug_preview = value
		if is_setup_valid():
			_preview_animation_at(debug_preview)

#--- private variables - order: export > normal var > onready -------------------------------------

## The actual gradient that is in use by your game and that is the target to receive the animation.
var _target_gradient: Gradient = null
## The node the tween should be created as reference
var _target_node: Node = null
var _tween: Tween

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func setup_transitioner(p_gradient: Gradient, p_node: Node) -> void:
	_target_gradient = p_gradient
	_target_node = p_node


func animate_gradient() -> void:
	if not is_setup_valid():
		push_error(
				"Trying to animate gradient transition without targets. "
				+"Run setup_transitioner first"
		)
		return 
	
	if from.get_point_count() != to.get_point_count():
		push_error(
				"Gradients must have the same amount of points to be animated!"
				+ "Gradient1: %s x Gradient2: %s"%[
						from.get_point_count(), to.get_point_count()
				]
		)
		return
	
	var point_count := from.get_point_count()
	_resize_target_gradient(point_count)
	
	if _tween:
		_tween.kill()
	_tween = _target_node.create_tween().set_parallel()
	_tween.finished.connect(_emit_finished)
	
	for index in point_count:
		var from_offset := from.get_offset(index)
		var to_offset := to.get_offset(index)
		var from_color := from.get_color(index)
		var to_color := to.get_color(index)
		_tween.tween_method(
				_animate_gradient_offset.bind(index), from_offset, to_offset, duration
		)
		_tween.tween_method(
				_animate_gradient_color.bind(index), from_color, to_color, duration
		)


func reset_transition() -> void:
	_update_target_gradient(from)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _resize_target_gradient(p_size: int) -> void:
	var target_point_size := _target_gradient.get_point_count()
	if p_size > target_point_size:
		for index in (p_size - target_point_size):
			_target_gradient.add_point(1.0-0.1*index,Color.WHITE)
	elif p_size < target_point_size:
		for index in range(target_point_size-1, p_size-1, -1):
			_target_gradient.remove_point(index)
	
	target_point_size = _target_gradient.get_point_count()


func _animate_gradient_offset(p_offset: float, index: int) -> void:
	_target_gradient.set_offset(index, p_offset)


func _animate_gradient_color(p_color: Color, index: int) -> void:
	_target_gradient.set_color(index, p_color)


func _emit_finished() -> void:
	transition_finished.emit()


func is_setup_valid() -> bool:
	return is_instance_valid(_target_gradient) and is_instance_valid(_target_node)


func _preview_animation_at(progress: float) -> void:
	if not is_setup_valid():
		push_error(
				"Trying to animate gradient transition without targets. "
				+"Run setup_transitioner first"
		)
		return 
	
	if from.get_point_count() != to.get_point_count():
		push_error(
				"Gradients must have the same amount of points to be animated!"
				+ "Gradient1: %s x Gradient2: %s"%[
						from.get_point_count(), to.get_point_count()
				]
		)
		return
	
	var point_count := from.get_point_count()
	_resize_target_gradient(point_count)
	for index in point_count:
		var from_offset := from.get_offset(index)
		var to_offset := to.get_offset(index)
		var from_color := from.get_color(index)
		var to_color := to.get_color(index)
		_animate_gradient_offset(lerp(from_offset, to_offset, progress), index)
		_animate_gradient_color(from_color.lerp(to_color, progress), index)


func _update_target_gradient(updated_gradient: Gradient) -> void:
	if not is_setup_valid():
		push_error(
				"Trying to animate gradient transition without targets. "
				+"Run setup_transitioner first"
		)
		return 
	
	var point_count := updated_gradient.get_point_count()
	_resize_target_gradient(point_count)
	for index in point_count:
		var updated_offset := updated_gradient.get_offset(index)
		var updated_color := updated_gradient.get_color(index)
		_target_gradient.set_offset(index, updated_offset)
		_target_gradient.set_color(index, updated_color)

### -----------------------------------------------------------------------------------------------
