extends RigidBody2D

var rigid_minecart_scene = preload("res://Platforming/Upgrades/MinecartRigid.tscn")


@onready var sprite = $PlayerSprite
@onready var minecart = $Minecart
@onready var animation_player = $AnimationPlayer
@onready var taunt_player = $TauntPlayer

var is_minecarting = false


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


func taunt(player_id: int):
	taunt_player.taunt(player_id)


func _on_animation_player_animation_finished(anim_name):
	pass 
