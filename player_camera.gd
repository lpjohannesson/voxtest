extends Node3D
class_name PlayerCamera

const DRAG_SPEED := 0.005
const MIN_DRAG_DISTANCE := 8.0
const DISTANCE_OFFSET := 1.0
const MAX_ZOOM := 16.0
const ABOVE_OFFSET := 1.0
const CAMERA_SMOOTH := 0.002

@export var camera: Camera3D
@export var player: Player

var holding_break := false
var dragging := false
var drag_distance := Vector2.ZERO
var drag_mouse_position := Vector2.ZERO

var zoom := MAX_ZOOM
var selected_block := 1

@onready var target_position := player.global_position

func cast_block() -> VoxelRaycastResult:
	var mouse_position := get_viewport().get_mouse_position()
	var ray_origin := camera.project_ray_origin(mouse_position)
	var ray_normal := camera.project_ray_normal(mouse_position)
	
	return GameScene.instance.voxel_tool.raycast(ray_origin, ray_normal, 1000.0)

func break_blocks() -> void:
	if dragging:
		return
	
	var cast := cast_block()
	
	if cast == null:
		return
	
	GameScene.instance.voxel_tool.set_voxel(cast.position, 0)

func place_blocks() -> void:
	if dragging:
		return
	
	var cast := cast_block()
	
	if cast == null:
		return
	
	GameScene.instance.voxel_tool.set_voxel(cast.previous_position, selected_block)

func cast_camera() -> void:
	if zoom == 0.0:
		camera.global_position = player.global_position
		player.mesh.hide()
		return
	
	player.mesh.show()
	
	var ray_direction := quaternion * Vector3.BACK
	var ray_from := player.global_position
	var ray_to := global_position + ray_direction * zoom + Vector3.UP * ABOVE_OFFSET
	
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(ray_from, ray_to)
	
	query.exclude = [player]
	
	var result := space_state.intersect_ray(query)
	
	if result.is_empty():
		camera.global_position = ray_to
	else:
		camera.global_position = result.position
	
	camera.global_position -= ray_direction * DISTANCE_OFFSET

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if not holding_break:
			return
		
		if dragging:
			rotation.x = clamp(rotation.x - event.relative.y * DRAG_SPEED, -PI * 0.5, PI * 0.5)
			rotation.y -= event.relative.x * DRAG_SPEED
		else:
			drag_distance += event.relative
			
			if drag_distance.length() >= MIN_DRAG_DISTANCE:
				dragging = true
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	target_position.x = player.global_position.x
	target_position.z = player.global_position.z
	
	if target_position.y > player.global_position.y or player.is_on_floor():
		target_position.y = player.global_position.y
	
	var last_position_2d := Vector2(global_position.x, global_position.z)
	global_position = global_position.lerp(target_position, 1.0 - pow(CAMERA_SMOOTH, delta))
	var position_2d := Vector2(global_position.x, global_position.z)
	
	var camera_movement := (position_2d - last_position_2d).length()
	rotation.y += Vector3.LEFT.rotated(Vector3.UP, rotation.y).dot(player.velocity) * camera_movement * 0.012 
	 
	cast_camera()
	
	if Input.is_action_just_pressed("zoom_in"):
		zoom = max(zoom - 1.0, 0.0)
	
	if Input.is_action_just_pressed("zoom_out"):
		zoom = min(zoom + 1.0, MAX_ZOOM)
	
	if Input.is_action_just_pressed("break"):
		holding_break = true
		
		drag_distance = Vector2.ZERO
		drag_mouse_position = get_viewport().get_mouse_position()
	
	if Input.is_action_just_released("break"):
		if dragging:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			Input.warp_mouse(drag_mouse_position)
		
		break_blocks()
		
		holding_break = false
		dragging = false
	
	if Input.is_action_just_pressed("place"):
		place_blocks()
