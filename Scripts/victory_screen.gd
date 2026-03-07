extends CanvasLayer



func _on_play_again_pressed() -> void:
	LevelManager.restart_current_gamemode()
	queue_free()
	
	


func _on_return_to_menu_pressed() -> void:
	LevelManager.return_to_main_menu()
