@tool
extends Label

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export var path_reference: NodePath:
	set(value):
		path_reference = value
		update_configuration_warnings()
@export var properties: PackedStringArray = []:
	set(value):
		properties = value
		update_configuration_warnings()

#--- private variables - order: export > normal var > onready -------------------------------------

@onready var _reference_node := get_node_or_null(path_reference)

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	if Engine.is_editor_hint():
		QuiverEditorHelper.disable_all_processing(self)
		return


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(_reference_node):
		push_error("invalid reference node (%s) for path: %s"%[_reference_node, path_reference])
		return
	
	var message := PackedStringArray()
	for property in properties:
		var value = _reference_node.get_indexed(property)
		if value is float:
			value = "%0.2f"%[value]
		message.append("%s.%s: %s"%[_reference_node.name, property, value])
	
	text = "\n".join(message)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	
	if path_reference.is_empty():
		warnings.append("path_reference must point to a valid node")
	
	if properties.is_empty():
		warnings.append("properties array is empty, this Debug Label has nothing to show.")
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------

