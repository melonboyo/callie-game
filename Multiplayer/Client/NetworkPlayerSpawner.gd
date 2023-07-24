extends Node2D

var player_scene = preload("res://Multiplayer/Client/NetworkPlayer.tscn")

@onready var client: Client = get_parent()
@onready var players = $Players
var player_nodes := {}


func _ready():
	Network.player_disconnected.connect(remove_player)


func sync_player(player_id: int, state):
	if not "position" in state and not "level" in state:
		return
	
	var player = client.get_player()
	var level = client.get_current_level(player)
	if state.level == level:
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


func add_player(player_id: int):
	var new_player = player_scene.instantiate()
	player_nodes[player_id] = new_player
	players.add_child(new_player)


func remove_player(player_id: int):
	if player_id in player_nodes:
		player_nodes[player_id].queue_free()
		player_nodes.erase(player_id)


func taunt(stamp: int, player_id: int):
	var player = player_nodes[player_id]
	player.taunt(stamp, player_id)
