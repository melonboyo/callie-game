extends Node2D
class_name NetworkPlayerSpawner

var player_scene = preload("res://Multiplayer/Client/NetworkPlayer.tscn")

@onready var client: Client = get_parent()
@onready var players = $Players
var player_nodes := {}


func _ready():
	Network.player_disconnected.connect(remove_player)


func sync_player(player_id: int, state):
	if not "position" in state and not "level" in state:
		return
	
	if client.current_level == state.level:
		update_player(player_id, state)
	else:
		remove_player(player_id)


func update_player(player_id: int, state):
	if not player_id in player_nodes:
		add_player(player_id)
	
	var player = player_nodes[player_id] as NetworkPlayer
	player.position = state.position

	if "has_collision" in state:
		player.set_collision(state.has_collision)
	if "rotation" in state:
		player.rotation = state.rotation
	if "velocity" in state:
		player.linear_velocity = state.velocity
	if "animation" in state:
		player.set_animation(state.animation)
	if "is_minecarting" in state:
		player.set_minecarting(state.is_minecarting)
	if "has_key" in state:
		player.has_key = state.has_key


func add_player(player_id: int):
	var new_player = player_scene.instantiate()
	player_nodes[player_id] = new_player
	players.add_child(new_player)


func remove_player(player_id: int):
	if not player_id in player_nodes:
		return
	
	player_nodes[player_id].queue_free()
	player_nodes.erase(player_id)


func taunt(stamp: int, player_id: int):
	if not player_id in player_nodes:
		return
	
	var player := player_nodes[player_id] as NetworkPlayer
	player.taunt(stamp, player_id)


func play_audio(player_id: int, sound: Constants.Sound, volume_db: float, pitch_scale: float):
	if not player_id in player_nodes:
		return
	
	var player := player_nodes[player_id] as NetworkPlayer
	var audio_player := player.get_node("AudioPlayer") as PlayerAudioPlayer
	
	audio_player.set_volume_db(sound, volume_db)
	audio_player.set_pitch_scale(sound, pitch_scale)
	audio_player.play(sound)


func stop_audio(player_id: int, sound: Constants.Sound):
	if not player_id in player_nodes:
		return
	
	var player := player_nodes[player_id] as NetworkPlayer
	var audio_player := player.get_node("AudioPlayer") as PlayerAudioPlayer
	
	audio_player.stop(sound)
