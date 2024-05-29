extends Resource

class_name CraftingManager

## Keeps a reference to the inventory
var inventory : InventoryManager

## Keeps a reference to the owner so we can get the tree
var owner : CharacterBody2D

## Reference to the crafting viewport
var crafting_viewport : CraftingViewport

## Keeps the queue of crafting orders
var orders : Array[Dictionary] = []

## Prevents the system from crafting the next order until the current one is done
var is_crafting: bool = false

func initialize_crafting_manager() -> void:
	crafting_viewport.send_order.connect(add_to_order)
	
func handle_craft_item() -> void:
	# Set that we are crafting
	is_crafting = true
	
	# Get the first item
	var order = orders[0]
	
	# Remove the items from our inventory
	for key in order.item.recipe.keys():
		inventory.remove_from_inventory(key, order.item.recipe[key] * order.quantity)
	
	# Loop through quantity and start crafting
	for i in range(0, order.quantity):
		await owner.get_tree().create_timer(order.item.time_to_craft).timeout
				
		# craft item
		var item = load(order.item.object_data.engine_info.asset_path).instantiate()
		__craft_item(item, order.item)
		
		# Add to inventory
		inventory.add_to_inventory(item)
	
	# Pop order off array
	orders.pop_front()
	is_crafting = false
	
func add_to_order(order: Dictionary) -> void:
	orders.push_back(order)

func __craft_item(item: StaticBody2D, recipe: Dictionary, key: String = "") -> void:
	# Get all the keys so we can populate item
	if key == "":
		# Color it
		for sprite: String in recipe.color.sprites:
			item.get_node("Sprite/%s" % sprite).self_modulate = Color.html(recipe.color.hex)
			
		# Break down the components and set values
		for k in recipe.object_data.keys():
			__craft_item(item, recipe.object_data[k], k)
		return
			
	# If base info then populate the root object
	for k in recipe.keys():
		if key == "base_info":
			if k == "type":
				item[k] = Enums.convert_string_to_item_type(recipe[k])
				continue
			if k == "damage_type":
				item[k] = Enums.convert_string_to_damage_type(recipe[k])
				continue
			item[k] = recipe[k]
			continue
	
		# Populate the components
		item[key][k] = recipe[k]
