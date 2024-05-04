extends StaticBody2D
class_name Item

enum TYPE { MAIN, HEAD, CHEST, LEGS, FEET, AMMO, CAPE, GLOVES, PRIMARY, SECONDARY, RING }

@export var damage : float
@export var range : float
@export var can_action_with : Array[String]
@export var type : TYPE 
@export var asset_path : String
@export var icon : String

# Add ourselvs to the caller inventory TODO currently doing equiped slot. needs changing
func _interact(player):
	
	# Instantiate a new hatchet
	var n_item = load(asset_path)
	var in_item = n_item.instantiate()
	
	# Add the hatchet to the inventory
	player.get_node("InventoryManager").add_to_inventory(in_item)
	
	# Clear the free the old one
	queue_free()
