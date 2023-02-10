extends CanvasLayer

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const FADE_DURATION = 0.3

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _tween: Tween

@onready var _animator := $AnimationPlayer as AnimationPlayer
@onready var _progress_bar := $ProgressBar as ProgressBar

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	pass

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func transition_to_scene(path: String) -> void:
	const ERROR_TRANSITION_FAILED = "Could not transition to %s | error: %s"
	const ERROR_PACKED_SCENE = \
			"%s is not a path to a PackedScene, it's only possible to transition between scenes"
	
	if not (
			BackgroundLoader.is_loading_resource(path) 
			or BackgroundLoader.is_loading_finished(path)
	):
		BackgroundLoader.load_resource(path)
	
	await fade_in_transition()
	get_tree().unload_current_scene()
	
	if BackgroundLoader.is_loading_resource(path):
		show_loading_bar_for(path)
		await BackgroundLoader.loading_finished
	
	var scene := BackgroundLoader.get_resource(path) as PackedScene
	if scene == null:
		push_error(ERROR_PACKED_SCENE%[path])
	
	var error := get_tree().change_scene_to_packed(scene)
	if error != OK:
		push_error(ERROR_TRANSITION_FAILED%[path, error])
	
	call_deferred("fade_out_transition")


func fade_in_transition(duration: = 1.0) -> void:
	_animator.play("fade_in_transition", -1, 1.0 / duration)
	await _animator.animation_finished


func fade_out_transition(duration := 1.0) -> void:
	_animator.play("fade_out_transition", -1, 1.0 / duration)
	await _animator.animation_finished


func show_loading_bar_for(path: String) -> void:
	_progress_bar.value = BackgroundLoader.get_progress_for(path)
	if _progress_bar.value < 1.0:
		BackgroundLoader.loading_progress.connect(_update_progress_bar.bind(path))
		if _tween:
			_tween.kill()
		
		_tween = create_tween()
		_tween.tween_property(_progress_bar, "modulate:a", 1.0, FADE_DURATION)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _update_progress_bar(resource_path: String, progress: float, path: String) -> void:
	if resource_path != path:
		return
	
	_progress_bar.value = progress
	if _progress_bar.value == 1.0:
		if _tween:
			_tween.kill()
		
		_tween = create_tween()
		_tween.tween_property(_progress_bar, "modulate:a", 0.0, FADE_DURATION)
		BackgroundLoader.loading_progress.disconnect(_update_progress_bar.bind(path))

### -----------------------------------------------------------------------------------------------
