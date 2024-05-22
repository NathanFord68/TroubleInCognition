extends ItemBase

## Class for all weapons in the game
class_name Weapon

## How far can the weaon hit
@export 
var weapon_reach: float

## What can the weapon action with
##
## Determines groups that this weapon can call their action method.
## For example, a hatchet can interact with a tree that is in group "Harvest"
@export 
var can_action_with: Array

## What type of damage does this weapon inflict
@export 
var damage_type: Enums.DAMAGE_TYPE

## How much base damage does this weapon
@export 
var damage: int

## Minimum damage that the weapon can do
##
## This is to be used for when a character's armor prevents damage using the base
@export 
var min_damage: int

## Can the character carry a secondary slot
@export 
var is_two_handed: bool

## How fast does the weapon attack
@export
var attack_speed: float
