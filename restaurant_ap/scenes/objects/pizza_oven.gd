extends FoodProcessor


func process_food():
	if (current_food.stack_type == "pizza"):
		current_food.set_cooked()





#func can_hold(food:Food) -> bool:
#	return (food.stack_type == "pizza")
