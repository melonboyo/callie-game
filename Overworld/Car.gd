@tool
extends RigidBody2D
class_name Car2D


@export_range(-360, 360) var car_rotation: float = 0.0:
	set(value):
		car_rotation = value
		var car_rotation_rad = deg_to_rad(value)
		
		%Pivot.rotation.y = car_rotation_rad
@export_node_path var camera_path
@onready var camera: Camera2D = get_node(camera_path)


const CAMERA_CATCH_UP = 2.0
const CAMERA_OFFSET = 32.0
const ACCELERATION = 2.0
const DECELERATION = 3.2
const MAX_SPEED = 190.0
const HANDLING = 1.7

var facing_rotation = 0.0
var input_rotation = 0.0
var actual_rotation = 0.0


func _physics_process(delta):
	if Engine.is_editor_hint():
		return
	
	var direction_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction_input.length() > 0.001:
		direction_input = direction_input.normalized()
		input_rotation = direction_input.reflect(Vector2.DOWN).angle_to(Vector2.DOWN)
	else:
		input_rotation = facing_rotation
	
	var handling = HANDLING * ((linear_velocity.length() / MAX_SPEED) * 0.3 + 0.7)
	facing_rotation = lerp_angle(facing_rotation, input_rotation, delta * handling)	
	var facing_direction = Vector2.DOWN.rotated(facing_rotation)
	
	if direction_input.length() > 0.001:
		linear_velocity = linear_velocity.lerp(facing_direction * MAX_SPEED, delta * ACCELERATION)
	else :
		linear_velocity = linear_velocity.lerp(Vector2.ZERO, delta * DECELERATION)
	
	camera.offset = camera.offset.lerp(
		direction_input.normalized() * (linear_velocity.length() / \
		MAX_SPEED) * CAMERA_OFFSET, delta * CAMERA_CATCH_UP
	)
	
	car_rotation = rad_to_deg(facing_rotation)
