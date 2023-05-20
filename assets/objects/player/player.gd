extends CharacterBody2D
class_name Player

const gravity = 300.0
const jump_speed = 175.0
const jump_midstop = 0.65

const walk_accel = 200.0
const max_walk_speed = 65.0

const ground_friction_strength = 4.0
const air_friction_strength = 0.5

const basic_stackling_file = preload("res://assets/objects/stackling/basic_stackling.tscn")

var top_stackling
var bottom_stackling

var walk_sign = 0
var jump_midstopped = false

var prev_on_floor = true

func update_hitbox():
	if top_stackling == null:
		# Enable only solo hitbox
		$SoloHitbox.set_deferred("disabled", false)
		$DuoHitbox.set_deferred("disabled", true)
	else:
		$SoloHitbox.set_deferred("disabled", true)
		$DuoHitbox.set_deferred("disabled", false)

func add_stackling(stackling):
	var added = false
	
	if bottom_stackling == null:
		added = true
		
		# Add first stackling to bottom
		bottom_stackling = stackling
		$Stacklings/BottomRoot.add_child(stackling)
		
		# Disable holding sprites
		bottom_stackling.set_holding(false)
	
	elif top_stackling == null:
		added = true
		
		# Teleport to new stackling
		global_position = stackling.global_position
		velocity = Vector2.ZERO
		
		# Move bottom stackling to top
		$Stacklings/BottomRoot.remove_child(bottom_stackling)
		$Stacklings/TopRoot.call_deferred("add_child", bottom_stackling)
		
		top_stackling = bottom_stackling
		
		# Remove new stackling from world and insert into player
		stackling.get_parent().remove_child(stackling)
		$Stacklings/BottomRoot.call_deferred("add_child", stackling)
		
		bottom_stackling = stackling
		
		# Center and stop new stackling
		bottom_stackling.position = Vector2.ZERO
		bottom_stackling.velocity = Vector2.ZERO
		
		# Make the bottom hold the top
		top_stackling.set_holding(false)
		bottom_stackling.set_holding(true)
		
		# Send capture callback
		top_stackling.on_performed_capture(self)
	
	if added:
		# Send captured callback
		stackling.on_captured(self)
		stackling.captured = true
	
	update_hitbox()

func animate_sprites():
	var bottom_player = bottom_stackling.get_node("AnimationPlayer")
	bottom_player.speed_scale = 1.0
	
	if is_on_floor():
		if bottom_player.current_animation == "hit_ground":
			return
		
		if not walk_sign == 0:
			$Stacklings.scale.x = walk_sign
		
		if not prev_on_floor:
			bottom_player.play("hit_ground")
			
			return
		
		if walk_sign == 0:
			bottom_player.play("idle")
			
			return
		
		var walk_anim_speed = abs(velocity.x) / max_walk_speed
		
		bottom_player.play("walk")
		bottom_player.speed_scale = walk_anim_speed
	else:
		bottom_player.play("jump")

func _ready():
	add_stackling(basic_stackling_file.instantiate())

func _physics_process(delta):
	velocity.y += gravity * delta
	
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = -jump_speed
			jump_midstopped = false
	
	if not jump_midstopped and velocity.y < 0.0:
		if Input.is_action_just_released("jump"):
			jump_midstopped = true
			velocity.y *= jump_midstop
	
	walk_sign = sign(Input.get_axis("move_left", "move_right"))
	
	var friction_strength = \
		ground_friction_strength if is_on_floor() else air_friction_strength
	
	var friction = pow(10.0, -friction_strength)
	
	if walk_sign == 0:
		velocity.x = lerp(velocity.x, 0.0, 1.0 - pow(friction, delta))
	else:
		velocity.x += walk_sign * walk_accel * delta
		velocity.x = clamp(velocity.x, -max_walk_speed, max_walk_speed)
	
	move_and_slide()
	
	if Input.is_action_just_pressed("throw"):
		if not top_stackling == null:
			top_stackling.end_stackling()
			top_stackling = null
			
			update_hitbox()
			
			bottom_stackling.set_holding(false)
	
	animate_sprites()
	prev_on_floor = is_on_floor()
	
	if Input.is_action_just_pressed("show_menu"):
		get_tree().reload_current_scene()

func _on_stomp_area_area_entered(area):
	if velocity.y <= 0.0:
		return
	
	if area is StacklingJumpOnArea:
		var stackling = area.stackling
		
		add_stackling(stackling)
