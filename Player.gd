@tool
extends CharacterBody2D
class_name Player

const MAX_RUN_SPEED = 112.0
const MAX_AIR_SPEED = 166.0
const MAX_CLIMB_SPEED = 60.0
const MAX_WALL_RUN_SPEED = 162.0
const ACCELERATION = 5.15
const AIR_ACCELERATION = 2.62
const CLIMB_ACCELERATION = 12.0
const MAX_FALL_SPEED = 300.0
const LOOK_OFFSET = 32.0
const OVERWORLD_SPEED = 87.0
const MINECART_START_SPEED = 210.0
const MINECART_SPEED = 170.0
const BOOTS_BOOST = 30.0

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

var step_sounds := [
	step_sounds_grass,
	step_sounds_concrete,
	step_sounds_wood
]

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var jump_velocity = -285.0
@export_range(1, 5) var jump_height: int = 2:
	set(value):
		jump_height = value
		var jump_height_pixels = value * 16.0
		jump_velocity = -sqrt(2 * gravity * jump_height_pixels) - 10.0


var last_strong_direction_x = 1.0
var hold_jump = false
var direction_x = 0.0
var direction_y = 0.0

var is_climbing = false
var can_climb = false
var first_climb_frame = false
var climb_x = 0.0

var was_on_floor = true
var jumped_last_frame = false
var jumped = false

var freeze = false
@export var is_in_overworld = false:
	set(value):
		is_in_overworld = value
		if value:
			motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
		else:
			motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
			
var exit_level = false
var exit_level_direction = Vector2.RIGHT

var is_minecarting = false
var is_entering_minecart = false
var minecart_direction = 1.0
var rigid_minecart = preload("res://Platforming/Upgrades/MinecartRigid.tscn")
var can_use_minecart = true

var is_wall_running = false
var can_wall_run = true
var wall_direction = 1.0
var boots_timeout = false
var direction_timeout = false

var pick_up: Node2D

@onready var sprite = %PlayerSprite


func _ready():
	if Engine.is_editor_hint():
		return
	jump_height = jump_height


func _process(delta):
	if Engine.is_editor_hint():
		return
	direction_x = Input.get_axis("move_left", "move_right")
	direction_y = Input.get_axis("move_up", "move_down")
	
	if GameState.has_upgrade(GameState.Upgrade.Jump1):
		jump_height = 2
	
	if Input.is_action_just_pressed("do_jump"):
		$JumpBufferEarly.start()


