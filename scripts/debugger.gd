extends Node

## Draws a line shape to visualize ray cast
static func visualize_ray_cast(start: Vector2, end: Vector2, n: Node = null) -> void:
	if is_instance_valid(n.get_node("RayCast")):
		n.get_node("RayCast").points = [start, end]
		return
	
	var line_node = Line2D.new()
	line_node.name = "RayCast"
	line_node.points = [start, end]
	line_node.width = 2
	line_node.top_level = true
	n.add_child(line_node)

## Draws a circle to visualize point casts
static func visualize_point(point: Vector2) -> void:
	pass
