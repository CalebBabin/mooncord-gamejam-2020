extends KinematicBody2D

signal fire_bullet

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var velocity:Vector2
var lastX:float = 1
var lastVelocity = Vector2(0,0)
var lastPosition = Vector2(0,0)
var camera:Camera2D

onready var gun = $GunNode
onready var gunAnimation = $GunAnimationPlayer


var on_ground = false
var smashing = false
var firing_gun = false
var gun_equiped = false
var last_on_ground = 0


const MAX_SPEED = 400
const ACCELERATION = 10
const FRICTION = 0.7
const JUMP_POWER = 800
const GUN_KNOCKBACK = 325
const GRAVITY = 20
const FLOOR = Vector2(0, -1)
const ANIMATION_THRESHOLD = MAX_SPEED/4
const JUMP_AVAILABILITY_TIMEOUT = 250

const MAX_GUN_SPEED = 5.0
const GUN_ACCELERATION = 0.5
var gun_speed = 0.0

onready var animationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	setup_camera()
	
	gun.scale.x = 0
	
	animationPlayer.connect("animation_finished", self, "_on_AnimationPlayer_finished")
	gunAnimation.connect("animation_finished", self, "_on_GunAnimationPlayer_finished")

func setup_camera() -> void:
	camera = Camera2D.new()
	camera.name = "Camera2D"
	camera.current = true
	add_child(camera)
	
func _unhandled_input(_event:InputEvent):
	if Input.is_action_just_pressed("ui_up") && last_on_ground + JUMP_AVAILABILITY_TIMEOUT >= OS.get_ticks_msec():
		velocity.y -= JUMP_POWER
		last_on_ground = 0
	if Input.is_action_just_pressed("ui_down"):
		velocity.y = max(0, velocity.y)
		if !Input.is_action_pressed("ui_left") && !Input.is_action_pressed("ui_right"):
			lastVelocity.x = 0
			lastVelocity.y = 1
	
	
	if Input.is_action_pressed("aim_up"):
		gun_equiped = true
	if Input.is_action_pressed("aim_down"):
		gun_equiped = false
	
	if Input.is_action_just_pressed("ui_accept"):
		if !firing_gun && !smashing:
			if gun_equiped:
				gunAnimation.play("Fire")
				firing_gun = true
				emit_signal("fire_bullet", self.position+gun.position, gun.rotation, 90)
				velocity += Vector2(cos(gun.rotation), sin(gun.rotation))*-1*GUN_KNOCKBACK
			else: 
				smashing = true
				if lastVelocity.x > 0:
					animationPlayer.play("SmashRight")
				elif lastVelocity.x < 0:
					animationPlayer.play("SmashLeft")
		
func _on_AnimationPlayer_finished(animation_name):
	if animation_name == "SmashLeft" || animation_name == "SmashRight":
		animationPlayer.stop()
		smashing = false
		
func _on_GunAnimationPlayer_finished(animation_name):
	if animation_name == "Fire":
		firing_gun = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if gun_equiped && gun.scale.x < 1:
		gun.scale.x += delta*10
	if !gun_equiped && gun.scale.x > 0:
		gun.scale.x -= delta*10
	if !gun_equiped && gun.scale.x < 0:
		gun.scale.x = 0
	

func _physics_process(delta:float):
	if Input.is_action_pressed("aim_left"):
		gun_speed += GUN_ACCELERATION
		gun.rotate(-delta*min(gun_speed, MAX_GUN_SPEED))
	elif Input.is_action_pressed("aim_right"):
		gun_speed += GUN_ACCELERATION
		gun.rotate(delta*min(gun_speed, MAX_GUN_SPEED))
	else:
		gun_speed = 0
	
	if !on_ground:
		if Input.is_action_pressed("ui_down"):
			velocity.y += GRAVITY*2
		else:
			velocity.y += GRAVITY
	
	if Input.is_action_pressed("ui_right"):
		velocity.x += ACCELERATION
	if Input.is_action_pressed("ui_left"):
		velocity.x -= ACCELERATION

	if !Input.is_action_pressed("ui_left") && !Input.is_action_pressed("ui_right"):
		velocity.x = lerp(velocity.x, 0, FRICTION)

	velocity.x = max(-MAX_SPEED, min(MAX_SPEED, velocity.x))
	
	velocity = move_and_slide(velocity, FLOOR)

	if (is_on_floor()):
		on_ground = true
		last_on_ground = OS.get_ticks_msec()
	else:
		on_ground = false

	lastPosition = self.position

	if !smashing:
		if !on_ground:
			if velocity.y > 0:
				if lastVelocity.x > 0:
					animationPlayer.play("LandRight")
				elif lastVelocity.x < 0:
					animationPlayer.play("LandLeft")
			if velocity.y < 0:
				if lastVelocity.x > 0:
					animationPlayer.play("JumpRight")
				elif lastVelocity.x < 0:
					animationPlayer.play("JumpLeft")
		elif abs(velocity.x) > ANIMATION_THRESHOLD:
			if velocity.x > ANIMATION_THRESHOLD:
				animationPlayer.play("WalkRight")
				lastVelocity = velocity;
			elif velocity.x < -ANIMATION_THRESHOLD:
				animationPlayer.play("WalkLeft")
				lastVelocity = velocity;
		else:
			if lastVelocity.x > 0:
				animationPlayer.play("IdleRight")
			elif lastVelocity.x < 0:
				animationPlayer.play("IdleLeft")
			else:
				animationPlayer.play("IdleDown")

func attack_hit(attack) -> void:
	print("Hit by attack", attack)

func projectile_hit(projectile) -> void:
	print("Player hit by projectile, ouch!", projectile)
