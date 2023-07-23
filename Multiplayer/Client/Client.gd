extends Node2D

@onready var network_sender = $NetworkSender
@onready var network_player_spawner = $NetworkPlayerSpawner
var has_online_collision := false

func _ready():
	Network.disconnected.connect(_on_disconnected)


func _process(delta: float):
	if Input.is_action_just_pressed("toggle_online_collision"):
		var player = get_player()
		has_online_collision = not has_online_collision
		player.set_collision_mask_value(9, has_online_collision)

	
func _on_disconnected():
	queue_free()


func get_player() -> Player:
	var nodes = get_tree().get_nodes_in_group("player")
	assert(nodes.size() == 1, "There is more than one player! oh no!")
	
	var player = nodes[0] as Player
	if not player is Player:
		return null
	
	return player


func get_current_level(player: Player):
	return player.get_parent().name


@rpc("any_peer", "unreliable")
func sync_player(state):
	var player_id = multiplayer.get_remote_sender_id()
	network_player_spawner.sync_player(player_id, state)
