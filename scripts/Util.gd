extends Node

# Given a array of enumeration values that represent bitmask flags (like
# collision_mask for a KinematicBody2D), this will convert the 0-indexed
# enumeration values to power-of-two bitwise-OR'd bitmask values. For example,
# if you have an enum like enum CollisionMasks { WORLD, PLAYER, ENEMY }, and you
# pass in [CollisionMasks.WORLD, CollisionMasks.ENEMY], then you're really
# passing in [0, 2], which will turn into (2^0 | 2^2) or 5.
static func convert_enum_to_bitmask(enum_values:Array) -> int:
	var bit_mask:int = 0
	for enum_value in enum_values:
		bit_mask |= int(pow(2, enum_value))

	return bit_mask

# Plays the sound file at the specified path. This will be added to "node" and
# will automatically be freed when the sound is done playing.
static func add_sound_to_node_by_sound_file(sound_path:String, node:Node, d2 = false) -> void:
	var audio_stream_player
	if d2:
		audio_stream_player = AudioStreamPlayer2D.new()
		audio_stream_player.max_distance = 3000
	else:
		audio_stream_player = AudioStreamPlayer.new()
	var audio_stream_sample:AudioStreamSample = load(sound_path)
	
	audio_stream_player.autoplay = true
	audio_stream_player.stream = audio_stream_sample
	audio_stream_player.bus = "Sounds"
	
	var _ignored = audio_stream_player.connect("finished", audio_stream_player, "queue_free")
	node.add_child(audio_stream_player)
