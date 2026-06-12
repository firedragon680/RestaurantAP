extends PanelContainer

signal food_selected(food_data)

#var pesto:IngredientData = load("res://restaurant_ap/resources/ingredients/pizza/pesto.tres")
#var crust:IngredientData = load("res://restaurant_ap/resources/ingredients/pizza/pizza_crust.tres")

var ingredient_list:Array[IngredientData] = []
var menu_item = load("res://restaurant_ap/scenes/objects/menu_ingredient.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for ingredient in ingredient_list:
		var item = menu_item.instantiate()
		item.set_food_data(ingredient)
		item.item_pressed.connect(item_pressed)
		$ScrollContainer/GridContainer.add_child(item)
	
	pass # Replace with function body.


func set_items(data_arr:Array[IngredientData]):
	clear_items()
	for data in data_arr:
		add_item(data)

func clear_items():
	var items = $ScrollContainer/GridContainer.get_children()
	for i in items:
		i.queue_free()
	ingredient_list.clear()

func add_item(ingredient):
	ingredient_list.append(ingredient)
	
	var item = menu_item.instantiate()
	item.set_food_data(ingredient)
	item.item_pressed.connect(item_pressed)
	$ScrollContainer/GridContainer.add_child(item)


# send data, close the menu
func item_pressed(data:IngredientData):
	#print(data.name)
	food_selected.emit(data)
	self.hide()
