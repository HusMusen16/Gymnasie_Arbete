extends CharacterBody2D
class_name ENEMY


@onready var x_timer: Timer = $X_timer
@onready var y_timer: Timer = $Y_timer
@onready var x_allow_timer: Timer = $X_allow_timer
@onready var y_allow_timer: Timer = $Y_allow_timer
@onready var shoot_timer: Timer = $Shoot_timer
@onready var lasers: Node = $Lasers
@onready var anim: AnimationPlayer = $ExplosionAnimation
@onready var explosion_picture: Sprite2D = $Explosion_Picture
@onready var main_sprite: Sprite2D = $Main_Sprite
@onready var debris: Node2D = $Debris_sprites
@onready var ship_collision: CollisionShape2D = $CollisionShape2D
@onready var gun_audio: AudioStreamPlayer2D = $GunSound
@onready var targeting_swap_timer: Timer = $Targeting_swap_timer


enum {IDLE, CHASING, ENGAGING, DEAD}

var state = IDLE
var allow_targeting_swap: bool = true

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

##################### GAME LOOP ########################
func _physics_process(_delta: float) -> void:
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


################# GENERAL FUNKTIONS ##############
func explode():
	if state != DEAD:
		state = DEAD
		LevelManager.kills += 1
		ship_collision.set_deferred("disabled", true)
		main_sprite.hide()
		debris.show()
		explosion_picture.show()
		anim.play("Exploding")
		await anim.animation_finished
		var tween = create_tween()
		tween.tween_property(debris, "modulate:a", 0, 1)
		await tween.finished
		queue_free()


func _movement(dir):
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


################## STATE FUNKTIONS #####################
func _CHASING_STATE(dir,distance):
	if distance <= 500 and allow_targeting_swap:
		_enter_engaging_state()
	else:
		_movement(dir)


func _ENGAGING_STATE(dir,distance):
	if distance > 500 and allow_targeting_swap:
		_enter_chasing_state()
	else:
		velocity = dir * SPEED * 0.1
		move_and_slide()


func _IDLE_STATE():
	if player:
		state = CHASING
		shoot_timer.paused = false
	else:
		shoot_timer.paused = true


func _DEAD_STATE():
	shoot_timer.paused = true


################# ENTER STATE FUNKTIONS ###################
func _enter_chasing_state():
	state = CHASING
	allow_targeting_swap = false
	targeting_swap_timer.start(-1)
	
	shoot_timer.stop()
	shoot_timer.wait_time = 2
	shoot_timer.start(-1)


func _enter_engaging_state():
	state = ENGAGING
	allow_targeting_swap = false
	targeting_swap_timer.start(-1)
	
	shoot_timer.stop()
	shoot_timer.wait_time = 0.5
	shoot_timer.start(-1)


func _enter_idle_state():
	state = IDLE
	shoot_timer.stop()


#################### TIMERS ########################
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
		gun_audio.play()
		var laser = laser_scene.instantiate()
		lasers.add_child(laser)
		laser.global_position = self.global_position
		laser.dir = global_position.direction_to(player.global_position)

func _on_targeting_swap_timer_timeout() -> void:
	allow_targeting_swap = true
