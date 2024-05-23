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

## Store the object path
const object_path : String = "res://assets/objects/%s.tscn"

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

func action(weapon : Weapon ) -> void:
	attributes.health -= weapon.damage
	print(attributes.health)
	
	if attributes.health <= 0:
		# Drop based off drop table TODO
		var rng := RandomNumberGenerator.new().randi_range(0, 100)
		for d in attributes.drop_table:
			__process_drop_item(rng, d)
		
		# Queue free if we're dead
		queue_free()

## Processes the interact of this object
func interact(caller: Node) -> void:
	print(caller)

func __process_drop_item(rng: int, data: Dictionary):
	if not (rng < data.chance):
		return
		
	var quantity := RandomNumberGenerator.new().randi_range(data.min, data.max)
	for i in range(0, quantity):
		var item : StaticBody2D = (load(object_path % data.object) as PackedScene).instantiate()
		var generator = RandomNumberGenerator.new()
		item.global_position = global_position + Vector2(generator.randf_range(0, 30), generator.randf_range(0, 30))
		get_tree().root.add_child(item)
		


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
