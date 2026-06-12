class_name PlayerManager extends Node


var action_queue:Array[Dictionary] = []
# all actions change the player's target position.
# actions are dictionaries with the following keys:
	# Required
		# "interactable":Interactable - the thing interacted with
		# "type":String - the action to be done
		# "pos":Vector2D - location
		# "started":bool - whether it's been started
	# "type":"nothing" - makes pos get set to current player position
	# "type":"move" - nothing special, just moves
	# "type":"ingredient" - adds ingredient to the stack
		# "ingredient":IngredientData - the thing to stack
	# "type":"swap" - swap held food with stored food on arrival
	# "type":"order" - take order from customer
		# "customer":Customer - the Customer with a Thoughtbubble
	# "type":"serve" - give food to customer
		# "customer":Customer - the Customer with a Thoughtbubble
enum STATE {STATE_IDLE, STATE_MOVING, STATE_WORKING}
@export var player:Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var interactable = get_tree().get_nodes_in_group("clickable")
	for node in interactable:
		node.object_targeted.connect(add_action)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if action_queue.size() < 1:
		return
	
	# check current action
	var state = player.current_state
	if state == STATE.STATE_IDLE:
		# end old actions
		if action_queue[0]["started"]:
			var action = action_queue.pop_front()
			match action["type"]:
				"swap":
					var object = action["interactable"]
					if object.available and object.can_hold(player.held_food):
						player.swap_food(action["interactable"])
						action["interactable"].on_store()
				"ingredient":
					if action.has("ingredient"):
						#print("stacking ", action["ingredient"])
						player.stack_food(action["ingredient"])
				"order":
					var customer = action["customer"]
					customer.on_interact()
				"serve":
					if !player.held_food or !player.held_food.edible:
						# can't serve, skip
						pass
					else:
						# can serve
						var customer = action["customer"]
						player.serve_food(customer)
		
		# start new actions
		elif !action_queue[0]["started"]:
			match action_queue[0]["type"]:
				"nothing":
					pass
				"move", "ingredient", "swap":
					set_player_target(action_queue[0]["pos"])
				"order","serve":
					set_player_target(action_queue[0]["pos"])
			action_queue[0]["started"] = true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("player_select"):
		#print("mouse click!")
		var interactable = get_tree().get_nodes_in_group("clickable")
		interactable.append_array(get_tree().get_nodes_in_group("bubble"))
		#print(interactable)
		
		# z sorting. higher value first
		interactable.sort_custom(func(a, b): return a.get_z_index() < b.get_z_index())
		
		for node in interactable:
			#print("looping")
			if node.hovered:
				if node.on_click(): 
					break
		# does not handle y values, everything stacked gets clicked
	
	
	if event.is_action_pressed("player_dequeue"):
		if action_queue.size() > 0 and !action_queue[-1]["started"]:
			action_queue.pop_back()
		


# add a generic interactable as an action to the queue
func add_action(node:Interactable):
	var action = {"interactable": node, "started":false}
	if !node.target_location:
		action["type"] = "nothing"
	elif node is FoodStorage:
		action["type"] = "swap"
		action["pos"] = node.to_global(node.target_location)
	elif node.ingredient:
		action["type"] = "ingredient"
		action["pos"] = node.to_global(node.target_location)
		action["ingredient"] = node.ingredient
	else:
		action["type"] = "move"
		action["pos"] = node.to_global(node.target_location)
	action_queue.append(action)

func set_player_target(pos):
	#print("moving to ", pos)
	player.set_movement_target(pos)
	pass

func add_customer_action(bubble:ThoughtBubble):
	#print("adding customer action")
	var customer = bubble.get_parent()
	if !(customer is Customer):
		print("thought bubble attached to non-customer")
		return
	for act in action_queue:
		if !act.has("customer"):
			continue
		if (act["interactable"] == bubble) or (act["customer"] == customer):
			print("not adding multiple of the same customer to the queue")
			return
	
	var action = {"interactable": bubble, "started":false,
		"pos":customer.to_global(customer.table.target_location),
		"customer":customer}
	
	match customer.current_state:
		customer.STATE.STATE_ORDERING:
			action["type"] = "order"
		customer.STATE.STATE_SITTING:
			action["type"] = "serve"
		_:
			print("customer in invalid state for action queuing")
			return
	#print(action)
	action_queue.append(action)
