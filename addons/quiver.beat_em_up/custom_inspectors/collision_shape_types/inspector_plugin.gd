extends EditorInspectorPlugin

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const TypeSelector = preload(
		"res://addons/quiver.beat_em_up/custom_inspectors/collision_shape_types/"
		+ "collision_type_selector.gd"
)
const TYPE_SELECTOR_SCENE = preload(
		"res://addons/quiver.beat_em_up/custom_inspectors/collision_shape_types/"
		+ "collision_type_selector.tscn"
)

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _can_handle(object) -> bool:
	return object is CollisionShape2D or object is Area2D


func _parse_begin(object: Object) -> void:
	var node := object as Node2D
	var type_selector := TYPE_SELECTOR_SCENE.instantiate() as TypeSelector
	type_selector.edited_node = node
	add_custom_control(type_selector)

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------

