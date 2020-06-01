extends Node

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
