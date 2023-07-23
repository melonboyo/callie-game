extends StaticBody2D


var is_crumbling = false
var player: Node2D = null


func _physics_process(delta):
	if Engine.is_editor_hint():
		return
	if not player:
		return
	if is_crumbling:
		return
	var velocity
	if player is Player:
#		velocity = player.velocity
		if player.is_on_floor() or player.was_on_floor:
			velocity = Vector2.DOWN * 100.0
		else:
			velocity = Vector2.UP * 100.0
	elif player is RigidBody2D:
		velocity = player.linear_velocity
	else:
		return
#	print((position.direction_to(player.position)).y, ", ", velocity.y, ", ", (position.direction_to(player.position).y < 0.0 and velocity.y > -1.0))
	if (position.direction_to(player.position).y < 0.0 and velocity.y > -1.0):
		crumble()


func _on_area_2d_body_entered(body):
	if not body is Node2D:
		return
	player = body
	var velocity
	if player is Player:
#		velocity = player.velocity
		if player.is_on_floor() or player.was_on_floor:
			velocity = Vector2.DOWN * 100.0
		else:
			velocity = Vector2.UP * 100.0
	elif player is RigidBody2D:
		velocity = player.linear_velocity
	else:
		return
#	print((position.direction_to(player.position)).y, ", ", velocity.y, ", ", (position.direction_to(player.position).y < 0.0 and velocity.y > -1.0))
	if (position.direction_to(player.position).y < 0.0 and velocity.y > -1.0):
		crumble()


func crumble():
	is_crumbling = true
	$AnimationPlayer.play("crumble")


func _on_area_2d_body_exited(body):
	if not body is Node2D:
		return
	player = null


func disable_platform(value: bool):
	if value:
		$CollisionShape2D.disabled = true
		$CrumblePlayer.play()


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "crumble":
		is_crumbling = false
