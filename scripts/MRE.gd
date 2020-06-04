extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal game_over
signal select_level

var camera:Camera2D
var hand
var hand_sprite
var grasp = false
var hand_velocity = Vector2.ZERO

const HAND_ACCEL = 10
const HAND_MAX_SPEED = 300
const HAND_REACH = 128

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = Camera2D.new()
	camera.name = "Camera2D"
	camera.current = true
	add_child(camera)
	
	hand = $Hand
	hand_sprite = $Hand/HandSprite

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#hand_sprite.frame = 0
	var input_velocity = Vector2.ZERO
	if Input.is_action_pressed("ui_left"):
		input_velocity.x += -1
	if Input.is_action_pressed("ui_right"):
		input_velocity.x += 1
	if Input.is_action_pressed("ui_up"):
		input_velocity.y += -1
	if Input.is_action_pressed("ui_down"):
		input_velocity.y += 1
	
	hand_velocity = hand_velocity.move_toward(input_velocity.normalized()*HAND_MAX_SPEED, HAND_ACCEL)
	
	hand.position += hand_velocity*delta


func _unhandled_input(_event:InputEvent):
	if Input.is_action_just_pressed("ui_accept"):
		grasp = !grasp
		if grasp:
			hand_sprite.frame = 1
		else:
			hand_sprite.frame = 0
