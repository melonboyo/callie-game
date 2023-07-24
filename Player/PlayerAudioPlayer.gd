extends Node2D
class_name PlayerAudioPlayer

signal playing(sound: Constants.Sound, volume_db: float, pitch_scale: float)
signal stopping(sound: Constants.Sound)

var sound_players := {}


func get_sound_player(sound: Constants.Sound) -> AudioStreamPlayer2D:
	return sound_players[sound]


func _ready():
	sound_players = {
		Constants.Sound.JUMP: $JumpPlayer,
		Constants.Sound.STEP_GRASS: $StepGrassPlayer,
		Constants.Sound.STEP_CONCRETE: $StepConcretePlayer,
		Constants.Sound.STEP_WOOD: $StepWoodPlayer,
		Constants.Sound.CLIMB: $ClimbPlayer,
		Constants.Sound.MINECART_GO: $MinecartGoPlayer,
		Constants.Sound.MINECART_JUMP: $MinecartJumpPlayer,
		Constants.Sound.MINECART_EXIT: $MinecartExitPlayer,
		Constants.Sound.MINECART_DRIVING: $MinecartDrivingPlayer,
	}


func set_pitch_scale(sound: Constants.Sound, pitch_scale: float):
	get_sound_player(sound).pitch_scale = pitch_scale


func set_volume_db(sound: Constants.Sound, volume_db: float):
	get_sound_player(sound).volume_db = volume_db


func is_playing(sound: Constants.Sound):
	return get_sound_player(sound).playing


func play(sound: Constants.Sound):
	var sound_player = get_sound_player(sound)
	if sound_player.has_method("play_random_sound"):
		sound_player.play_random_sound()
	else:
		sound_player.play()
	
	playing.emit(sound, sound_player.volume_db, sound_player.pitch_scale)


func stop(sound: Constants.Sound):
	var sound_player = get_sound_player(sound)
	get_sound_player(sound).stop()
	
	stopping.emit(sound)
