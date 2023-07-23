extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	var args = Network.get_cmd_args()
	if args.error:
		get_tree().quit(args.error)
		return
	
	if args.server:
		Network.connected.connect(_on_connected)
		Network.create_dedicated_server(
			args.port, 
			args.max_players, 
			args.inactive_seconds, 
			args.lobby_token)
	else:
		get_tree().change_scene_to_file("res://Title.tscn")


func _on_connected():
	get_tree().change_scene_to_file("res://Game.tscn")
