class_name HappinessMeter extends ProgressBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_max(1.0)
	set_happy(value)

func set_happy(val:float):
	set_value(val)
	if value < 0.2: # <20%
		set_modulate(Color(0.863, 0.196, 0.196, 1.0))
	elif value < 0.5: # <50%
		set_modulate(Color(0.86, 0.672, 0.198, 1.0))
	elif value < 0.9: # <90%
		set_modulate(Color(0.196, 0.863, 0.196, 1.0))
	else: # >=90%
		set_modulate(Color(0.196, 0.863, 1.0, 1.0))
