extends CharacterBody2D
class_name Stackling

@export var texture: Texture
@export var hold_texture: Texture

var captured = false

func set_holding(holding):
	$SpriteRoot/Sprite.texture = hold_texture if holding else texture
	$SpriteRoot/HoldBackSprite.visible = holding

func end_stackling():
	queue_free()

func enemy_process(_delta):
	pass

func enemy_physics_process(_delta):
	pass

func on_captured(_player):
	$JumpOnArea.monitoring = false
	$CollisionShape2D.set_deferred("disabled", true)
	
	$SpriteRoot.scale.x = 1

func on_performed_capture(_player):
	$AnimationPlayer.play("hit_ground")
	$AnimationPlayer.queue("idle")

func _ready():
	set_holding(false)

func _process(delta):
	if not captured:
		enemy_process(delta)

func _physics_process(delta):
	if not captured:
		enemy_physics_process(delta)
