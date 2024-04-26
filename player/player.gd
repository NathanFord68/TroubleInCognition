extends CharacterBody2D

const SPEED = 300.0

var equipped = null

func _ready():
	$AnimationPlayer.play("Idle")

func _input(event):
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed:
		$Components/Playercontroller.handle_main_hand_action()

func _physics_process(delta):
	# Interact
	if Input.is_action_just_pressed("player_interact"):
		$Components/Playercontroller.handle_interact()
	
	if Input.is_action_just_pressed("dev_debug"):
		$Components/Playercontroller.debug()
	
	# Movement
	velocity.x = Input.get_axis("player_left", "player_right") * SPEED
	velocity.y = Input.get_axis("player_up", "player_down") * SPEED

	$Components/Animationcontroller.handle_flip(velocity)

	if velocity != Vector2():
		$Components/Animationcontroller.handle_walk_forward()
	else:
		$Components/Animationcontroller.handle_idle()

	move_and_slide()
