class_name CustomerManager extends Node

# gives the points for that customer's happiness
signal customer_left(value:float)

@export var player_manager:PlayerManager = null
@export var order_viewer:OrderViewer = null


var customers:Array[Customer] = []

var tables:Array[Table] = []
var table_max:int = 6
var table_num:int = 6

var ingredient_directory = "res://restaurant_ap/resources/ingredients/"
var customer_directory = "res://restaurant_ap/resources/customers/"
var customer_scene = load("res://restaurant_ap/scenes/entities/customer.tscn")

var ingredients:Dictionary[String, IngredientData] = {}
var current_ingredients:Array[String] = []

var recipes:Dictionary[String, Array] = {}
var current_recipes:Array[String] = []

var customer_data:Dictionary[String, CustomerData] = {}
var current_customer_types:Array[String] = []
var customer_type_timers:Dictionary[String, Timer]

var spawn_timer:Timer
var spawn_interval:float = 36.0
var star_intervals:Array[float] = [36.0, 20.0, 20.0, 16.0, 16.0]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_food_resources()
	load_customer_resources()
	#spawn_customer(customer_data[current_customer_types[0]])
	#print(generate_food().ingredient_stack)
	#print("whitesauce disliked and provalone liked: ")
	#for i in range(0, 10):
	#	print(generate_food().ingredient_stack)
	
	pass # Replace with function body.

func _process(_delta: float) -> void:
	if customers.size() > 0 and tables.size() > 0:
		set_table_targets()

# change to processing AP things
# maybe put AP data in input
func refresh_current(stars:int):
	current_ingredients = ingredients.keys()
	current_recipes = recipes.keys()
	current_customer_types = customer_data.keys()
	spawn_interval = star_intervals[stars-1]


#region FOOD_GENERATION
func load_food_resources():
	var loading = ResourceLoader.list_directory(ingredient_directory)
	#print(loading)
	for path in loading:
		if path.ends_with("/"):
			if !recipes.has(path.trim_suffix("/")):
				recipes[path.trim_suffix("/")] = []
			file_recursion(ingredient_directory + path)
	

func file_recursion(base_path):
	var loading = ResourceLoader.list_directory(base_path)
	#print(loading)
	for path in loading:
		if path.ends_with("/"):
			file_recursion(base_path + path)
		else:
			var ingredient:IngredientData = load(base_path + path)
			if !ingredients.has(ingredient.get_name()):
				ingredients[ingredient.get_name()] = ingredient
	pass




func generate_food(likes:Array[String] = [], dislikes:Array[String] = [], num_extras = -1)->Food:
	var output = Food.new()
	
	var recipe:String = get_random_recipe(likes, dislikes)
	match recipe:
		"pizza":
			output.add_stack(ingredients["plate"])
			output.add_stack(ingredients["pizzacrust"])
			
			# sauces
			var sauce = get_random_ingredient("pizza", "sauce", likes, dislikes)
			if !valid_ingredient(sauce, "pizza", "sauce"):
				print("No valid sauces")
			else:
				output.add_stack(ingredients[sauce])
			
			# cheeses
			var cheese = get_random_ingredient("pizza", "cheese", likes, dislikes)
			if !valid_ingredient(cheese, "pizza", "cheese"):
				print("No valid cheeses")
			else:
				output.add_stack(ingredients[cheese])
			
			# toppings
			if num_extras < 0:
				num_extras = randi_range(0, 2)
			
			var toppings = get_random_ingredients("pizza", "topping", num_extras, likes, dislikes)
			for top in toppings:
				if !valid_ingredient(top, "pizza", "topping"):
					print("No valid toppings")
				else:
					output.add_stack(ingredients[top])
			
	
	
	return output

func valid_ingredient(ing:String, recipe:String, stack:String)->bool:
	if !ingredients[ing].stack_behavior.has(recipe):
		#print(ingredients[ing], " does not define ", recipe)
		return false
	var thing = ingredients[ing].stack_behavior[recipe].trim_suffix("_odd")
	return thing == stack


func get_random_recipe(likes:Array[String] = [], dislikes:Array[String] = [])->String:
	var result:String = ""
	var recipes_arr:Array[String] = recipes.keys()
	recipes_arr.erase("plate")
	
	# filter for only liked ones if possible
	var liked_recipes:Array[String] = intersect_arrays(likes, recipes_arr)
	if liked_recipes.size() > 0:
		recipes_arr = liked_recipes
	
	# remove disliked ones if possible
	var not_disliked_recipes:Array[String] = subtract_arrays(recipes_arr, dislikes)
	if not_disliked_recipes.size() > 0:
		recipes_arr = not_disliked_recipes
	
	result = recipes_arr.pick_random()
	
	return result

