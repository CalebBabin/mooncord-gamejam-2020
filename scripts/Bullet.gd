extends KinematicBody2D

class_name Projectile

const SPEED = 1500

var velocity_direction:Vector2
var TTL = 10
var direction
var die_on_world_collide

var is_dead:bool = false

func init(position, direction_angle, distance, die_on_world = false, ttl = 10) -> void:
	velocity_direction = Vector2(cos(direction_angle), sin(direction_angle))
	die_on_world_collide = die_on_world
	TTL = ttl
	self.set_rotation(direction_angle)
	self.position = position + velocity_direction*distance
	
	
	add_to_group("projectiles")
	
	
	#var collision_layer:int = Constants.PhysicsMasks.PLAYER_PROJECTILE if is_player else Constants.PhysicsMasks.ENEMY_PROJECTILE
	#var collision_mask:int = Constants.PhysicsMasks.ENEMY if is_player else Constants.PhysicsMasks.PLAYER
	#self.collision_layer = Util.convert_enum_to_bitmask([collision_layer])
	#self.collision_mask = Util.convert_enum_to_bitmask([Constants.PhysicsMasks.WORLD_WALLS, collision_mask])

func get_damage() -> float:
	return 1.0

func _physics_process(delta:float) -> void:
	
	var _ignored = move_and_slide(velocity_direction * SPEED)
	
	if get_slide_count() > 0:
		# Note that if a projectile is colliding with multiple bodies (e.g. the
		# world AND the player), then by only getting the first collision, we
		# may not handle the collision with the player. This is a relatively
		# minor bug.
		var collision:KinematicCollision2D = get_slide_collision(0)
		var body:Object = collision.collider
		collided_with_body(body)

	TTL -= delta
	if TTL <= 0:
		queue_free()
	
	# Fade projectiles out toward the end of their lifespans
	#if TTL < 0.1:
	#	modulate[3] = (TTL / 0.1)

# This is called when this collides with a body or when a body collides with
# this. Godot considers those two events to be different, but from a player's
# perspective, they both represent this projectile hitting something.
func collided_with_body(body:Node) -> void:
	if is_dead:
		return
		
	if die_on_world_collide:
		is_dead = true
		queue_free()
	
	if body.has_method("projectile_hit"):
		body.projectile_hit(self)
		is_dead = true
		queue_free()
		
