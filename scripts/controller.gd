extends Node

## Controls players and ai
class_name Controller

## The tree that controls all animations
@export 
var animation_tree: AnimationTree

var direction_facing: Enums.DIRECTION_FACING

## Plays the action animation
##
## Plays the designated animation based on which direction we are facing
## The Animation should be responsible for calling the handle_action method of this controller
## When finished
func anim_action() -> void:
	var animation: String
	match direction_facing:
		Enums.DIRECTION_FACING.FRONT:
			animation = "Swing-Toward"
		Enums.DIRECTION_FACING.BACK:
			pass
		Enums.DIRECTION_FACING.LEFT:
			pass
		Enums.DIRECTION_FACING.RIGHT:
			pass
	animation_tree.set("parameters/%s/request" % animation, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	await get_tree().create_timer(( $"../AnimationPlayer" as AnimationPlayer).get_animation(animation).length).timeout

## Determines if we can handle calling the action of the target
func can_handle_action(target: Node) -> bool:
	# TODO add logic to check groups vs can action with
	if not is_instance_valid(target):
		return false
	return true

## Calls the action of a target if it can
func handle_action(target: Node) -> void:
	if can_handle_action(target):
		await anim_action()
		target.action($"..")
	
	
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
	# Add velocity and play animations
	if v.x > 0: # Player walking Right
		(animation_tree.get("parameters/locomotion/playback") as AnimationNodeStateMachinePlayback).travel("Walk-Sideways")
		__animate_equipment_locomotion("Walk-Sideways")
		flip_sprites(false)
		direction_facing = Enums.DIRECTION_FACING.LEFT
	if v.x < 0: # Player Walking left
		(animation_tree.get("parameters/locomotion/playback") as AnimationNodeStateMachinePlayback).travel("Walk-Sideways")
		__animate_equipment_locomotion("Walk-Sideways")
		flip_sprites()
		direction_facing = Enums.DIRECTION_FACING.RIGHT
	if v.y > 0: # Player Walk Toward player
		(animation_tree.get("parameters/locomotion/playback") as AnimationNodeStateMachinePlayback).travel("Walk-Toward")
		__animate_equipment_locomotion("Walk-Toward")
		flip_sprites()
		direction_facing = Enums.DIRECTION_FACING.FRONT
	if v.y < 0: # Player Walk away from player
		(animation_tree.get("parameters/locomotion/playback") as AnimationNodeStateMachinePlayback).travel("Walk-Away")
		__animate_equipment_locomotion("Walk-Away")
		direction_facing = Enums.DIRECTION_FACING.BACK
	if v == Vector2(): # Default to idle
		(animation_tree.get("parameters/locomotion/playback") as AnimationNodeStateMachinePlayback).travel("Idle")
		__animate_equipment_locomotion("Idle")
		flip_sprites()
		direction_facing = Enums.DIRECTION_FACING.FRONT
		
	$"..".velocity = v

func __animate_equipment_locomotion(param: String):
	if ($"../Equipment" as Node2D).get_child_count() == 0:
		return
	for equipment: StaticBody2D in $"../Equipment".get_children():
		(( equipment.get_node("AnimationTree") 
			as AnimationTree).get("parameters/locomotion/playback")
				as AnimationNodeStateMachinePlayback ).travel(param)

## Flips the sprites for the animations
func flip_sprites(default: bool = true):
	for sprite: Sprite2D in $"../Sprite".get_children():
		sprite.flip_h = !default
		
	if ($"../Equipment" as Node2D).get_child_count() == 0:
		return
	
	for equipment: StaticBody2D in $"../Equipment".get_children():
		for sprite : Sprite2D in equipment.get_node("Sprite").get_children():
			sprite.flip_h = !default
	
