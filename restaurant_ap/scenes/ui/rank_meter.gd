class_name RankMeter extends TextureProgressBar

# basically max happiness from an npc
var happiness_mult:float = 64.0
# different values for happiness_mult based on current stars
var star_multipliers:Array[float] = [64.0, 40.0, 32.0, 27.0, 20.0]

# min rank thresholds
var rank:Dictionary[String, float] = {"F":0.0, "D":80.0, 
	"C":140.0, "B":200.0, "A":260.0, "S":290.0}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#value = 320.0
	#print(get_rank())
	pass # Replace with function body.

func set_multiplier(stars:int):
	var index = clamp(stars, 1, 5) - 1
	happiness_mult = star_multipliers[index]

func get_rank()->int:
	var output:int = -1
	for r in rank.values():
		if value > r:
			output += 1
	return output

func add_happiness(happy:float):
	var add:float = 0.0
	if happy < 0.2:
		add = 0
	elif happy < 0.5:
		add = 0.3 * happiness_mult
	elif happy < 0.9:
		add = 0.5 * happiness_mult
	else:
		add = 1.0 * happiness_mult
	
	
	set_value(value + add)
