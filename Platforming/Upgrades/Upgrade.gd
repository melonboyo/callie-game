extends Node2D
class_name Upgrade


func _on_area_2d_body_entered(body):
	pick_up()
	queue_free()


func pick_up():
	pass
