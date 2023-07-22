extends Node2D
class_name Level


func _ready():
	PaletteSwitch.current_palette = 12
	PaletteSwitch.set_fade(-0.9)
	var player: Player = $Player
	player.freeze = true
	player.position = %SpawnPoint.position
	await get_tree().create_timer(0.5).timeout
	PaletteSwitch.fade_in()
	player.freeze = false


func _on_death_zone_body_entered(body):
	PaletteSwitch.fade_out_in()
	$Player.freeze = true
	await get_tree().create_timer(0.71).timeout
	$Player.position = %SpawnPoint.position
	$Player.reset()
