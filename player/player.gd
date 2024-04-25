extends CharacterBody2D

const SPEED = 300.0

var equipped = null

func _input(event):
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed:
		handle_main_hand_action()

func _physics_process(delta):
	# Interact
	if Input.is_action_just_pressed("player_interact"):
		handle_interact()
	
	if Input.is_action_just_pressed("dev_debug"):
		debug()
	
	# Movement
	velocity.x = Input.get_axis("player_left", "player_right") * SPEED
	velocity.y = Input.get_axis("player_up", "player_down") * SPEED

	move_and_slide()

func handle_interact():
	# Get the object at that position
	var hit = point_to_mouse()
	
	# TODO fix issue with objects being between what I'm trying to pick up
	# Ray Trace to position to see if we can reach
	if hit != trace_to_mouse(20, true):
		return
	
	# Check that we can interact with it
	if "Interact" not in hit.get_groups():
		return
	
	# Call interact method if it has it
	hit.interact(self)

func handle_main_hand_action():
	# Return if nothing is equipped
	if equipped == null:
		return
	
	# Get the item we're hitting
	var hit = trace_to_mouse(equipped.range, true)
	
	# Checking the two objects are compatible
	var can_action = false
	for g in hit.get_groups():
		if g in equipped.can_action_with:
			can_action = true
			break
			
	# Calling the action function if they are
	if can_action:
		hit.action(self)
		

func point_to_mouse():
	# Get world space physics
	var space = get_world_2d().direct_space_state
	
	# Create query
	var query = PhysicsPointQueryParameters2D.new()
	query.exclude = [ self ]
	query.position = get_global_mouse_position()
	
	# Cast the query
	var hit = space.intersect_point(query)
	print(hit)
	
	# Return hit objects
	if "collider" in hit[0]:
		return hit[0].collider
	
	return null
	
func trace_to_mouse(reach, visualize):
		
	# Normalize to mouse position
	var click_normalized : Vector2 = global_position.direction_to(get_global_mouse_position())
	
	# Get world space physics
	var space = get_world_2d().direct_space_state
	
	# Create the query
	var end = global_position + (click_normalized * 40 )
	var query = PhysicsRayQueryParameters2D.create(global_position, end)
	query.exclude = [self]
	
	# Cast the query
	var hit = space.intersect_ray(query)
	
	# Visualize if true
	if visualize:
		visualize_ray_cast(global_position, end)
	
	# Return collider if hit
	if "collider" in hit:
		return hit.collider
	
	return null


func visualize_ray_cast(start, end):
	if get_node("PlayerRayCast"):
		get_node("PlayerRayCast").points = [global_position, end]
		return
	
	var line_node = Line2D.new()
	line_node.name = "PlayerRayCast"
	line_node.points = [global_position, end]
	line_node.width = 2
	line_node.top_level = true
	add_child(line_node)


func debug():
	print(equipped)
	print(equipped.damage)
