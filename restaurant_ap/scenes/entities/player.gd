class_name Player extends CharacterBody2D

enum STATE {STATE_IDLE, STATE_MOVING, STATE_WORKING}
var current_state:STATE = STATE.STATE_IDLE

var speed = 600.0
var target_position: Vector2 = Vector2(1500.0,1000.0)
@onready var navigation_agent:NavigationAgent2D = $NavigationAgent2D

var held_food:Food

func _ready():
	navigation_agent.path_desired_distance = 40.0
	navigation_agent.target_desired_distance = 20.0
	target_position = position
	actor_setup.call_deferred()
	
	spawn_food()

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(target_position)

func set_movement_target(movement_target: Vector2):
	current_state = STATE.STATE_MOVING
	navigation_agent.target_position = movement_target

func _physics_process(_delta: float) -> void:
	#direct_movement()
	if navigation_agent.is_navigation_finished():
		current_state = STATE.STATE_IDLE
		return
	
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	
	velocity = current_agent_position.direction_to(next_path_position) * speed
	#$Label.set_text(str(navigation_agent.distance_to_target()))
	
	move_and_slide()

# overwrites current food, if any
func spawn_food():
	if held_food and get_children().has(held_food):
		remove_child(held_food)
	
	held_food = Food.new()
	add_child(held_food)
	held_food.set_z_index(1)
	held_food.set_position(Vector2(0, -320))


func stack_food(ingredient:IngredientData):
	held_food.show()
	held_food.add_stack(ingredient)
	pass

func swap_food(location:FoodStorage):
	var old_food:Food = held_food
	remove_child(held_food)
	
	held_food = location.current_food
	location.current_food = old_food
	
	if !held_food:
		spawn_food()
	else:
		add_child(held_food)
	

func serve_food(customer:Customer):
	customer.served_food = held_food
	spawn_food()
	customer.on_interact()






# probably going to be unused but just in case... put in physics process  
func direct_movement():
	var direction := Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
	if direction:
		velocity = direction * speed
	else:
		velocity = Vector2(0, 0)
	move_and_slide()
