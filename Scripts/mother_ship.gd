extends CharacterBody2D
class_name  MOTHERSHIP

var Player = null
var player_checked = false
var number = 0
var rotation_comparison = null
var rotation_checked: bool = false

@onready var gun1 = $Guns/Gun
@onready var gun2 = $Guns/Gun2
@onready var gun3 = $Guns/Gun3
@onready var player_data_timer: Timer = $Player_Data_Timer




func _physics_process(delta: float) -> void:
	if rotation_comparison != null and not rotation_checked: 
		gun1.rotation_adjustment = rotation_comparison
		gun2.rotation_adjustment = rotation_comparison
		gun3.rotation_adjustment = rotation_comparison
		rotation_checked = true
			
		

func _on_player_data_timer_timeout() -> void:
	if Player != null:
		gun1.player = Player
		gun2.player = Player
		gun3.player = Player
		player_checked = true
		player_data_timer.stop()
