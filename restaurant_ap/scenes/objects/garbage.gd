extends FoodStorage


func on_store():
	current_food.queue_free()
