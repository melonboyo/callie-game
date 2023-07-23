extends Node
class_name TickTimer

signal tick

@export var every_nth_tick: int = 1

var timer: Timer

func _ready():
	timer = Timer.new()
	timer.wait_time = Network.TICKS_PER_SECOND * every_nth_tick
	timer.autostart = true
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)


func _on_timer_timeout():
	tick.emit()


func _exit_tree():
	timer.timeout.disconnect(_on_timer_timeout)
	
