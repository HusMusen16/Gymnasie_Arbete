extends Node2D
class_name GUN

"""
EXPLANATION OF THE UNIT

The gun attached to motherships with a total of 3 per
ship. Might get destroyed when mothership takes damage 
"""

################################# PACKED SCENES ################################
var laser_scene: PackedScene = load("res://Scenes/enemy_laser.tscn")



############################# ON READY VARIABLES ###############################
@onready var lasers: Node = $Lasers
@onready var laser_source: Marker2D = $Laser_Source
@onready var shoot_timer: Timer = $Shoot_Timer
@onready var gun_audio: AudioStreamPlayer2D = $GunSound



#################################### VARIABLES #################################
var broken: bool = false 
var player = null
var fire_rates = [1,1.2,1.4,1.6,1.8]
var rotation_adjustment = null



################################### FUNCTIONS ##################################
func _ready() -> void:
	"""
	Makes sure the lasers randomized firerate is set.
	"""
	shoot_timer.wait_time = fire_rates.pick_random()


func _physics_process(_delta: float) -> void:
	"""
	Makes sure the gun is angled to always point at the 
	player if it has a reference for it and is not broken
	"""
	if player and not broken:
		var rotation_adjustment_in_radians = deg_to_rad(rotation_adjustment.rotation_degrees)
		var dir = global_position.direction_to(player.global_position)
		rotation = dir.angle() - rotation_adjustment_in_radians


func _on_shoot_timer_timeout() -> void:
	"""
	Makes sure to spawn in a laser aimed at the player every
	time the timer times out. Also makes sure to change some
	stats for the laser so it is different from that of 
	enemy_1.
	"""
	if player and not broken:
		gun_audio.play()
		var laser = laser_scene.instantiate()
		lasers.add_child(laser)
		laser.type = MOTHERSHIP
		laser.SPEED = 1000
		laser.scale = Vector2(2,2)
		laser.global_position = laser_source.global_position
		laser.dir = global_position.direction_to(player.global_position)
