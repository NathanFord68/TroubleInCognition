extends Resource

## Controls players and ai
class_name Controller

## Locomotion settings for the owning actor, do not set action animations
## as action animations should be set in the primary weapon
@export
var IDLE_LENGTH: float
@export
var WALK_LENGTH: float

## The tree that controls all animations
var animation_tree: AnimationTree

## Refernce to get all the animations
var animation_player: AnimationPlayer

## Who owns this controller
var resource_owner: CharacterBody2D

## Keeps a reference to the owner
var owner : Player

var direction_facing: Enums.DIRECTION_FACING

var is_sprite_flipped : bool = false
var playing_action_animation : bool = false

## Determines if we can handle calling the action of the target
func can_handle_action(target: Node) -> bool:
	# Return if there's nothing there
	if not is_instance_valid(target):
		return false
	
	if playing_action_animation:
		return false
		
	# Check the groups to make sure all of my equipment is in the actionable item
	for group in target.get_groups():
		if group not in owner.equipment_manager.equipment[Enums.ITEM_TYPE.PRIMARY].get_groups():
			return false
	return true

## Calls the action of a target if it can
func handle_action(target: Node) -> void:
	# Check if we can do an action
	if not can_handle_action(target):
		return
	
	# Play that animation
	playing_action_animation = true
	await __set_animation("Swing", owner.equipment_manager.equipment[5].attack_speed, false, true)
	playing_action_animation = false
	
	# Check the target is still set
	if not is_instance_valid(target): # Protects us from rogue handle_action calls with null values
		return
	
	# Call that targets action
	target.action(owner.equipment_manager.equipment[Enums.ITEM_TYPE.PRIMARY])

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

## Updates the velocity of the owner
func _maneuver(v: Vector2, f: Vector2 = Vector2()) -> void:
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
		__set_animation("Idle", IDLE_LENGTH)
	else:
		__set_animation("Walk", WALK_LENGTH)
		
	resource_owner.velocity = v + f


## Goes through all logic to set an animation
##
## If the is_one_shot is set to true, method will wait for desired time length and then return true
func __set_animation(state_machine_name: String, desired_length : float, is_locomotion: bool = true, is_one_shot: bool = false) -> Variant:
	if is_one_shot:
		animation_tree.set("parameters/%s/conditions/finish" % state_machine_name, false)
	
	# Set the animation variable accordingly. Also update the time
	__set_state_machine(state_machine_name, is_locomotion)
	__set_time_scale_node(state_machine_name, desired_length)
	
	if is_one_shot:
		# Start the animation
		animation_tree.get("parameters/%s/playback" % state_machine_name).start("Start")
		animation_tree.set("parameters/%s-One-Shot/request" % state_machine_name, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		
		# Wait for the animation to finish
		await owner.get_tree().create_timer(desired_length).timeout
		
		# Set the finished condition and return to let caller know that animation is finished
		animation_tree.set("parameters/%s/conditions/finish" % state_machine_name, true)
		return true
	return
	

func __set_state_machine(state_machine_name: String, is_locomotion: bool = true) -> void:
	animation_tree.set("parameters/%s/conditions/away" % state_machine_name, direction_facing == Enums.DIRECTION_FACING.BACK)
	animation_tree.set("parameters/%s/conditions/forward" % state_machine_name, direction_facing == Enums.DIRECTION_FACING.FRONT)
	animation_tree.set("parameters/%s/conditions/right" % state_machine_name, direction_facing == Enums.DIRECTION_FACING.RIGHT)
	animation_tree.set("parameters/%s/conditions/left" % state_machine_name, direction_facing == Enums.DIRECTION_FACING.LEFT)
	if is_locomotion:
		animation_tree.set("parameters/Locomotion-Transitions/transition_request", state_machine_name)
	
func __set_time_scale_node(state_machine_name: String, desired_time: float) -> void:
	var node_from_direction : String
	if direction_facing == Enums.DIRECTION_FACING.BACK:
		node_from_direction = "%s-Away"
	if direction_facing == Enums.DIRECTION_FACING.FRONT:
		node_from_direction = "%s-Toward"
	if direction_facing == Enums.DIRECTION_FACING.RIGHT:
		node_from_direction = "%s-Right"
	if direction_facing == Enums.DIRECTION_FACING.LEFT:
		node_from_direction = "%s-Left"
		
	node_from_direction = node_from_direction % state_machine_name
	
	var anim = animation_player.get_animation(node_from_direction)
	if is_instance_valid(anim):
		animation_tree.set("parameters/TimeScale/scale", 1 / (desired_time / anim.length))