func _physics_process(delta):
	if Engine.is_editor_hint():
		return
	
	if not is_wall_running:
		rotation = 0.0
	
	if freeze:
		velocity = Vector2.ZERO
		return
	
	if is_in_overworld:
		overworld_move(delta)
		return
	
	if last_strong_direction_x < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	
	if exit_level:
		exit_level_move(delta)
		animate()
		return
	
	set_collision_mask_value(4, true)
	
	animate_pick_up(delta)
	
	if is_on_floor():
		can_use_minecart = true
		can_wall_run = true
	
	if GameState.acquired_upgrades[GameState.Upgrade.Boots]:
		$WallCast.enabled = true
		$WallCast.target_position = Vector2(last_strong_direction_x, 0.0).normalized() * 16.0
	
	if (GameState.acquired_upgrades[GameState.Upgrade.Boots] and 
		is_on_wall() and
		direction_x and
		(abs(velocity.x) > 2.0 or not is_on_floor()) and
		can_wall_run and 
		not is_wall_running
	):
		if $WallCast.is_colliding():
			is_wall_running = true
			wall_direction = last_strong_direction_x
			velocity.y = -abs(velocity.x) * 0.2 + velocity.y * 0.9 - BOOTS_BOOST
			velocity.x = wall_direction * 20.0
			$BootsTimer.start()
	
	if is_wall_running:
		$WallCast.target_position = Vector2.DOWN * 16.0
		boots_move(delta)
		if is_wall_running:
			return
	
	$StepPlayer.pitch_scale = 1.0
	boots_timeout = false
	direction_timeout = false
	if not $DirectionHeldTimer.is_stopped():
		$DirectionHeldTimer.stop()
	if not $BootsCooldownTimer.is_stopped():
		$BootsCooldownTimer.stop()
	if not $BootsTimer.is_stopped():
		$BootsTimer.stop()
	
	if is_minecarting:
		minecart_move(delta)
		if is_minecarting:
			return
	
	sprite.offset = sprite.offset.move_toward(Vector2.ZERO, delta * 50.0)
	
	if can_climb and abs(direction_y) > 0.8 and not $ClimbWait.time_left > 0.0:
		$ClimbWait.stop()
		is_climbing = true
		can_use_minecart = true
		first_climb_frame = true
	
	if is_climbing:
		climb_move(delta)
		if is_climbing:
			set_collision_mask_value(4, false)
			move_and_slide()
			return
	
	if (
		Input.is_action_just_pressed("minecart") and 
		GameState.acquired_upgrades[GameState.Upgrade.Minecart]
		and not is_climbing
		and can_use_minecart
	):
		is_entering_minecart = true
		can_use_minecart = false
		$AnimationPlayer.play("enter_minecart")
		freeze = true
		minecart_direction = last_strong_direction_x
		return
	
	if not is_on_floor():
		if was_on_floor and not jumped_last_frame:
			$JumpBufferLate.start()
		jumped_last_frame = false
		velocity.y += gravity * delta

	var desired_velocity
	var acceleration
	
	if is_on_floor():
		jumped = false
		desired_velocity = direction_x * MAX_RUN_SPEED
		acceleration = ACCELERATION
		
		if not was_on_floor:
			play_step_sound(0)
	else:
		desired_velocity = direction_x * MAX_AIR_SPEED
		acceleration = clampf((1.0 - (velocity.x / MAX_AIR_SPEED) * 0.8), 0.2, 1.0) *  AIR_ACCELERATION

	if direction_x:
		velocity.x = lerpf(velocity.x, desired_velocity, delta * acceleration)
		last_strong_direction_x = direction_x
	else:
		velocity.x = lerpf(velocity.x, 0, delta * ACCELERATION)
		if abs(velocity.x) < 8.0:
			velocity.x = 0.0
	
	jump()
	
	if not is_on_floor():
		velocity.y = minf(velocity.y, MAX_FALL_SPEED)
	
	animate()

	was_on_floor = is_on_floor()
	
	look_up_or_down()
	
	move_and_slide()


func climb_move(delta):
	position.x = lerpf(position.x, climb_x, delta * 15.0)
	velocity.x = 0.0
	
	if direction_y:
		velocity.y = lerpf(velocity.y, (direction_y * 1.2 + 0.2) * MAX_CLIMB_SPEED, delta * CLIMB_ACCELERATION)
	else:
		velocity.y = lerpf(velocity.y, 0.0, delta * CLIMB_ACCELERATION)
		if abs(velocity.y) < 8.0:
			velocity.y = 0.0
	
	jump()
	animate()
	
	if is_climbing and is_on_floor() and direction_y > 0.5 and not first_climb_frame:
		is_climbing = false
		$ClimbWait.start()
	
	first_climb_frame = false


func boots_move(delta):
	rotation = -0.5*PI if wall_direction > 0.0 else 0.5*PI
	var hold_away = (wall_direction > 0.0 and direction_x < 0.0) or (wall_direction < 0.0 and direction_x > 0.0)
	if hold_away and $DirectionHeldTimer.is_stopped():
		$DirectionHeldTimer.start()
		direction_timeout = false
	
#	print(direction_timeout)d
	
	if jump() or direction_timeout:
		if is_minecarting:
			stop_minecarting()
		boots_timeout = false
		direction_timeout = false
		$BootsCooldownTimer.start()
		is_wall_running = false
		return
	
	if not ($WallCast.is_colliding() and rotation != 0.0):
		velocity.y += minf(velocity.y * 1.0, -54.0)
		velocity.y = maxf(velocity.y, jump_velocity)
		boots_timeout = false
		if is_minecarting:
			stop_minecarting()
		direction_timeout = false
		$BootsCooldownTimer.start()
		is_wall_running = false
		return
	
	if boots_timeout:
		boots_timeout = false
		direction_timeout = false
		can_wall_run = false
		if is_minecarting:
			stop_minecarting()
		is_wall_running = false
		return
	
	velocity.y = lerpf(velocity.y, -MAX_WALL_RUN_SPEED if not hold_away else -MAX_WALL_RUN_SPEED*0.72, delta * ACCELERATION * 1.4)
	velocity.x = wall_direction * 20.0
	
	sprite.animation = "run"
	sprite.speed_scale = 1.8 * abs(velocity.y) / MAX_RUN_SPEED + 0.2
	$StepPlayer.pitch_scale = abs(velocity.y) / MAX_RUN_SPEED * 0.2 + 1.0
	$StepPlayer.volume_db = -6.0
	
	move_and_slide()


