extends CharacterBody3D
class_name Player

const MAX_SPEED := 8.0
const GROUND_ACCEL := 100.0
const AIR_ACCEL := 20.0
const FRICTION := 0.00005
const GRAVITY := 25.0
const JUMP_VELOCITY := 15.0
const JUMP_STOP := 0.6

@export var player_camera: PlayerCamera
@export var jump_timer: Timer
@export var coyote_timer: Timer

var midstopped = true

func _physics_process(delta: float) -> void:
	velocity.y -= GRAVITY * delta
	
	if Input.is_action_just_pressed("jump"):
		jump_timer.start()
	
	if is_on_floor():
		coyote_timer.start()
	
	if coyote_timer.is_stopped():
		if not Input.is_action_pressed("jump") and not midstopped and velocity.y > 0.0:
			midstopped = true
			velocity.y *= JUMP_STOP
		
	else:
		if jump_timer.is_stopped():
			midstopped = true
		else:
			jump_timer.stop()
			coyote_timer.stop()
			velocity.y = JUMP_VELOCITY
			midstopped = false
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down").rotated(-player_camera.rotation.y)
	var velocity_2d := Vector2(velocity.x, velocity.z)
	
	if is_on_floor():
		velocity_2d += input_dir * GROUND_ACCEL * delta
		velocity_2d *= pow(FRICTION, delta)
	else:
		velocity_2d += input_dir * AIR_ACCEL * delta
	
	velocity_2d = velocity_2d.limit_length(MAX_SPEED)
	
	velocity.x = velocity_2d.x
	velocity.z = velocity_2d.y
	
	move_and_slide()
