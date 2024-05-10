extends CharacterBody2D

## Handles player interaction
class_name Player

## Stats of the player
@export
var stats : Stats

## Attributes of the player
@export
var attributes : EnhancedAttributes

## Engine specific information about the player
@export
var engine_info : EngineInfo

## Manages our inventory
@export
var inventory_manager : InventoryManager

func _input(event) -> void:
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed:
		$Controller.handle_action(get_target(attributes.base_reach))
	
func _physics_process(delta) -> void:
	if not can_physics_process():
		return 
	if Input.is_action_just_pressed("dev_debug"):
		inventory_manager.debug_print()
	
	if Input.is_action_just_pressed("player_interact"):
		$Controller.handle_interact(get_target(attributes.base_reach))
	
	# Movement
	$Controller.maneuver(Vector2(
		Input.get_axis("player_left", "player_right") * attributes.speed,
		Input.get_axis("player_up", "player_down") * attributes.speed
	))

	move_and_slide()

## Checks to make sure everything the physics process will need has been instantiated
func can_physics_process() -> bool:
	if not is_instance_valid(attributes):
		return false
	return true

## Gets the target the player is trying to interact with
func get_target(range : float) -> Node:
	var p_hit = point_to_mouse(true)
	var t_hit = trace_to_mouse(range, true)
	if p_hit == t_hit:
		return p_hit
	return null

## Ray traces to the mouse position from the player
func trace_to_mouse(range: float, debug: bool) -> Node:
	# Normalize to mouse position
	var click_normalized : Vector2 = global_position.direction_to(get_global_mouse_position())
	
	# Get world space physics
	var space = get_world_2d().direct_space_state
	
	# Create the query
	var end = global_position + (click_normalized * range )
	var query = PhysicsRayQueryParameters2D.create(global_position, end)
	query.exclude = [self]
	
	# Cast the query
	var hit = space.intersect_ray(query)
	
	# Visualize if true
	if Env.mode == Enums.MODE.DEV:
		Debug.visualize_ray_cast(global_position, end, self)
	
	# Return collider if hit
	if "collider" in hit:
		return hit.collider
	
	return null

## Point trace at the mouse position
func point_to_mouse(debug: bool) -> Node:
	# Get world space physics
	var space = get_world_2d().direct_space_state
	
	# Create query
	var query = PhysicsPointQueryParameters2D.new()
	query.exclude = [ self ]
	query.position = get_global_mouse_position()
	
	# Cast the query
	var hit = space.intersect_point(query)
	
	# Return hit objects
	if hit.size() > 0:
		return hit[0].collider
	
	return null
