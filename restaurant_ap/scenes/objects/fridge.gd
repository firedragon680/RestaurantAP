extends Interactable

@export var menu:Control
var menu_toggle = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	menu_toggle = false
	menu.food_selected.connect(food_selected)
	menu.hide()
	pass # Replace with function body.




func toggle_menu():
	if menu_toggle:
		menu.hide()
	else:
		menu.show()
	menu_toggle = !menu_toggle

func on_click():
	#print("fridge!")
	toggle_menu()

func food_selected(food):
	toggle_menu()
	ingredient = food
	super.on_click()
	pass
