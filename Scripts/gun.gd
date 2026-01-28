extends Node2D
class_name GUN

var laser_scene: PackedScene = load("res://Scenes/enemy_laser.tscn")

@onready var lasers: Node = $Lasers
@onready var laser_source: Marker2D = $Laser_Source
@onready var shoot_timer: Timer = $Shoot_Timer

var dead: bool = false 
var player = null
var fire_rates = [0.6,0.8,1,1.2,1.4]
var rotation_adjustment = null


func _ready() -> void:
	var random_fire_rate = fire_rates.pick_random()
	shoot_timer.wait_time = random_fire_rate

func _physics_process(delta: float) -> void:
	if player:
		var rotation_adjustment_in_radians = deg_to_rad(rotation_adjustment.rotation_degrees)
		var dir = global_position.direction_to(player.global_position)
		rotation = dir.angle() - rotation_adjustment_in_radians

func _on_shoot_timer_timeout() -> void:
	if player and not dead:
		var laser = laser_scene.instantiate()
		lasers.add_child(laser)
		laser.type = MOTHERSHIP
		laser.SPEED = 1000
		laser.scale = Vector2(2,2)
		laser.global_position = laser_source.global_position
		laser.dir = global_position.direction_to(player.global_position)
