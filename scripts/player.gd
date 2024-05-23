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

var is_action_pressed : bool = false

var acting_force : Vector2

func _ready() -> void:
	controller.resource_owner = self # TODO get rid of this
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
	
	inventory_manager.send_item_equipped.connect(equipment_manager.set_equipment_item)
	inventory_manager.send_item_unequpped.connect(equipment_manager.remove_equipment)
	
	
func _input(event) -> void:
	if event is InputEventMouseButton and event.button_index == 1:
		is_action_pressed = event.pressed
	
func _physics_process(_delta) -> void:
	if not can_physics_process():
		return 
	if Input.is_action_just_pressed("dev_debug"):
		inventory_manager.debug_print()
	
	if Input.is_action_just_pressed("player_interact"):
		controller.handle_interact(get_target(attributes.base_reach))
	
	if is_action_pressed:
		__handle_primary_mouse_pressed()
	
	
	# Movement
	controller._maneuver(Vector2(
		Input.get_axis("player_left", "player_right") * attributes.speed,
		Input.get_axis("player_up", "player_down") * attributes.speed
	), acting_force)
	
	# Crafting
	if not crafting_manager.is_crafting and crafting_manager.orders.size() > 0:
		crafting_manager.handle_craft_item()

	move_and_slide()

## Checks to make sure everything the physics process will need has been instantiated
func can_physics_process() -> bool:
	if not is_instance_valid(attributes):
		return false
	return true

## Processes the action of this object
func action(
	weapon: Node, 
	force_direction: Vector2 = Vector2(), 
	force_time : float = 0, 
	is_force_continuous : bool= false) -> void:
	
	# Apply the damage
	attributes.health -= weapon.damage
	
	if attributes.health <= 0:
		queue_free()
	# Return if there is no force to apply
	if force_time == 0:
		return
	
	# Apply the force
	acting_force = force_direction * weapon.knock_back_strength
	if is_force_continuous:
		return
	
	await get_tree().create_timer(force_time).timeout
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

func __get_weapon_reach() -> float:
	if Enums.ITEM_TYPE.PRIMARY in equipment_manager.equipment:
		return equipment_manager.equipment[Enums.ITEM_TYPE.PRIMARY].weapon_reach
	return -1

func __handle_primary_mouse_pressed() -> void:
	var reach = __get_weapon_reach()
	if reach == -1:
		return
	controller.handle_action(get_target(reach))
