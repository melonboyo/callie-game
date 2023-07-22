extends Control


var palettes := {
	1: preload("res://Textures/Palettes/01.png"),
	2: preload("res://Textures/Palettes/02.png"),
	3: preload("res://Textures/Palettes/03.png"),
	4: preload("res://Textures/Palettes/04.png"),
	5: preload("res://Textures/Palettes/05.png"),
	6: preload("res://Textures/Palettes/06.png"),
	7: preload("res://Textures/Palettes/07.png"),
	8: preload("res://Textures/Palettes/08.png"),
	9: preload("res://Textures/Palettes/09.png"),
	10: preload("res://Textures/Palettes/10.png"),
	11: preload("res://Textures/Palettes/11.png"),
	12: preload("res://Textures/Palettes/12.png"),
}

@onready var tween: Tween = create_tween()

var actual_palette = 0:
	set(value):
		actual_palette = Math.modi(value, palettes.size())

@export_range(1, 100) var current_palette: int = 1:
	set(value):
		current_palette = Math.modi(value - 1, palettes.size())
		current_palette += 1
		actual_palette = value - 1
		material.set_shader_parameter("palette", palettes[current_palette])

var fade_out_immediate = false


func _ready():
	if Engine.is_editor_hint():
		return
	material.set_shader_parameter("palette", palettes[current_palette])


func _process(_delta):
	if Engine.is_editor_hint():
		return
	
	if Input.is_action_just_pressed("ui_page_down"):
		current_palette += 1
		material.set_shader_parameter("palette", palettes[current_palette])
	elif Input.is_action_just_pressed("ui_page_up"):
		current_palette -= 1
		material.set_shader_parameter("palette", palettes[current_palette])


func fade_out():
	if not tween:
		return
	if tween.is_running():
		tween.stop()
	tween = create_tween()
	tween.tween_method(set_fade, 0.0, -0.9, 0.7)
	tween.play()


func fade_in():
	if not tween:
		return
	if tween.is_running():
		tween.stop()
	tween = create_tween()
	tween.tween_method(set_fade, -0.9, 0.0, 0.7)
	tween.play()


func fade_out_in():
	fade_out()
	await get_tree().create_timer(1.0).timeout
	fade_in()


func set_fade(value: float):
	material.set_shader_parameter("u_offset", value)
