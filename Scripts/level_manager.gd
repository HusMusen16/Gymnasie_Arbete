extends Node2D

const SAVE_PATH = "user://spacegame_savefile.data"

var current_gamemode = null

var mothership_kills = 0
var kills = 0

var endless_highscore = 0
var surge_highscore = 0
var station_highscore = 0



"""
LEVEL_1 = Endless mode
LEVEL_2 = Mothership surge mode
LEVEL_3 = Defend space stations mode
"""

func _ready() -> void:
	#Byt plats på hashtagen för att återställa highscore sparfilen
	_get_highscores()
	#_save_highscores()

func return_to_main_menu():
	kills = 0
	mothership_kills = 0
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func restart_current_gamemode():
	kills = 0
	mothership_kills = 0
	get_tree().change_scene_to_file("res://Scenes/level_" + str(current_gamemode) + ".tscn")


func start_endless_mode():
	get_tree().change_scene_to_file("res://Scenes/level_1.tscn")

func start_mothership_surge_mode():
	get_tree().change_scene_to_file("res://Scenes/level_2.tscn")

func start_defend_spacestation_mode():
	get_tree().change_scene_to_file("res://Scenes/level_3.tscn")


func _get_highscores() -> void:
	print("highscore gotten")
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		endless_highscore = file.get_var(endless_highscore)
		file.close()
	else:
		print("no savefile")


func _save_highscores() -> void:
	print("highscore saved")
	endless_highscore = kills
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(endless_highscore)
	file.close()


func check_highscore():
	print("highscore checked")
	if endless_highscore < kills:
		_save_highscores()
