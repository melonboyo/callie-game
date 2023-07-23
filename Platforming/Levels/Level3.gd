extends Level
class_name Level3


func _enter_tree():
	GameState.current_level = 2


func level_specific_ready():
	Music.play(Music.Track.Mountain)
	if testing:
		return
	if GameState.exit == 4:
		$Checkpoints.checkpoint = 0


func end():
	PaletteSwitch.fade_out()
	await get_tree().create_timer(0.71).timeout
	get_tree().change_scene_to_file("res://OverworldCar.tscn")


func _on_exit_level_5_body_entered(body):
	end()
