extends CharacterBody2D
class_name METEOR

var random_rotation_number = RandomNumberGenerator.new().randf_range(0.01, 0.1)
var random_meteor_number = RandomNumberGenerator.new().randf_range(0, 7)
var random_speed_x = RandomNumberGenerator.new().randf_range(150,300)
var random_speed_y = RandomNumberGenerator.new().randf_range(150,300)

var dir_x = [1,-1].pick_random()
var dir_y = [1,-1].pick_random()

var meteor_x = RandomNumberGenerator.new().randf_range(0,500)
var meteor_y = RandomNumberGenerator.new().randf_range(0,500)


@onready var sprite: Sprite2D = $Sprite2D

"""Eventuellt ta bort big2 meteor då kollisionskroppen ej stämmer"""
const meteors = [preload("res://assets/PNG/Meteors/meteorBrown_big1.png"),
				preload("res://assets/PNG/Meteors/meteorBrown_big3.png"),
				preload("res://assets/PNG/Meteors/meteorBrown_big4.png"),
				preload("res://assets/PNG/Meteors/meteorBrown_big2.png"),
				preload("res://assets/PNG/Meteors/meteorGrey_big1.png"),
				preload("res://assets/PNG/Meteors/meteorGrey_big2.png"),
				preload("res://assets/PNG/Meteors/meteorGrey_big3.png"),
				preload("res://assets/PNG/Meteors/meteorGrey_big4.png")]


func _ready() -> void:
	sprite.texture = meteors[random_meteor_number]
	global_position[0] = meteor_x
	global_position[1] = meteor_y


func _physics_process(delta: float) -> void:
	global_rotation += random_rotation_number
	global_position[0] += random_speed_x * delta * dir_x
	global_position[1] += random_speed_x * delta * dir_y	
