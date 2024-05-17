extends PanelContainer

class_name EquipmentSlot

## The item in this slot
@export
var quantity : int

@export 
var item : ItemBase

## The type of items this slot allows
@export 
var allowed_type : Enums.ITEM_TYPE

## The root of the inventory viewport
@export
var inventory_root : Control

# Called when the node enters the scene tree for the first time.
func _ready():
	update_icon()

func update_label():
	( get_node("Count") as Label ).text = "" if quantity == 0 or quantity == 1 else str(quantity)

## Updates the icon for this slot
func update_icon():
	update_label()
	if !is_instance_valid(item):	
		$Item.texture = null
		return
		
	var item_size : Vector2 = (item.get_node("CollisionShape2D") as CollisionShape2D).shape.get_rect().size + Vector2(6, 6)
	var final_img = Image.create(item_size.x, item_size.y, false,Image.FORMAT_RGBA8)
	
	# TODO refactor this so it's not nested so deep
	for child : Sprite2D in item.get_node("Sprite").get_children():
		var img = child.texture.get_image()
		final_img.blend_rect(img, Rect2(
			32 - (item_size.x / 2), 
			32 - (item_size.y / 2), 
			item_size.x, 
			item_size.y), Vector2(0, 0))
		if child.self_modulate != Color(1, 1, 1, 1):
			for x in range(0, item_size.x):
				for y in range(0, item_size.y):
					if final_img.get_pixel(x, y) == Color(1, 1, 1, 1):
						final_img.set_pixel(x, y, child.self_modulate)
		
	
	$Item.texture = ImageTexture.create_from_image(final_img)
	return	


func _get_drag_data(_at_position: Vector2):
	set_drag_preview(make_drag_preview())
	return self
	
func make_drag_preview():
	var t := TextureRect.new()
	t.texture = $Item.texture
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.custom_minimum_size = size
	return t

func is_empty() -> bool:
	return quantity == 0

func _can_drop_data(_at_position, data):
	if allowed_type == Enums.ITEM_TYPE.MAIN:
		return true
		
	if allowed_type != data.item.type:
		return false
	return true
	
func _drop_data(at_position : Vector2, data : Variant) -> void:
	# If the slot has something not allowed in our slot return
	if ( data.allowed_type != Enums.ITEM_TYPE.MAIN 
		and is_instance_valid(item)
		and item.type != data.allowed_type ):
		return
	
	# Update quantities
	var our_old_quantity = quantity
	quantity = data.quantity
	data.quantity = our_old_quantity
	
	# Update the items
	var our_old_item = item
	item = data.item
	data.item = our_old_item
	
	# Update icons
	update_icon()
	data.update_icon()
	
	
	# Signal that the item has been dropped in this slot
	if not (allowed_type == Enums.ITEM_TYPE.MAIN and data.allowed_type == Enums.ITEM_TYPE.MAIN):
		inventory_root.item_dropped.emit(allowed_type, self)
