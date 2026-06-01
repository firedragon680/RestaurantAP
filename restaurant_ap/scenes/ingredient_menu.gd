extends PanelContainer

signal food_selected(food_data)

var pesto:IngredientData = load("res://restaurant_ap/resources/ingredients/pizza/pesto.tres")
var crust:IngredientData = load("res://restaurant_ap/resources/ingredients/pizza/pizza_crust.tres")

var ingredient_list:Array[IngredientData] = [
	pesto, crust, pesto, crust, 
	pesto, pesto, pesto, pesto, 
	pesto, pesto, pesto, pesto, 
	pesto, pesto, pesto, pesto, 
	pesto, pesto, pesto, pesto, 
	pesto, pesto, pesto, pesto, 
	pesto, pesto, pesto, pesto
]
var menu_item = load("res://restaurant_ap/scenes/menu_ingredient.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for ingredient in ingredient_list:
		var item = menu_item.instantiate()
		item.set_food_data(ingredient)
		item.item_pressed.connect(item_pressed)
		$ScrollContainer/GridContainer.add_child(item)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# send item, close the menu
func item_pressed(data:IngredientData):
	#print(data.name)
	food_selected.emit(data)
	self.hide()
