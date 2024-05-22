extends CharacterBody2D

@export
var attributes : EnhancedAttributes

@export
var engine_info : EngineInfo

@export
var controller : Controller

var weapon : Weapon

var player_detected : Player

# Called when the node enters the scene tree for the first time.
func _ready():
	weapon = Weapon.new()
	weapon.damage = 5
	
	controller.animation_tree = $AnimationTree
	controller.animation_player = $AnimationPlayer
	controller.resource_owner = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if is_instance_valid(player_detected):
		var direction = global_position.direction_to(player_detected.global_position)
		controller.maneuver( direction * attributes.speed )
	else:
		controller.maneuver(Vector2())
	move_and_slide()

# Forget the player 
func _on_forget_player_body_exited(body):
	if "Player" in body.get_groups():
		player_detected = null

# Start tracking the player 
func _on_detect_player_body_entered(body):
	if "Player" in body.get_groups():
		player_detected = body

func _on_attack_player_body_entered(body : CharacterBody2D):
	if "Player" in body.get_groups():
		var direction = global_position.direction_to(player_detected.global_position)
		body.action(weapon, direction * 100, 10)
