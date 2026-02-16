extends Node2D


var mothership_kills = 0
var current_gamemode = null
var kills = 0

"""
LEVEL_1 = Endless mode
LEVEL_2 = Mothership surge mode
LEVEL_3 = Defend space stations mode
"""


func return_to_main_menu():
	mothership_kills = 0
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func restart_current_gamemode():
	mothership_kills = 0
	get_tree().change_scene_to_file("res://Scenes/level_" + str(current_gamemode) + ".tscn")



func start_endless_mode():
	get_tree().change_scene_to_file("res://Scenes/level_1.tscn")


func start_mothership_surge_mode():
	get_tree().change_scene_to_file("res://Scenes/level_2.tscn")

func start_defend_spacestation_mode():
	get_tree().change_scene_to_file("res://Scenes/level_3.tscn")
