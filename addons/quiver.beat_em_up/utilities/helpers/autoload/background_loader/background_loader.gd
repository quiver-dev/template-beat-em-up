extends Node

## Wrapper autoload for loading resources in the background using ResourceLoader thread methods.

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

## Emitted once the resource finishes loading. It only sends the path as an argument, you have to 
## call [method get_resource] with the same path to actually get the loaded resource.
signal loading_finished(path: String)
## Emitted every frame while loading.
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

## Starts loading resource on the path given using threads. Will give errors if resource is 
## already loading or already loaded.
func load_resource(path: String) -> void:
	var status := ResourceLoader.load_threaded_get_status(path)
	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		push_warning("Already loading %s"%[path])
		return
	elif status == ResourceLoader.THREAD_LOAD_LOADED:
		push_warning("Already finished loading %s but resource hasn't been retrieved yet."%[
				path
		])
		return
	
	ResourceLoader.load_threaded_request(path, "", false, ResourceLoader.CACHE_MODE_REUSE)
	
	_progress[path] = []
	var load_status := ResourceLoader.load_threaded_get_status(path, _progress[path])
	while load_status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		loading_progress.emit(path, _progress[path][0])
		print("path: %s progress?: %s"%[path, _progress[path][0]])
		await  get_tree().process_frame
		load_status = ResourceLoader.load_threaded_get_status(path, _progress[path])
	print("path: %s progress?: %s"%[path, _progress[path][0]])
	
	if load_status == ResourceLoader.THREAD_LOAD_LOADED:
		loading_progress.emit(path, 1.0)
		loading_finished.emit(path)
	else:
		_push_loading_error(path)
		_progress.erase(path)


## Returns the progress from any given path, or an error if the path is not being loaded.
func get_progress_for(path: String) -> float:
	var value := 0.0
	
	if _progress.has(path):
		value = _progress[path][0]
	else:
		push_error("Path not found in progress dictionary: %s"%[path])
	
	return value


## Returns the loaded Resource from any given path, or an error if the path hasn't been loaded.
func get_resource(path: String) -> Resource:
	const ERROR_NO_PATH = "Resource at path %s is not on cache nor loading. Have you used the 
			function start_loading() with it?"
	var loaded_resource: Resource = null
	var status := ResourceLoader.load_threaded_get_status(path)
	
	if status in [ResourceLoader.THREAD_LOAD_IN_PROGRESS, ResourceLoader.THREAD_LOAD_LOADED]:
		loaded_resource = ResourceLoader.load_threaded_get(path)
		_progress.erase(path)
	elif status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		if ResourceLoader.has_cached(path):
			loaded_resource = ResourceLoader.load(path)
		else:
			push_error(ERROR_NO_PATH)
	
	return loaded_resource


## Returns true if the resource is loading. Be careful that false means it either never started 
## loading or already has finished loading.
func is_loading_resource(path: String) -> bool:
	return ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS


## Returns true if it has been loaded but not retrieved yet.
func is_loading_finished(path: String) -> bool:
	return ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_LOADED

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _push_loading_error(path) -> void:
	push_error("Failed to load resource: %s | Error: %s"%[
			path,
			ResourceLoader.load_threaded_get_status(path)
	])

### -----------------------------------------------------------------------------------------------
