extends Resource

## Manage the inventory of the player
class_name InventoryManager

## Max slots the backpack allows
@export
var max_backpack_size : int

## Reference to our inventory viewport
var inventory_viewport : Control

## Reference to the equipment node for the player
var equipment : Node2D

## Holds the items of the players backpack
var backpack : Array[EquipmentSlot] = []

var total_item_count : Dictionary = {}

var slots_that_have_equipment: Array[int] = []

signal send_item_did_equip
signal send_item_did_remove_equip

func initialize_backpack():
	# Resize and populate the backpack with equipment slots
	var bp_slots := inventory_viewport.get_backpack() as GridContainer
	backpack.resize(max_backpack_size)
	for a in range(0, max_backpack_size):
		var n_equipment_slot := ( load("res://assets/objects/equipment_slot.tscn") as PackedScene ).instantiate() as EquipmentSlot
		n_equipment_slot.inventory_root = inventory_viewport
		n_equipment_slot.index_in_backpack = a
		backpack[a] = n_equipment_slot
		n_equipment_slot.viewport = inventory_viewport
		bp_slots.add_child(n_equipment_slot)
		
	inventory_viewport.item_dropped.connect(handle_item_dropped_into_slot)

## Handles the emission of the item_dropped signal from the viewport
func handle_item_dropped_into_slot(from: EquipmentSlot, to: EquipmentSlot):
	# Both main and no swap
	if ( from.allowed_type == Enums.ITEM_TYPE.MAIN 
		 and to.allowed_type == Enums.ITEM_TYPE.MAIN
		 and not is_instance_valid(to.item)
	):
		to.item = from.item
		to.quantity = from.quantity
		
		from.item = null
		from.quantity = 0
		slots_that_have_equipment.remove_at(slots_that_have_equipment.find(from.index_in_backpack))
		slots_that_have_equipment.push_back(to.index_in_backpack)
	
	# Both main and swapping
	elif ( from.allowed_type == Enums.ITEM_TYPE.MAIN 
		 and to.allowed_type == Enums.ITEM_TYPE.MAIN
		 and is_instance_valid(to.item)
	):
		# Update quantities
		var to_old_quantity = to.quantity
		var to_old_item = to.item
		
		to.quantity = from.quantity
		to.item = from.item
		
		from.quantity = to_old_quantity
		from.item = to_old_item
	
	# Main -> Equipment, no swap
	elif ( from.allowed_type == Enums.ITEM_TYPE.MAIN
		 and to.allowed_type != Enums.ITEM_TYPE.MAIN
		 and not is_instance_valid(to.item)
	):
		to.item = from.item
		to.quantity = from.quantity
		add_to_equipment_slot(to.allowed_type, to)
		
		from.item = null
		from.quantity = 0
		
		slots_that_have_equipment.remove_at(slots_that_have_equipment.find(from.index_in_backpack))
	
	# Main -> Equipment, swapping
	elif ( from.allowed_type == Enums.ITEM_TYPE.MAIN
		 and to.allowed_type != Enums.ITEM_TYPE.MAIN
		 and is_instance_valid(to.item)
	):
		var to_old_quantity = to.quantity
		var to_old_item = to.item
		
		to.quantity = from.quantity
		to.item = from.item
		
		from.quantity = to_old_quantity
		from.item = to_old_item
		
		remove_item_from_equipment_slot(to.allowed_type)
		add_to_equipment_slot(to.allowed_type, to)
		
	# Equipment -> Main, no swap
	elif ( from.allowed_type != Enums.ITEM_TYPE.MAIN
		 and to.allowed_type == Enums.ITEM_TYPE.MAIN
		 and not is_instance_valid(to.item)
	):
		to.item = from.item
		to.quantity = from.quantity
		
		from.item = null
		from.quantity = 0
		
		remove_item_from_equipment_slot(from.allowed_type)
		slots_that_have_equipment.push_back(to.index_in_backpack)
	
	# Equipment -> Main, swapping
	elif ( from.allowed_type != Enums.ITEM_TYPE.MAIN
		 and to.allowed_type == Enums.ITEM_TYPE.MAIN
		 and is_instance_valid(to.item)
	):
		var to_old_quantity = to.quantity
		var to_old_item = to.item
		
		to.quantity = from.quantity
		to.item = from.item
		
		from.quantity = to_old_quantity
		from.item = to_old_item
		
		remove_item_from_equipment_slot(from.allowed_type)
		add_to_equipment_slot(from.allowed_type, to)
	
	to.update_icon()
	from.update_icon()

