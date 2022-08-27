class_name QuiverBitwiseHelper
extends RefCounted

## Helps with bitwise operations, specially for using flags as a simplifications of multiple
## booleans, for things like categories, filters, types, etc...
## 
## For more details take a look at:
## http://www.alanzucconi.com/2015/07/26/enum-flags-and-bitwise-operators/
## And for all of this to make more sense, always remember that we are dealing with power of 2
## numbers that when represented as bits will always have only one position as 1 and the rest as 0:
## 0 -> 0000 
## 1 -> 0001 (same as 1 << 1 or 2^0)
## 2 -> 0010 (same as 1 << 2 or 2^1)
## 4 -> 0100 (same as 1 << 3 or 2^2)
## 8 -> 1000 (same as 1 << 4 or 2^3)
## ....

### Public Methods --------------------------------------------------------------------------------

## This reads as "mask OR flag" and will make sure all the bits from flag are "turned on" 
## on mask, and return the new value
static func set_bitwise_flag_on(flag: int, mask: int) -> int:
	return mask | flag


## This reads as "mask AND NOT flag" and will make sure all of the flag's bits are "turned off"
## on mask and return the new value
static func unset_bitwise_flag_on(flag: int, mask: int) -> int:
	return mask & (~flag)


## Reads as "mask AND flag are EQUAL TO flag". What is happening is that "mask & flag" will
## set all of the bits from mask to 0 except the ones from flag, so essentially, if the result
## of that is the flag itself, that bitwise mask has the flag, otherwise the result will be 0
static func has_flag_on(flag: int, mask: int) -> bool:
	return (mask & flag) == flag


## This reads as "mask XOR flag". XOR stands for "eXclusive OR" and returns true only if the
## bits at the same position are different. If they're both 0 or both 1 it will return 0 and
## this has the effect of toggling that particular flag.
static func toggle_flag_on(flag: int, mask: int) -> int:
	return mask ^ flag

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
