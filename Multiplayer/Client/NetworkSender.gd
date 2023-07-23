extends Node

@onready var client = get_parent()

# Responsible for sending client data to the server
func _on_tick_timer_tick():
	var player = client.get_player()
	if player == null:
		print("Player is null.. why...")
		return
	
	var level = client.get_current_level(player)
	
	for network_player in Network.players.values():
		send_state(network_player.id, level, player)


func send_state(receiver_id, level, player):
	if receiver_id == 1 or receiver_id == multiplayer.get_unique_id():
		return
	
	var animation = player.get_animation()
	client.rpc_id(receiver_id, "sync_player", {
		level = level,
		position = player.position,
		rotation = player.rotation,
		velocity = player.velocity,
		animation = player.get_animation(),
		is_minecarting = player.is_minecarting or player.is_entering_minecart,
	})
