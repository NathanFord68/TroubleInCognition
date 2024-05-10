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
	# Get the weapon that's hitting us
	var weapon :=  caller.get_node("Equipment/%s" % Enums.ITEM_TYPE.PRIMARY) as Weapon 
	
	# Deal the necessary damage
	attributes.health -= weapon.damage
	
	
	if attributes.health <= 0:
		# Drop based off drop table TODO
		
		# Queue free if we're dead
		queue_free()

## Processes the interact of this object
func interact(caller: Node) -> void:
	print(caller)
