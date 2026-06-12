class_name ThoughtBubble extends Area2D


signal bubble_clicked(this:ThoughtBubble)

enum STATE {STATE_IDLE, STATE_MOVING, STATE_READING, 
# idle: not seated yet, waiting. unhappy timer
# moving: walking to/from table
# reading: reading the menu, not interactable
			STATE_ORDERING, STATE_SITTING, STATE_EATING}
# ordering: waiting for order to be taken. unhappy timer
# sitting: waiting for food to arrive. unhappy timer
# eating: nom food
var current_state:STATE = STATE.STATE_IDLE
@export var sprite:AnimatedSprite2D

var hovered:bool = false
# rating should be -1, 0, 1
var food_rating = 0
var timer:SceneTreeTimer = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("bubble")
	pass # Replace with function body.


func change_state(state:STATE):
	if state == current_state:
		return
	
	match state:
		STATE.STATE_IDLE:
			hide()
		STATE.STATE_MOVING:
			hide()
		STATE.STATE_READING:
			sprite.play("reading")
			show()
		STATE.STATE_ORDERING:
			sprite.play("ordering")
			show()
		STATE.STATE_SITTING:
			sprite.play("hungry")
			show()
		STATE.STATE_EATING:
			if food_rating == 0:
				hide()
			if food_rating > 0:
				sprite.play("happy")
				show()
				make_timer(2.0)
			if food_rating < 0:
				sprite.play("unhappy")
				show()
				make_timer(2.0)
	current_state = state

func is_clickable()->bool:
	return is_visible() and (current_state > STATE.STATE_READING) and (current_state < STATE.STATE_EATING)

func make_timer(time:float):
	timer = get_tree().create_timer(time)
	timer.timeout.connect(hide)

# called by main scene
func on_click()-> bool:
	#print("bubble on_click()")
	if is_clickable():
		#print("emitting bubble_clicked")
		bubble_clicked.emit(self)
	else: 
		return false
	return true

func _mouse_enter() -> void:
	hovered = true
	update_color()
func _mouse_exit() -> void:
	hovered = false
	update_color()

func update_color()->void:
	if is_clickable() and hovered:
		set_modulate(Color(0.224, 0.882, 0.0, 1.0))
	else:
		set_modulate(Color(1,1,1))
