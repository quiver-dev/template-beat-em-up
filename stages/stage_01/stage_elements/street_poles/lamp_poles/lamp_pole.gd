@tool
extends Sprite2D

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

@export var day_cycle_data: DayCycleData

@onready var _light := $LampLight as PointLight2D
@onready var _light_sprite := $LightSprite as Sprite2D

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	_on_twilight_changed()
	QuiverEditorHelper.connect_between(day_cycle_data.twilight_changed, _on_twilight_changed)

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_twilight_changed() -> void:
	_light.enabled = day_cycle_data.twilight_transition >= 0.5
	_light_sprite.visible = _light.enabled
	if _light.enabled:
		var progress := smoothstep(0.5, 1.0, day_cycle_data.twilight_transition)
		_light.energy = progress
		_light_sprite.modulate.a = progress
	elif _light.energy != 0:
		_light.energy = 0
		_light_sprite.modulate.a = 0

### -----------------------------------------------------------------------------------------------
