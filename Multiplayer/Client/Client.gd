extends Node2D
class_name Client

@onready var network_sender := $NetworkSender as NetworkSender
@onready var network_player_spawner := $NetworkPlayerSpawner as NetworkPlayerSpawner
var has_online_collision := true
var current_level := ""

func _ready():
	Network.disconnected.connect(_on_disconnected)


func connect_player():
	var player = get_player()
	var audio_player = get_audio_player(player)
	audio_player.playing.connect(_on_playing_audio)
	audio_player.stopping.connect(_on_stopping_audio)


func for_all_players_in_level(callback: Callable):
	for player_id in network_player_spawner.player_nodes.keys():
		if player_id == 1 or player_id == multiplayer.get_unique_id():
			continue
		
		callback.call(player_id)


func _process(delta: float):
	var player = get_player()
	
	# Connect to any signals in the player when the level changes
	var new_level = player.get_parent().name
	if new_level != current_level:
		current_level = new_level
		connect_player()
	
	if Input.is_action_just_pressed("toggle_online_collision"):
		has_online_collision = not has_online_collision
	
	if Input.is_action_just_pressed("taunt"):
		var stamp = Time.get_ticks_msec()
		player.taunt(stamp)
		for_all_players_in_level(func (receiver_id: int): rpc_id(receiver_id, "taunt", stamp))
	
	player.set_collision_mask_value(9, has_online_collision)


func _on_disconnected():
	queue_free()


func _on_playing_audio(sound: Constants.Sound, volume_db: float, pitch_scale: float):
	for_all_players_in_level(func (receiver_id: int): rpc_id(receiver_id, "play_audio", sound, volume_db, pitch_scale))


func _on_stopping_audio(sound: Constants.Sound):
	for_all_players_in_level(func (receiver_id: int): rpc_id(receiver_id, "stop_audio", sound))


func get_player() -> Player:
	var nodes = get_tree().get_nodes_in_group("player")
	assert(nodes.size() == 1, "There is more than one player! oh no!")
	
	var player = nodes[0] as Player
	if not player is Player:
		return null
	
	return player


func get_audio_player(player: Player) -> PlayerAudioPlayer:
	return player.get_node("AudioPlayer") as PlayerAudioPlayer


@rpc("any_peer", "unreliable")
func sync_player(state):
	var player_id = multiplayer.get_remote_sender_id()
	network_player_spawner.sync_player(player_id, state)
  

@rpc("any_peer", "unreliable")
func taunt(stamp: int):
	var player_id = multiplayer.get_remote_sender_id()
	network_player_spawner.taunt(stamp, player_id)


@rpc("any_peer", "unreliable")
func play_audio(sound: Constants.Sound, volume_db: float, pitch_scale: float):
	var player_id = multiplayer.get_remote_sender_id()
	network_player_spawner.play_audio(player_id, sound, volume_db, pitch_scale)


@rpc("any_peer", "unreliable")
func stop_audio(sound: Constants.Sound):
	var player_id = multiplayer.get_remote_sender_id()
	network_player_spawner.stop_audio(player_id, sound)
