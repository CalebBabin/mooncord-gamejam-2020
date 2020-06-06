extends Node

onready var TitleMusic = preload("res://scenes/music/TitleMusic.tscn").instance()

# Remove and free the current scene from the tree. We always assume that the
# first child is the root of the scene.
func remove_current_scene() -> void:	
	var children = get_children()
	if children.size() > 0:
		var current_scene:Node = children[0]
		if current_scene:
			remove_child(current_scene)
			current_scene.queue_free()
	
func setup_main_menu() -> void:
	remove_current_scene()
	var MainMenuScene:PackedScene = preload("res://scenes/MainMenu.tscn")
	var main_menu_scene:Node = MainMenuScene.instance()

	add_child(main_menu_scene)

	var _ignored = main_menu_scene.connect("start_game", self, "_on_start_game")

func _on_start_game(level) -> void:
	var player_stats:Stats = Stats.new()
	_on_level_select(level, player_stats)

var last_level = 0
func _on_level_select(level, player_stats) -> void:
	remove_current_scene()
	last_level = level
	
	var GameplayAndUIScene
	if level == 0:
		GameplayAndUIScene = preload("res://scenes/levels/CorruptedForest.tscn")
	elif level == 2:
		GameplayAndUIScene = preload("res://scenes/levels/DankCastle.tscn")
	elif level == 3:
		GameplayAndUIScene = preload("res://scenes/levels/FutureLab.tscn")
	elif level == 69:
		GameplayAndUIScene = preload("res://scenes/minigames/MRE.tscn")
	else:
		GameplayAndUIScene = preload("res://scenes/levels/CorruptedForest.tscn")

	var gameplay_and_ui_scene:Node = GameplayAndUIScene.instance()
	add_gameplay_signal_listeners(gameplay_and_ui_scene)
	add_child(gameplay_and_ui_scene)
	if gameplay_and_ui_scene.has_method("init_player_stats"):
		gameplay_and_ui_scene.init_player_stats(player_stats)

func add_gameplay_signal_listeners(scene):
	scene.connect("game_over", self, "_on_game_over")
	scene.connect("select_level", self, "_on_level_select")
	

func _on_game_over():
	remove_current_scene()
	var GameOverScene:PackedScene = preload("res://scenes/GameOver.tscn")
	var game_over_scene:Node = GameOverScene.instance()
	add_child(game_over_scene)
	var _ignored = game_over_scene.connect("retry", self, "_start_last_level")
	var _ignored2 = game_over_scene.connect("restart", self, "setup_main_menu")


func _start_last_level():
	_on_start_game(last_level)

func _ready() -> void:
	setup_main_menu()
