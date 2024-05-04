extends StaticBody2D

## Base class for all items in the game
class_name ItemBase

## Specifies the item type for player and ai equipment and inventories
@export 
var type: Enums.ITEM_TYPE

## Specifies the needed ingredients to craft this item
@export 
var recipe: Array[Dictionary]

## Information about this item related to engine assets
@export 
var engine_info: EngineInfo

## Basic attributes for this item. Health will be durability
@export 
var attributes: BaseAttributes

## Processes the action to be done on this item when a caller actions with it
func action(caller: Node) -> void:
	pass

## Process the interact to be done on this item when a caller interacts with it
func interact(caller: Node) -> void:
	pass
