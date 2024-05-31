extends CharacterBody2D

## Handles player interaction
class_name Player

## Controls the actor and it's animations
@export
var controller : Controller

## Stats of the player
@export
var stats : Stats

## Attributes of the player
@export
var attributes : EnhancedAttributes

## Engine specific information about the player
@export
var engine_info : EngineInfo

## Manages our inventory
@export
var inventory_manager : InventoryManager

## Manages our crafting stuff
@export
var crafting_manager : CraftingManager

## Holds references to items the player has equipped
@export 
var equipment_manager : EquipmentManager

## Tracks if we pressed the primary action mouse button
var is_primary_action_pressed : bool = false

## Tracks building information
var is_in_build_mode: bool
var building_to_place: StaticBody2D

## Tracks external forces being applied to us
var acting_force : Vector2

func _ready() -> void:
	controller.animation_tree = $AnimationTree
	controller.animation_player = $AnimationPlayer
	controller.owner = self
	
	inventory_manager.inventory_viewport = $PlayerViewport/InventoryViewport
	inventory_manager.equipment = $Equipment
	inventory_manager.initialize_backpack()
	
	( $PlayerViewport/CraftingViewport as CraftingViewport).inventory = inventory_manager
	crafting_manager.inventory = inventory_manager
	crafting_manager.crafting_viewport = $PlayerViewport/CraftingViewport
	crafting_manager.owner = self
	crafting_manager.initialize_crafting_manager()
	
	inventory_manager.send_item_did_equip.connect(equipment_manager.set_equipment_item)
	inventory_manager.send_item_did_remove_equip.connect(equipment_manager.remove_equipment)
	
	$PlayerViewport/InventoryViewport.enter_build_mode.connect(handle_enter_build_mode)
	
	
func _input(event) -> void:
	if event is InputEventMouseButton and event.button_index == 1:
		is_primary_action_pressed = event.pressed
		
	if event is InputEventMouseButton and event.button_index == 4:
		var zoom = clamp($Camera2D.zoom.x + .05, 1.5, 3)
		$Camera2D.zoom = Vector2(zoom, zoom)
		
	if event is InputEventMouseButton and event.button_index == 5:
		var zoom = clamp($Camera2D.zoom.x - .05, 1.5, 3)
		$Camera2D.zoom = Vector2(zoom, zoom)
		
	
func _physics_process(delta) -> void:
	if not can_physics_process():
		return

	if Input.is_action_pressed("player_interact"):
		controller.handle_interact(get_target(attributes.base_reach))
	
	if Input.is_action_just_pressed("player_escape"):
		handle_player_escape_input()
	
	if is_primary_action_pressed:
		__handle_primary_mouse_pressed()
	
	if is_in_build_mode:
		building_to_place.global_position = get_global_mouse_position()
	
	# Movement
	controller._maneuver(Vector2(
		Input.get_axis("player_left", "player_right") * attributes.speed,
		Input.get_axis("player_up", "player_down") * attributes.speed
	), acting_force)
	
	# Crafting
	if not crafting_manager.is_crafting and crafting_manager.orders.size() > 0:
		crafting_manager.handle_craft_item()

	move_and_collide(velocity * delta)
	#move_and_slide()

func handle_enter_build_mode(building: StaticBody2D):
	# Enter build mode
	is_in_build_mode = true
	
	# Setup the building to place
	building_to_place = building
	for sprite : Sprite2D in building_to_place.get_node("Sprite").get_children():
		sprite.self_modulate = Color(0, 125, 125, 150)
	building_to_place.set_collision_layer_value(16, true)
	building_to_place.set_collision_layer_value(1, false)
	add_child(building_to_place)
	
	# Turn the viewport off
	$PlayerViewport/InventoryViewport.visible = false
	
	
## Checks to make sure everything the physics process will need has been instantiated
func can_physics_process() -> bool:
	if not is_instance_valid(attributes):
		return false
	return true

