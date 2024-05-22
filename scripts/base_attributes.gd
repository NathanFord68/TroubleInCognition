extends Resource

## Base class for anything that needs attributes
class_name BaseAttributes

## Health of HarvestNodes and Characters / Durability of items
@export 
var health: int

## What can this object drop when health is zero
@export 
var drop_table: Array

## Name of the object for player use
@export 
var object_name: String

## Handles the death of this object
func on_health_depleted() -> void: 
	pass
