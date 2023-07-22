extends Node2D


func _on_body_entered_checkpoint(body):
	get_parent().checkpoint = int(str(name))
