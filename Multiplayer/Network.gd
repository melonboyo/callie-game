extends Node

const TICKS_PER_SECOND = 1.0 / 60.0

signal connected
signal disconnected
signal failed_to_connect
signal is_connecting_changed(is_connecting: bool)
signal player_connected(id: int)
signal player_changed(id: int)
signal player_disconnected(id: int)

var client

var is_server := false
var server_peer: MultiplayerPeer = null

var address: ServerAddress = null

var is_connected := false:
	set(value):
		is_connected = value
		if is_connected:
			print("Connected!")
		else:
			print("Disconnected")

var is_connecting := false:
	set(value):
		is_connecting = value
		emit_signal("is_connecting_changed", is_connecting)

var players := {}
var client_info := {
	id = 0,
}:
	get:
		if players.has(multiplayer.get_unique_id()) and (not is_server):
			return players[multiplayer.get_unique_id()]
		return client_info
	set(value):
		# TODO: send new client_info to server/peers?
		emit_signal("client_info_changed")
		client_info = value


func set_address(server_address: ServerAddress):
	address = server_address


func create_server() -> ENetMultiplayerPeer:
	is_connecting = true
	var peer = ENetMultiplayerPeer.new()
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	peer.create_server(address.port)
	print('server listening on 0.0.0.0:%s' % address.port)
	is_server = true
	return peer


func create_dedicated_server():
	var peer = create_server()
	multiplayer.set_multiplayer_peer(peer)
	server_peer = peer

	is_connected = true
	is_connecting = false

	emit_signal("connected")


func create_remote_connection():
	is_connecting = true
	var peer: MultiplayerPeer
	if OS.has_feature("web"):
		peer = WebRTCMultiplayerPeer.new()
	else:
		peer = ENetMultiplayerPeer.new()
	
	print('connecting to server %s:%s' % [address.host, address.port])
	multiplayer.connected_to_server.connect(_on_server_connected)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	peer.create_client(address.host, address.port)
	multiplayer.set_multiplayer_peer(peer)
	
	var client_scene = load("res://Multiplayer/Client/Client.tscn") as PackedScene
	client = client_scene.instantiate()
	add_child(client)


func disconnect_from_server():
	for peer in multiplayer.get_peers():
		multiplayer.multiplayer_peer.disconnect_peer(peer)


func _on_player_connected(id: int) -> void:
	print("Player %s connected" % id)
	rpc_id(id, "send_client_info")


func _on_player_disconnected(id: int) -> void:
	print("Player %s disconnected" % id)
	rpc("unregister_player", id)


@rpc
func send_client_info():
	rpc_id(1, "init", client_info)


@rpc("any_peer")
func init(info):
	# Init should only be handled by the server
	if not multiplayer.is_server():
		return
	
	# If this is the first player to connect, assign them the role as host
	if players.size() == 0:
		info.host = true
	
	# Update the player info on the server
	info.id = multiplayer.get_remote_sender_id()
	
	# Tell everyone including ourself the new player's info
	rpc("register_player", info)
	
	# Send the connected player list and server configuration to the new player
	rpc_id(info.id, "player_init", players)


@rpc
func player_init(players):
	# Assign server state
	self.players = players
	
	# Load into the game lobby
	connected.emit()


@rpc("call_local")
func register_player(info):
	# Check if the player is already registered
	var is_registered = players.has(info.id)
	
	# Update player info
	players[info.id] = info
	
	# Fire event based on whether the player was modified or just connected
	if is_registered:
		player_changed.emit(info.id)
	else:
		player_connected.emit(info.id)


@rpc("call_local")
func unregister_player(id: int):
	# Remove the player info
	players.erase(id)
	player_disconnected.emit(id)


func for_all_players(callback: Callable):
	for network_player in players.values():
		if network_player.id == 1 or network_player.id == multiplayer.get_unique_id():
			continue
		
		callback.call(network_player.id)


func _on_server_connected():
	is_connected = true
	is_connecting = false


func reconnect_to_server(in_seconds: int = 0):
	if in_seconds > 0:
		print("Reconnecting in ", in_seconds, " seconds...")
		await get_tree().create_timer(in_seconds).timeout
	else:
		print("Reconnecting...")
	
	create_remote_connection()


func _on_server_disconnected():
	multiplayer.server_disconnected.disconnect(self._on_server_disconnected)
	
	is_connected = false
	
	disconnected.emit()
	
	reconnect_to_server()


func _on_connection_failed():
	is_connecting = false
	print("Failed to connect.")
	failed_to_connect.emit()
	
	reconnect_to_server()
