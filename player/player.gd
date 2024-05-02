extends CharacterBody2D

const SPEED : float = 300.0

var equipped = null

func _input(event):
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed:
		$Playercontroller.handle_main_hand_action()

func _physics_process(delta):
	# Interact
	if Input.is_action_just_pressed("player_interact"):
		$Playercontroller.handle_interact()
	
	if Input.is_action_just_pressed("dev_debug"):
		$Playercontroller.debug()
		
	if Input.is_action_just_pressed("player_toggle_inventory"):
		# Get size of the players vision
		#var camera_size : Vector2 = get_canvas_transform().affine_inverse().basis_xform(get_viewport_rect().size)
		
		# Set the parameters of the inventory screen
		#$Inventory.position = camera_size / -2
		#$Inventory.size = camera_size
		#$Inventory/SplitScreen.split_offset = camera_size.x / 2 
		
		# Pause game and show inventory
		$PlayerViewport/Inventory.visible = true
		get_tree().paused = true
	
	# Movement
	velocity.x = Input.get_axis("player_left", "player_right") * SPEED
	velocity.y = Input.get_axis("player_up", "player_down") * SPEED

	$Animationcontroller.handle_flip(velocity)

	if velocity != Vector2():
		$Animationcontroller.handle_walk_forward()
	else:
		$Animationcontroller.handle_idle()

	move_and_slide()
