extends CharacterBody2D
class_name METEOR

var random_rotation_number = RandomNumberGenerator.new().randf_range(0.01, 0.1)
var random_meteor_number = RandomNumberGenerator.new().randf_range(0, 7)
var random_speed_x = RandomNumberGenerator.new().randf_range(0,500)
var random_speed_y = RandomNumberGenerator.new().randf_range(0,500)


var dir_x = [1,-1].pick_random()
var dir_y = [1,-1].pick_random()


var width = [-1000, 5500]
var hight = [-1000, 3500]


var meteor_x = RandomNumberGenerator.new().randf_range(-1000, 5500)
var meteor_y = RandomNumberGenerator.new().randf_range(-1000,3500)


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
	global_position.x = meteor_x
	global_position.y = meteor_y


func _physics_process(delta: float) -> void:
	global_rotation += random_rotation_number
	_movement(delta)
	outside_play_area()

func explode():
	queue_free()


func outside_play_area():
	if (width[0] > self.global_position.x or self.global_position.x > width[1]) or (hight[0] > self.global_position.y or self.global_position.y > hight[1]):
		queue_free()

func _movement(delta):
	velocity.x = random_speed_x * dir_x
	velocity.y = random_speed_y * dir_y
	move_and_slide()
