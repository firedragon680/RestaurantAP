class_name Seat extends Node2D

var seated_customer:Customer = null

# probably the parent of this node. table
@export var table:Table
@onready var sprite = $Sprite2D

# the basic offset to make customers look seated
@export var seating_offset:Vector2 = Vector2(0,0)
# non-flipped direction is right
@export var facing_left = false



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



func set_facing_left(left):
	facing_left = left
	sprite.set_flip_h(left)

func sit(customer:Customer):
	seated_customer = customer
	# add customer's distinct offset later
	var offset = seating_offset
	if facing_left:
		offset *= Vector2(-1, 1)
	customer.set_global_position(get_global_position()+offset)
	
	
	
