class_name DayTimer extends Node2D

signal closing_time()

@export var timer:Timer = null
@export var time_limit:float = 180.0
var started = false

var star_times:Array[float] = [180.0, 180.0, 240.0, 240.0, 240.0]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var center = get_viewport().get_visible_rect().size / 2.0
	set_position(Vector2(center.x, 0))
	timer.timeout.connect(timeout)
	#start()

func start():
	timer.start(time_limit)
	started = true

func timeout():
	started = false
	closing_time.emit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if !started:
		return
	var progress = (time_limit - timer.time_left) / time_limit
	$Hand.set_rotation(PI * progress)
