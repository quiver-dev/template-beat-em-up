extends EditorInspectorPlugin

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const CreateMirrorWidget = preload(
		"res://addons/quiver.beat_em_up/custom_inspectors/create_mirrored_animation/"
		+"create_mirrored_animation_button.gd"
)

const CREATE_MIRROR_SCENE = preload(
		"res://addons/quiver.beat_em_up/custom_inspectors/create_mirrored_animation/"
		+"create_mirrored_animation_button.tscn"
)

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _can_handle(object) -> bool:
	return object is Animation


func _parse_begin(object: Object) -> void:
	var widget = CREATE_MIRROR_SCENE.instantiate() as CreateMirrorWidget
	widget.animation = object
	add_custom_control(widget)

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
