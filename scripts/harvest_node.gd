extends StaticBody2D

## Base class for any world object that the player can do stuff with
class_name HarvestNode

## The attributes of the node
@export
var attributes: BaseAttributes

## Information about this item for godot
@export
var engine_info: EngineInfo

## Tracks if this is a building
@export
var can_place: bool

## Allows buildings to stack in inventory
@export
var stack_size: int

## Describes the thing
@export
var description: String

## Store the object path
const object_path : String = "res://assets/objects/%s.tscn"

## Processes the action of this object
func action(weapon: Weapon) -> void:
	# Deal the necessary damage
	attributes.health -= weapon.damage

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
		
