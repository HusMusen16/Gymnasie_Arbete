extends Node2D
class_name LEVEL

var laser_scene: PackedScene = load("res://Scenes/laser.tscn")
var meteor_scene: PackedScene = load("res://Scenes/meteor.tscn")
var enemy_scene: PackedScene = load("res://Scenes/enemy_1.tscn")


@onready var player: PLAYER = $Player
@onready var lasers: Node = $Lasers
@onready var meteors: Node = $Meteors
@onready var enemies: Node = $Enemies
@onready var meteor_timer: Timer = $Meteor_Timer
@onready var enemy_timer: Timer = $Enemy_Timer
	



func _spawn_enemy():
	var enemy = enemy_scene.instantiate()
	enemies.add_child(enemy)
	enemy.player = player


func _on_player_laser(pos: Variant, dir: Variant) -> void:
	var laser = laser_scene.instantiate()
	lasers.add_child(laser)
	laser.position = pos
	laser.rotation_degrees = dir


func _on_meteor_timer_timeout() -> void:
	var meteor = meteor_scene.instantiate()
	meteors.add_child(meteor)


func _on_enemy_timer_timeout() -> void:
	_spawn_enemy()
