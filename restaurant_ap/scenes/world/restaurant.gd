extends Node

@export var day_timer:DayTimer
@export var meter:RankMeter
var closed:bool = false

var star_rating:int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Camera2D.make_current()
	
	
	$CustomerManager.get_seating()
	$CustomerManager.customer_left.connect(customer_left)
	$CustomerManager.refresh_current(star_rating)
	$CustomerManager.spawn_timer_setup()
	
	update_fridge()
	
	day_timer.time_limit = day_timer.star_times[star_rating-1]
	day_timer.closing_time.connect(closing_time)
	day_timer.start()
	
	$UI/WinPopup.hide()


func customer_left(value:float):
	meter.add_happiness(value)
	check_done()
	

func check_done():
	if closed and $CustomerManager.customers.size() <= 0:
		#print("all customers left")
		var rank_texture = $UI/WinPopup/PanelContainer/VBoxContainer/TextureRect.texture
		rank_texture.set_region(Rect2(40*(meter.get_rank()), 0, 40, 40))
		$UI/WinPopup.show()
		pass

func closing_time():
	closed = true
	$CustomerManager.spawn_timer.stop()
	check_done()
	#print("closing time")

func update_fridge():
	var ingredients = $CustomerManager.ingredients.duplicate()
	
	# remove things that don't go in the fridge
	ingredients.erase("plate")
	
	var output:Array[IngredientData] = []
	for ing in $CustomerManager.current_ingredients:
		if ingredients.has(ing) and !output.has(ingredients[ing]):
			output.append(ingredients[ing])
	
	$Fridge.menu.set_items(output)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	


func to_main_menu() -> void:
	get_tree().change_scene_to_file("res://restaurant_ap/scenes/title.tscn")
