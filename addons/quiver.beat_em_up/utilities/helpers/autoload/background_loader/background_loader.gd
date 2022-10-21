extends Node

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

signal loading_finished(path: String, resource: Resource)
signal loading_progress(path: String, progress: float)

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

## Keys are paths being loaded, and values are arrays with one float value, that are returned
## from ResourceLoader
var _progress := {}

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	pass

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func load_resource(path: String) -> void:
	ResourceLoader.load_threaded_request(path, "", false, ResourceLoader.CACHE_MODE_REUSE)
	
	_progress[path] = []
	var load_status := ResourceLoader.load_threaded_get_status(path, _progress[path])
	while load_status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		loading_progress.emit(path, _progress[path][0])
		await  get_tree().process_frame
		load_status = ResourceLoader.load_threaded_get_status(path, _progress[path])
	
	if load_status == ResourceLoader.THREAD_LOAD_LOADED:
		loading_progress.emit(path, 1.0)
		loading_finished.emit(path)
	else:
		_push_loading_error(path)


func get_progress_for(path: String) -> float:
	var value := 0.0
	
	if _progress.has(path):
		value = _progress[path][0]
	else:
		push_error("Path not found in progress dictionary: %s"%[path])
	
	return value


func get_resource(path: String) -> Resource:
	return ResourceLoader.load_threaded_get(path)


func is_loading_resource(path: String) -> bool:
	return ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _push_loading_error(path) -> void:
	push_error("Failed to load resource: %s | Error: %s"%[
			path,
			ResourceLoader.load_threaded_get_status(path)
	])

### -----------------------------------------------------------------------------------------------