func stop_minecarting():
	$Minecart.visible = false
	$CartShape.disabled = true
	$PlayerShape.disabled = false
	$MinecartPlayer.play()
	$CartDrivingPlayer.stop()
	var minecart_instance = rigid_minecart.instantiate()
	if is_wall_running:
		minecart_instance.linear_velocity.y = velocity.y
	else:
		minecart_instance.linear_velocity.x = velocity.x
	minecart_instance.position = position
	minecart_instance.rotation = rotation
	get_parent().add_child(minecart_instance)
	is_minecarting = false


func minecart_move(delta):
	if jump():
		stop_minecarting()
		$MinecartPlayer.stream = load("res://Sounds/sfx/BUMP.ogg")
		return
	velocity.x = lerpf(velocity.x, minecart_direction * MINECART_SPEED, delta * ACCELERATION)
	if not is_on_floor():
		velocity.y += gravity * delta
		velocity.y = minf(velocity.y, MAX_FALL_SPEED)
		if $CartDrivingPlayer.playing:
			$CartDrivingPlayer.stop()
	else:
		if not $CartDrivingPlayer.playing:
			$CartDrivingPlayer.play()
		$CartDrivingPlayer.volume_db = remap(abs(velocity.x), 0.0, MINECART_START_SPEED, -80.0, -11.0)
		$CartDrivingPlayer.pitch_scale = remap(abs(velocity.x), 0.0, MINECART_START_SPEED, 1.2, 1.8)
	
	var down_velocity = velocity.y
	if is_wall_running:
		if wall_direction > 0:
			down_velocity = velocity.x
		else:
			down_velocity = -velocity.x
	
	sprite.offset.y = move_toward(sprite.offset.y, -3.0 - (abs(clampf(down_velocity, 0.0, MAX_FALL_SPEED)) / abs(MAX_FALL_SPEED)) * 32.0, delta * 17.0)
	if velocity.y <= 0.5:
		sprite.offset.y = -3.0
	
	move_and_slide()


func exit_level_move(delta):
	velocity.x = lerpf(velocity.x, exit_level_direction.x * MAX_RUN_SPEED, delta * ACCELERATION)
	last_strong_direction_x = exit_level_direction.x
	if not is_on_floor():
		velocity.y += gravity * delta
		velocity.y = minf(velocity.y, MAX_FALL_SPEED)
	
	move_and_slide()


func overworld_move(delta):
	var direction_input = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()

	velocity = direction_input * OVERWORLD_SPEED
	
	if velocity.length() > 0.001:
		sprite.play("run")
		
		if velocity.x < -0.01:
			sprite.flip_h = true
		elif velocity.x > 0.01:
			sprite.flip_h = false
	else:
		sprite.play("idle")
	
	move_and_slide()


func jump() -> bool:
	if (
		((is_on_floor() or is_climbing) and $JumpBufferEarly.time_left > 0.0 and not is_minecarting and not is_wall_running) or
		(not is_on_floor() and $JumpBufferLate.time_left > 0.0 and Input.is_action_just_pressed("do_jump") and not jumped and not is_minecarting and not is_wall_running) or 
		(is_minecarting and $JumpBufferEarly.time_left > 0.0) or 
		(is_wall_running and $JumpBufferEarly.time_left > 0.0)
	):
		if is_wall_running:
			var up_factor = -direction_y
			if not direction_y:
				up_factor = 0.8
			velocity = 1.28 * jump_velocity * Vector2(wall_direction * 0.68, up_factor).normalized()
		else:
			velocity.y = jump_velocity
		$JumpPlayer.play()
		
		if is_climbing:
			velocity.x = direction_x * MAX_RUN_SPEED * 0.6
		
		if not is_wall_running:
			hold_jump = true
		$JumpBufferEarly.stop()
		$JumpBufferLate.stop()
		jumped_last_frame = true
		jumped = true
		is_climbing = false
		$ClimbWait.start()
		
	if Input.is_action_just_released("do_jump") and hold_jump:
		if velocity.y < 0:
			velocity.y += pow(abs(velocity.y) / jump_velocity, 2) * abs(jump_velocity * 0.8)
		hold_jump = false

	if not Input.is_action_pressed("do_jump"):
		hold_jump = false
	
	return jumped_last_frame


