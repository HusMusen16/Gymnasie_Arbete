extends CharacterBody2D
class_name ENEMY


@onready var x_timer: Timer = $X_timer
@onready var y_timer: Timer = $Y_timer
@onready var x_allow_timer: Timer = $X_allow_timer
@onready var y_allow_timer: Timer = $Y_allow_timer
@onready var shoot_timer: Timer = $Shoot_timer
@onready var lasers: Node = $Lasers

var laser_scene: PackedScene = load("res://Scenes/enemy_laser.tscn")

var player = null
var choice = [0,1,2,3,4,5]

var pause_x = false
var pause_y = false

var x_pause_allowed = true
var y_pause_allowed = true

var enemy_x = RandomNumberGenerator.new().randf_range(-1000, 5500)
var enemy_y = RandomNumberGenerator.new().randf_range(-1000,3500)



const SPEED = 500


func _ready() -> void:
	global_position.x = enemy_x
	global_position.y = enemy_y


func _movement(dir, distance):	
	if not pause_x:
		var choice_x = choice.pick_random()
		if choice_x == 0 and x_pause_allowed:
			pause_x = true
			x_pause_allowed = false
			x_timer.start(-1)
			x_allow_timer.start(-1)
			velocity.x = 0
		else:
			velocity.x = dir[0] * SPEED
		
	if not pause_y:
		var choice_y = choice.pick_random()
		if choice_y == 0 and y_pause_allowed:
			pause_y = true
			y_pause_allowed = false
			y_timer.start(-1)
			y_allow_timer.start(-1)
			velocity.y = 0
		else:
			velocity.y = dir[1] * SPEED
			
	move_and_slide()



#################### STATE MACHINE ISH #########################
func _physics_process(delta: float) -> void:
	if player:
		var dir = global_position.direction_to(player.global_position)
		var distance = global_position.distance_to(player.global_position)
		if distance > 500:
			_CHASING(dir, distance)
		else:
			_ENGAGING(dir, distance)
			




####################### STATES ISH ###############################
func _CHASING(dir, distance):
	_movement(dir, distance)
	shoot_timer.wait_time = 3

func _ENGAGING(dir, distance):
	velocity = dir * SPEED * 0.1
	move_and_slide()
	shoot_timer.wait_time = 1
	



#################### TIMER TIMEOUTS ########################
func _on_x_timer_timeout() -> void:
	pause_x = false

func _on_y_timer_timeout() -> void:
	pause_y = false

func _on_x_allow_timer_timeout() -> void:
	x_pause_allowed = true

func _on_y_allow_timer_timeout() -> void:
	y_pause_allowed = true

func _on_shoot_timer_timeout() -> void:
	if player:
		var laser = laser_scene.instantiate()
		lasers.add_child(laser)
		laser.global_position = self.global_position
		laser.dir = global_position.direction_to(player.global_position)
