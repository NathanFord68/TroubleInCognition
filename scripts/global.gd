extends Node

const IMAGE_EDGE_BUFFER_AMOUNT : int = 6

## Draws a line shape to visualize ray cast
func visualize_ray_cast(start: Vector2, end: Vector2, n: Node = null) -> void:
	if is_instance_valid(n) and n.has_node("RayCast"):
		n.get_node("RayCast").points = [start, end]
		return
	
	var line_node = Line2D.new()
	line_node.name = "RayCast"
	line_node.points = [start, end]
	line_node.width = 2
	line_node.top_level = true
	n.add_child(line_node)

## Draws a circle to visualize point casts
func visualize_point(point: Vector2) -> void:
	print(point)

func generate_image_texture_from_scene(s: Node) -> ImageTexture:
	# Return an image texture if there is already an image
	if FileAccess.file_exists("res://assets/resources/%s.png" % s.attributes.object_name):
		return ImageTexture.create_from_image(Image.load_from_file("res://assets/resources/%s.png" % s.attributes.object_name))
	
	# Get the size of the new image
	var item_size : Vector2 = (s.get_node("CollisionShape2D") as CollisionShape2D).shape.get_rect().size
	item_size.x = max(item_size.x, item_size.y)
	item_size.y = max(item_size.x, item_size.y)
	item_size += Vector2(IMAGE_EDGE_BUFFER_AMOUNT, IMAGE_EDGE_BUFFER_AMOUNT)
	
	# Create the canvas
	var final_img = Image.create(int(item_size.x), int(item_size.y), false, Image.FORMAT_RGBA8)
	
	# Apply sprites to canvas
	for child : Sprite2D in s.get_node("Sprite").get_children():
		__apply_sprite_to_image(final_img, child, item_size)
	
	final_img.save_png("res://assets/resources/%s.png" % s.attributes.object_name)
	# Generate and return the texture
	return ImageTexture.create_from_image(final_img)

## Apply the texture of the sprite to the image
## 
## This method assumes the sprite is 64X64 and will re-color the image if 
## it detects that the self_modulate is not default
func __apply_sprite_to_image(final_img: Image, sprite: Sprite2D, img_size: Vector2) -> void:
	# Get the image
	var img = sprite.texture.get_image()
	# Blend the texture into the final image
	final_img.blend_rect(img, Rect2(
		32 - (img_size.x / 2), 
		32 - (img_size.y / 2), 
		img_size.x, 
		img_size.y), Vector2(0, 0))
		
	# Pass it to the coloring if the self_modulate is not default
	# A non default modulate suggests rendering different color but the
	# texutre is not effected which is why we need to pass it here
	if sprite.self_modulate != Color(1, 1, 1, 1):
		__apply_color_to_final_image(final_img, img_size, sprite.self_modulate)

## Apply the color to canvas pixels
##
## This method assumes canvas pixels are (1, 1, 1, 1)
## This is a result of self_modulate not modifying the image itself.
func __apply_color_to_final_image(final_img: Image, img_size: Vector2, color: Color) -> void:
	for x in range(0, img_size.x):
		for y in range(0, img_size.y):
			if final_img.get_pixel(x, y) == Color(1, 1, 1, 1):
				final_img.set_pixel(x, y, color)
