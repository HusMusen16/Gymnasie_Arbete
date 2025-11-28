extends Node2D
class_name LEVEL

var laser_scene: PackedScene = load("res://Scenes/laser.tscn")
var meteor_scene: PackedScene = load("res://Scenes/meteor.tscn")


@onready var lasers: Node = $Lasers
@onready var meteors: Node = $meteors
@onready var meteor_timer: Timer = $Meteor_Timer


func _on_player_laser(pos: Variant, dir: Variant) -> void:
	print(pos, dir)
	var laser = laser_scene.instantiate()
	lasers.add_child(laser)
	laser.position = pos
	laser.rotation_degrees = dir
	


func _physics_process(_delta: float) -> void:
	pass


func _on_meteor_timer_timeout() -> void:
	var meteor = meteor_scene.instantiate()
	meteors.add_child(meteor)
