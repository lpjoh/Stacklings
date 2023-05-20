extends Stackling

const walk_speed = 50.0

func _ready():
	velocity.x = walk_speed

func enemy_physics_process(delta):
	velocity.y += Player.gravity * delta
	
	var prev_velocity = velocity
	move_and_slide()
	
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		
		if not collision.get_normal().y == 0.0:
			continue
		
		velocity.x = -prev_velocity.x
		$SpriteRoot.scale.x = sign(velocity.x)
	
	if is_on_floor():
		$AnimationPlayer.play("walk")
	else:
		$AnimationPlayer.play("jump")
