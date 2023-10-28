extends Camera2D

const drag_x_limit = 16
const offset_x_limit = 48
const floor_y_offset = 16
const fall_limit = 48

@export var player : Node2D

var vertical_tween : Tween

func _ready():
	global_position = player.global_position

func _physics_process(delta):
	#print(player.global_position * get_viewport().get_camera_2d().transform)
	
	var player_x = player.global_position.x
	var left_edge = player_x - drag_x_limit
	var right_edge = player_x + drag_x_limit
	
	var clamped_x = clamp(global_position.x, left_edge, right_edge)
	
	if global_position.x != clamped_x:
		offset.x = clamp(
			offset.x + (clamped_x - global_position.x),
			-offset_x_limit,
			offset_x_limit)
	
	global_position.x = clamped_x
	
	if player.is_on_floor() and not player.prev_on_floor:
		if vertical_tween != null:
			vertical_tween.kill()
		
		vertical_tween = create_tween()
		vertical_tween.tween_property(
			self,
			"global_position:y",
			player.global_position.y - floor_y_offset,
			0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	global_position.y = max(global_position.y, player.position.y - fall_limit)
	
	Engine.max_fps = 60
