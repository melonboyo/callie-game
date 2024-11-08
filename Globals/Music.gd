extends Node

enum Track {
	Overworld,
	Forest,
	Castle,
	Mountain
}

var streams = {
	Track.Forest : preload("res://Sounds/music/forest theme (you are on your way!).ogg"),
	Track.Overworld : preload("res://Sounds/music/overworld pog.ogg"),
	Track.Castle : preload("res://Sounds/music/castle theme (you are on a minecart!).ogg"),
	Track.Mountain : preload("res://Sounds/music/2023-07-23_deff_mountain.ogg")
}

var volume = 0
var volumes = {
	Track.Forest : -14.5,
	Track.Overworld : -16.5,
	Track.Castle : -17.5,
	Track.Mountain : -17.5
}

var selected_track = null
var music_player: AudioStreamPlayer
var position:
	get:
		return floori(music_player.get_playback_position() * 1000)


func _ready():
	music_player = AudioStreamPlayer.new()
	music_player.volume_db = -80.0
	music_player.bus = "Music"
	add_child(music_player)


func play(track: Track):
	if streams[track] == null:
		return
	
	selected_track = track
	music_player.stream = streams[track]
	music_player.volume_db = volumes[track] + volume
	music_player.play()


func stop():
	var fade_out_tween = create_tween()
	fade_out_tween.tween_property(music_player, "volume_db", -80, 1.2).from_current()
