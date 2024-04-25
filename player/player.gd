extends CharacterBody2D

const SPEED = 300.0

func _input(event):
	if event is InputEventMouseButton and event.button_index == 1:
		var click_normalized : Vector2 = position.direction_to(get_local_mouse_position())
		var space = get_world_2d().direct_space_state
		var end = position + (click_normalized * 100 )
		var query = PhysicsRayQueryParameters2D.create(position, end)
		var hit = space.intersect_ray(query)
		print(hit)
		
		
		

func _physics_process(delta):
	velocity.x = Input.get_axis("player_left", "player_right") * SPEED
	velocity.y = Input.get_axis("player_up", "player_down") * SPEED

	move_and_slide()
