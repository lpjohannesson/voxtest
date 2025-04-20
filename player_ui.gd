extends CanvasLayer
class_name PlayerUI

@export var player: Player

func _on_button_pressed() -> void:
	player.player_camera.selected_block = 1

func _on_button_2_pressed() -> void:
	player.player_camera.selected_block = 2

func _on_button_3_pressed() -> void:
	player.player_camera.selected_block = 3