func animate():
	if is_climbing:
		sprite.play("climb")
		sprite.speed_scale = abs(velocity.y) / MAX_CLIMB_SPEED
	elif not is_on_floor():
		if velocity.y > 70.0:
			sprite.play("fall")
		else:
			sprite.play("jump")
	elif velocity.length() > 5.0:
		sprite.play("run")
		sprite.speed_scale = 0.8 * abs(velocity.x) / MAX_RUN_SPEED + 0.2
	elif direction_y > 0.1:
		sprite.play("look_down")
	elif direction_y < -0.1:
		sprite.play("look_up")
	else:
		sprite.play("idle")


func get_animation():
	return {
		animation = sprite.animation,
		flip_h = sprite.flip_h,
		offset_y = sprite.offset.y,
	}


func animate_pick_up(delta):
	if not pick_up:
		return
	var direction_to_player = pick_up.position.direction_to(position)
	var desired_position = position - direction_to_player * 12.0
	var distance_to = pick_up.position.distance_to(desired_position)
	var follow_speed = clampf(distance_to / 28.0, 0.0, 1.0) * 3.8
	pick_up.position = pick_up.position.lerp(desired_position, delta * follow_speed)
	if not GameState.has_key:
		pick_up.queue_free()
		pick_up = null


func play_step_sound(type: int):
	var sounds = step_sounds[type]
	var sound = sounds[randi_range(0, sounds.size()-1)]
	$StepPlayer.stream = sound
	if not is_wall_running:
		$StepPlayer.volume_db = -9.5
	$StepPlayer.play()


func reset():
	velocity = Vector2.ZERO
	$StepPlayer.pitch_scale = 1.0
	$JumpBufferEarly.stop()
	$JumpBufferLate.stop()
	$BootsTimer.stop()
	$BootsCooldownTimer.stop()
	$DirectionHeldTimer.stop()
	direction_timeout = false
	$ClimbWait.stop()
	if is_minecarting:
		stop_minecarting()
	is_entering_minecart = false
	is_climbing = false
	$Minecart.visible = false
	$CartShape.disabled = true
	$PlayerShape.disabled = false
	$WallCast.enabled = true
	sprite.offset = Vector2.ZERO
	rotation = 0.0
	is_wall_running = false
	can_wall_run = true
	boots_timeout = false


func _on_ladder_area_entered(area):
	can_climb = true
	climb_x = area.position.x


func _on_ladder_area_exited(area):
	can_climb = false
	is_climbing = false
	$ClimbWait.start()


signal set_cam_look_offset(offset)

func look_up_or_down():
	if is_on_floor() and direction_y and velocity.x < 0.5:
		if direction_y > 0.1:
			if $LookDownTimer.is_stopped():
				$LookDownTimer.start()
		elif direction_y < -0.1:
			if $LookUpTimer.is_stopped():
				$LookUpTimer.start()
		else:
			$LookDownTimer.stop()
			$LookUpTimer.stop()
			set_cam_look_offset.emit(0.0)
	else:
		$LookDownTimer.stop()
		$LookUpTimer.stop()
		set_cam_look_offset.emit(0.0)


func _on_look_up_timer_timeout():
	set_cam_look_offset.emit(-LOOK_OFFSET)


func _on_look_down_timer_timeout():
	set_cam_look_offset.emit(LOOK_OFFSET)


func _on_key_key_picked_up(key):
	pick_up = key


func _on_player_sprite_frame_changed():
	if sprite.is_playing():
		if sprite.frame == 0:
			if sprite.animation == "run":
				play_step_sound(0)
			elif sprite.animation == "climb":
				play_step_sound(2)


func _on_animation_player_animation_finished(anim_name):
	if Engine.is_editor_hint():
		return
	if anim_name == "enter_minecart":
		is_entering_minecart = false
		$MinecartPlayer2.play()
		is_minecarting = true
		$CartShape.disabled = false
		$PlayerShape.disabled = true
		freeze = false
		velocity.x = minecart_direction * MINECART_START_SPEED
		velocity.y = -10.0


func _on_boots_timer_timeout():
#	is_wall_running = false
	boots_timeout = true
	can_wall_run = false
	$MinecartPlayer.play()


func _on_boots_cooldown_timer_timeout():
	can_wall_run = true


func _on_direction_held_timer_timeout():
	direction_timeout = true
