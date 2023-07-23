extends StaticBody2D



@export var id = 0

signal open_door()


func _on_area_2d_body_entered(body):
	if GameState.has_key:
		GameState.has_key = false
		open_door.emit()
		GameState.opened_doors[GameState.current_level][id] = true
		queue_free()


func _ready():
	if GameState.opened_doors[GameState.current_level][id]:
		queue_free()
