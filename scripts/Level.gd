extends Node

signal game_over
signal select_level
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var Bullet
var Laser
var Slash
var player_stats:Stats
var player

func _on_player_select_level(level):
	emit_signal("select_level", level)

# Called when the node enters the scene tree for the first time.
func _ready():
	player = find_node("Player")
	player.stats = player_stats

	player.connect("fire_bullet", self, "_on_fire_bullet")
	player.connect("fire_slash", self, "_on_fire_slash")
	player.connect("death", self, "_on_player_death")
	player.connect("select_level", self, "_on_player_select_level")
	
	var cultists = $Cultists.get_children()
	for cultist in cultists:
		cultist.init(player)
		cultist.connect("fire_laser", self, "_on_fire_laser")
	
	var bats = $Bats.get_children()
	for bat in bats:
		bat.init(player)
	
	Bullet = preload("res://scenes/projectiles/Bullet.tscn")
	Laser = preload("res://scenes/projectiles/Laser.tscn")
	Slash = preload("res://scenes/projectiles/Slash.tscn")
	pass # Replace with function body.

func init_player_stats(_player_stats):
	player_stats = _player_stats

var game_ending = false
var game_end_opacity = 1
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_ending:
		game_end_opacity -= delta
		if game_end_opacity <= 0:
			emit_signal("game_over")
		self.modulate = Color(0,0,0,game_end_opacity)
	pass

func _on_fire_bullet(position:Vector2, velocity:Vector2, distance, collision_mask) -> void:
	var bullet = Bullet.instance()
	bullet.init(position, velocity, distance, true, 10, 1500)
	bullet.collision_mask = Util.convert_enum_to_bitmask([Constants.PhysicsMasks.WORLD_COLLISIONS, collision_mask])
	add_child(bullet)

func _on_fire_slash(position:Vector2, velocity:Vector2, distance, collision_mask) -> void:
	var bullet = Slash.instance()
	bullet.init(position, velocity, distance, true, 0.06, 1500)
	bullet.collision_mask = Util.convert_enum_to_bitmask([collision_mask])
	add_child(bullet)

func _on_fire_laser(position:Vector2, velocity:Vector2, distance, collision_mask) -> void:
	var bullet = Laser.instance()
	bullet.init(position, velocity, distance/2, false, 0.75, 750)
	bullet.collision_mask = Util.convert_enum_to_bitmask([Constants.PhysicsMasks.WORLD_COLLISIONS, collision_mask])
	add_child(bullet)

func _on_player_death():
	game_ending = true

func _on_level_select(level:int):
	emit_signal("select_level", level)
