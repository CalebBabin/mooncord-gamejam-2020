extends KinematicBody2D

signal fire_laser

var damage_group = 1

var velocity = Vector2()
var lastVelocity = velocity
var on_ground = false
var direction = 0
var lastDirection = -1
var lastAction = 0
var attacking = false
var attacked = false
var dying = false
onready var animationPlayer = $AnimationPlayer
var player

const ACTIVITY_DELAY = 5000
const MAX_SPEED = 200
const ACCELERATION = 10
const FRICTION = 0.5
const GRAVITY = 20
const FLOOR = Vector2(0, -1)
const ANIMATION_THRESHOLD = 0.1
const KNOCKBACK_AMOUNT = 500
const DYING_LENGTH = 5000


# Called when the node enters the scene tree for the first time.
func _ready():
	var _ignored = animationPlayer.connect("animation_finished", self, "_on_AnimationPlayer_finished")

func init(_player):
	player = _player


func attack() -> void:
	if !attacked && !dying && player:
		print(position.angle_to(player.position))
		if direction > 0:
			animationPlayer.play("AttackRight")
			emit_signal("fire_laser", self.position, position.direction_to(player.position), 10, Constants.PhysicsMasks.ENEMY_PROJECTILE_COLLISIONS)
		if direction < 0:
			animationPlayer.play("AttackLeft")
			emit_signal("fire_laser", self.position, position.direction_to(player.position), 10, Constants.PhysicsMasks.ENEMY_PROJECTILE_COLLISIONS)
		
		if lastDirection != 0:
			attacking = true
			Util.add_sound_to_node_by_sound_file("res://assets/sounds/Cultist_Attack.wav", self, true)


func _on_AnimationPlayer_finished(animation_name):
	if animation_name == "AttackRight" || animation_name == "AttackLeft":
		attacking = false
		attacked = true
		if lastDirection > 0:
			animationPlayer.play("IdleRight")
		if lastDirection < 0:
			animationPlayer.play("IdleLeft")
		

func _physics_process(_delta:float):
	
	if !on_ground && !dying:
		velocity.y += GRAVITY

	if !dying:
		velocity.x += ACCELERATION*direction
		velocity = move_and_slide(velocity, FLOOR)
	
	if (is_on_floor()):
		on_ground = true
	else:
		on_ground = false

	if dying:
		if $AnimatedSprite.rotation_degrees < 90:
			$AnimatedSprite.rotate(0.1)
		if $AnimatedSprite.rotation_degrees >= 90 && OS.get_ticks_msec() - dying > DYING_LENGTH:
			queue_free()
	else:
		if lastAction + ACTIVITY_DELAY < OS.get_ticks_msec() && !attacking:
			lastAction = OS.get_ticks_msec()
			attacked = false
			attacking = false
			if direction == 0:
				direction = lastDirection*-1
				lastDirection = direction
			else:
				attack()
				direction = 0


		if direction == 0:
			velocity.x = lerp(velocity.x, 0, FRICTION)

		var collisionCounter = get_slide_count() - 1
		if collisionCounter > -1:
			var col = get_slide_collision(collisionCounter)
			if (col.normal.x != 0):
				direction = direction * -1
	
		if !attacking:
			if direction > 0:
				animationPlayer.play("WalkRight")
				lastVelocity = velocity
			elif direction < 0:
				animationPlayer.play("WalkLeft")
				lastVelocity = velocity
			else:
				if lastVelocity.x > 0:
					animationPlayer.play("IdleRight")
				elif lastVelocity.x < 0:
					animationPlayer.play("IdleLeft")
				else:
					animationPlayer.play("IdleDown")
		velocity.x = max(-MAX_SPEED, min(MAX_SPEED, velocity.x))

func attack_hit(attack) -> void:
	print("Hit by attack", attack)

func projectile_hit(projectile) -> void:
	velocity += projectile.velocity_direction*KNOCKBACK_AMOUNT
	if !dying:
		dying = OS.get_ticks_msec()
		remove_child($CollisionShape2D)
