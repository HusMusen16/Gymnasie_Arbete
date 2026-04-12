extends CharacterBody2D
class_name ENEMY

"""
EXPLANATION OF THE UNIT

The standard unit of the enemy. Shoots lasers at varying 
rate towards the player and tries to close the gap at 
varying pace
"""


############################### PACKED SCENES ##################################
var laser_scene: PackedScene = load("res://Scenes/enemy_laser.tscn")



############################# ON READY VARIABLE ################################
@onready var x_timer: Timer = $X_timer
@onready var y_timer: Timer = $Y_timer
@onready var x_allow_timer: Timer = $X_allow_timer
@onready var y_allow_timer: Timer = $Y_allow_timer
@onready var targeting_swap_timer: Timer = $Targeting_swap_timer

@onready var shoot_timer: Timer = $Shoot_timer
@onready var lasers: Node = $Lasers

@onready var anim: AnimationPlayer = $ExplosionAnimation
@onready var explosion_picture: Sprite2D = $Explosion_Picture
@onready var main_sprite: Sprite2D = $Main_Sprite
@onready var debris: Node2D = $Debris_sprites

@onready var ship_collision: CollisionShape2D = $CollisionShape2D
@onready var gun_audio: AudioStreamPlayer2D = $GunSound
@onready var destruction_audio: AudioStreamPlayer2D = $Destruction_Audio



############################# STATE VARIABLES + ################################
enum {IDLE, CHASING, ENGAGING, DEAD}
var state = IDLE



##################################### VARIABLES ################################
var allow_targeting_swap: bool = true
var player = null

var pause_x = false
var pause_y = false

var x_pause_allowed = true
var y_pause_allowed = true

var enemy_x = RandomNumberGenerator.new().randf_range(-1000, 5500)
var enemy_y = RandomNumberGenerator.new().randf_range(-1000,3500)



############################# CONSTANTS ########################################
const SPEED = 500



############################## GAME LOOP #######################################
func _physics_process(_delta: float) -> void:
	"""
	Makes sure the enemy is doing what it is supposed to.
	also gives the enemy the direction and distance to the player
	"""
	if player:
		var dir = global_position.direction_to(player.global_position)
		var distance = global_position.distance_to(player.global_position)
		
		match state:
			CHASING:
				_CHASING_STATE(dir, distance)
			ENGAGING:
				_ENGAGING_STATE(dir, distance)
			IDLE:
				_IDLE_STATE()
			DEAD:
				_DEAD_STATE()
	else:
		if state != IDLE:
			_enter_idle_state()
		_IDLE_STATE()



########################### GENERAL FUNKTIONS ##################################
func explode():
	"""
	Destroys the enemy ship and plays an explosion animation
	Also increases your kills by 1 and disables its own collision
	"""
	if state != DEAD:
		state = DEAD
		LevelManager.kills += 1
		ship_collision.set_deferred("disabled", true)
		main_sprite.hide()
		debris.show()
		explosion_picture.show()
		anim.play("Exploding")
		destruction_audio.play()
		await anim.animation_finished
		var tween = create_tween()
		tween.tween_property(debris, "modulate:a", 0, 1)
		await tween.finished
		queue_free()


func _movement(dir):
	"""
	Moves the enemy towards the player 
	
	dir = the direction to the player
	
	choice_x / choice_y = a random number between 0-6 that decides
	if the movement on the respective axle should be paused, movement
	is paused if the number is 0.
	"""
	"""
	Each movement axis has a chance to be paused to give the
	enemy feel less artificial. After a axis is paused it cannot 
	be immediately paused again.
	"""
	if not pause_x:
		var choice_x = randi() % 6
		if choice_x == 0 and x_pause_allowed:
			pause_x = true
			x_pause_allowed = false
			x_timer.start(-1)
			x_allow_timer.start(-1)
			velocity.x = 0
		else:
			velocity.x = dir[0] * SPEED
		
	if not pause_y:
		var choice_y = randi() % 6
		if choice_y == 0 and y_pause_allowed:
			pause_y = true
			y_pause_allowed = false
			y_timer.start(-1)
			y_allow_timer.start(-1)
			velocity.y = 0
		else:
			velocity.y = dir[1] * SPEED
			
	move_and_slide()



############################# STATE FUNKTIONS ##################################
func _CHASING_STATE(dir,distance):
	"""
	The state where the enemy tries to catch up 
	with the player.
	"""
	if distance <= 500 and allow_targeting_swap:
		_enter_engaging_state()
	else:
		_movement(dir)


func _ENGAGING_STATE(dir,distance):
	"""
	The state where the enemy has caught up with the player
	Here the enemy shoots very quickly but moves very slowly
	"""
	if distance > 500 and allow_targeting_swap:
		_enter_chasing_state()
	else:
		velocity = dir * SPEED * 0.1
		move_and_slide()


func _IDLE_STATE():
	"""
	The enemys first state
	Here it checks if it has a player to follow.
	If it has it will change to the Chasing state
	Otherwise it will stay stationary and disable its shooting timer.
	"""
	if player:
		state = CHASING
		shoot_timer.paused = false
	else:
		shoot_timer.paused = true


func _DEAD_STATE():
	"""
	The state the enemy is in when it has gotten killed.
	Makes sure that the enemy will not fire or move.
	"""
	shoot_timer.paused = true



############################ ENTER STATE FUNKTIONS #############################
func _enter_chasing_state():
	"""
	Activates when the enemy needs to change to the chasing state.
	Makes sure to change the fire rate (shoot_timer) so it fires more slowly.
	"""
	state = CHASING
	allow_targeting_swap = false
	targeting_swap_timer.start(-1)
	
	shoot_timer.stop()
	shoot_timer.wait_time = 2
	shoot_timer.start(-1)


func _enter_engaging_state():
	"""
	Activates when the enemy is close enought to the player
	and therefore should be in the engaging state.
	Increases the fire rate (shoot_timer) 
	"""
	state = ENGAGING
	allow_targeting_swap = false
	targeting_swap_timer.start(-1)
	
	shoot_timer.stop()
	shoot_timer.wait_time = 0.5
	shoot_timer.start(-1)


func _enter_idle_state():
	"""
	Activates when the enemy does not have a reference to the player
	Makes sure to change the state to IDLE
	"""
	state = IDLE
	shoot_timer.stop()



################################# TIMERS #######################################
func _on_x_timer_timeout() -> void:
	"""
	unpauses movement on the x-axis during the CHASE state
	"""
	pause_x = false


func _on_y_timer_timeout() -> void:
	"""
	unpauses movement on the y-axis during the CHASE state
	"""
	pause_y = false


func _on_x_allow_timer_timeout() -> void:
	"""
	A timer that makes sure the movement on the x-axis cannot
	be paused directly again.
	"""
	x_pause_allowed = true


func _on_y_allow_timer_timeout() -> void:
	"""
	A timer that makes sure the movement on the y-axis cannot
	be paused directly again.
	"""
	y_pause_allowed = true


func _on_shoot_timer_timeout() -> void:
	"""
	shoots a laser at the player and plays a respective sound
	"""
	if player:
		gun_audio.play()
		var laser = laser_scene.instantiate()
		lasers.add_child(laser)
		laser.global_position = self.global_position
		laser.dir = global_position.direction_to(player.global_position)


func _on_targeting_swap_timer_timeout() -> void:
	"""
	A timer that makes sure the enemy does not immediatly 
	change state again entering the CHASE/ENGAGING state
	"""
	allow_targeting_swap = true
