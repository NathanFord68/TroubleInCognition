extends Enemy

class_name Rabius

func _ready() -> void:
	super._ready()
	var weapon = Weapon.new()
	weapon.attack_speed = 1
	weapon.damage = 5
	weapon.min_damage = 1
	weapon.knock_back_strength = 500
	weapon.is_two_handed = true
	equipment_manager.equipment[5] = weapon
	weapon.can_action_with = ["Player"]
	
	($AttackPlayer/CollisionShape2D.shape as CircleShape2D ).radius = 20

func _physics_process(delta : float) -> void:
	super._physics_process(delta)
