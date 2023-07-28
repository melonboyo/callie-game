extends Level
class_name Level4


func _enter_tree():
	GameState.current_level = 1


func level_specific_ready():
	Music.play(Music.Track.Forest)
	for c in %KeyDoors.get_children():
		if GameState.opened_doors[1][c.id]:
			c.queue_free()
	if testing:
		return
	if GameState.exit == 1:
		$Checkpoints.checkpoint = 0
	elif GameState.exit == 2:
		$Checkpoints.checkpoint = 5
