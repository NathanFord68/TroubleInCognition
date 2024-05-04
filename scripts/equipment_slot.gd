extends PanelContainer

class_name EquipmentSlot

## The item in this slot
@export 
var item : Item

## The type of items this slot allows
@export var allowed_type : Enums.ITEM_TYPE

# Called when the node enters the scene tree for the first time.
func _ready():
	update_icon()
		
func update_icon():
	if is_instance_valid(item):
		$Item.texture = load(item.icon)
		return
	$Item.texture = null

func _get_drag_data(at_position: Vector2):
	set_drag_preview(make_drag_preview())
	return self
	
func make_drag_preview():
	var t := TextureRect.new()
	t.texture = $Item.texture
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.custom_minimum_size = size
	return t

func _can_drop_data(at_position, data):
	if allowed_type == Enums.ITEM_TYPE.MAIN:
		return true
		
	if allowed_type != data.item.type:
		return false
	return true
	
func _drop_data(at_position : Vector2, data : Variant):
	# Update my information
	item = data.item
	update_icon()
	
	# Update the senders information
	data.item = null
	data.update_icon()
