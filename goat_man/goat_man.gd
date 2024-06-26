extends Area3D

const SPEED = 20
const CORRIDOR_SIZE = 5
const POS_MARGIN = 0.2
const RESPAWN_TIME = 6
const RESPAWN_VARIANCE = 2
const SCREAM_DISTANCE = 15
var forward = -Vector3.FORWARD
var turn_timer = 0
var g_position
var respawn_timer = 0
var respawn_pos = null
var is_screaming = false
var player = null

@onready var right_ray = $RayCastRight
@onready var left_ray  = $RayCastLeft
@onready var forward_ray = $RayCastForward
@onready var player_ray = $RayCastPlayer

func _ready():
	$GoatRunNoise.play()
	forward_ray.add_exception(player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	g_position = global_position + Vector3(2.5, 0, 2.5)
	
	turn_timer -= delta
	
	if respawn_timer > 0:
		respawn_timer -= delta
		if respawn_timer <= 0:
			respawn()
		return
	
	# Always run forward
	g_position += forward*SPEED*delta
	
	if forward_ray.is_colliding() or (in_grid() and turn_timer <= 0 and 
	(not left_ray.is_colliding() or not right_ray.is_colliding())):
		
		turn_timer = 0.2
		
		# Adjust so in middle of corridor
		g_position.x = snapped(g_position.x, 5)
		g_position.z = snapped(g_position.z, 5)
		
		var turn_options = []
		
		if not forward_ray.is_colliding():
			turn_options.append(0)
		
		if not right_ray.is_colliding():
			turn_options.append(PI/2)
		
		if not left_ray.is_colliding():
			turn_options.append(-PI/2)
			
		var turn = 0
		
		if turn_options:
			turn = turn_options.pick_random()
		else:
			turn = PI
			
		rotate_y(turn)
		forward = forward.rotated(Vector3(0, 1, 0), turn)
		
	global_position = g_position - Vector3(2.5, 0, 2.5)
	
	if player != null:
		handle_scream()
		
func in_grid():
	var global_pos = abs(g_position)
	var decimal_x = global_pos.x - int(global_pos.x)
	var decimal_z = global_pos.z - int(global_pos.z)
	var mod_x = int(global_pos.x) % 5
	var mod_z = int(global_pos.z) % 5
	
	var within_x = (POS_MARGIN > (mod_x + decimal_x)) or (POS_MARGIN > (mod_x - decimal_x))
	var within_z = (POS_MARGIN > (mod_z + decimal_z)) or (POS_MARGIN > (mod_z - decimal_z))
	
	return within_x and within_z
	
func hit():
	$GoatDeadNoise.play()
	$GoatRunNoise.playing = false
	transform.origin = Vector3(-10, -10, -10)
	respawn_timer = RESPAWN_TIME + randf_range(-RESPAWN_VARIANCE, RESPAWN_VARIANCE)
	
func respawn():
	global_position = get_parent().get_parent().get_respawn_pos()
	$GoatRunNoise.playing = true

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.dead()
		
func handle_scream():
	$TestBall.global_position = player_ray.get_collision_point()
	var collider = player_ray.get_collider()
	
	if (collider == null and global_position.distance_to(player.global_position) < SCREAM_DISTANCE and not is_screaming):
		$GoatScreamNoise.play()
		is_screaming = true
	if (global_position.distance_to(player.global_position) > SCREAM_DISTANCE and is_screaming):
		$GoatScreamNoise.stop()
		is_screaming = false
		
