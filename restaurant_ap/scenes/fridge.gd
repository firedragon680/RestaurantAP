extends Node2D

@export var menu:Control
var menu_toggle = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menu_toggle = false
	menu.hide()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func toggle_menu():
	if menu_toggle:
		menu.hide()
	else:
		menu.show()
	menu_toggle = !menu_toggle
