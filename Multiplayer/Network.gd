extends Node

var public_server_host = "localhost" if OS.is_debug_build() else "callie.pckv.me"

var public_server_port = 45276

const TICKS_PER_SECOND = 1.0 / 60.0

signal connected
signal disconnected
signal is_connecting_changed(is_connecting: bool)
signal player_connected(id: int)
signal player_changed(id: int)
signal player_disconnected(id: int)

var client

var is_server := false
var server_peer: MultiplayerPeer = null

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


func create_server(port: int) -> ENetMultiplayerPeer:
	is_connecting = true
	var peer = ENetMultiplayerPeer.new()
	multiplayer.peer_connected.connect(self._on_player_connected)
	multiplayer.peer_disconnected.connect(self._on_player_disconnected)
	peer.create_server(port)
	print('server listening on 0.0.0.0:%s' % port)
	is_server = true
	return peer


func create_dedicated_server():
	var peer = create_server(public_server_port)
	multiplayer.set_multiplayer_peer(peer)
	server_peer = peer

	is_connected = true
	is_connecting = false

	emit_signal("connected")


func create_remote_connection():
	is_connecting = true
	var peer = ENetMultiplayerPeer.new()
	print('connecting to server %s:%s' % [public_server_host, public_server_port])
	peer.create_client(public_server_host, public_server_port)
	multiplayer.connected_to_server.connect(self._on_server_connected)
	multiplayer.connection_failed.connect(self._on_connection_failed)
	multiplayer.server_disconnected.connect(self._on_server_disconnected)
	multiplayer.set_multiplayer_peer(peer)


func shutdown_server():
	get_tree().quit()


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
	emit_signal("connected")


@rpc("call_local")
func register_player(info):
	# Check if the player is already registered
	var is_registered = players.has(info.id)
	
	# Update player info
	players[info.id] = info
	
	# Fire event based on whether the player was modified or just connected
	if is_registered:
		emit_signal("player_changed", info.id)
	else:
		emit_signal("player_connected", info.id)


@rpc("call_local")
func unregister_player(id: int):
	# Remove the player info
	players.erase(id)
	emit_signal("player_disconnected", id)


func _on_server_connected():
	var client_scene = load("res://Multiplayer/Client/Client.tscn") as PackedScene
	client = client_scene.instantiate()
	add_child(client)

	is_connected = true
	is_connecting = false


func _on_server_disconnected():
	multiplayer.server_disconnected.disconnect(self._on_server_disconnected)
	
	is_connected = false
	
	emit_signal("disconnected")


func _on_connection_failed():
	print("Failed to connect")
