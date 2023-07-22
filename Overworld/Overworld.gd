extends Node2D


var on_level = false
var entering_level = false
var level = 1

@onready var player = $Player


func _on_start_level_1_body_entered(body, exit):
	level = 1
	GameState.exit = exit
	on_level = true


func _on_start_level_1_body_exited(body):
	on_level = false


func _ready():
	PaletteSwitch.set_fade(-0.9)
	player.freeze = true
	player.position = $Spawns.get_children()[GameState.exit].position
	await get_tree().create_timer(0.5).timeout
	PaletteSwitch.fade_in()
	Music.play(Music.Track.Overworld)
	player.freeze = false


func _process(delta):
	if not on_level and not entering_level:
		%EnterUI.visible = false
		return
	
	%EnterUI.visible = true
	if Input.is_action_just_pressed("interact"):
		entering_level = true
		PaletteSwitch.fade_out()
		await get_tree().create_timer(1.4).timeout
		get_tree().change_scene_to_packed(Levels.levels[1])
