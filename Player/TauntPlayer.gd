extends Node2D
class_name TauntPlayer

@onready var taunt_player := $TauntPlayer as AudioStreamPlayer2D

var taunt_sounds = [
	preload("res://Sounds/taunts/taunt1.ogg"),
	preload("res://Sounds/taunts/taunt2.ogg"),
	preload("res://Sounds/taunts/taunt3.ogg"),
	preload("res://Sounds/taunts/taunt4.ogg"),
	preload("res://Sounds/taunts/taunt5.ogg"),
	preload("res://Sounds/taunts/taunt6.ogg"),
	preload("res://Sounds/taunts/taunt7.ogg"),
	preload("res://Sounds/taunts/taunt8.ogg"),
	preload("res://Sounds/taunts/taunt9.ogg"),
	preload("res://Sounds/taunts/taunt10.ogg"),
	preload("res://Sounds/taunts/taunt11.ogg"),
	preload("res://Sounds/taunts/taunt12.ogg"),
	preload("res://Sounds/taunts/taunt13.ogg"),
	preload("res://Sounds/taunts/taunt14.ogg"),
	preload("res://Sounds/taunts/taunt15.ogg"),
	preload("res://Sounds/taunts/taunt16.ogg"),
	preload("res://Sounds/taunts/taunt17.ogg"),
	preload("res://Sounds/taunts/taunt18.ogg"),
	preload("res://Sounds/taunts/taunt19.ogg"),
	preload("res://Sounds/taunts/taunt20.ogg"),
	preload("res://Sounds/taunts/taunt21.ogg"),
	preload("res://Sounds/taunts/taunt22.ogg"),
	preload("res://Sounds/taunts/taunt23.ogg"),
	preload("res://Sounds/taunts/taunt24.ogg"),
	preload("res://Sounds/taunts/taunt25.ogg"),
	preload("res://Sounds/taunts/taunt26.ogg"),
	preload("res://Sounds/taunts/taunt27.ogg"),
	preload("res://Sounds/taunts/taunt28.ogg"),
	preload("res://Sounds/taunts/taunt29.ogg"),
	preload("res://Sounds/taunts/taunt30.ogg"),
	preload("res://Sounds/taunts/taunt31.ogg"),
	preload("res://Sounds/taunts/taunt32.ogg"),
	preload("res://Sounds/taunts/taunt33.ogg"),
	preload("res://Sounds/taunts/taunt34.ogg"),
	preload("res://Sounds/taunts/taunt35.ogg"),
	preload("res://Sounds/taunts/taunt36.ogg"),
	preload("res://Sounds/taunts/taunt37.ogg"),
	preload("res://Sounds/taunts/taunt38.ogg"),
]


func taunt(stamp: int, player_id: int):
	var taunt_result = rand_from_seed(player_id + stamp)
	var sound = taunt_sounds[taunt_result[0] % taunt_sounds.size()]
	$TauntPlayer.stream = sound
	
	var pitch_result = rand_from_seed(player_id)
	var pitch_variance = float(pitch_result[0] % 100)
	$TauntPlayer.pitch_scale = remap(pitch_variance, 0, 100, 0.7, 1.3)
	
	$TauntPlayer.play()
