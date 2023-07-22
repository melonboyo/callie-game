@tool
extends Area2D
class_name CameraZone

var font = load("res://Fonts/Pixellari.ttf")


@export_range(0, 100) var id = 0:
	set(value):
		id = value
		queue_redraw()
@export var follow_y = false
@export var follow_x = true
@export_range(-2000, 2000) var y_offset = 0:
	set(value):
		y_offset = value
		queue_redraw()
@export_range(-2000, 2000) var x_focus = 0:
	set(value):
		x_focus = value
		queue_redraw()
signal camera_zone_entered(_y_offset, _follow_y, _x, _follow_x)
signal camera_zone_exited(_id)


func _on_body_entered(body):
	camera_zone_entered.emit(y_offset, follow_y, x_focus + position.x, follow_x, id)


func _on_body_exited(body):
	camera_zone_exited.emit(id)


func _draw():
	if not Engine.is_editor_hint():
		return
	font.antialiasing = 0
	if not follow_x:
		draw_string(font, x_focus * Vector2.RIGHT + y_offset * Vector2.DOWN, str(id), HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color.GREEN_YELLOW)
	draw_string(font, y_offset * Vector2.DOWN, str(id), HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color.RED)
