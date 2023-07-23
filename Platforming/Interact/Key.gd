extends Area2D
class_name Key


signal key_picked_up(key)

var is_picked_up = false
@export var id = 0

func _on_body_entered(body):
	if is_picked_up:
		return
	key_picked_up.emit(self)
	GameState.has_key = true
	$SpinPlayer.speed_scale = 20.0
	$PickUpPlayer.play()
	create_tween().tween_property($SpinPlayer, "speed_scale", 2.0, 2.0).from_current().set_ease(Tween.EASE_OUT)
	is_picked_up = true


func _ready():
#	print(GameState.opened_doors[GameState.current_level][id])
	if GameState.opened_doors[GameState.current_level][id]:
		queue_free()
