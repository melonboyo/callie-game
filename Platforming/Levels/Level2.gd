extends Level
class_name Level2


func _enter_tree():
	GameState.current_level = 2


func level_specific_ready():
	Music.play(Music.Track.Castle)
	for c in %KeyDoors.get_children():
		if GameState.opened_doors[2][c.id]:
			c.queue_free()
	if testing:
		return
	if GameState.exit == 3:
		$Checkpoints.checkpoint = 0
