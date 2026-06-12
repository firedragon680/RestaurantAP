class_name Table extends Interactable

signal table_emptied(table:Table)

@export var food_positions:Array[Vector2] = []
@export var slots:int = 2
var current_food:Array[Food] = []
var current_customers:Array[Customer] = []


var seats:Array[Seat]

var available = true
var dirty:bool = false
@onready var sprite = $Sprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	add_to_group("table")
	var children = get_children()
	for node in children:
		if node is Seat:
			seats.append(node)
	if seats.size() > slots:
		print("Too many seats on Table ", self)
	elif seats.size() < slots:
		slots = seats.size()


func set_dirty(dirt:bool = true):
	dirty = dirt
	if dirt:
		sprite.play("dirty")
	else:
		sprite.play("default")
		set_available(true)

func clean():
	set_dirty(false)

func set_available(value:bool = true):
	if value:
		table_emptied.emit(self)
	available = value

func update_color()->void:
	if hovered and dirty:
		set_modulate(Color(1.0, 0.612, 0.0, 1.0))
	else:
		set_modulate(Color(1,1,1))


func on_click()-> bool:
	if dirty:
		clean()
		return true
	return false

func can_add_party(customers:Array[Customer]):
	return available and (customers.size() <= slots)

func add_party(customers:Array[Customer]):
	if !can_add_party(customers):
		return 
	
	for i in customers.size():
		var customer = customers[i]
		customer.sit(seats[i])
		customer.left_table.connect(remove_party)
		current_customers.append(customer)
		seats[i].sit(customer)
	set_available(false)
	pass

# change to array[customer] later, matching add_party()
func remove_party(customer:Customer):
	var removed = false
	if current_customers.has(customer):
		current_customers.erase(customer)
		for seat in seats:
			if seat.seated_customer == customer:
				seat.seated_customer = null
				removed = true
	if removed:
		for food in current_food:
			food.queue_free()
		if current_food.size() > 0:
			set_dirty()
		else:
			set_available(true)
		current_food.clear()
	pass

# change to account for multiple customers per table
func place_food(customer:Customer):
	if !current_customers.has(customer):
		return
	var food = customer.served_food
	current_food.append(customer.served_food)
	add_child(food)
	food.set_position(food_positions[0])
	pass
