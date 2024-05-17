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

var total_item_count : Dictionary = {}

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
		remove_item_from_equipment_slot(data.item.type)
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

## Clears an equipment slot of the equipped item
##
## This does not clear the item in the inventory 
## Since this instance was a clone of the inventory item
func remove_item_from_equipment_slot(slot: Enums.ITEM_TYPE):
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
	for slot : EquipmentSlot in backpack:
		quantity = __handle_remove_quantity_from_slot(slot, item_name, quantity)
	
	return true
	
## Determines if this slot has the item we are removing and calls process as necessary
func __handle_remove_quantity_from_slot(slot: EquipmentSlot, item_to_remove: String, quantity: int) -> int:
	if is_instance_valid(slot.item) and slot.item.attributes.object_name == item_to_remove:
		return __process_remove_quantity_from_slot(slot, quantity)
	return quantity

## Handle logic for removing quantity from a given slot
func __process_remove_quantity_from_slot(slot: EquipmentSlot, quantity: int) -> int:
	# EquipmentSlot < quantity
	if slot.quantity < quantity:
		var r_quantity = quantity - slot.quantity
		slot.quantity = 0
		slot.item = null
		slot.update_icon()
		return r_quantity
	
	# EquipmentSlot >= quantity
	slot.quantity -= quantity
	if slot.quantity == 0:
		slot.item = null
		slot.update_icon()
	return 0
