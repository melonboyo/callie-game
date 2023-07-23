extends Node2D
class_name Level


@onready var player: Player = $Player
@export var testing = false
#@onready var overworld := preload("res://Overworld/Overworld.tscn")


func _ready():
	PaletteSwitch.current_palette = 12
	PaletteSwitch.set_fade(-0.9)
	player.freeze = true
	level_specific_ready()
	player.position = %SpawnPoint.position
	await get_tree().create_timer(0.5).timeout
	PaletteSwitch.fade_in()
	player.freeze = false


func level_specific_ready():
	pass


func _on_death_zone_body_entered(body):
	$DeathPlayer.play()
	PaletteSwitch.fade_out_in()
	player.reset()
	player.freeze = true
	await get_tree().create_timer(0.71).timeout
	player.position = %SpawnPoint.position
	player.freeze = false


func _on_exit_level_timer_timeout():
	get_tree().change_scene_to_file("res://Overworld.tscn")


func _on_exit_level(body, exit, direction):
	GameState.exit = exit
	player.exit_level = true
	player.exit_level_direction = direction
	Music.stop()
	$ExitLevelTimer.start()
	PaletteSwitch.fade_out()


func _on_open_door():
	$OpenDoorPlayer.play()
