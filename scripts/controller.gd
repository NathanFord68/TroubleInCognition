extends Node

## Controls players and ai
class_name Controller

## Calls the action of a target if it can
func handle_action(target: Node) -> void:
	if can_handle_action(target):
		target.action($"..")

## Determines if we can handle calling the action of the target
func can_handle_action(target: Node) -> bool:
	if not is_instance_valid(target):
		return false
	return true

## Processes the action of this object
func action(caller: Node) -> void:
	pass

## Calls the interact of a target if it can
func handle_interact(target: Node) -> void:
	if can_handle_interact(target):
		target.interact($"..")

## Determines if we can handle interacting with the target
func can_handle_interact(target: Node) -> bool:
	if not is_instance_valid(target):
		return false
	if "Interact" not in target.get_groups():
		return false
	return true

## Processes the interact of this object
func interact(caller: Node) -> void:
	pass

## Updates the velocity of the owner
func maneuver(v: Vector2) -> void:
	$"..".velocity = v
