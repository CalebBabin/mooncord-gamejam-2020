extends KinematicBody2D


var velocity = Vector2()
var lastVelocity = velocity
var on_ground = false
var direction = 0
var lastDirection = -1
var lastAction = 0
var attacking = false
var attacked = false
onready var animationPlayer = $AnimationPlayer

const ACTIVITY_DELAY = 5000
const MAX_SPEED = 200
const ACCELERATION = 10
const FRICTION = 0.5
const GRAVITY = 20
const FLOOR = Vector2(0, -1)
const ANIMATION_THRESHOLD = 0.5


# Called when the node enters the scene tree for the first time.
func _ready():
	var _ignored = animationPlayer.connect("animation_finished", self, "_on_AnimationPlayer_finished")
	pass # Replace with function body.

func _on_AnimationPlayer_finished(animation_name):
	if !attacked:
		if animation_name == "IdleRight":
			animationPlayer.play("AttackRight")
			attacking = true
		if animation_name == "IdleLeft":
			animationPlayer.play("AttackLeft")
			attacking = true
	if animation_name == "AttackRight" || animation_name == "AttackLeft":
		attacking = false
		attacked = true

func _physics_process(_delta:float):
	
	if lastAction + ACTIVITY_DELAY < OS.get_ticks_msec() && !attacking:
		attacked = false
		lastAction = OS.get_ticks_msec()
		if direction == 0:
			direction = lastDirection*-1
			lastDirection = direction
		else:
			direction = 0
	velocity.y += GRAVITY
	
	velocity.x += ACCELERATION*direction

	if direction == 0:
		velocity.x = lerp(velocity.x, 0, FRICTION)

	velocity.x = max(-MAX_SPEED, min(MAX_SPEED, velocity.x))
	
	velocity = move_and_slide(velocity, FLOOR)

	var collisionCounter = get_slide_count() - 1
	if collisionCounter > -1:
		var col = get_slide_collision(collisionCounter)
		if (col.normal.x != 0):
			direction = direction * -1
	
	if (is_on_floor()):
		on_ground = true
	else:
		on_ground = false


	if !attacking:
		if velocity.x > ANIMATION_THRESHOLD:
			animationPlayer.play("WalkRight")
			lastVelocity = velocity
		elif velocity.x < -ANIMATION_THRESHOLD:
			animationPlayer.play("WalkLeft")
			lastVelocity = velocity
		else:
			if lastVelocity.x > 0:
				animationPlayer.play("IdleRight")
			elif lastVelocity.x < 0:
				animationPlayer.play("IdleLeft")
			else:
				animationPlayer.play("IdleDown")
