class_name Customer extends CharacterBody2D

signal customer_left(them:Customer)
signal table_reached(them:Customer)
signal left_table(them:Customer)
signal order_thought(them:Customer)
signal order_given(them:Customer)
signal order_completed()

enum STATE {STATE_IDLE, STATE_MOVING, STATE_READING, 
# idle: not seated yet, waiting. unhappy timer
# moving: walking to/from table
# reading: reading the menu, not interactable
			STATE_ORDERING, STATE_SITTING, STATE_EATING}
# ordering: waiting for order to be taken. unhappy timer
# sitting: waiting for food to arrive. unhappy timer
# eating: nom food

enum FOOD_SCORE {SCORE_BAD = -1, SCORE_NEUTRAL = 0, SCORE_GREAT = 1}

var time_modifier = 1.0

var current_state:STATE = STATE.STATE_IDLE
var leaving:bool = false
var requested_food:Food = null
var served_food:Food = null

var door_pos:Vector2 = Vector2(2050.0, 500.0)

var spawn_position:Vector2 = Vector2(2050.0, 500.0)
var speed:float = 400.0 * 1.5
var target_position:Vector2 = Vector2(100.0, 1000.0)
@onready var navigation_agent:NavigationAgent2D = NavigationAgent2D.new()

@export var thought:ThoughtBubble
@export var data:CustomerData
var customer_id:int = -1
var party_id:int = -1

# probably replace this with an animated one later
@onready var sprite_top:AnimatedSprite2D = AnimatedSprite2D.new()
@onready var sprite_bottom:AnimatedSprite2D = AnimatedSprite2D.new()

# value from 0 to 1, basically percent
@export_range(0, 1, 0.01) var happiness:float = 0.6
# whether decay is happening
var unhappy:bool = false
# the happiness meter
@onready var meter:HappinessMeter = load("res://restaurant_ap/scenes/entities/happiness_meter.tscn").instantiate()
var unhappy_timer:SceneTreeTimer

var hovered:bool = false

var table:Table = null
var seat:Seat = null
var table_targeted:bool = false
var action_timer:SceneTreeTimer

func _ready():
	set_global_position(spawn_position)
	
	add_to_group("customer")
	add_child(navigation_agent)
	navigation_agent.path_desired_distance = 30.0
	navigation_agent.target_desired_distance = 15.0
	target_position = position
	actor_setup.call_deferred()
	
	add_child(sprite_top)
	sprite_top.set_z_index(2)
	add_child(sprite_bottom)
	render_sprite()
	
	add_child(meter)
	meter.set_position(Vector2(60,-190))
	meter.set_z_index(3)
	meter.set_happy(happiness)
	
	thought.mouse_entered.connect(_mouse_enter)
	thought.mouse_exited.connect(_mouse_exit)
	

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	
	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(target_position)

func set_movement_target(movement_target: Vector2):
	change_state(STATE.STATE_MOVING)
	navigation_agent.target_position = movement_target

func _physics_process(_delta: float) -> void:
	if current_state != STATE.STATE_MOVING:
		return
	if navigation_agent.is_navigation_finished():
		if leaving:
			customer_left.emit(self)
		elif table_targeted:
			table_reached.emit(self)
		else:
			change_state(STATE.STATE_IDLE)
		return
	
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	
	velocity = current_agent_position.direction_to(next_path_position) * speed
	
	move_and_slide()

func _process(delta: float) -> void:
	match current_state:
		STATE.STATE_IDLE:
			pass
		STATE.STATE_MOVING:
			# in _physics_process
			pass
		STATE.STATE_READING:
			pass
		STATE.STATE_ORDERING:
			pass
		STATE.STATE_SITTING:
			pass
		STATE.STATE_EATING:
			pass
	
	if unhappy:
		happiness -= data.happiness_decay * delta
	if happiness <= 0 and !leaving:
		leaving = true
		if current_state < STATE.STATE_EATING:
			leave()
		pass
	meter.set_happy(happiness)
	
	pass

func set_data(thing:CustomerData):
	data = thing

func render_sprite():
	if sprite_top and sprite_bottom:
		sprite_top.set_sprite_frames(data.images_top)
		sprite_bottom.set_sprite_frames(data.images_bottom)
		sprite_top.set_position(data.image_offset)
		sprite_bottom.set_position(data.image_offset)
	else: 
		print("no sprites?")

