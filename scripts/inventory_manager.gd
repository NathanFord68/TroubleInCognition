extends Node

## Manage the inventory of the player
class_name InventoryManager

## Max slots the backpack allows
@export
var max_backpack_size : int

## Holds the items of the players backpack
var backpack : Array[ItemBase] = []

func _ready():
	$"../PlayerViewport/InventoryViewport".item_dropped.connect(handle_item_dropped)

## Handles the emission of the item_dropped signal from the viewport
func handle_item_dropped(t: Enums.ITEM_TYPE, item: ItemBase):
	if t == Enums.ITEM_TYPE.MAIN:
		equipment_to_inventory()
		return
	
	inventory_to_equipment(t, item)

## Move item from inventory to equipment slot
func inventory_to_equipment(t: Enums.ITEM_TYPE, item: ItemBase):
	item.name = str(t)
	item.get_node("AnimationTree").active = true
	for s : Sprite2D in item.get_node("Sprite").get_children():
		if "icon" in s.name:
			s.visible = false
			continue
		s.visible = true
	$"../Equipment".add_child(item)
	
	

## Move item from equipment to inventory
func equipment_to_inventory():
	pass

## Adds an item to the inventory
func add_to_inventory(item : Node, index : int = -1) -> bool:
	var i : int = index
	
	if index == -1:
		# Find the lowest index and set i equal to
		i = backpack.size()
	
	# Check that what we are trying is valid
	if i >= max_backpack_size:
		# Let the player know their inventory is full
		print("Inventory is too large")
		return false
	
	# Check if the slot is already taken
	if backpack.size() > 0 and !is_instance_valid(backpack[i]):
		return __swap_items(item, i)
		
	
	# Insert the item to last slot
	backpack.push_back(item)
	
	# Update the inventory UI with our image
	$"../PlayerViewport/InventoryViewport".get_backpack().get_children()[i].item = item
	$"../PlayerViewport/InventoryViewport".get_backpack().get_children()[i].update_icon()
	return true
	

## Swaps the the item dropped with the item in this slot
func __swap_items(item : Item, index : int) -> bool:
	return true
	
func debug_print():
	print_debug("Entering debug_print")
	for item in backpack:
		print_debug(item)
