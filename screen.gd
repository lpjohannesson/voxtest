extends Control

const DRAG_SPEED := 0.005
const MIN_DRAG_DISTANCE := 8.0

var holding_break := false
var dragging := false
var drag_distance := Vector2.ZERO
var drag_mouse_position := Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if not holding_break:
			return
		
		var player_camera := GameScene.instance.player_camera
		
		if dragging:
			player_camera.rotation.x = clamp(
				player_camera.rotation.x - event.relative.y * DRAG_SPEED,
				-PI * 0.5,
				PI * 0.5)
			
			player_camera.rotation.y -= event.relative.x * DRAG_SPEED
		else:
			drag_distance += event.relative
			
			if drag_distance.length() >= MIN_DRAG_DISTANCE:
				dragging = true
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if event.pressed:
					holding_break = true
					
					drag_distance = Vector2.ZERO
					drag_mouse_position = get_viewport().get_mouse_position()
				else:
					if dragging:
						Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
						Input.warp_mouse(drag_mouse_position)
					else:
						GameScene.instance.player_camera.break_blocks()
					
					holding_break = false
					dragging = false
			MOUSE_BUTTON_RIGHT:
				if event.pressed:
					GameScene.instance.player_camera.place_blocks()
