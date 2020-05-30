extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var velocity:Vector2
var lastX:float = 1
var lastVelocity:Vector2
var camera:Camera2D

var on_ground = false


const MAX_SPEED = 200
const ACCELERATION = 10
const FRICTION = 0.5
const JUMP_POWER = 600
const GRAVITY = 20
const FLOOR = Vector2(0, -1)
const ANIMATION_THRESHOLD = MAX_SPEED/2

onready var animationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	setup_camera()

func setup_camera() -> void:
	camera = Camera2D.new()
	camera.name = "Camera2D"
	camera.current = true
	add_child(camera)
	
func _unhandled_input(_event:InputEvent):
	if Input.is_action_just_pressed("ui_up") && on_ground:
		velocity.y -= JUMP_POWER
	if Input.is_action_just_pressed("ui_down"):
		velocity.y = max(0, velocity.y)
		if !Input.is_action_pressed("ui_left") && !Input.is_action_pressed("ui_right"):
			lastVelocity.x = 0
			lastVelocity.y = 1
		



func _physics_process(_delta:float):
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
	else:
		on_ground = false
	
	if abs(velocity.x) > ANIMATION_THRESHOLD:
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
