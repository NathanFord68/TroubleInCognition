extends Resource

## Controls players and ai
class_name Controller

## The tree that controls all animations
var animation_tree: AnimationTree

## Who owns this controller
var resource_owner: CharacterBody2D

## Keeps a reference to the owner
var owner : CharacterBody2D

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
	
	await owner.get_tree().create_timer(1).timeout
	
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
	#for p in animation_tree.get_property_list():
	#	print(p)
	# Add velocity and play animations
	if v.x > 0: # Player walking Right
		direction_facing = Enums.DIRECTION_FACING.RIGHT
	if v.x < 0: # Player Walking left
		direction_facing = Enums.DIRECTION_FACING.LEFT
	if v.y > 0: # Player Walk Toward player
		direction_facing = Enums.DIRECTION_FACING.FRONT
	if v.y < 0: # Player Walk away from player
		direction_facing = Enums.DIRECTION_FACING.BACK
	if v == Vector2(): # Default to idle
		animation_tree.set("parameters/Idle/conditions/away", direction_facing == Enums.DIRECTION_FACING.BACK)
		animation_tree.set("parameters/Idle/conditions/forward", direction_facing == Enums.DIRECTION_FACING.FRONT)
		animation_tree.set("parameters/Idle/conditions/right", direction_facing == Enums.DIRECTION_FACING.RIGHT)
		animation_tree.set("parameters/Idle/conditions/left", direction_facing == Enums.DIRECTION_FACING.LEFT)
		animation_tree.set("parameters/Idle-Walk/blend_amount", 0)
	else:
		animation_tree.set("parameters/Walk/conditions/away", direction_facing == Enums.DIRECTION_FACING.BACK)
		animation_tree.set("parameters/Walk/conditions/forward", direction_facing == Enums.DIRECTION_FACING.FRONT)
		animation_tree.set("parameters/Walk/conditions/right", direction_facing == Enums.DIRECTION_FACING.RIGHT)
		animation_tree.set("parameters/Walk/conditions/left", direction_facing == Enums.DIRECTION_FACING.LEFT)
		animation_tree.set("parameters/Idle-Walk/blend_amount", 1)
		
	resource_owner.velocity = v
