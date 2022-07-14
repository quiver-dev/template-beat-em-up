class_name QuiverDebugLogger
extends Resource

# Simple class to log

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const LOG_FILE = "user://debug_log/%s_debug_session.csv"
const RELEASE_LOG_FILE = "res://debug_log/%s_session.csv"

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _current_log_file := ""

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

static func get_logger() -> QuiverDebugLogger:
	var value := load("res://addons/quiver.beat_em_up/utilities/quiver_debug_logger.tres") \
			as QuiverDebugLogger
	return value


func start_new_log() -> void:
	if not _is_logging_enabled():
		return
	
	var file_path = LOG_FILE if OS.has_feature("debug") else RELEASE_LOG_FILE
	var date_time := Time.get_datetime_string_from_system().replace(":", "-")
	_current_log_file = file_path%[date_time]
	
	var dir := Directory.new()
	if not dir.dir_exists("user://debug_log/"):
		dir.make_dir_recursive("user://debug_log/")
	
	# Improve this later to make it properly with all the error checks
	var file = File.new()
	file.open(_current_log_file, File.WRITE)
	file.store_string("")
	file.close()


func log_message(msg: PackedStringArray) -> void:
	if not _is_logging_enabled() or not _has_created_log_file():
		return
	
	var date_time := Time.get_datetime_string_from_system()
	var log_entry: = "%s,%09d,%s \n"%[date_time, Time.get_ticks_msec(), ",".join(msg)]
	
	# Improve this later to make it properly with all the error checks
	var file = File.new()
	file.open(_current_log_file, File.READ_WRITE)
	
	var contents: String = file.get_as_text()
	contents += log_entry
	file.store_string(contents)
	
	file.close()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _is_logging_enabled() -> bool:
	return ProjectSettings.get_setting(QuiverCyclicHelper.SETTINGS_LOGGING)


func _has_created_log_file() -> bool:
	var file: = File.new()
	var value := not _current_log_file.is_empty() and file.file_exists(_current_log_file)
	return value

### -----------------------------------------------------------------------------------------------
