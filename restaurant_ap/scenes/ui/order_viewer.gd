class_name OrderViewer extends PanelContainer

var list_scene = load("res://restaurant_ap/scenes/ui/order_list.tscn")
var orders:Dictionary[OrderList, Customer]
@export var tab:TabContainer = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_order(customer:Customer):
	if orders.values().has(customer):
		return
	var list = list_scene.instantiate()
	list.order = customer.requested_food
	tab.add_child(list)
	if customer.table:
		tab.set_tab_title(tab.get_tab_count()-1, customer.table.name)
	customer.order_completed.connect(remove_order.bind(list))

func remove_order(order:OrderList):
	orders.erase(order)
	order.queue_free()
