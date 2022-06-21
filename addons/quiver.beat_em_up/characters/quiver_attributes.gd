class_name QuiverAttributes
extends Resource

## Resource to store characters or other objects attributes.
##
## The purpose of this is to separate Data from Animations/Behavior/Feedback as much as possible.
## When two characters are fighting we want the Character Scenes worry about the "how" while
## the data resources will take of the "what", and will be able to guide the scenes. 
## [br][br]
## It is also easier to pass resources around than nodes, or node references. So for example,
## with resources a HitBox that is nested deeply on character skin to follow it's animation can
## collide with a deeply nested HurtBox of another charater and they can just trade attribute
## resources to resolve the damage, and the resource will notify the appropriate node.
## [br][br]
## It is a more modular way of architecturing the game, where you can use the best of nodes
## and node hierarchies without worrying about complex structures making your life harder as
## the most important logic can happen between simple resources.

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

enum WeightClass {LIGHT, MEDIUM, HEAVY}

#--- constants ------------------------------------------------------------------------------------

# move this to the function that will calculate jump force when you refactor
const WEIGHT_MULTIPLIER = {
	WeightClass.LIGHT: 1.0,
	WeightClass.MEDIUM: 2.0,
	WeightClass.HEAVY: 4.0,
}

#--- public variables - order: export > normal var > onready --------------------------------------

## Max health for the character, when their life bar is full.
@export_range(0, 1, 1, "or_greater") var health_max := 100

## Max movement speed for the character.
@export_range(0, 1000, 1, "or_greater") var speed_max := 600
## Character's jump force. The heavier the character more jump force they'll need to reach the
## same jump height as a lighter character.
@export_range(0, 0, 1, "or_lesser") var jump_force := -1200
## Character's weight. Influences jump and things like if the character can be thrown or not.[br]
## Heavier character will only be able to be thrown by stronger characters.
@export var weight: WeightClass = WeightClass.MEDIUM

## Character's current health. What the health bar will be showing.
var health_current := health_max

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

## Returns the character's current health as percentage.
func get_health_as_percentage() -> float:
	var value := health_current / float(health_max)
	return value

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------

