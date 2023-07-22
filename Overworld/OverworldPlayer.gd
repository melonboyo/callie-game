extends CharacterBody2D


const SPEED = 100.0

@onready var sprite = $PlayerSprite


func _physics_process(delta):
	var direction_input = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()

	velocity = direction_input * SPEED
	
	if velocity.length() > 0.001:
		sprite.play("run")
		
		if velocity.x < -0.01:
			sprite.flip_h = true
		elif velocity.x > 0.01:
			sprite.flip_h = false
	else:
		sprite.play("idle")
	
	move_and_slide()
