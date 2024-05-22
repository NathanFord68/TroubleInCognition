extends Resource

class_name EquipmentManager

var equipment : Dictionary

func set_equipment_item(item: ItemBase) -> void:
	equipment[item.type] = item
