class_name FoodProcessor extends FoodStorage

@export var timer:ProcessTimer


func _ready() -> void:
	super._ready()
	timer.completed.connect(on_completed)
	timer.hide()

func on_store():
	if !current_food or current_food.stack_size <= 0:
		return
	if timer.is_stopped():
		set_available(false)
		timer.show()
		timer.start_timer()
		process_food()
	

# wow it's almost like the name of the node, crazy
# gets implemented per instance
func process_food():
	pass

func on_completed():
	set_available(true)
	timer.hide()
