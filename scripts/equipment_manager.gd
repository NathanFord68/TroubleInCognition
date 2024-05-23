extends Resource

class_name EquipmentManager

var equipment : Dictionary

func set_equipment_item(item: ItemBase) -> void:
	equipment[item.type] = item

func remove_equipment(slot: Enums.ITEM_TYPE) -> void:
	equipment[slot] = null
