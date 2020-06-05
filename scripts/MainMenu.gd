extends Control

onready var start_game_button:Button = $CenterContainer/GridContainer/CenterContainer2/GridContainer/StartButton


signal start_game(level)

func _start_game() -> void:
	emit_signal("start_game", 1)


# Called when the node enters the scene tree for the first time.
func _ready():
	var _ignored = start_game_button.connect("pressed", self, "_start_game")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


