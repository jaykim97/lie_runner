extends CharacterBody2D

const GRAVITY : int = 4000
const JUMP_SPEED : int = -1500
const DOUBLE_JUMP_SPEED := -1000
var double_jump = true

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	if is_on_floor():
		double_jump = true
		if not get_parent().game_running:
			pass
		else:
			$RunCol.disabled = false
			if Input.is_action_pressed("JUMP"):
				velocity.y = JUMP_SPEED
				$JumpSound.play()
			elif Input.is_action_pressed("DUCK"):
				$AnimatedSprite2D.play("duck")
				$RunCol.disabled = true
			else:
				$AnimatedSprite2D.play("Run")
	else:
		if Input.is_action_pressed("DUCK"):
			velocity.y = JUMP_SPEED * -2
			$AnimatedSprite2D.play("duck")
			$RunCol.disabled = true
		elif Input.is_action_just_pressed("JUMP"):
			if double_jump:
				double_jump = false
				velocity.y = DOUBLE_JUMP_SPEED
				$JumpSound2.play()
				$AnimatedSprite2D.play("Jump")
				
				
		else:
			$AnimatedSprite2D.play("Jump")
	move_and_slide()
