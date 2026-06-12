class_name OrderList extends ScrollContainer

var textboxes:Array[Label] = []
var order:Food = null
@export var box:VBoxContainer = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_order(order)
	pass # Replace with function body.

func set_order(food:Food):
	if !order:
		return
	
	for i in textboxes:
		i.queue_free()
	textboxes.clear()
	
	for i in food.ingredient_stack:
		var text:Label = Label.new()
		text.set_text(i._to_string())
		textboxes.append(text)
		box.add_child(text)
