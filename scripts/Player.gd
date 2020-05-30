extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var velocity:Vector2
var lastX:float = 1
var lastVelocity:Vector2
var camera:Camera2D
const maxSpeed = 200

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
	lastVelocity = velocity;
	velocity = Vector2()
	
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	velocity = velocity.normalized()



func _physics_process(_delta:float):
	var _ignored = self.move_and_slide(velocity*maxSpeed)
	if velocity != Vector2.ZERO:
		if velocity.x > 0:
			animationPlayer.play("WalkRight")
		elif velocity.x < 0:
			animationPlayer.play("WalkLeft")
		elif velocity.y > 0:
			animationPlayer.play("WalkDown")
		elif velocity.y < 0:
			animationPlayer.play("WalkUp")
	else:
		if lastVelocity.x > 0:
			animationPlayer.play("IdleRight")
		if lastVelocity.x < 0:
			animationPlayer.play("IdleLeft")
		if lastVelocity.y > 0:
			animationPlayer.play("IdleDown")
		if lastVelocity.y < 0:
			animationPlayer.play("IdleUp")
