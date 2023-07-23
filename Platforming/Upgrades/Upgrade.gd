extends Node2D
class_name Upgrade


func _on_area_2d_body_entered(body):
	pick_up()
	$Area2D.set_deferred("monitoring", false)
	$PickUpPlayer.play()
	$SpinPlayer.speed_scale = 20.0
	var tween = create_tween()
	tween.set_parallel()
	tween.finished.connect(_on_tween_finished)
	tween.tween_property($SpinPlayer, "speed_scale", 2.0, 1.0).from_current().set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 1.0).from_current().set_ease(Tween.EASE_OUT)


func _on_tween_finished():
	queue_free()


func pick_up():
	pass
