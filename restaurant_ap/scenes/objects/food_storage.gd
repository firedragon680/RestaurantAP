class_name FoodStorage extends Interactable

var current_food:Food
var available = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()

# called by main scene
func on_click():
	if available:
		super.on_click()
	#print("lol")

# do something to the food
func on_store():
	pass
	

func set_available(new:bool):
	available = new
	update_color()


func update_color()->void:
	if hovered and available:
		set_modulate(Color(1.0, 0.612, 0.0, 1.0))
	else:
		set_modulate(Color(1,1,1))

func can_hold(_food:Food) -> bool:
	return true
