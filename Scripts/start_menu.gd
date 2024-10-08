extends CenterContainer

# NOTE: '%' here means we are accessing as a unique name; useful for control nodes
# 		because scene structure can often change for UI elements, menus, etc
@onready var start_game_button = %StartGameButton
@onready var quit_game_button = %QuitGameButton

func _ready():
	# sets start button as focus object on game start (good for controller)
	# it knows to navigate up/down from here because buttons are inside 'Vbox'
	# if i want to set them manually, they're in the containers 'focus' options
	start_game_button.grab_focus()

func _on_start_game_button_pressed():
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file("res://Scenes/level_one.tscn")
	LevelTransition.fade_from_black()

func _on_quit_game_button_pressed():
	get_tree().quit
