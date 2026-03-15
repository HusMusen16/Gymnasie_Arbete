extends CanvasLayer

##Used to determine what menu is pressing the buttons (pause, victory or defeat), use only lowercase letters.
@export var type: String = "" 

signal unpause_game()

func _on_play_again_pressed() -> void:
	if type == "pause":
		unpause_game.emit()
		if LevelManager.current_gamemode == 1:
			LevelManager.check_highscore()
	LevelManager.restart_current_gamemode()
	queue_free()


func _on_return_to_menu_pressed() -> void:
	if type == "pause" and LevelManager.current_gamemode == 1:
		LevelManager.check_highscore()
	LevelManager.return_to_main_menu()
