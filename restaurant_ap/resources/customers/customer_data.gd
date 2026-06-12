class_name CustomerData extends Resource

@export var name: String
# if this customer needs AI overrides, instance this instead
# make sure it's a Customer scene
@export var customer_override:PackedScene

# animations:
	# "default" : mirror walking
	# "walking"
	# "sitting"
@export var images_top: SpriteFrames
@export var images_bottom: SpriteFrames
@export var image_offset: Vector2

# value subtracted per second when unhappy. 
# default is 0.02, so it takes 25 seconds from 0.5 to hit 0
@export_range(0, 0.1, 0.001) var happiness_decay:float = 0.02
# seconds before unhappiness starts (for food)
# gets multiplied by expected actions to make the food
@export_range(0, 60, 0.5) var unhappy_delay_food:float = 5
# seconds before unhappiness starts (for ordering)
@export_range(0, 60, 0.5) var unhappy_delay_ordering:float = 5
# seconds before unhappiness starts (for finding a seat)
@export_range(0, 60, 0.5) var unhappy_delay_seating:float = 15

# format for things should be:
	# recipe/plain ingredient: "name"
	# recipe + ingredient: "recipe_ingredient"
	# no ingredient + ingredient (yet)
@export var likes:Array[String]
@export var dislikes:Array[String]

@export var unique:bool = false
@export var spawn_gap:float = 5.0



# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(name_d:String = "", images_d:SpriteFrames = null, 
		image_offset_d:Vector2 = Vector2(0,0), decay_d:float = 0.02,
		unhappy_delay_d:float = 5, unique_d:bool = false,
		spawn_gap_d:float = 5.0):
	name = name_d
	images_top = images_d
	images_bottom = images_d
	image_offset = image_offset_d
	happiness_decay = decay_d
	unhappy_delay_food = unhappy_delay_d
	unhappy_delay_ordering = unhappy_delay_d
	unhappy_delay_seating = unhappy_delay_d
	unique = unique_d
	spawn_gap = spawn_gap_d


func _to_string():
	return name
