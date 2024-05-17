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
var recipes: Dictionary

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
	# Get the file contents
	var file = FileAccess.open("res://scripts/%s.json" % file_name, FileAccess.READ)
	
	# Assign to recipes
	recipes = JSON.parse_string(file.get_as_text())
	
func can_craft() -> bool:
	# Get list of required mats
	var mats = []
	for key in craft_order.recipe.keys():
		mats.push_back({
			"required": craft_order.recipe[key] * craft_order.quantity,
			"name": key
		})
	
	# For each mat, check the inventory
	for mat in mats: 
		if inventory.total_item_count[mat.name] < mat.required:
			return false # short the method out and return false
	
	# Return true by default
	return true
