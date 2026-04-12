extends Node2D
"""
This is a global scene/script meaning it will always run when the game runs.
Is used to keep track of all the data between scenes and is the scene
that switches the current scene.
"""

"""
LEVEL_1 = Endless mode
LEVEL_2 = Mothership surge mode
LEVEL_3 = Defend space stations mode
"""



########################## ON READY VARIABLES ##################################
"""
variables below is always used when switching scenes. Darkens the screen and then 
undoes it to reveal the new scene. Similar to real cinema courtains.
"""
@onready var fade_anim = $Fade_anim
@onready var cinema_courtains = $Cinema_Courtains



################################# VARIABLES ####################################
var current_gamemode = null

var mothership_kills = 0
var kills = 0

var endless_highscore = 0
var surge_highscore = 0
var station_highscore = 0
var mothership_kill_goal: int = 3
var spacestation_survival_time: int = 180



############################# CONSTANTS ########################################

## The save path for the highscore
const SAVE_PATH = "user://spacegame_savefile.data"



################## GENERAL FUNKTIONS ###################
func _ready() -> void:
	"""
	Makes sure the current highscore is known when starting the game. 
	"""
	_get_highscores()


func quit_game() -> void:
	"""
	Darkens the screen and quits the game
	"""
	fade_anim.play("fade in")
	await fade_anim.animation_finished
	get_tree().quit()



################## LEVEL INITIATION FUNKTIONS ##################
func initiate_mothership_surge_mode_selection_menu() -> void:
	"""
	Changes scene to middle_screen_mothership.
	"""
	fade_anim.play("fade in")
	await fade_anim.animation_finished
	get_tree().change_scene_to_file("res://Scenes/middle_screen_mothership.tscn")
	fade_anim.play("fade out")


func initiate_defend_spacestation_mode_selection_menu() -> void:
	"""
	Changes scene to middle_screen_space_station.
	"""
	fade_anim.play("fade in")
	await fade_anim.animation_finished
	get_tree().change_scene_to_file("res://Scenes/middle_screen_space_station.tscn")
	fade_anim.play("fade out")



#################### START LEVEL FUNKTIONS #################
func return_to_main_menu() -> void:
	"""
	Changes scene to main_menu. Also makes sure to reset your killcount
	so it isn't kept between plays.
	""" 
	kills = 0
	mothership_kills = 0
	
	fade_anim.play("fade in")
	await fade_anim.animation_finished
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	fade_anim.play("fade out")


func restart_current_gamemode() -> void:
	"""
	Restarts the current scene. Also makes sure to reset your killcount
	so it isn't kept between plays.
	"""
	kills = 0
	mothership_kills = 0
	
	fade_anim.play("fade in")
	await fade_anim.animation_finished
	get_tree().change_scene_to_file("res://Scenes/level_" + str(current_gamemode) + ".tscn")
	fade_anim.play("fade out")


func start_endless_mode() -> void:
	"""
	Changes scene to level_1 (endless mode).
	"""
	fade_anim.play("fade in")
	await fade_anim.animation_finished
	get_tree().change_scene_to_file("res://Scenes/level_1.tscn")
	fade_anim.play("fade out")


func start_mothership_surge_mode() -> void:
	"""
	Changes scene to level_2 (mothership surge mode).
	"""
	fade_anim.play("fade in")
	await fade_anim.animation_finished
	get_tree().change_scene_to_file("res://Scenes/level_2.tscn")
	fade_anim.play("fade out")


func start_defend_spacestation_mode() -> void:
	"""
	Changes scene to level_3 (defend space station mode).
	"""
	fade_anim.play("fade in")
	await fade_anim.animation_finished
	get_tree().change_scene_to_file("res://Scenes/level_3.tscn")
	fade_anim.play("fade out")


func start_tutorial_mode() -> void:
	"""
	Changes scene to level_4 (tutorial mode).
	"""
	fade_anim.play("fade in")
	await fade_anim.animation_finished
	get_tree().change_scene_to_file("res://Scenes/level_4.tscn")
	fade_anim.play("fade out")



###################### HIGHSCORE FUNKTIONS #####################
func reset_highscore() -> void:
	"""
	Sets the highscore to 0 then saves it 
	"""
	endless_highscore = 0
	_save_highscores()


func _get_highscores() -> void:
	"""
	Checks if the savefile for the highscore exists. If it does 
	it reads it and saves that number to the variable 
	endless_highscore. If it doesnt it will do nothing as the 
	standard value for endless_highscore is 0. The funktion is also
	only called when starting the game.
	"""
	#print("highscore gotten")
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		endless_highscore = file.get_var(endless_highscore)
		file.close()
	else:
		#Swap the hashtag if problems arise with the savefile 
		pass
		#print("no savefile")


func _save_highscores() -> void:
	"""
	overwrites the highscore in the save file with the new one.
	"""
	#print("highscore saved")
	endless_highscore = kills
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(endless_highscore)
	file.close()


func check_highscore() -> void:
	"""
	Checks if your score (kills) is greater than your highscore.
	If it is it overwrites your old one in the _save_highscores() 
	funktion.
	"""
	#print("highscore checked")
	if endless_highscore < kills:
		_save_highscores()
