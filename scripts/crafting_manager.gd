extends Node

class_name CraftingManager

## Keeps a reference to the inventory
@export
var inventory : InventoryManager

var orders : Array[Dictionary] = []

var is_crafting: bool = false

func _ready() -> void:
	( $"../PlayerViewport/CraftingViewport" as CraftingViewport ).send_order.connect(add_to_order)

func _process(delta : float) -> void:
	# If there are orders and we're not crafting call craft item
	if not is_crafting and orders.size() > 0:
		craft_item()
	
func craft_item() -> void:
	# Set that we are crafting
	is_crafting = true
	
	# Get the first item
	var order = orders[0]
	
	# Remove the items from our inventory
	for key in order.recipe.keys():
		inventory.remove_from_inventory(key, order.recipe[key] * order.quantity)
	
	# Loop through quantity and start crafting
	for i in range(0, order.quantity):
		# Wait for crafting to finish
		get_tree().create_timer(order.recipe.craft_time)
		
		# craft item
		var item = load(order.recipe.object_info.engine_info.asset_path).instantiate()
		
		# Add to inventory
		inventory.add_to_inventory(item, order.recipe)
	
	# Pop order off array
	orders.pop_front()
	is_crafting = false
	
func add_to_order(order: Dictionary) -> void:
	orders.push_back(order)

func __craft_item(item: ItemBase, recipe: Dictionary, key: String = "") -> void:
	# Get all the keys so we can populate item
	if key == "":
		for k in recipe.object_data.keys():
			__craft_item(item, recipe.object_data[k], k)
		return
			
	# If base info then populate the root object
	if key == "base_info":
		for k in recipe.keys():
			item[k] = recipe[k]
		return
	
	# Populate the components
	for k in recipe.keys():
		item[key][k] = recipe[k]
	
