extends AudioStreamPlayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var stopping = false
var volume = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func play_music():
	stopping = false
	volume = 0
	self.play()

func stop_music():
	stopping = true
	volume = self.get_volume_db()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if stopping:
		volume -= delta/100
		if volume > -36:
			self.set_volume_db(volume)
		else:
			self.stop()
			stopping = false
			volume = 0
