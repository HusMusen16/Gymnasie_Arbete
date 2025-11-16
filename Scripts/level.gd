extends Node2D
class_name LEVEL

var laser_scene: PackedScene = load("res://Scenes/laser.tscn")
@onready var lasers = $Lasers


func _on_player_laser(pos: Variant, dir: Variant) -> void:
	#print(pos, dir)
	var laser = laser_scene.instantiate()
	lasers.add_child(laser)
	laser.position = pos
	laser.rotation_degrees = dir
	

func _physics_process(delta: float) -> void:
	#Ta bort lasrar
	pass
