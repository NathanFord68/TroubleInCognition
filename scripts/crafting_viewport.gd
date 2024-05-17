extends Control

class_name CraftingViewport

## The inventory manager so we can check if crafts can be completed
@export
var inventory : InventoryManager

## The crafting order to be send to the manager
##
## quantity: int
## item: recipe
var craft_order : Dictionary

## Stores all recipes for the given craftables
var recipes: Array

## Signals to the crafting manager to begin crafting
signal send_order

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("player_toggle_crafting"):
		if visible:
			visible = false
			get_tree().paused = false
			return
		populate_recipes("hand_craft")
		visible = true
		get_tree().paused = true

func populate_recipes(file_name: String) -> void:
	var file = FileAccess.open("res://scripts/%s.json" % file_name, FileAccess.READ)
	var contents = JSON.parse_string(file.get_as_text())
	
	# weapons
	
	# armor
	
	# common
	
	# buildings
	
func can_craft() -> bool:
	return false
