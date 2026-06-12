class_name ProcessTimer extends ProgressBar

signal completed()

var timer:Timer = Timer.new()
@export var wait_time:float = 5.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.set_one_shot(true)
	timer.timeout.connect(done)
	add_child(timer)
	#start_timer()


func _process(_delta: float) -> void:
	if !timer.is_stopped():
		set_value_no_signal(wait_time - timer.get_time_left())
		
		pass

func start_timer():
	set_max(wait_time)
	timer.start(wait_time)
	

func is_stopped()->bool:
	return timer.is_stopped()

func done():
	completed.emit()
