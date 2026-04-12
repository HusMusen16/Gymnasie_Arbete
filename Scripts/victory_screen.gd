extends CanvasLayer

"""
The screen that appears when winning. Even though they are different scenes
the defeat_scene and pause_menu also both run on this script as they
share almost everything except the text.
"""



################################# VARIABLES ####################################
##Used to determine what menu is pressing the buttons (pause, victory or defeat), use only lowercase letters.
@export var type: String = "" 



################################ SIGNALS #######################################

##A signal that is called when you choose to restart the current level
signal unpause_game()



################################## FUNCTIONS ###################################
func _on_play_again_pressed() -> void:
	"""
	Called when the Play Again button is pressed.
	Restarts the current scene tree (except the level manager) via the
	level manager. Also checks if you have beaten your highscore
	if it is level_1 (endless mode). Removes itself from the scene
	tree afterwards.
	"""
	if type == "pause":
		unpause_game.emit()
		if LevelManager.current_gamemode == 1:
			LevelManager.check_highscore()
	LevelManager.restart_current_gamemode()
	queue_free()


func _on_return_to_menu_pressed() -> void:
	"""
	Called when the Return to menu button is pressed.
	Changes the current scene to the main menu via level manager
	Also checks if you have beaten your highscore if it is level_1 
	(endless mode)
	"""
	if type == "pause" and LevelManager.current_gamemode == 1:
		LevelManager.check_highscore()
	LevelManager.return_to_main_menu()