# arr1 ∩ arr2
# removes any repeats
func intersect_arrays(arr1, arr2)->Array[String]:
	var result:Array[String] = []
	for i in arr1:
		if arr2.has(i) and !result.has(i):
			result.append(i)
	return result

# arr1 - arr2
# removes any repeats
func subtract_arrays(arr1, arr2)->Array[String]:
	var result:Array[String] = []
	for i in arr1:
		if !arr2.has(i) and !result.has(i):
			result.append(i)
	return result

func get_random_ingredient(recipe:String, type:String, likes:Array[String] = [], dislikes:Array[String] = [])->String:
	var result:String = ""
	var ing_arr:Array[String] = prepare_ingredient_list(recipe, type, likes, dislikes)
	result = ing_arr.pick_random()
	
	return result

func get_random_ingredients(recipe:String, type:String, num:int = 1, likes:Array[String] = [], dislikes:Array[String] = [])->Array[String]:
	var result:Array[String] = []
	var ing_arr:Array[String] = prepare_ingredient_list(recipe, type, likes, dislikes)
	
	if ing_arr.size() < num:
		print("Not enough ", type, " ingredients")
		return result
	
	for _i in num:
		var rand = randi_range(0, ing_arr.size() -1)
		result.append(ing_arr.pop_at(rand))
	
	return result

func prepare_ingredient_list(recipe:String, type:String, likes:Array[String] = [], dislikes:Array[String] = [])->Array[String]:
	var ing_arr:Array[String] = get_current_ingredients()
	ing_arr = get_all_stack_type(recipe, type, ing_arr)
	if ing_arr.size() <= 0:
		print("No ingredients of ", type, " stack type available")
		return []
	
	# filter likes to relevant ones
	# can include odd ones
	var filtered_likes = filter_preferences(recipe, type, likes)
	#print("likes: ", filtered_likes)
	
	# filter for only liked ones if possible
	var liked_ingredients:Array[String] = intersect_arrays(filtered_likes, ing_arr)
	if liked_ingredients.size() > 0:
		ing_arr = liked_ingredients
	
	# filter dislikes to relevant ones
	# can include odd ones
	var filtered_dislikes = filter_preferences(recipe, type, dislikes)
	#print("dislikes: ", filtered_dislikes)
	
	# remove disliked ones if possible
	var not_disliked_ingredients:Array[String] = subtract_arrays(ing_arr, filtered_dislikes)
	if not_disliked_ingredients.size() > 0:
		ing_arr = not_disliked_ingredients
	
	# remove the (non-liked) odd ones if possible
	var not_liked_odd:Array[String] = subtract_arrays(get_odd(recipe), liked_ingredients)
	not_liked_odd = subtract_arrays(ing_arr, not_liked_odd)
	
	return ing_arr


func get_all_stack_type(recipe:String, type:String, list:Array[String])->Array[String]:
	var result:Array[String] = []
	for ingredient in list:
		if valid_ingredient(ingredient, recipe, type):
			result.append(ingredient)
	return result


func filter_preferences(recipe:String, type:String, list:Array[String])->Array[String]:
	var result:Array[String] = []
	
	for thing in list:
		var parts:PackedStringArray = thing.split("_", true)
		if parts.size() <= 0:
			print("(dis)likes have empty string")
			continue
		if parts.size() > 2:
			print("invalid (dis)like format, too many _")
			continue
		
		# there should be exactly 1 or 2 strings
		var first = parts[0]
		var last = parts[-1]
		if !ingredients.has(last):
			# likes include something not on the list.
			# fine, since ingredients will be filtered
			# based on what AP items have been received
			continue
		if !ingredients[last].stack_behavior.has(recipe):
			#print(ingredients[last], " does not define ", recipe)
			continue
		
		# ingredient is always last
		var stack = ingredients[last].stack_behavior[recipe]
		stack = stack.trim_suffix("_odd")
		
		# if recipe is not included
		if parts.size() == 1 and (stack == type):
			result.append(first)
		# if recipe is included
		elif parts.size() == 2 and (stack == type) and (recipe == first):
			result.append(last)
	
	return result