## Processes the action of this object
func action(weapon: Node) -> void:
	# Apply the damage
	attributes.health -= weapon.damage
	
	if attributes.health <= 0:
		queue_free()

func apply_force(
	direction: Vector2,
	strength: float,
	time: float,
	is_continuous: bool
):
	# Apply the force
	acting_force = direction * strength
	if is_continuous:
		return
	
	await get_tree().create_timer(time).timeout
	acting_force = Vector2()
	
func interact() -> void:
	pass

## Gets the target the player is trying to interact with
func get_target(reach_range : float) -> Node:
	var p_hit = point_to_mouse()
	
	if Env.mode == Enums.MODE.DEV:
		var click_normalized : Vector2 = global_position.direction_to(get_global_mouse_position())
		var end = global_position + (click_normalized * reach_range )
		Global.visualize_ray_cast(global_position, end, self)
		
	if not is_instance_valid(p_hit):
		return null
		
	if global_position.distance_to(p_hit.global_position) > reach_range:
		return null
		
	return p_hit

## Ray traces to the mouse position from the player
func trace_to_mouse(reach_range: float) -> Node:
	# Normalize to mouse position
	var click_normalized : Vector2 = global_position.direction_to(get_global_mouse_position())
	
	# Get world space physics
	var space = get_world_2d().direct_space_state
	
	# Create the query
	var end = global_position + (click_normalized * reach_range )
	var query = PhysicsRayQueryParameters2D.create(global_position, end)
	query.exclude = [self]
	
	# Cast the query
	var hit = space.intersect_ray(query)
	
	# Visualize if true
	if Env.mode == Enums.MODE.DEV:
		Global.visualize_ray_cast(global_position, end, self)
	
	# Return collider if hit
	if "collider" in hit:
		return hit.collider
	
	return null

## Point trace at the mouse position
func point_to_mouse() -> Node:
	# Get world space physics
	var space = get_world_2d().direct_space_state
	
	# Create query
	var query = PhysicsPointQueryParameters2D.new()
	query.exclude = [ self ]
	query.position = get_global_mouse_position()
	
	# Cast the query
	var hit = space.intersect_point(query)
	
	# Return hit objects
	if hit.size() > 0:
		return hit[0].collider
	
	return null

## Handle the placement of the building in the world
func handle_place_build() -> void:
	# Instantiate new instance of the thing we are crafting
	var building_that_can_place = load(building_to_place.engine_info.asset_path).instantiate()
	building_that_can_place.global_position = get_global_mouse_position()
	# Attach to tree
	get_tree().root.add_child(building_that_can_place)
	
	# Remove from inventory
	inventory_manager.remove_from_inventory(building_to_place.attributes.object_name, 1)
	
	is_primary_action_pressed = false
	
	# Check if we are out of the item
	if inventory_manager.total_item_count[building_to_place.attributes.object_name] <= 0:
		# Queue free the current selected building
		building_to_place.queue_free()
		is_in_build_mode = false
	
func can_handle_place_build() -> bool:
	return true

func handle_player_escape_input() -> void:
	var mode = "continue"
	for vp in $PlayerViewport.get_children():
		if vp.visible:
			vp.visible = false
			mode = "finished"
	if mode == "continue" and is_in_build_mode == true:
		mode = "finished"
		remove_child(building_to_place)
		building_to_place = null
		is_in_build_mode = false
	if mode == "continue":
		print_debug("Open the menu")

func __get_weapon_reach() -> float:
	if Enums.ITEM_TYPE.PRIMARY in equipment_manager.equipment and is_instance_valid(equipment_manager.equipment[Enums.ITEM_TYPE.PRIMARY]):
		return equipment_manager.equipment[Enums.ITEM_TYPE.PRIMARY].weapon_reach
	return -1

func __handle_primary_mouse_pressed() -> void:
	if is_in_build_mode:
		handle_place_build()
		return
	var reach = __get_weapon_reach()
	if reach == -1:
		return
	controller._handle_action(get_target(reach))
