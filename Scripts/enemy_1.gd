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


var laser_scene: PackedScene = load("res://Scenes/enemy_laser.tscn")

var dead:bool = false
var player = null
var choice = [0,1,2,3,4,5]


var pause_x = false
var pause_y = false

var x_pause_allowed = true
var y_pause_allowed = true

var enemy_x = RandomNumberGenerator.new().randf_range(-1000, 5500)
var enemy_y = RandomNumberGenerator.new().randf_range(-1000,3500)



const SPEED = 500


################# GENERAL FUNKTIONS ##############
func explode():
	if not dead:
		LevelManager.kills += 1
		dead = true
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


func _physics_process(_delta: float) -> void:
	if player and not dead:
		var dir = global_position.direction_to(player.global_position)
		var distance = global_position.distance_to(player.global_position)
		if distance > 500:
			_CHASING(dir)
		else:
			_ENGAGING(dir)



################## MOVEMENT FUNKTIONS #####################
func _CHASING(dir):
	_movement(dir)
	shoot_timer.wait_time = 5


func _ENGAGING(dir):
	velocity = dir * SPEED * 0.1
	move_and_slide()
	shoot_timer.wait_time = 1


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
	if player and not dead:
		gun_audio.play()
		var laser = laser_scene.instantiate()
		lasers.add_child(laser)
		laser.global_position = self.global_position
		laser.dir = global_position.direction_to(player.global_position)
