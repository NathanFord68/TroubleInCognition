extends Resource

## Controls players and ai
class_name Controller

## The tree that controls all animations
var animation_tree: AnimationTree

## Who owns this controller
var resource_owner: CharacterBody2D

var direction_facing: Enums.DIRECTION_FACING

var is_sprite_flipped : bool = false
var playing_action_animation : bool = false

## Plays the action animation
##
## Plays the designated animation based on which direction we are facing
## The Animation should be responsible for calling the handle_action method of this controller
## When finished
func anim_action() -> void:
	playing_action_animation = true
	var equipment_tree := resource_owner.get_node("Equipment/%s/AnimationTree" % str(Enums.ITEM_TYPE.PRIMARY)) as AnimationTree
	animation_tree.set("parameters/Swing-Tree/T-A/add_amount", 1 if direction_facing == Enums.DIRECTION_FACING.BACK else 0)
	equipment_tree.set("parameters/Swing-Tree/T-A/add_amount", 1 if direction_facing == Enums.DIRECTION_FACING.BACK else 0)
	animation_tree.set("parameters/Swing-Tree/TA-L/add_amount", 1 if direction_facing == Enums.DIRECTION_FACING.LEFT else 0)
	equipment_tree.set("parameters/Swing-Tree/TA-L/add_amount", 1 if direction_facing == Enums.DIRECTION_FACING.LEFT else 0)
	animation_tree.set("parameters/Swing-Tree/TAL-R/add_amount", 1 if direction_facing == Enums.DIRECTION_FACING.RIGHT else 0)
	equipment_tree.set("parameters/Swing-Tree/TAL-R/add_amount", 1 if direction_facing == Enums.DIRECTION_FACING.RIGHT else 0)
	
	animation_tree.set("parameters/Swing-OS/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	equipment_tree.set("parameters/Swing-OS/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	await resource_owner.get_tree().create_timer(resource_owner.get_node("AnimationPlayer").get_animation("Swing-Toward").length).timeout
	playing_action_animation = false
	
## Determines if we can handle calling the action of the target
func can_handle_action(target: Node) -> bool:
	# Return if there's nothing there
	if not is_instance_valid(target):
		return false
	
	if playing_action_animation:
		return false
		
	# Check the groups to make sure all of my equipment is in the actionable item
	for group in target.get_groups():
		if group not in resource_owner.get_node("Equipment/%s" % str(Enums.ITEM_TYPE.PRIMARY)).get_groups():
			return false
	return true

## Calls the action of a target if it can
func handle_action(target: Node) -> void:
	if not can_handle_action(target):
		return
	await anim_action()
	
	if not is_instance_valid(target):
		return
	target.action(resource_owner)
	
	
## Processes the action of this object
func action(_caller: Node) -> void:
	pass

## Calls the interact of a target if it can
func handle_interact(target: Node) -> void:
	if can_handle_interact(target):
		target.interact(resource_owner)

## Determines if we can handle interacting with the target
func can_handle_interact(target: Node) -> bool:
	if not is_instance_valid(target):
		return false
		
	if "Interact" not in target.get_groups():
		return false
		
	return true

## Processes the interact of this object
func interact(_caller: Node) -> void:
	pass

## Updates the velocity of the owner
func maneuver(v: Vector2) -> void:
	# Add velocity and play animations
	if v.x > 0: # Player walking Right
		(animation_tree.get("parameters/locomotion/playback") as AnimationNodeStateMachinePlayback).travel("Walk-Sideways")
		__animate_equipment_locomotion("Walk-Sideways")
		sprites_left(false)
		direction_facing = Enums.DIRECTION_FACING.RIGHT
	if v.x < 0: # Player Walking left
		(animation_tree.get("parameters/locomotion/playback") as AnimationNodeStateMachinePlayback).travel("Walk-Sideways")
		__animate_equipment_locomotion("Walk-Sideways")
		sprites_left(true)
		direction_facing = Enums.DIRECTION_FACING.LEFT
	if v.y > 0: # Player Walk Toward player
		(animation_tree.get("parameters/locomotion/playback") as AnimationNodeStateMachinePlayback).travel("Walk-Toward")
		__animate_equipment_locomotion("Walk-Toward")
		sprites_left(true)
		direction_facing = Enums.DIRECTION_FACING.FRONT
	if v.y < 0: # Player Walk away from player
		(animation_tree.get("parameters/locomotion/playback") as AnimationNodeStateMachinePlayback).travel("Walk-Away")
		__animate_equipment_locomotion("Walk-Away")
		direction_facing = Enums.DIRECTION_FACING.BACK
	if v == Vector2(): # Default to idle
		match direction_facing:
			Enums.DIRECTION_FACING.FRONT:
				(animation_tree.get("parameters/locomotion/playback") as AnimationNodeStateMachinePlayback).travel("Idle")
				__animate_equipment_locomotion("Idle")
				sprites_left(true)
			Enums.DIRECTION_FACING.BACK:
				(animation_tree.get("parameters/locomotion/playback") as AnimationNodeStateMachinePlayback).travel("Idle-Away")
				__animate_equipment_locomotion("Idle-Away")
				sprites_left(true)
			Enums.DIRECTION_FACING.LEFT:
				(animation_tree.get("parameters/locomotion/playback") as AnimationNodeStateMachinePlayback).travel("Idle-Sideways")
				__animate_equipment_locomotion("Idle-Sideways")
				sprites_left(true)
			Enums.DIRECTION_FACING.RIGHT:
				(animation_tree.get("parameters/locomotion/playback") as AnimationNodeStateMachinePlayback).travel("Idle-Sideways")
				__animate_equipment_locomotion("Idle-Sideways")
				sprites_left(false)
		
	resource_owner.velocity = v

func __animate_equipment_locomotion(param: String):
	if (resource_owner.get_node("Equipment") as Node2D).get_child_count() == 0:
		return
	for equipment: StaticBody2D in resource_owner.get_node("Equipment").get_children():
		(( equipment.get_node("AnimationTree") 
			as AnimationTree).get("parameters/locomotion/playback")
				as AnimationNodeStateMachinePlayback ).travel(param)

## Flips the sprites for the animations
func sprites_left(left: bool):
	# If the sprite does not need to be flipped return
	if left and not is_sprite_flipped:
		return
	if not left and is_sprite_flipped:
		return
	
	is_sprite_flipped = !left
	
	# Flip the sprite to the direction we are trying to go
	for sprite: Sprite2D in resource_owner.get_node("Sprite").get_children():
		sprite.flip_h = !left
		
	for equipment: StaticBody2D in resource_owner.get_node("Equipment").get_children():
		for sprite : Sprite2D in equipment.get_node("Sprite").get_children():
			sprite.flip_h = !left
	
