extends Node2D
class_name Overworld


var on_level = false
var entering_level = false
var level = 1

@onready var player = $Player
var camera_offset = Vector2.ZERO



func _on_start_level_body_exited(body):
	on_level = false
	camera_offset = Vector2.ZERO


func _ready():
	PaletteSwitch.set_fade(-0.9)
	player.freeze = true
	player.position = $Spawns.get_children()[GameState.exit].position
	await get_tree().create_timer(0.5).timeout
	PaletteSwitch.fade_in()
	Music.play(Music.Track.Overworld)
	player.freeze = false


func _process(delta):
	%Camera2D.offset = %Camera2D.offset.lerp(camera_offset, delta * 1.7)
	
	if not on_level and not entering_level:
		%EnterUI.visible = false
		return
	
	%EnterUI.visible = true
	if Input.is_action_just_pressed("interact"):
		entering_level = true
		PaletteSwitch.fade_out()
		await get_tree().create_timer(1.4).timeout
		
		get_tree().change_scene_to_file(levels[level])


#var levels := {
#	1: preload("res://Platforming/Levels/Level1.tscn"),
#	2: preload("res://Platforming/Levels/Level2.tscn"),
#	3: preload("res://Platforming/Levels/Level3.tscn"),
#}

var levels = {
	1: "res://Platforming/Levels/Level1.tscn",
	2: "res://Platforming/Levels/Level2.tscn",
	3: "res://Platforming/Levels/Level3.tscn",
}


func _on_start_level_1_body_entered(body, exit):
	level = 1
	GameState.current_level = 1
	GameState.exit = exit
	on_level = true
	if exit == 1:
		camera_offset = Vector2.RIGHT * 64.0
	else:
		camera_offset = Vector2.RIGHT * 64.0


func _on_start_level_2_body_entered(body, exit):
	level = 2
	GameState.current_level = 2
	GameState.exit = exit
	on_level = true
	camera_offset = Vector2.UP * 90.0


func _on_start_level_3_body_entered(body, exit):
	level = 3
	GameState.current_level = 3
	GameState.exit = exit
	on_level = true
	camera_offset = Vector2.UP * 76.0
