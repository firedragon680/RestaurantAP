extends TextureButton

signal item_pressed(food)

@export var food_data:IngredientData
@export var button:BaseButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_food_data(data):
	food_data = data
	set_texture_normal(food_data.icon_image)
	set_tooltip_text(food_data.name)


func _on_pressed() -> void:
	#print(food_data.name)
	item_pressed.emit(food_data)
