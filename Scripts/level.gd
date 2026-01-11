extends Node2D
class_name LEVEL

var laser_scene: PackedScene = load("res://Scenes/laser.tscn")
var meteor_scene: PackedScene = load("res://Scenes/meteor.tscn")
var enemy_scene: PackedScene = load("res://Scenes/enemy_1.tscn")
var plasma_scene: PackedScene = load("res://Scenes/plasma_blast.tscn")


@onready var player: PLAYER = $Player
@onready var lasers: Node = $Lasers
@onready var meteors: Node = $Meteors
@onready var enemies: Node = $Enemies
@onready var plasmas: Node = $Plasmas
@onready var meteor_timer: Timer = $Meteor_Timer
@onready var enemy_timer: Timer = $Enemy_Timer
@onready var health_bar: ProgressBar = $BG/ColorRect/HealthBar
@onready var damage_timer: Timer = $Damage_Timer
@onready var plasma_countdown_bar: ProgressBar = $BG/ColorRect2/plasma_countdown
@onready var plasma_label: Label = $BG/ColorRect2/Label


var health = 100

var safe: bool = false


func _spawn_enemy():
	var enemy = enemy_scene.instantiate()
	enemies.add_child(enemy)
	enemy.player = player


###################### TIMERS ############################
func _on_meteor_timer_timeout() -> void:
	var meteor = meteor_scene.instantiate()
	meteors.add_child(meteor)


func _on_enemy_timer_timeout() -> void:
	_spawn_enemy()


func _on_damage_timer_timeout() -> void:
	safe = false


###################### SIGNALS ###########################
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


func _on_player_plasma_countdown(time: Variant) -> void:
	plasma_countdown_bar.value = time * 25
	if plasma_countdown_bar.value <= 0:
		plasma_label.show()
	else:
		plasma_label.hide()


func _on_player_player_hit(type: Variant) -> void:
	if not safe:
		if type == ENEMY:
			health -= 5
		elif type == METEOR:
			health -= 10
		health_bar.value = health
		safe = true
		damage_timer.start(-1)
