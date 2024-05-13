extends Node

## Manage the inventory of the player
class_name InventoryManager

## Max slots the backpack allows
@export
var max_backpack_size : int

## Reference to our inventory viewport
@export
var inventory_viewport : Control

## Holds the items of the players backpack
var backpack : Array[EquipmentSlot] = []

func _ready():
	# Resize and populate the backpack with equipment slots
	var bp_slots := $"../PlayerViewport/InventoryViewport".get_backpack() as GridContainer
	backpack.resize(max_backpack_size)
	for a in range(0, max_backpack_size):
		var n_equipment_slot := ( load("res://assets/objects/equipment_slot.tscn") as PackedScene ).instantiate() as EquipmentSlot
		n_equipment_slot.inventory_root = inventory_viewport
		backpack[a] = n_equipment_slot
		bp_slots.add_child(n_equipment_slot)
	$"../PlayerViewport/InventoryViewport".item_dropped.connect(handle_item_dropped_into_slot)

## Handles the emission of the item_dropped signal from the viewport
func handle_item_dropped_into_slot(t: Enums.ITEM_TYPE, data: EquipmentSlot):
	if t == Enums.ITEM_TYPE.MAIN:
		remove_from_inventory(data.item.type)
		return
	
	add_to_equipment_slot(t, data)

## Move item from inventory to equipment slot
func add_to_equipment_slot(slot: Enums.ITEM_TYPE, data: EquipmentSlot):
	# Set the name to it's slot name and activate it's animation tree
	var equipment_instance = load(data.item.engine_info.asset_path).instantiate()
	equipment_instance.name = str(slot)
	equipment_instance.get_node("AnimationTree").active = true
	
	# Turn the icon off and the sprites on
	for s : Sprite2D in equipment_instance.get_node("Sprite").get_children():
		if "icon" in s.name:
			s.visible = false
			continue
		s.visible = true
	
	# Add it to our the equipment slot of our player
	$"../Equipment".add_child(equipment_instance)

## Move item from equipment to inventory
func remove_from_inventory(slot: Enums.ITEM_TYPE):
	$"../Equipment".get_node(str(slot)).queue_free()

## Adds an item to the inventory
func add_to_inventory(item : Node, index : int = -1) -> bool:
	var _index : int = index
	
	if _index == -1:
		# Find the lowest index and set i equal to
		for i in range(0, max_backpack_size):
			# Set it to first empty slot if it does not have an index yet
			if backpack[i].is_empty() and _index == -1:
				_index = i
			
			# Set it to stack onto a slot if there is room
			if (!backpack[i].is_empty() # Checks that this slot is not an empty slot
				and backpack[i].item.attributes.object_name == item.attributes.object_name # Item in slot is of this items type
				and backpack[i].quantity < backpack[i].item.stack_size ): # Stack is not full 
				_index = i
				break
	
	if _index == -1: ## TODO test this
		return false
		
	# Insert the item to last slot
	if backpack[_index].quantity == 0:
		backpack[_index].item = item
	backpack[_index].quantity += 1
	backpack[_index].update_icon()
	( backpack[_index].get_node("Count") as Label ).text = str(backpack[_index].quantity)

	return true
	

## Swaps the the item dropped with the item in this slot
func __swap_items(item : Item, index : int) -> bool:
	return true
