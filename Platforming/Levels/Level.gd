extends Node2D
class_name Level


@onready var player: Player = $Player


func _ready():
	PaletteSwitch.current_palette = 12
	PaletteSwitch.set_fade(-0.9)
	player.freeze = true
	player.position = %SpawnPoint.position
	await get_tree().create_timer(0.5).timeout
	PaletteSwitch.fade_in()
	player.freeze = false


func _on_death_zone_body_entered(body):
	PaletteSwitch.fade_out_in()
	player.freeze = true
	await get_tree().create_timer(0.71).timeout
	player.position = %SpawnPoint.position
	player.reset()


func _on_exit_level_timer_timeout():
	get_tree().change_scene_to_packed(Levels.overworld)


func _on_exit_level(body, exit, direction):
	GameState.exit = exit
	player.exit_level = true
	player.exit_level_direction = direction
	$ExitLevelTimer.start()
	PaletteSwitch.fade_out()