func change_state(state:STATE):
	if state == current_state:
		return
	#print("changing state to ", state)
	set_unhappy(false)
	if unhappy_timer and unhappy_timer.timeout.is_connected(unhappy_timeout):
		unhappy_timer.timeout.disconnect(unhappy_timeout)
	
	match state:
		STATE.STATE_IDLE:
			thought.change_state(thought.STATE.STATE_IDLE)
			add_unhappy_timer(data.unhappy_delay_seating)
		STATE.STATE_MOVING:
			thought.change_state(thought.STATE.STATE_MOVING)
		STATE.STATE_READING:
			thought.change_state(thought.STATE.STATE_READING)
			happiness += 0.1
			action_timer = get_tree().create_timer(5.0 * time_modifier)
			action_timer.timeout.connect(change_state.bind(STATE.STATE_ORDERING))
		STATE.STATE_ORDERING:
			thought.change_state(thought.STATE.STATE_ORDERING)
			order_thought.emit(self)
			add_unhappy_timer(data.unhappy_delay_ordering)
		STATE.STATE_SITTING:
			thought.change_state(thought.STATE.STATE_SITTING)
			order_given.emit(self)
			happiness += 0.1
			add_unhappy_timer(data.unhappy_delay_food + 0.2*requested_food.ingredient_stack.size())
		STATE.STATE_EATING:
			leaving = true
			# judge the food. for now, +0.5
			var judge = judge_food(requested_food, served_food)
			match judge:
				FOOD_SCORE.SCORE_GREAT:
					happiness += 0.5
				FOOD_SCORE.SCORE_NEUTRAL:
					happiness += 0.2
				FOOD_SCORE.SCORE_BAD:
					pass # nothing
			thought.food_rating = judge
			
			table.place_food(self)
			order_completed.emit()
			
			thought.change_state(thought.STATE.STATE_EATING)
			action_timer = get_tree().create_timer(5.0 * time_modifier)
			action_timer.timeout.connect(leave)
	current_state = state
	refresh_sprites()

func add_unhappy_timer(time:float = 5.0):
	unhappy_timer = get_tree().create_timer(time)
	unhappy_timer.timeout.connect(unhappy_timeout)

func unhappy_timeout():
	set_unhappy(true)

func set_unhappy(value:bool):
	unhappy = value

func leave():
	leaving = true
	left_table.emit(self)
	set_movement_target(door_pos)

func is_clickable()-> bool:
	var value = false
	match current_state:
		STATE.STATE_IDLE:
			pass
		STATE.STATE_MOVING:
			pass
		STATE.STATE_READING:
			pass
		STATE.STATE_ORDERING:
			value = true
		STATE.STATE_SITTING:
			value = true
		STATE.STATE_EATING:
			pass
	
	return value

func refresh_sprites():
	match current_state:
		STATE.STATE_IDLE:
			sprite_top.play("default")
			sprite_bottom.play("default")
		STATE.STATE_MOVING:
			sprite_top.play("walking")
			sprite_bottom.play("walking")
		STATE.STATE_READING:
			sprite_top.play("sitting")
			sprite_bottom.play("sitting")
		STATE.STATE_ORDERING:
			sprite_top.play("sitting")
			sprite_bottom.play("sitting")
		STATE.STATE_SITTING:
			sprite_top.play("sitting")
			sprite_bottom.play("sitting")
		STATE.STATE_EATING:
			sprite_top.play("sitting")
			sprite_bottom.play("sitting")


func _mouse_enter() -> void:
	hovered = true
	update_color()
func _mouse_exit() -> void:
	hovered = false
	update_color()

func update_color()->void:
	if is_clickable() and hovered:
		sprite_top.set_modulate(Color(0.224, 0.882, 0.0, 1.0))
		sprite_bottom.set_modulate(Color(0.224, 0.882, 0.0, 1.0))
	else:
		sprite_top.set_modulate(Color(1,1,1))
		sprite_bottom.set_modulate(Color(1,1,1))
		


# called by main scene
func on_click()-> bool:
	return false

# when the player gets over to them
func on_interact():
	match current_state:
		# order is taken
		# ordered food is already generated
		STATE.STATE_ORDERING:
			change_state(STATE.STATE_SITTING)
		
		# food is served
		STATE.STATE_SITTING:
			change_state(STATE.STATE_EATING)

func sit(there:Seat):
	seat = there
	change_state(STATE.STATE_READING)

func target_table(there:Table):
	table = there
	table_targeted = true
	#print(there.get_target())
	set_movement_target(there.get_target())

func set_requested_food(foo:Food):
	requested_food = foo
	#print("food requested: ", foo.ingredient_stack)
	if bad_food(foo):
		happiness -= 0.5
	pass

# checks if the food sucks (>= 50% disliked)
func bad_food(foo:Food)-> bool:
	if data.dislikes.size() <= 0:
		return false
	
	var count:float = 0.0
	
	for ing in foo.ingredient_stack:
		if data.dislikes.has(ing.get_name()):
			count += 1.0
	
	return (count / data.dislikes.size()) > 0.5

func judge_food(base:Food, test:Food)->FOOD_SCORE:
	var result:FOOD_SCORE = FOOD_SCORE.SCORE_NEUTRAL
	
	var score:int = 0
	
	# judge the recipe type
	if test.stack_type != base.stack_type:
		score += -1
	if data.likes.has(test.stack_type):
		score += 1
	if data.dislikes.has(test.stack_type):
		score -= 2
	
	# judge applied ingredients
	for ing in test.ingredient_stack:
		var namae = ing.get_name()
		# liked ingredients: +1
		if data.likes.has(namae) or data.likes.has(test.stack_type + "_" + namae):
			score += 1
		# weird, not liked ingredients: -1
		elif test.is_odd(ing):
			score += -1
		# disliked ingredients: -2
		if data.dislikes.has(namae):
			score += -2
		# incorrect ingredients: -1
		if !base.ingredient_stack.has(ing):
			score += -1
	
	# check for missing ingredients
	for ing in base.ingredient_stack:
		# missing ingredients: -1
		if !test.ingredient_stack.has(ing):
			score += -1
	
	
	if score < 0:
		result = FOOD_SCORE.SCORE_BAD
	if score > 0:
		result = FOOD_SCORE.SCORE_GREAT
	return result
