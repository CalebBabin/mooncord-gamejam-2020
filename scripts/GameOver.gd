extends Node2D

signal retry
signal restart

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _unhandled_input(_event:InputEvent):
	if Input.is_action_just_pressed("ui_1"):
		emit_signal("retry")
	if Input.is_action_just_pressed("ui_9"):
		emit_signal("restart")
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
