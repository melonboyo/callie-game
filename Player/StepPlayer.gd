extends AudioStreamPlayer2D
class_name StepPlayer

enum StepSound {
	GRASS,
	CONCRETE,
	WOOD,
}

@export var step_sound := StepSound.GRASS

var step_sounds_grass := [
	preload("res://Sounds/kenney_impact-sounds/Audio/footstep_grass_000.ogg"),
#	preload("res://Sounds/kenney_impact-sounds/Audio/footstep_grass_001.ogg"),
#	preload("res://Sounds/kenney_impact-sounds/Audio/footstep_grass_002.ogg"),
	preload("res://Sounds/kenney_impact-sounds/Audio/footstep_grass_003.ogg"),
	preload("res://Sounds/kenney_impact-sounds/Audio/footstep_grass_004.ogg"),
]

var step_sounds_concrete := [
	preload("res://Sounds/kenney_impact-sounds/Audio/footstep_concrete_000.ogg"),
	preload("res://Sounds/kenney_impact-sounds/Audio/footstep_concrete_001.ogg"),
	preload("res://Sounds/kenney_impact-sounds/Audio/footstep_concrete_002.ogg"),
	preload("res://Sounds/kenney_impact-sounds/Audio/footstep_concrete_003.ogg"),
	preload("res://Sounds/kenney_impact-sounds/Audio/footstep_concrete_004.ogg"),
]

var step_sounds_wood := [
	preload("res://Sounds/kenney_impact-sounds/Audio/footstep_wood_000.ogg"),
	preload("res://Sounds/kenney_impact-sounds/Audio/footstep_wood_001.ogg"),
	preload("res://Sounds/kenney_impact-sounds/Audio/footstep_wood_002.ogg"),
	preload("res://Sounds/kenney_impact-sounds/Audio/footstep_wood_003.ogg"),
	preload("res://Sounds/kenney_impact-sounds/Audio/footstep_wood_004.ogg"),
]

var step_sounds := {
	StepSound.GRASS: step_sounds_grass,
	StepSound.CONCRETE: step_sounds_concrete,
	StepSound.WOOD: step_sounds_wood,
}


func play_random_sound(from: float = 0.0):
	var sounds = step_sounds[step_sound]
	var sound = sounds[randi_range(0, sounds.size() - 1)]
	stream = sound
	play(from)
