extends Node2D
class_name Camera

@export_node_path("CharacterBody2D") var player_path
@onready var player: Player = get_node(player_path)

@export_range(-1000.0, 1000.0) var initial_y_offset = -48.0


const MOVE_SPEED = 5.0

@onready var camera = $Camera2D
var follow_y = false
var follow_x = true
var y_offset = 0.0
var camera_x = 0.0
var zones_entered = 0
var player_look_offset = 0.0


func _ready():
	y_offset = initial_y_offset
	position.y = initial_y_offset
	position.x = player.position.x


func _physics_process(delta):
	var target_camera_x = camera_x
	if follow_x:
		target_camera_x = player.position.x
	position.x = lerpf(position.x, target_camera_x, delta * MOVE_SPEED)
	if abs(target_camera_x - position.x) < 1.8:
		position.x = target_camera_x
	var target_camera_y = y_offset
	if follow_y:
		target_camera_y = player.position.y + y_offset
	target_camera_y += player_look_offset
	position.y = lerpf(position.y, target_camera_y, delta * MOVE_SPEED)
	if abs(target_camera_y - position.y) < 1.8:
		position.y = target_camera_y


func reset():
	y_offset = initial_y_offset
	follow_y = false
	follow_x = true


class CameraSetting:
	var id: int
	var y: float
	var x: float
	var y_f: bool
	var x_f: bool
	func _init(_id, _y, _x, _y_f, _x_f):
		id = _id
		y = _y
		x = _x
		y_f = _y_f
		x_f = _x_f

var camera_settings = []


func _on_camera_zone_entered(new_y_offset, _follow_y, new_camera_x, _follow_x, id):
	var setting = CameraSetting.new(id, new_y_offset, new_camera_x, _follow_y, _follow_x)
	camera_settings.push_front(setting)
	y_offset = new_y_offset
	follow_y = _follow_y
	camera_x = new_camera_x
	follow_x = _follow_x
	zones_entered += 1


func _on_camera_zone_exited(_id):
	zones_entered -= 1
	for i in range(camera_settings.size()):
		if camera_settings[i].id == _id:
			camera_settings.pop_at(i)
			break
	if zones_entered != 0:
		y_offset = camera_settings[0].y
		camera_x = camera_settings[0].x
		follow_y = camera_settings[0].y_f
		follow_x = camera_settings[0].x_f


func _on_player_set_cam_look_offset(offset):
	player_look_offset = offset
