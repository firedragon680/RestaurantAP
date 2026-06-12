class_name Food extends Node2D

var ingredient_stack:Array[IngredientData]
var sprite_stack:Array[Sprite2D]
var stack_type:String = "none" # the recipe
var stack_stage:String = "" # the last ingredient type
var stack_size:int = 0

var cooked = false
var edible = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var test = "res://restaurant_ap/resources/ingredients/"
	#var test_plate = load(test + "plate.tres")
	#var test_crust = load(test + "pizza/pizza_crust.tres")
	#var test_pesto = load(test + "pizza/pesto.tres")
	#add_stack(test_plate)
	#add_stack(test_crust)
	#add_stack(test_pesto)
	#print(ingredient_stack)
	pass


func can_stack(new_ingredient:IngredientData, no_odd:bool = false) -> bool:
	# if it's already cooked, no more can be added
	if cooked:
		print("already cooked")
		return false
	
	var result = false
	
	# if it's already in the stack, no more
	if ingredient_stack.has(new_ingredient):
		print("duplicate ingredient")
		return false
	
	# no defined stack behavior for this recipe, no stack
	if !new_ingredient.stack_behavior.has(stack_type):
		print("undefined stack behavior")
		return false
	var new_type:String = new_ingredient.stack_behavior[stack_type]
	
	# odd food types are not a factor in ability to stack
	# But, this is used while generating food, and odd types 
	# may not be wanted 
	if !no_odd:
		new_type = new_type.trim_suffix("_odd")
	
	match stack_type:
		# goes on a plate
		"pizza": 
			var priority = {"crust": 0, "sauce": 1, 
			"cheese": 2, "topping": 3}
			
			if new_type == "crust" or new_type == "plate":
				pass # still false. no stacking crusts
			elif priority.has(new_type) and priority.has(stack_stage):
				var old = priority[stack_stage]
				var new = priority[new_type]
				if new >= old:
					result = true
		
		# 'root' stack type. but plate
		"plate":
			result = true
		
		# 'root' stack type. always works, used to set stack_type
		"none":
			result = true
	
	
	
	return result

func add_stack(new_ingredient:IngredientData):
	if can_stack(new_ingredient):
		ingredient_stack.append(new_ingredient)
		match stack_type:
			"plate":
				stack_type = new_ingredient.stack_behavior["plate"]
			"none":
				stack_type = new_ingredient.stack_behavior["none"]
		stack_stage = new_ingredient.stack_behavior[stack_type]
		render_stack()
	
	

func render_stack():
	if sprite_stack.size() < ingredient_stack.size():
		for i in range(sprite_stack.size(), ingredient_stack.size()):
			var sprite = Sprite2D.new()
			sprite_stack.append(sprite)
			add_child(sprite)
	elif sprite_stack.size() > ingredient_stack.size():
		var sprite = sprite_stack.pop_back()
		remove_child(sprite)
	stack_size = sprite_stack.size()
	
	var stack_offset = 0
	for i in range(stack_size):
		# make a dict or something for defining ingredient's offsets
		# they add to the current stack offset
		sprite_stack[i].set_position(Vector2(0, -stack_offset))
		#print("setting texture #", i)
		sprite_stack[i].set_texture(ingredient_stack[i].stack_images[stack_type])
	

func set_cooked(value:bool = true):
	cooked = value
	if stack_type == "pizza":
		edible = true

func is_odd(ing:IngredientData)->bool:
	var result:bool = false
	
	if ing.stack_behavior.has(stack_type):
		result = ing.stack_behavior[stack_type].right(4) == "_odd"
	
	return result
