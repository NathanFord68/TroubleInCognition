extends Node

## Draws a line shape to visualize ray cast
func visualize_ray_cast(start: Vector2, end: Vector2) -> void:
	if is_instance_valid(get_node("PlayerRayCast")):
		get_node("PlayerRayCast").points = [start, end]
		return
	
	var line_node = Line2D.new()
	line_node.name = "PlayerRayCast"
	line_node.points = [start, end]
	line_node.width = 2
	line_node.top_level = true
	add_child(line_node)

## Draws a circle to visualize point casts
func visualize_point(point: Vector2) -> void:
	pass
