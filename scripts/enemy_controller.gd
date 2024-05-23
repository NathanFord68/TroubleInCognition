extends Controller

class_name EnemyController 

var player_detected : Player = null
var did_just_attack : bool = false
var can_attack_player : bool = false

func _handle_attack_player() -> void:
	if can_attack_player and not did_just_attack and is_instance_valid(player_detected):
		# Perform the attack
		var direction = resource_owner.global_position.direction_to(player_detected.global_position)
		player_detected.action(resource_owner.equipment_manager.equipment[5], direction, .1)
		
		# Create delay between attacks
		did_just_attack = true
		await resource_owner.get_tree().create_timer(resource_owner.equipment_manager.equipment[5].attack_speed).timeout
		did_just_attack = false
