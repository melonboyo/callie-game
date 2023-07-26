extends RigidBody2D
class_name NetworkPlayer

var rigid_minecart_scene = preload("res://Platforming/Upgrades/MinecartRigid.tscn")
var key_scene = preload("res://Platforming/Interact/Key.tscn")


@onready var sprite := $PlayerSprite
@onready var minecart := $Minecart
@onready var animation_player := $AnimationPlayer
@onready var taunt_player := $TauntPlayer as TauntPlayer
@onready var audio_player := $AudioPlayer as PlayerAudioPlayer

var current_character := 0

var is_minecarting = false
var has_key = false

var pick_up: Node2D = null


func _process(delta):
	if has_key and not pick_up is Key:
		var key = key_scene.instantiate()
		key.is_picked_up = true
		key.modulate = Constants.SECONDARY_COLOR
		get_parent().add_child(key)
		pick_up = key
	if not has_key and pick_up is Key:
		remove_pick_up()
	
	animate_pick_up(delta)


func _exit_tree():
	if pick_up != null:
		remove_pick_up()


func animate_pick_up(delta):
	if pick_up == null:
		return
	var direction_to_player = pick_up.position.direction_to(position)
	var desired_position = position - direction_to_player * 12.0
	var distance_to = pick_up.position.distance_to(desired_position)
	var follow_speed = clampf(distance_to / 28.0, 0.0, 1.0) * 3.8
	pick_up.position = pick_up.position.lerp(desired_position, delta * follow_speed)


func remove_pick_up():
	pick_up.queue_free()
	pick_up = null


func set_collision(collision: bool):
	set_collision_layer_value(9, collision)


func change_character(character: int):
	if character == current_character:
		return
	
	current_character = character
	
	var character_scene = load(Constants.character_scenes[character])
	var new_sprite = character_scene.instantiate()
	var old_sprite = sprite
	
	sprite.replace_by(new_sprite)
	old_sprite.queue_free()
	sprite = new_sprite


func set_animation(animation_state):
	if sprite.animation != animation_state.animation:
		sprite.play(animation_state.animation)
	sprite.flip_h = animation_state.flip_h
	sprite.offset.y = animation_state.offset_y


func is_wall_running():
	return rotation != 0


func set_minecarting(new_is_minecarting: bool):
	if new_is_minecarting and not is_minecarting:
		print("start minecarting")
		is_minecarting = true
		animation_player.play("enter_minecart")
	if not new_is_minecarting and is_minecarting:
		print("stop minecarting")
		is_minecarting = false
		minecart.visible = false
		var minecart_instance = rigid_minecart_scene.instantiate()
		if is_wall_running():
			minecart_instance.linear_velocity.y = linear_velocity.y
		else:
			minecart_instance.linear_velocity.x = linear_velocity.x
		minecart_instance.position = position
		minecart_instance.rotation = rotation
		get_parent().add_child(minecart_instance)


func taunt(stamp: int, player_id: int):
	taunt_player.taunt(stamp, player_id)


func _on_animation_player_animation_finished(anim_name):
	pass 
