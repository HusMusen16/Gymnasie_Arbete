extends Node2D


@onready var button = $UI/Endless_button
@onready var lasers = $Lasers
@onready var plasmas = $Plasmas

var plasma_scene: PackedScene = load("res://Scenes/plasma_blast.tscn")
var laser_scene: PackedScene = load("res://Scenes/laser.tscn")

func _physics_process(_delta: float) -> void:
	pass


func _on_endless_button_pressed() -> void:
	LevelManager.start_endless_mode()
	LevelManager.start_endless_mode()

func _on_mothership_surge_button_pressed() -> void:
	LevelManager.start_mothership_surge_mode()


func _on_spacestation_defense_button_pressed() -> void:
	LevelManager.start_defend_spacestation_mode()


func _on_player_laser(type: Variant, pos: Variant, dir: Variant) -> void:
	if type == "laser":
		var laser = laser_scene.instantiate()
		lasers.add_child(laser)
		laser.position = pos
		laser.rotation_degrees = dir
	elif type == "plasma":
		var plasma = plasma_scene.instantiate()
		plasmas.add_child(plasma)
		plasma.position = pos
		plasma.rotation_degrees = dir
