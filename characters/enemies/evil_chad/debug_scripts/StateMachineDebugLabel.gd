@tool
extends "res://addons/quiver.beat_em_up/utilities/custom_nodes/quiver_debug_property_label.gd"

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

@export_node_path(Label) var _path_combo_label = ^"../Combo1"

@onready var _combo_label := get_node(_path_combo_label) as Label

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()


func _physics_process(delta: float) -> void:
	super(delta)
	if _reference_node.state_name == ^"Ground/Combo1":
		_combo_label.show()
	else:
		_combo_label.hide()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------

