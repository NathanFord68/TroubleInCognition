extends Node

class_name CraftingManager

## Keeps a reference to the inventory
@export
var inventory : InventoryManager

var orders : Array[Dictionary] = []

func _process(delta : float) -> void:
	pass
	
func craft_item() -> void:
	pass
	
func add_to_order(order: Dictionary) -> void:
	pass
