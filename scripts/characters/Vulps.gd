extends KinematicBody2D

var damage_group = 1

var velocity = Vector2(0,0)
var target_position:Vector2
var dying = false

const ACTIVITY_DELAY = 5000
const MAX_SPEED = 300
const ACCELERATION = 25
const FRICTION = 0.5
const ANIMATION_THRESHOLD = 0.1
const KNOCKBACK_AMOUNT = 600
const DYING_LENGTH = 5000
const MAXIMUM_VISION = 600
const FLOOR = Vector2(0, -1)
const GRAVITY = 20


var player

func get_damage():
	return 0.75

func init(_player):
	target_position = self.position
	player = _player

func _physics_process(_delta:float):
	if player && player.position.distance_to(self.position) < MAXIMUM_VISION:
		target_position = player.get_global_position()
	
	if !dying:
		if !is_on_floor():
			velocity.y += GRAVITY
		velocity += Vector2(target_position.x - global_position.x, 0).normalized()*ACCELERATION
		velocity = move_and_slide(velocity, FLOOR)
		
		if get_slide_count() > 0:
			var collision:KinematicCollision2D = get_slide_collision(0)
			var body:Object = collision.collider
			collided_with_body(body)

	if dying:
		if $AnimatedSprite.rotation_degrees < 90:
			$AnimatedSprite.rotate(0.1)
		if $AnimatedSprite.rotation_degrees >= 90 && OS.get_ticks_msec() - dying > DYING_LENGTH:
			queue_free()
	else:
		if velocity.x > 0:
			$AnimatedSprite.scale.x = -1
		elif velocity.y < 0:
			$AnimatedSprite.scale.x = 1
		velocity.x = max(-MAX_SPEED, min(MAX_SPEED, velocity.x))

func attack_hit(attack) -> void:
	print("Hit by attack", attack)

func projectile_hit(projectile) -> void:
	velocity += projectile.velocity_direction*KNOCKBACK_AMOUNT
	if !dying:
		dying = OS.get_ticks_msec()
		remove_child($CollisionShape2D)

func collided_with_body(body:Node) -> void:
	if dying:
		return
	
	if body.has_method("attack_hit"):
		body.attack_hit(self)
		velocity = body.position.direction_to(position)*KNOCKBACK_AMOUNT
