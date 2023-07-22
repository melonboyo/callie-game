@tool
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
const OVERWORLD_SPEED = 87.0

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
var climb_x = 0.0

var was_on_floor = true
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

var pick_up: Node2D

@onready var sprite = $PlayerSprite


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
	
	if freeze:
		velocity = Vector2.ZERO
		return
	
	if is_in_overworld:
		overworld_move(delta)
		return
	
	if exit_level:
		exit_level_move(delta)
		animate()
		return
	
	collision_mask = 9
	
	animate_pick_up(delta)
	
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
	
	if last_strong_direction_x < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	
	animate()

	was_on_floor = is_on_floor()
	
	look_up_or_down()
	
	move_and_slide()


func exit_level_move(delta):
	velocity.x = lerpf(velocity.x, exit_level_direction.x * MAX_RUN_SPEED, delta * ACCELERATION)
	last_strong_direction_x = exit_level_direction
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


func jump():
	if (
		((is_on_floor() or is_climbing) and $JumpBufferEarly.time_left > 0.0) or
		(not is_on_floor() and $JumpBufferLate.time_left > 0.0 and Input.is_action_just_pressed("do_jump"))
	):
		velocity.y = jump_velocity
		$JumpPlayer.play()
		
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
	$StepPlayer.play()


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


func _on_player_sprite_frame_changed():
	if sprite.is_playing():
		if sprite.frame == 0:
			if sprite.animation == "run":
				play_step_sound(0)
			elif sprite.animation == "climb":
				play_step_sound(2)


