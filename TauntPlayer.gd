extends Node2D

@onready var taunt_player = $TauntPlayer

var total_taunts = 0
var taunt_sounds = [
	preload("res://Sounds/egg/close_door.ogg"), 
	preload("res://Sounds/egg/confirm.ogg"), 
	preload("res://Sounds/egg/eat.ogg"), 
	preload("res://Sounds/egg/effect_down.ogg"), 
	preload("res://Sounds/egg/error.ogg"), 
	preload("res://Sounds/egg/hunger_up.ogg"), 
	preload("res://Sounds/egg/jump.ogg"), 
	preload("res://Sounds/egg/next.ogg"), 
	preload("res://Sounds/egg/open_door.ogg"), 
	preload("res://Sounds/egg/sad.ogg"), 
	preload("res://Sounds/egg/select.ogg"), 
	preload("res://Sounds/egg/talk1.ogg"), 
	preload("res://Sounds/egg/talk2.ogg"), 
	preload("res://Sounds/egg/talk3.ogg"), 
	preload("res://Sounds/egg/talk4.ogg"), 
	preload("res://Sounds/egg/talk5.ogg"), 
	preload("res://Sounds/egg/talk6.ogg"), 
	preload("res://Sounds/egg/talk7.ogg"), 
	preload("res://Sounds/egg/tired_full.ogg"), 
	preload("res://Sounds/egg/window_slide.ogg"), 
	preload("res://Sounds/egg/win_small_thing.ogg"), 
	preload("res://Sounds/egg/wrong.ogg"),
]

func taunt(seed: int):
	var random_result = rand_from_seed(seed + total_taunts)
	var sound = taunt_sounds[random_result[0] % taunt_sounds.size()]
	$TauntPlayer.stream = sound
	$TauntPlayer.play()
	total_taunts += 1
