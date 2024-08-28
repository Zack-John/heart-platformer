extends Node2D

#@onready var collision_polygon_2d = $StaticBody2D/CollisionPolygon2D
#@onready var polygon_2d = $StaticBody2D/CollisionPolygon2D/Polygon2D

@onready var level_complete = $CanvasLayer/LevelComplete
@export var next_level: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	#polygon_2d.polygon = collision_polygon_2d.polygon # set poly2D to align with collision poly
	RenderingServer.set_default_clear_color(Color.BLACK)
	Events.level_complete.connect(show_level_complete_text)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func show_level_complete_text():
	level_complete.show()
	
	if next_level is PackedScene:
		get_tree().paused = true
		await LevelTransition.fade_to_black()
		get_tree().paused = false
		get_tree().change_scene_to_packed(next_level)
		LevelTransition.fade_from_black()
	
	else:
		# pause the game when there are no more levels to load
		get_tree().paused = true
		LevelTransition.fade_to_black()
