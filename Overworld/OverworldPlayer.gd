extends CharacterBody2D


const SPEED = 100.0


func _physics_process(delta):	
	var direction_input = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()

	velocity = direction_input * SPEED
	
	if velocity.length() > 0.001:
		$Sprite.play("run")
		
		if velocity.x < -0.01:
			$Sprite.flip_h = true
		elif velocity.x > 0.01:
			$Sprite.flip_h = false
	else:
		$Sprite.play("idle")
	
	move_and_slide()
