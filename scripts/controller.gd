extends Node

## Controls players and ai
class_name Controller

## The tree that controls all animations
@export 
var animation_tree: AnimationTree

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
	if v.x > 0: # Player walking Right
		animate_walk_right()
	if v.x < 0: # Player Walking left
		animate_walk_left()
	if v.y > 0:
		animate_walk_toward()
	if v.y < 0:
		animate_walk_away()
	if v == Vector2():
		animate_idle()
	$"..".velocity = v

func animate_idle():	
	# Reset the flip of each sprite
	(animation_tree.get("parameters/locomotion/playback") as AnimationNodeStateMachinePlayback).travel("Idle")
	
	# Flip the sprites back to default
	for sprite: Sprite2D in $"../Sprite".get_children():
		sprite.flip_h = false

func animate_walk_right():
	(animation_tree.get("parameters/locomotion/playback") as AnimationNodeStateMachinePlayback).travel("Walk-Sideways")
	
	# Flip so sprite is walking right instead of default left
	for sprite: Sprite2D in $"../Sprite".get_children():
		sprite.flip_h = true
		
func animate_walk_left():
	(animation_tree.get("parameters/locomotion/playback") as AnimationNodeStateMachinePlayback).travel("Walk-Sideways")
	
	# Ensure the flip is default
	for sprite: Sprite2D in $"../Sprite".get_children():
		sprite.flip_h = false
	
func animate_walk_toward():
	(animation_tree.get("parameters/locomotion/playback") as AnimationNodeStateMachinePlayback).travel("Walk-Toward")
	
	# Ensure the flip is default
	for sprite: Sprite2D in $"../Sprite".get_children():
		sprite.flip_h = false
	
func animate_walk_away():
	(animation_tree.get("parameters/locomotion/playback") as AnimationNodeStateMachinePlayback).travel("Walk-Away")
