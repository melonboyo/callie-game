extends CharacterBody2D
class_name Player

const MAX_RUN_SPEED = 110.0
const MAX_AIR_SPEED = 150.0
const MAX_CLIMB_SPEED = 60.0
const ACCELERATION = 4.2
const AIR_ACCELERATION = 1.8
const CLIMB_ACCELERATION = 12.0
const MAX_FALL_SPEED = 300.0
const LOOK_OFFSET = 32.0

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
var climb_x = 0.0

var was_on_floor = true
var jumped = false

var freeze = false

var pick_up: Node2D


func _ready():
	jump_height = jump_height


func _process(delta):
	direction_x = Input.get_axis("move_left", "move_right")
	direction_y = Input.get_axis("move_up", "move_down")
	
	if GameState.has_upgrade(GameState.Upgrade.Jump1):
		jump_height = 2
	
	if Input.is_action_just_pressed("do_jump"):
		$JumpBufferEarly.start()


func _physics_process(delta):
	collision_mask = 9
	
	if freeze:
		velocity = Vector2.ZERO
		return
	
	if pick_up:
		var direction_to_player = pick_up.position.direction_to(position)
		var desired_position = position - direction_to_player * 12.0
		var distance_to = pick_up.position.distance_to(desired_position)
		var follow_speed = clampf(distance_to / 28.0, 0.0, 1.0) * 3.8
		pick_up.position = pick_up.position.lerp(desired_position, delta * follow_speed)
		if not GameState.has_key:
			pick_up.queue_free()
	
	if can_climb and abs(direction_y) > 0.8 and not $ClimbWait.time_left > 0.0:
		$ClimbWait.stop()
		is_climbing = true
	
	if is_climbing:
		position.x = lerpf(position.x, climb_x, delta * 15.0)
		velocity.x = 0.0
		
		if direction_y:
			velocity.y = lerpf(velocity.y, direction_y * MAX_CLIMB_SPEED, delta * CLIMB_ACCELERATION)
		else:
			velocity.y = lerpf(velocity.y, 0.0, delta * CLIMB_ACCELERATION)
			if abs(velocity.y) < 8.0:
				velocity.y = 0.0
		
		jump()
		animate()
		
		if is_climbing:
			collision_mask = 1
			move_and_slide()
			return
	
	if not is_on_floor():
		if was_on_floor and not jumped:
			$JumpBufferLate.start()
		jumped = false
		velocity.y += gravity * delta

	var desired_velocity
	var acceleration
	
	if is_on_floor():
		desired_velocity = direction_x * MAX_RUN_SPEED
		acceleration = ACCELERATION
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
	
	if last_strong_direction_x < 0:
		$Sprite.flip_h = true
	else:
		$Sprite.flip_h = false
	
	animate()

	was_on_floor = is_on_floor()
	
	look_up_or_down()
	
	move_and_slide()


func jump():
	if (
		((is_on_floor() or is_climbing) and $JumpBufferEarly.time_left > 0.0) or
		(not is_on_floor() and $JumpBufferLate.time_left > 0.0 and Input.is_action_just_pressed("do_jump"))
	):
		velocity.y = jump_velocity
		
		if is_climbing:
			velocity.x = direction_x * MAX_RUN_SPEED * 0.6
		
		hold_jump = true
		$JumpBufferEarly.stop()
		$JumpBufferLate.stop()
		jumped = true
		is_climbing = false
		$ClimbWait.start()
		
	if Input.is_action_just_released("do_jump") and hold_jump:
		if velocity.y < 0:
			velocity.y += pow(abs(velocity.y) / jump_velocity, 2) * abs(jump_velocity * 0.8)
		hold_jump = false

	if not Input.is_action_pressed("do_jump"):
		hold_jump = false


func animate():
	if is_climbing:
		$Sprite.play("climb")
		$Sprite.speed_scale = abs(velocity.y) / MAX_CLIMB_SPEED
	elif not is_on_floor():
		if velocity.y > 70.0:
			$Sprite.play("fall")
		else:
			$Sprite.play("jump")
	elif velocity.length() > 5.0:
		$Sprite.play("run")
		$Sprite.speed_scale = 0.8 * abs(velocity.x) / MAX_RUN_SPEED + 0.2
	elif direction_y > 0.1:
		$Sprite.play("look_down")
	elif direction_y < -0.1:
		$Sprite.play("look_up")
	else:
		$Sprite.play("idle")


func reset():
	velocity = Vector2.ZERO
	$JumpBufferEarly.stop()
	$JumpBufferLate.stop()
	$ClimbWait.stop()
	freeze = false


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
