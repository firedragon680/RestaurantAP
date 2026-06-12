class_name IngredientData extends Resource

@export var name:String
@export var icon_image:Texture2D
@export var stack_behavior:Dictionary[String, String]
	## Stack behavior info
	# Should be recipe_name: type, with type referring 
	# to a position within that recipe.
	# Both in lower case.
	# -
	# If this ingredient is a "stem", i.e. able to be the first
	# in a stack, include the key "none", with their matching
	# recipe as the value.
	# ex: Plates are {"none": "plate", "plate": "plate"}.
	# -
	# Plates are also a type of stem, for plated foods.
	# ex: Pizza crust is {"plate": "pizza", "pizza": "crust"}
	# -
	# If a recipe is not included, the ingredient will be 
	# unable to place itself into a food stack of that recipe.
	# To allow for non-standard combinations to exist, 
	# add the suffix _odd to the type.
	# ex: Chocolate drizzle has the pair "pizza": "topping_odd"
@export var stack_images:Dictionary[String, Texture2D]
	# images for when in each stack type



# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(image_d:Texture2D = null, stack_behavior_d:Dictionary[String, String] = {}, stack_images_d:Dictionary[String, Texture2D] = {}, name_d:String = ""):
	icon_image = image_d
	stack_behavior = stack_behavior_d
	stack_images = stack_images_d
	name = name_d


func _to_string():
	return name
