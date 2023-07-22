extends StaticBody2D


func _on_area_2d_body_entered(body):
	if GameState.has_key:
		GameState.has_key = false
		queue_free()
