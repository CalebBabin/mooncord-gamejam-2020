extends Node


# Remove and free the current scene from the tree. We always assume that the
# first child is the root of the scene.
func remove_current_scene() -> void:	
	var current_scene:Node = get_children()[0]
	remove_child(current_scene)
	current_scene.queue_free()
	
func setup_main_menu() -> void:
	var MainMenuScene:PackedScene = preload("res://scenes/MainMenu.tscn")
	var main_menu_scene:Node = MainMenuScene.instance()

	add_child(main_menu_scene)

	var _ignored = main_menu_scene.connect("start_game", self, "_on_start_game")


func _on_start_game(_level:int) -> void:
	remove_current_scene()
	
	var GameplayAndUIScene:PackedScene = preload("res://scenes/test.tscn")
	var gameplay_and_ui_scene:Node = GameplayAndUIScene.instance()
	add_child(gameplay_and_ui_scene)
	gameplay_and_ui_scene.init()

func _on_game_over():
	remove_current_scene()
	setup_main_menu()
	

func _ready() -> void:
	setup_main_menu()
