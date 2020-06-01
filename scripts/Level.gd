extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var Bullet
var Laser


# Called when the node enters the scene tree for the first time.
func _ready():
	var player = get_node("Player")
	player.connect("fire_bullet", self, "_on_fire_bullet")
	
	var cultists = $Cultists.get_children()
	for cultist in cultists:
		cultist.connect("fire_laser", self, "_on_fire_laser")
	
	Bullet = preload("res://scenes/Bullet.tscn")
	Laser = preload("res://scenes/Laser.tscn")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _on_fire_bullet(position, direction, distance, collision_mask) -> void:
	var bullet = Bullet.instance()
	bullet.init(position, direction, distance, true)
	bullet.collision_layer = Util.convert_enum_to_bitmask([Constants.PhysicsMasks.WORLD_COLLISIONS, collision_mask])
	add_child(bullet)

func _on_fire_laser(position, direction, distance, collision_mask) -> void:
	var bullet = Laser.instance()
	bullet.init(position, direction, distance/2, false, 1)
	bullet.collision_layer = Util.convert_enum_to_bitmask([Constants.PhysicsMasks.WORLD_COLLISIONS, collision_mask])
	add_child(bullet)
