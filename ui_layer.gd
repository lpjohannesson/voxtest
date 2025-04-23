extends CanvasLayer
class_name PlayerUI

func select_block(index: int) -> void:
	GameScene.instance.player.player_camera.selected_block = index

func _on_button_pressed() -> void:
	select_block(1)

func _on_button_2_pressed() -> void:
	select_block(2)

func _on_button_3_pressed() -> void:
	select_block(3)
