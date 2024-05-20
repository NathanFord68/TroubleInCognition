extends Control

## Liason of all inventory viewport slots 
class_name InventoryViewport

## Signals from lower to higher that an item was dropped in a slot
signal item_dropped


func _process(_delta):
	if Input.is_action_just_pressed("player_toggle_inventory"):
		if visible:
			visible = false
			get_tree().paused = false
			return
		visible = true
		get_tree().paused = true

## Returns a reference to the backpack from lower
func get_backpack():
	return %Backpack
