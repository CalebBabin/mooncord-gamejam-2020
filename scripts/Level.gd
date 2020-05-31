extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var Bullet


# Called when the node enters the scene tree for the first time.
func _ready():
	var player = get_node("player")
	player.connect("fire_bullet", self, "_on_fire_bullet")
	
	Bullet = preload("res://scenes/Bullet.tscn")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _on_fire_bullet(position, direction, distance) -> void:
	var bullet = Bullet.instance()
	bullet.init(position, direction, distance)
	add_child(bullet)
	pass
