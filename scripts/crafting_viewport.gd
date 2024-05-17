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

func _ready() -> void:
	populate_recipes("hand_craft")
	_on_tab_container_tab_clicked(0)
	

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
	for key in craft_order.item.recipe.keys():
		mats.push_back({
			"required": craft_order.item.recipe[key] * craft_order.quantity,
			"name": key
		})
	
	# For each mat, check the inventory
	for mat in mats: 
		if mat.name not in inventory.total_item_count or inventory.total_item_count[mat.name] < mat.required:
			return false # short the method out and return false
	
	# Return true by default
	return true


## Updates the Object list with the current selected tab of items
func _on_tab_container_tab_clicked(tab):
	# Create new list of items that we can craft based off tab
	var list = load("res://assets/objects/craft_list.tscn").instantiate()
	for item in recipes[__convert_tab_to_string(tab)]:
		var b := load("res://assets/objects/craft_item_button.tscn").instantiate() as Button
		b.text = item.name
		b.item = item
		b.send_button_was_pressed.connect(__update_ui_on_item_button_pressed)
		list.add_child(b)
	
	# Queue free the old list
	if %ItemListScene.get_child_count() == 2:
		%ItemListScene.get_child(1).queue_free()
		
	# Attach the new list
	%ItemListScene.add_child(list)
	pass

func __convert_tab_to_string(tab: int) -> String:
	match tab:
		0: return "weapon"
		1: return "armor"
		2: return "common"
		3: return "building"
	return ""

func __update_ui_on_item_button_pressed(item: Dictionary):
	craft_order = {
		"quantity": 1,
		"item": item
	}
	if can_craft():
		send_order.emit(craft_order)
