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


## Updates the icon for this slot
func update_icon():
	if is_instance_valid(item):
		$Item.texture = load(item.engine_info.icon_path)
		return
	$Item.texture = null

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
	
func _drop_data(at_position : Vector2, data : Variant):
	# If the slot has something not allowed in our slot return
	if ( data.allowed_type != Enums.ITEM_TYPE.MAIN 
		and is_instance_valid(item)
		and item.type != data.allowed_type ):
		return
	
	# Update my information
	item = data.item
	quantity += 1
	update_icon()
	( get_node("Count") as Label ).text = "" if quantity == 0 else str(quantity)
	
	# Update the senders information
	data.quantity -= 1
	if data.quantity == 0:
		data.item = null
		data.update_icon()
	( data.get_node("Count") as Label ).text = "" if data.quantity == 0 else str(data.quantity)
	
	var t = %InventoryViewportRootChild
	# Signal that the item has been dropped in this slot
	inventory_root.item_dropped.emit(allowed_type, self)
