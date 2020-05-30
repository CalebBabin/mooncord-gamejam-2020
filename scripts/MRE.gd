extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var camera:Camera2D
var hand
var hand_sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = Camera2D.new()
	camera.name = "Camera2D"
	camera.current = true
	add_child(camera)
	
	hand = $Hand
	hand_sprite = $Hand/HandSprite

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#hand_sprite.frame = 0
	pass
