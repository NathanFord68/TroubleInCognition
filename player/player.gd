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
