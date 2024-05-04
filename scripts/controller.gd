extends Node

## Controls players and ai
class_name Controller

## Calls the action of a target if it can
func handle_action(target: Node) -> void:
	pass

## Processes the action of this object
func action(caller: Node) -> void:
	pass

## Calls the interact of a target if it can
func handle_interact(target: Node) -> void:
	print(target)

## Processes the interact of this object
func interact(caller: Node) -> void:
	pass

## Updates the velocity of the owner
func maneuver(v: Vector2) -> void:
	$"..".velocity = v
