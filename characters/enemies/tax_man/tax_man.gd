@tool
extends QuiverEnemyCharacter

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _health_previous := 1.0
var _current_cumulated_damage := 0.0

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()
	
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return
	
	_health_previous = attributes.get_health_as_percentage()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _update_cumulated_damage() -> void:
	_current_cumulated_damage += _health_previous - attributes.get_health_as_percentage()


func _reset_cumulated_damage() -> void:
	_current_cumulated_damage = 0.0
	_health_previous = attributes.get_health_as_percentage()

### -----------------------------------------------------------------------------------------------
