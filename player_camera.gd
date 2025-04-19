extends Node3D
class_name PlayerCamera

const DRAG_SPEED := 0.005
const MIN_DRAG_DISTANCE := 8.0
const DISTANCE_OFFSET := 1.0
const MAX_VIEW_DISTANCE := 16.0

@export var camera: Camera3D
@export var player: Player

var dragging := false
var drag_distance := Vector2.ZERO
var view_distance := MAX_VIEW_DISTANCE
var drag_mouse_position := Vector2.ZERO
var selected_block := 1

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
	var cast := cast_block()
	
	if cast == null:
		return
	
	GameScene.instance.voxel_tool.set_voxel(cast.previous_position, selected_block)

func cast_camera() -> void:
	if view_distance == 0.0:
		camera.position.z =  0.0
		return
	
	var ray_direction := quaternion * Vector3.BACK
	var ray_from := global_position
	var ray_to := ray_from + ray_direction * view_distance
	
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(ray_from, ray_to)
	var result := space_state.intersect_ray(query)
	
	if result.is_empty():
		camera.position.z = view_distance - DISTANCE_OFFSET
	else:
		camera.global_position = result.position - quaternion * Vector3.BACK * DISTANCE_OFFSET

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if not Input.is_action_pressed("break"):
			return
		
		if dragging:
			rotation.x = clamp(rotation.x - event.relative.y * DRAG_SPEED, -PI * 0.5, PI * 0.5)
			rotation.y -= event.relative.x * DRAG_SPEED
			
		else:
			drag_distance += event.relative
			
			if drag_distance.length() >= MIN_DRAG_DISTANCE:
				dragging = true
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
	cast_camera()
	
	if Input.is_action_just_pressed("zoom_in"):
		view_distance = max(view_distance - 1.0, 0.0)
	
	if Input.is_action_just_pressed("zoom_out"):
		view_distance = min(view_distance + 1.0, MAX_VIEW_DISTANCE)
	
	if Input.is_action_just_pressed("break"):
		dragging = false
		drag_distance = Vector2.ZERO
		drag_mouse_position = get_viewport().get_mouse_position()
	
	if Input.is_action_just_released("break"):
		if dragging:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			Input.warp_mouse(drag_mouse_position)
		
		break_blocks()
	
	if Input.is_action_just_pressed("place"):
		place_blocks()
	
	rotation.y += Vector3.LEFT.rotated(Vector3.UP, rotation.y).dot(player.velocity) * 0.05 * delta
