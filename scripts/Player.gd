extends KinematicBody2D

signal fire_bullet
signal fire_slash
signal select_level
signal death

var damage_group = 0

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var velocity:Vector2
var lastX:float = 1
var lastVelocity = Vector2(0,0)
var lastPosition = Vector2(0,0)
var camera:Camera2D

var stats

onready var gun = $GunNode
onready var gunAnimation = $GunAnimationPlayer


var on_ground = false
var smashing = false
var firing_gun = false
var gun_equiped = false
var last_on_ground = 0
var damage_taken = 0
var last_hit_time = 0


const MAX_SPEED = 400
const ACCELERATION = 10
const FRICTION = 0.7
const JUMP_POWER = 800
const GUN_KNOCKBACK = 325
const GRAVITY = 20
const FLOOR = Vector2(0, -1)
const ANIMATION_THRESHOLD = 0
const JUMP_AVAILABILITY_TIMEOUT = 250
const KNOCKBACK_AMOUNT = 600
const ATTACK_KNOCKBACK_AMOUNT = 800
const GROUND_ANIMATION_THRESHOLD = 250
const DAMAGE_THRESHOLD = 5

var iframes_duration = 500

const MAX_GUN_SPEED = 5.0
const GUN_ACCELERATION = 0.5
var gun_speed = 0.0
var invincible = false

onready var animationPlayer = $AnimationPlayer

onready var HealthBubble = preload("res://scenes/HealthBubble.tscn")
func setup_health_bubbles():
	var children = $HealthNodes.get_children()
	for child in children:
		child.queue_free()
		
	var number_of_bubbles = DAMAGE_THRESHOLD - damage_taken;
	for i in range(0, ceil(number_of_bubbles)):
		var bubble = HealthBubble.instance()
		bubble.position.x = 15*(i - ceil(number_of_bubbles)/2)
		bubble.scale = Vector2(0.5,0.5)
		if i == floor(number_of_bubbles):
			var array = str(number_of_bubbles).split(".")
			print(array)
			if array.size() > 1:
				bubble.scale *= float("0." + str(number_of_bubbles).split(".")[1])
		$HealthNodes.add_child(bubble)

# Called when the node enters the scene tree for the first time.
func _ready():
	setup_camera()
	setup_health_bubbles()
	
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
	if Input.is_action_pressed("ui_down"):
		collision_mask = Util.convert_enum_to_bitmask([Constants.PhysicsMasks.WORLD_COLLISIONS])
		collision_layer = Util.convert_enum_to_bitmask([Constants.PhysicsMasks.WORLD_COLLISIONS])
	else:
		collision_mask = Util.convert_enum_to_bitmask([Constants.PhysicsMasks.WORLD_COLLISIONS, Constants.PhysicsMasks.PLATFORM_COLLISIONS])
		collision_layer = Util.convert_enum_to_bitmask([Constants.PhysicsMasks.WORLD_COLLISIONS, Constants.PhysicsMasks.PLATFORM_COLLISIONS])
	
	if Input.is_action_pressed("aim_up"):
		gun_equiped = true
	if Input.is_action_pressed("aim_down"):
		gun_equiped = false
	
	if Input.is_action_just_pressed("ui_accept"):
		if !firing_gun && !smashing:
			if gun_equiped:
				gunAnimation.play("Fire")
				firing_gun = true
				emit_signal("fire_bullet", self.position+gun.position, Vector2(cos(gun.rotation), sin(gun.rotation)), 90, Constants.PhysicsMasks.PLAYER_PROJECTILE_COLLISIONS)
				velocity += Vector2(cos(gun.rotation), sin(gun.rotation))*-1*GUN_KNOCKBACK
			else: 
				smashing = true
				if lastVelocity.x > 0:
					animationPlayer.play("SmashRight")
					emit_signal("fire_slash", self.position, Vector2(1, 0), 0, Constants.PhysicsMasks.PLAYER_PROJECTILE_COLLISIONS)
				elif lastVelocity.x < 0:
					animationPlayer.play("SmashLeft")
					emit_signal("fire_slash", self.position, Vector2(-1, 0), 0, Constants.PhysicsMasks.PLAYER_PROJECTILE_COLLISIONS)

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
	
	var hit_time_elapsed = OS.get_ticks_msec() - last_hit_time
	if hit_time_elapsed < iframes_duration:
		invincible = true
		if int(round(hit_time_elapsed/100)) % 2 == 0:
			modulate = Color(1, 0, 0, 0.5)
		else:
			modulate = Color(1, 1, 1, 1)
	else:
		invincible = false
		modulate = Color(1, 1, 1, 1)

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
		velocity.y += GRAVITY
	
	if Input.is_action_pressed("ui_right"):
		if velocity.x < 0:
			velocity.x = 0
		velocity.x += ACCELERATION
	if Input.is_action_pressed("ui_left"):
		if velocity.x > 0:
			velocity.x = 0
		velocity.x -= ACCELERATION

	if !Input.is_action_pressed("ui_left") && !Input.is_action_pressed("ui_right"):
		velocity.x = lerp(velocity.x, 0, FRICTION)

	velocity.x = max(-MAX_SPEED, min(MAX_SPEED, velocity.x))
	
	velocity = move_and_slide(velocity, FLOOR)
	
	if get_slide_count() > 0:
			var collision:KinematicCollision2D = get_slide_collision(0)
			var body:Object = collision.collider
			if body.has_method("get_level"):
				emit_signal("select_level", body.get_level())

	if (is_on_floor()):
		on_ground = true
		last_on_ground = OS.get_ticks_msec()
	else:
		on_ground = false

	lastPosition = self.position

	if !smashing:
		if !on_ground && OS.get_ticks_msec() - last_on_ground > GROUND_ANIMATION_THRESHOLD:
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
		elif Input.is_action_pressed("ui_down") && !Input.is_action_pressed("ui_left") && !Input.is_action_pressed("ui_right"):
			if velocity.x > 0:
				animationPlayer.play("CrouchRight")
			elif velocity.x < 0:
				animationPlayer.play("CrouchLeft")
			elif lastVelocity.x > 0:
				animationPlayer.play("CrouchRight")
			else:
				animationPlayer.play("CrouchLeft")
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
				animationPlayer.play("IdleRight")

func attack_hit(attack) -> void:
	velocity = attack.position.direction_to(position)*ATTACK_KNOCKBACK_AMOUNT

	receive_damage(attack.get_damage())

func projectile_hit(projectile) -> void:
	velocity += Vector2(projectile.velocity_direction.x, max(projectile.velocity_direction.y, 0.5))*KNOCKBACK_AMOUNT
	receive_damage(projectile.get_damage())
	

const hurt_sound_list = [
	"res://assets/sounds/ouch_1.wav",
	"res://assets/sounds/ouch_2.wav",
	"res://assets/sounds/ouch_3.wav",
	"res://assets/sounds/ouch_4.wav",
	"res://assets/sounds/ouch_5.wav"
]
func receive_damage(damage):
	if invincible:
		return
	Util.add_sound_to_node_by_sound_file(hurt_sound_list[randi() % hurt_sound_list.size()], self, true)
	damage_taken += damage
	last_hit_time = OS.get_ticks_msec()
	print(damage_taken, " damage taken")
	setup_health_bubbles()
	if damage_taken > DAMAGE_THRESHOLD:
		emit_signal("death")
