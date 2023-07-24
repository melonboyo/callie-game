extends Node2D

@onready var taunt_player = $TauntPlayer

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


func taunt(seed: int):
	var random_result = rand_from_seed(seed)
	var sound = taunt_sounds[random_result[0] % taunt_sounds.size()]
	$TauntPlayer.stream = sound
	$TauntPlayer.play()
