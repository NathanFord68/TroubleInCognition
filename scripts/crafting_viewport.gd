extends Control

class_name CraftingViewport

## What item is selected
var selected_item : Dictionary

## How many are we making
var craft_quantity : int

## The inventory manager so we can check if crafts can be completed
var inventory_manager : InventoryManager

## Signals to the crafting manager to begin crafting
signal start_crafting

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("player_toggle_crafting"):
		if visible:
			visible = false
			get_tree().paused = false
			return
		populate_crafting_list("hand_craftable.json")
		visible = true
		get_tree().paused = true

func populate_crafting_list(file_name: String):
	var file = FileAccess.open("res://scripts/%s" % file_name, FileAccess.READ)
	var contents = JSON.parse_string(file.get_as_text())
	
	# weapons
	
	# armor
	
	# common
	
	# buildings

## Signal to start the crafting process
func _on_craft_button_pressed() -> void:
	for item_name in selected_item.recipe.keys():
		if inventory_manager.total_item_count[item_name] < selected_item.recipe[item_name] * craft_quantity:
			return
	start_crafting.emit()
