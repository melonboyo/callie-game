extends Level
class_name Level3


func _enter_tree():
	GameState.current_level = 2


func level_specific_ready():
	if testing:
		return
	if GameState.exit == 4:
		$Checkpoints.checkpoint = 0
