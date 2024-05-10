extends Node

## Base class for any world object that the player can do stuff with
class_name HarvestNode

## The attributes of the node
@export
var attributes: BaseAttributes

## Information about this item for godot
@export
var engine_info: EngineInfo

## Processes the action of this object
func action(caller: Node) -> void:
	print(caller)

## Processes the interact of this object
func interact(caller: Node) -> void:
	print(caller)
