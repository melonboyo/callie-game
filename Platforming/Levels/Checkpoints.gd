@tool
extends Node2D


@export_range(0, 20) var checkpoint = 0:
	set(value):
		var c = get_node_or_null(str(value))
		if not c:
			return
		checkpoint = value
		$SpawnPoint.position = c.position
		queue_redraw()


func _draw():
	if not Engine.is_editor_hint():
		return
	var c = get_node_or_null(str(checkpoint))
	if not c:
		return
	draw_circle(c.position, 10.0, Color.CRIMSON)
