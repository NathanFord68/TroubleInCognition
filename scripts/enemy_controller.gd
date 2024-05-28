extends Controller

class_name EnemyController 

var detected_player : Player = null
var did_just_attack : bool = false
var can_attack_player : bool = false

## Calls the action of a target if it can
func _handle_action(_target: Node) -> void:
	# Check if we can do an action
	if not can_handle_action(detected_player):
		return
	
	# Play that animation
	playing_action_animation = true
	await __set_animation("Swing", owner.equipment_manager.equipment[Enums.ITEM_TYPE.PRIMARY].attack_speed, false, true)
	playing_action_animation = false
	
	# Call that targets action
	if not is_instance_valid(detected_player):
		return
	
	if not can_attack_player:
		return
	detected_player.action(owner.equipment_manager.equipment[Enums.ITEM_TYPE.PRIMARY])
	
	if owner.equipment_manager.equipment[Enums.ITEM_TYPE.PRIMARY].knock_back_strength != 0:
		detected_player.apply_force(
			owner.global_position.direction_to(detected_player.global_position), 
			owner.equipment_manager.equipment[Enums.ITEM_TYPE.PRIMARY].knock_back_strength, 
			.1, 
			false
		)

func _handle_attack_player() -> void:
	if playing_action_animation:
		owner.velocity = Vector2.ZERO
		
	if not _can_handle_attack_player():
		return
	
	# Call the players action and apply force
	_handle_action(detected_player)
	
	# Create delay between attacks
	did_just_attack = true
	await owner.get_tree().create_timer(owner.equipment_manager.equipment[Enums.ITEM_TYPE.PRIMARY].attack_speed).timeout
	did_just_attack = false

func _can_handle_attack_player() -> bool:
	if not can_attack_player:
		return false
	if did_just_attack:
		return false
	if not is_instance_valid(detected_player):
		return false
	return true
