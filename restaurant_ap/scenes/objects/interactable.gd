class_name Interactable extends Area2D

signal object_targeted(node)

@export var target_location: Vector2 = Vector2(0,0)
var hovered:bool = false
@export var ingredient:IngredientData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("clickable")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _mouse_enter() -> void:
	hovered = true
	update_color()
func _mouse_exit() -> void:
	hovered = false
	update_color()

func update_color()->void:
	if hovered:
		set_modulate(Color(1.0, 0.612, 0.0, 1.0))
	else:
		set_modulate(Color(1,1,1))


# called by main scene
func on_click()-> bool:
	object_targeted.emit(self)
	return true

func get_target()->Vector2:
	return get_global_position() + target_location
