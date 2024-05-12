extends Node

class_name Importer

const object_base_path: String = "res://resource_importer/object_base.tscn"
const object_path: String = "res://assets/objects/%s"

func _ready():
	# Get the checksum from the last time we ran the importer
	var json_checksum = FileAccess.get_md5("res://resource_importer/assets.json")
	
	var checksum_json = __get_checksum_json()
	
	# If the checksum is different, import the assets
	if "json" not in checksum_json or checksum_json["json"] != json_checksum:
		var import_successful = __import_assets()
		if not import_successful:
			return
		
		# Get the json again, as it will have changed during the import
		checksum_json = __get_checksum_json()
		
	
	# Write back to checksum file to update to new checksum
	__write_checksum_json("json", json_checksum, checksum_json)
	
	get_tree().quit()
	
func __import_assets() -> bool:
	# Get the file
	var file = FileAccess.open("res://resource_importer/assets.json", FileAccess.READ)
	var checksum_json = __get_checksum_json()
	var diff = []

	# Open the file
	var content = file.get_as_text()

	# Read json and parse to array
	var assets = JSON.parse_string(content)
	
	# Interate through array. 
	var n
	for a in assets:
		if a.name in checksum_json and a.hash() == checksum_json[a.name]:
			continue

		match a.type:
			_:
				if a.name in checksum_json and a.hash() != checksum_json[a.name]:
					n = update_item(a)
					print_rich("[color=yellow]Updated %s[/color]" % a.name)
					checksum_json = __write_checksum_json(a.name, a.hash(), checksum_json)
				else:
					n = generate_object(a)
				
		var packed_scene = PackedScene.new()
		var pack_error = packed_scene.pack(n)
		if pack_error != OK:
			print(pack_error)
			return false
		var save_error = ResourceSaver.save(
			packed_scene, 
			object_path % a.engine_info.asset_path
		)
		if save_error != OK:
			print(save_error)
			return false
		diff.push_back(a.name)
		checksum_json = __write_checksum_json(a.name, a.hash(), checksum_json)
	__write_diff_file(diff)
	return true

## Updates an existing item
func update_item(data: Dictionary) -> Node:
	var n = load(object_path % data.engine_info.asset_path).instantiate()
	
	var components = __write_components(n, data)
	
	__write_sprites(n, data)
	
	match data.type:
		"WEAPON":
			__write_weapon_data(n, data, components)
		"ITEM":
			__write_item_data(n, data, components)
		"HARVEST":
			__write_harvest_data(n, data, components)
		_:
			pass
	return n

## Generates a new game object
func generate_object(data: Dictionary) -> Node:
	# Instantiate and name Item Base
	var n = preload(object_base_path).instantiate()
	n.name = data.name
	
	var components = __write_components(n, data)
	
	# Define the sprites
	__write_sprites(n, data)
	
	# Define and Attach the item script
	match data.type:
		"HARVEST":
			n.set_script(load("res://scripts/harvest_node.gd"))
			__write_harvest_data(n, data, components)
		"WEAPON":
			n.set_script(load("res://scripts/weapon.gd"))
			__write_weapon_data(n, data, components)
		"ITEM":
			n.set_script(load("res://scripts/item.gd"))
			__write_item_data(n, data, components)
		_:
			pass
	return n
	

func __generate_harvest_node(data: Dictionary) -> Node:
	return null

## Converts json damage type to our Enum damage type
func __get_damage_type(t : String) -> Enums.DAMAGE_TYPE:
	match t :
		"MELEE": return Enums.DAMAGE_TYPE.MELEE
		"RANGE": return Enums.DAMAGE_TYPE.RANGE
		_: return Enums.DAMAGE_TYPE.MAGIC

## Gets the check sums from the checksum file
func __get_checksum_json() -> Dictionary:
	var checksum_file_read = FileAccess.open("res://resource_importer/checksum.json", FileAccess.READ)
	var checksum_content = checksum_file_read.get_as_text()
	return JSON.parse_string(checksum_content)

## Updates the checksum file, overwrites the old
func __write_checksum_json(param: String, val: Variant, json: Dictionary) -> Dictionary:
	var checksum_file_write = FileAccess.open("res://resource_importer/checksum.json", FileAccess.WRITE)
	json[param] = val
	checksum_file_write.store_string(JSON.stringify(json))
	return json

## Writes out to the diff file, overwrites the old
func __write_diff_file(json: Array) -> void:
	var diff_file = FileAccess.open("res://resource_importer/diff.json", FileAccess.WRITE)
	diff_file.store_string(JSON.stringify(json))

## Creates components for our objects
## BaseAttributes
## EngineInfo
## CollisionShape2D
func __write_components(n: Node, data: Dictionary) -> Dictionary:
	# Define the attributes
	var attributes := n.get_node("BaseAttributes") as BaseAttributes
	attributes.health = data.attributes.health
	attributes.drop_table = data.attributes.drop_table
	attributes.object_name = data.attributes.object_name
	
	# Define the Engine Info
	var engine_info := n.get_node("EngineInfo") as EngineInfo
	engine_info.asset_path = object_path % data.engine_info.asset_path
	engine_info.icon_path = object_path % data.engine_info.icon_path
	
	# Define the collision shape
	var collision := RectangleShape2D.new()
	collision.size = Vector2(data.collision[0], data.collision[1])
	(n.get_node("CollisionShape2D") as CollisionShape2D).shape = collision
	
	return {"attributes": attributes, "engine_info": engine_info, "collision": collision}

## Writes new sprites if the don't exist, and updates the sprite sheet if it does
func __write_sprites(n: Node, data: Dictionary) -> void:
	var sprite := n.get_node("Sprite") as Node2D
	for s : String in data.sprites:
		# Update if the sprite already exists
		if is_instance_valid(sprite.get_node(s)):
			sprite.get_node(s).texture = load(object_path % "%s.png" % s)
			continue
		
		# Create a new sprite if the sprite does not
		var m = Sprite2D.new()
		m.texture = load(object_path % "%s.png" % s)
		m.name = s
		sprite.add_child(m, true)
		m.owner = n
	
	if is_instance_valid(sprite.get_node("%s_icon" % data.name)):
		sprite.get_node("%s_icon" % data.name).texture = load(object_path % data.engine_info.icon_path)
		return
	var icon = Sprite2D.new()
	icon.texture = load(object_path % data.engine_info.icon_path)
	icon.name = "%s_icon" % data.name
	sprite.add_child(icon)
	icon.owner = n

func __write_weapon_data(n: Node, data: Dictionary, components: Dictionary) -> void:
	n.weapon_reach = data.weapon.weapon_reach
	n.can_action_with = data.weapon.can_action_with
	n.damage_type = __get_damage_type(data.weapon.damage_type)
	n.damage = data.weapon.damage
	n.min_damage = data.weapon.min_damage
	n.is_two_handed = data.weapon.is_two_handed
	n.type = Enums.ITEM_TYPE.PRIMARY
	n.recipe = data.recipe
	n.engine_info = components.engine_info
	n.attributes = components.attributes

func __write_harvest_data(n: Node, data: Dictionary, components: Dictionary) -> void:
	n.engine_info = components.engine_info
	n.attributes = components.attributes

func __write_item_data(n: Node, data: Dictionary, components: Dictionary) -> void:
	n.engine_info = components.engine_info
	n.attributes = components.attributes