## Move item from inventory to equipment slot
func add_to_equipment_slot(slot: Enums.ITEM_TYPE, data: EquipmentSlot):
	# Add it to our the equipment slot of our player
	equipment.get_node(str(slot)).texture = Global.generate_image_texture_from_scene(data.item)
	
	# Signal the item that was added
	send_item_did_equip.emit(data.item)

## Clears an equipment slot of the equipped item
##
## This does not clear the item in the inventory 
## Since this instance was a clone of the inventory item
func remove_item_from_equipment_slot(slot: Enums.ITEM_TYPE):
	equipment.get_node(str(slot)).texture = null
	send_item_did_remove_equip.emit(slot)

## Adds an item to the inventory
func add_to_inventory(item : Node, index : int = -1) -> bool:
	var _index : int = index
	
	if _index == -1:
		for slot in slots_that_have_equipment:
			# Set it to stack onto a slot if there is room
			if (backpack[slot].item.attributes.object_name == item.attributes.object_name # Item in slot is of this items type
				and backpack[slot].quantity < backpack[slot].item.stack_size ): # Stack is not full
				_index = slot
				break
		# Find the lowest index and set i equal to
		for i in range(0, max_backpack_size):
			if _index >= 0:
				break
			# Set it to first empty slot if it does not have an index yet
			if backpack[i].is_empty() and _index == -1:
				_index = i
				slots_that_have_equipment.push_back(i)
				break
	
	if _index == -1: ## TODO test this
		return false
		
	# Insert the item to last slot
	if backpack[_index].quantity == 0:
		backpack[_index].item = item
	backpack[_index].quantity += 1
	backpack[_index].update_icon()
	
	if item.attributes.object_name in total_item_count:
		total_item_count[item.attributes.object_name] += 1
	else:
		total_item_count[item.attributes.object_name] = 1

	return true

## Removes items from the inventory and the total count. 
##
## If index is set it will only drop from that slot
func remove_from_inventory(item_name: String, quantity: int, index: int = -1) -> bool:
	if index != -1:
		pass # TODO develop this logic
	
	# Check if the quantity we need to remove is available
	if total_item_count[item_name] < quantity:
		return false
	
	# Reduce count in total
	total_item_count[item_name] -= quantity
	
	# Iterate through and reduce / delete from backback until we are done
	var list_of_value_to_pop : Array[int] = []
	for i in range(0, slots_that_have_equipment.size()):
		var quantity_empty = __handle_remove_quantity_from_slot(backpack[slots_that_have_equipment[i]], item_name, quantity)
		quantity = quantity_empty[0]
		if quantity_empty[1]:
			list_of_value_to_pop.push_back(backpack[slots_that_have_equipment[i]].index_in_backpack)
		if quantity == 0:
			break
	
	for pop_value in list_of_value_to_pop:
		slots_that_have_equipment.remove_at(slots_that_have_equipment.find(pop_value))
	
	return true
	
## Determines if this slot has the item we are removing and calls process as necessary
func __handle_remove_quantity_from_slot(slot: EquipmentSlot, item_to_remove: String, quantity: int) -> Array:
	if is_instance_valid(slot.item) and slot.item.attributes.object_name == item_to_remove:
		return __process_remove_quantity_from_slot(slot, quantity)
	return [ quantity, false ]

## Handle logic for removing quantity from a given slot
func __process_remove_quantity_from_slot(slot: EquipmentSlot, quantity: int) -> Array:
	# EquipmentSlot < quantity
	if slot.quantity < quantity:
		var r_quantity = quantity - slot.quantity
		slot.quantity = 0
		slot.item = null
		slot.update_icon()
		return [ r_quantity, true ]
	
	# EquipmentSlot >= quantity
	slot.quantity -= quantity
	var is_slot_empty: bool = false
	if slot.quantity == 0:
		slot.item = null
		slot.update_icon()
		is_slot_empty = true
	else:
		slot.update_label()
	return [0, is_slot_empty]
