extends Node

func _ready():
	if DisplayServer.get_name() == "headless":
		Network.create_dedicated_server()
		get_tree().change_scene_to_file("res://Multiplayer/Server/Server.tscn")
	else:
		Network.create_remote_connection()
		get_tree().change_scene_to_file("res://Platforming/Levels/Level1.tscn")
