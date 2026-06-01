class_name Food extends Node2D

var ingredient_stack:Array[IngredientData]
var sprite_stack:Array[Sprite2D]
var stack_type:String = "none" # the recipe
var stack_stage:String = "" # the last ingredient type

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var test = "res://restaurant_ap/resources/ingredients/"
	var test_plate = load(test + "plate.tres")
	var test_crust = load(test + "pizza/pizza_crust.tres")
	var test_pesto = load(test + "pizza/pesto.tres")
	add_stack(test_plate)
	add_stack(test_crust)
	add_stack(test_pesto)
	print(ingredient_stack)
	pass


func can_stack(new_ingredient:IngredientData) -> bool:
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
	new_type = new_type.trim_suffix("_odd")
	
	match stack_type:
		# goes on a plate
		"pizza": 
			var priority = {"crust": 0, "cheese": 1, 
			"sauce": 2, "topping": 3}
			
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
	pass

func render_stack():
	if sprite_stack.size() < ingredient_stack.size():
		for i in range(sprite_stack.size(), ingredient_stack.size()):
			var sprite = Sprite2D.new()
			sprite_stack.append(sprite)
			add_child(sprite)
	elif sprite_stack.size() > ingredient_stack.size():
		sprite_stack.pop_back()
	
	for i in range(sprite_stack.size()):
		sprite_stack[i].set_texture(ingredient_stack[i].stack_images[stack_type])
	
