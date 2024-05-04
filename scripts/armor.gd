extends ItemBase

## Base class for all armor items
class_name Armor

## Base value to deduct from hit
@export 
var base_defense: int

## Value to deduct from melee hits
@export 
var melee_defense: int

## Value to deduct from magic hits
@export 
var magic_defense: int

## Value to deduct from range hits
@export 
var range_defense: int
