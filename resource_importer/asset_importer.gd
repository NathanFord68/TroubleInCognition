extends Node

class_name Importer

const item_base_path: String = "res://resource_importer/item_base.tscn"
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
				n = __generate_item(a)
				
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

func __generate_item(data: Dictionary) -> Node:
	# Instantiate and name Item Base
	var n = preload(item_base_path).instantiate()
	n.name = data.name
	
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
	
	# Define the sprites
	var sprite := n.get_node("Sprite") as Node2D
	for s : String in data.sprites:
		var m = Sprite2D.new()
		m.texture = load(object_path % "%s.png" % s)
		m.name = s
		sprite.add_child(m, true)
		m.owner = n
	
	var icon = Sprite2D.new()
	icon.texture = load(object_path % data.engine_info.icon_path)
	icon.name = "%s_icon" % data.name
	sprite.add_child(icon)
	icon.owner = n
	
	# Define and Attach the item script
	match data.type:
		"WEAPON":
			n.set_script(load("res://scripts/weapon.gd"))
			n.weapon_reach = data.weapon.weapon_reach
			n.can_action_with = data.weapon.can_action_with
			n.damage_type = __get_damage_type(data.weapon.damage_type)
			n.damage = data.weapon.damage
			n.min_damage = data.weapon.min_damage
			n.is_two_handed = data.weapon.is_two_handed
			n.type = Enums.ITEM_TYPE.PRIMARY
			n.recipe = data.recipe
			n.engine_info = engine_info
			n.attributes = attributes
		"ITEM":
			pass
		_:
			pass
	return n
	

func __generate_harvest_node(data: Dictionary) -> Node:
	return null

func __get_damage_type(t : String) -> Enums.DAMAGE_TYPE:
	match t :
		"MELEE": return Enums.DAMAGE_TYPE.MELEE
		"RANGE": return Enums.DAMAGE_TYPE.RANGE
		_: return Enums.DAMAGE_TYPE.MAGIC

func __get_checksum_json() -> Dictionary:
	var checksum_file_read = FileAccess.open("res://resource_importer/checksum.json", FileAccess.READ)
	var checksum_content = checksum_file_read.get_as_text()
	return JSON.parse_string(checksum_content)

func __write_checksum_json(param: String, val: Variant, json: Dictionary) -> Dictionary:
	var checksum_file_write = FileAccess.open("res://resource_importer/checksum.json", FileAccess.WRITE)
	json[param] = val
	checksum_file_write.store_string(JSON.stringify(json))
	return json

func __write_diff_file(json: Array) -> void:
	var diff_file = FileAccess.open("res://resource_importer/diff.json", FileAccess.WRITE)
	diff_file.store_string(JSON.stringify(json))
