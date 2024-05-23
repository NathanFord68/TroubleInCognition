extends CharacterBody2D

class_name Enemy

@export
var attributes : EnhancedAttributes

@export
var engine_info : EngineInfo

@export
var controller : EnemyController

@export
var equipment_manager : EquipmentManager

var player_detected : Player

# Called when the node enters the scene tree for the first time.
func _ready():
	controller.animation_tree = $AnimationTree
	controller.animation_player = $AnimationPlayer
	controller.resource_owner = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta : float) -> void:
	if is_instance_valid(controller.player_detected):
		var direction = global_position.direction_to(controller.player_detected.global_position)
		controller._maneuver( direction * attributes.speed )
	else:
		controller._maneuver(Vector2())
		
	controller._handle_attack_player()
	
	move_and_slide()

# Forget the player 
func _on_forget_player_body_exited(body : Node2D) -> void:
	if "Player" in body.get_groups():
		controller.player_detected = null

# Start tracking the player 
func _on_detect_player_body_entered(body : Node2D) -> void:
	if "Player" in body.get_groups():
		controller.player_detected = body

func _on_attack_player_body_entered(body : Node2D) -> void:
	if "Player" in body.get_groups():
		controller.can_attack_player = true

func _on_attack_player_body_exited(body : Node2D) -> void:
	if "Player" in body.get_groups():
		controller.can_attack_player = false
