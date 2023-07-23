extends Level
class_name Level2


func _enter_tree():
	GameState.current_level = 2


func level_specific_ready():
	if testing:
		return
	if GameState.exit == 3:
		$Checkpoints.checkpoint = 0
