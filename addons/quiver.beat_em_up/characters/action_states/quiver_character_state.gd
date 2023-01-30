class_name QuiverCharacterState
extends QuiverState

## Specialized [QuiverState] class designed to give easier access and autocomplete to commom
## properties, like the character itself, the skin and character attributes.
## [br][br]
## It also provides an easy "late" initialization function with [member _on_owner_ready].

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

## Easy access to [QuiverCharacter] main node.
var _character: QuiverCharacter
## Easy access to character's [QuiverCharacterSkin] node.
var _skin: QuiverCharacterSkin
## Easy access to character's [QuiverAttributes] resource.
var _attributes: QuiverAttributes

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	super()
	if is_instance_valid(owner):
		await owner.ready
		_on_owner_ready()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

## Late initialization function, useful if you need to get other nodes from your character or 
## do any setup that requires you to be sure all the character's nodes are ready. Can be overriden
## but don't forget to call [code]super()[/code] to assign the basic properties, or re-assign them in
## your override.
func _on_owner_ready() -> void:
	_character = owner as QuiverCharacter
	_skin = _character._skin as QuiverCharacterSkin
	_attributes = _character.attributes

### -----------------------------------------------------------------------------------------------

