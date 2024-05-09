extends StaticBody2D

## Base class for all items in the game
class_name ItemBase

## Specifies the item type for player and ai equipment and inventories
@export 
var type: Enums.ITEM_TYPE

## Specifies the needed ingredients to craft this item
@export 
var recipe: Array

## Information about this item related to engine assets
@export 
var engine_info: EngineInfo

## Basic attributes for this item. Health will be durability
@export 
var attributes: BaseAttributes

#func _init(
	#_type,
	#_recipe,
	#_engine_info,
	#_attributes
#):
	#self.type = _type
	#self.recipe = _recipe
	#self.engine_info = _engine_info
	#self.attributes = _attributes

## Processes the action to be done on this item when a caller actions with it
func action(caller: Node) -> void:
	print(caller)

## Process the interact to be done on this item when a caller interacts with it
func interact(caller: Node) -> void:
	var n_item := (load(engine_info.asset_path) as PackedScene).instantiate() as ItemBase
	var can_queue_free = false

	if "Player" in caller.get_groups():
		can_queue_free = caller.inventory_manager.add_to_inventory(n_item)

	if can_queue_free:
		queue_free()