func get_odd(recipe:String)->Array[String]:
	var result:Array[String] = []
	
	for ing in ingredients:
		var data:IngredientData = ingredients[ing]
		if !data.stack_behavior.has(recipe):
			#print(data, " does not define ", recipe)
			continue
		var stack = data.stack_behavior[recipe]
		if stack.right(4) == "_odd":
			result.append(ing)
	
	return result


func get_current_ingredients()->Array[String]:
	return current_ingredients
func get_current_recipes()->Array[String]:
	return current_recipes

func add_recipe(namae:String):
	if recipes.has(namae) and !current_recipes.has(namae):
		current_recipes.append(namae)
func add_ingredient(namae:String):
	if ingredients.has(namae) and !current_ingredients.has(namae):
		current_ingredients.append(namae)


#endregion

#region CUSTOMER_SPAWNING
func load_customer_resources():
	var loading = ResourceLoader.list_directory(customer_directory)
	#print(loading)
	for path in loading:
		if path.ends_with(".tres"):
			var customer:CustomerData = load(customer_directory + path)
			if !customer_data.has(customer.get_name()):
				customer_data[customer.get_name()] = customer
				
				var timer = Timer.new()
				timer.set_wait_time(customer.spawn_gap)
				timer.set_one_shot(true)
				customer_type_timers[customer.get_name()] = timer
				add_child(timer)
				#timer.start()
	

func get_seating():
	tables.clear()
	var teeburu = get_tree().get_nodes_in_group("table")
	for node in teeburu:
		if node is Table:
			tables.append(node)
			node.table_emptied.connect(d)
	

func get_open_tables()-> Array[Table]:
	var result:Array[Table] = []
	for table in tables:
		if table.available:
			result.append(table)
	return result

func get_seat_count()-> int:
	var result:int = 0
	for i in tables:
		result += i.slots
	return result


func spawn_timer_setup():
	spawn_timer = Timer.new()
	spawn_timer.timeout.connect(customer_spawn_check)
	spawn_timer.set_wait_time(spawn_interval)
	add_child(spawn_timer)
	spawn_timer.start(spawn_interval)
	customer_spawn_check()


func customer_spawn_check():
	if customers.size() > get_seat_count():
		return
	
	var spawnable = get_spawnable_customers()
	if spawnable.size() > 0:
		var spawn = spawnable.pick_random()
		spawn_customer(customer_data[spawn])
		customer_type_timers[spawn].start()
	#spawn_customer(customer_data[current_customer_types[0]])

func get_spawnable_customers()->Array[String]:
	var result:Array[String] = []
	for type in current_customer_types:
		var data:CustomerData = customer_data[type]
		
		# check for duplicates of unique customers
		if data.unique:
			var dupe:bool = false
			for i in customers:
				if i.data == data:
					dupe = true
					continue
			if dupe:
				continue
		
		if customer_type_timers.has(type):
			var timer = customer_type_timers[type]
			if timer and timer.is_stopped():
				result.append(type)
		
	return result




func spawn_customer(data:CustomerData):
	var customer:Customer = null
	if data.customer_override:
		print("customer override time")
		customer = data.customer_override.new()
	else:
		customer = customer_scene.instantiate()
	
	
	customer.set_data(data)
	
	customer.customer_left.connect(remove_customer)
	customer.table_reached.connect(customer_to_table)
	customer.thought.bubble_clicked.connect(bubble_clicked)
	customer.order_thought.connect(send_order)
	customer.order_given.connect(read_order)
	
	
	customers.append(customer)
	add_child(customer)
	
	pass


func remove_customer(customer:Customer):
	customers.erase(customer)
	
	# include customer type multiplier later
	customer_left.emit(customer.happiness)
	
	customer.queue_free()

func set_table_targets():
	for i in tables.size():
		var table = tables[i]
		
		if i >= table_num:
			table.hide()
			continue
		table.show()
		
		if table.available:
			for customer in customers:
				if customer.current_state == customer.STATE.STATE_IDLE:
					#print("targeting table")
					customer.target_table(table)
					
					pass
	
	pass



func customer_to_table(customer:Customer):
	#print("table reached")
	customer.table.add_party([customer])
	pass


func bubble_clicked(bubble:ThoughtBubble):
	#print("bubble clicked")
	player_manager.add_customer_action(bubble)
	pass

func send_order(customer:Customer):
	#print("order requested")
	var food = generate_food(customer.data.likes, customer.data.dislikes)
	customer.set_requested_food(food)

func read_order(customer:Customer):
	order_viewer.add_order(customer)

# is there a point to this one? maybe
func d(table:Table):
	#print("table emptied")
	pass




#endregion
