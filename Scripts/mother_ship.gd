extends CharacterBody2D
class_name  MOTHERSHIP

var Player = null
var player_checked = false
var number = 0
var rotation_comparison = null
var rotation_checked: bool = false

#Sätt health 1 lägre än det rätta värdet
var health = 4

@onready var gun1 = $Guns/Gun
@onready var gun2 = $Guns/Gun2
@onready var gun3 = $Guns/Gun3

@onready var player_data_timer: Timer = $Player_Data_Timer
@onready var Gun_explosion_pic: Sprite2D = $Guns/Gun_explosion_pic
@onready var gun_anim: AnimationPlayer = $Guns/Explosion_anim
@onready var gun1_destroyed_particles: GPUParticles2D = $Guns/GunParticles
@onready var gun2_destroyed_particles: GPUParticles2D = $Guns/Gun2Particles
@onready var gun3_destroyed_particles: GPUParticles2D = $Guns/Gun3Particles

@onready var damage1: Sprite2D = $Damage/Damage1
@onready var damage1_1: Sprite2D = $Damage/Damage1_1
@onready var damage2: Sprite2D = $Damage/Damage2
@onready var damage2_1: Sprite2D = $Damage/Damage2_1
@onready var damage3: Sprite2D = $Damage/Damage3
@onready var damage3_1: Sprite2D = $Damage/Damage3_1

@onready var big_explosion_pic: Sprite2D = $Big_explosion_pic
@onready var big_explosion_anim: AnimationPlayer = $Big_explosion_anim
@onready var ship_collision: CollisionPolygon2D = $Ship_Collision


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


func damage_progress():
	if health == 2:
		gun1.hide()
		gun_anim.play("Gun_Explosion")
		gun1.broken = true
		gun1_destroyed_particles.emitting = true
		damage1.show()
		damage1_1.show()
	elif health == 1:
		gun2.hide()
		Gun_explosion_pic.position = Vector2(0,-82)
		gun_anim.play("Gun_Explosion")
		gun2.broken = true
		gun2_destroyed_particles.emitting = true
		damage2.show()
		damage2_1.show()
	elif health == 0:
		gun3.hide()
		Gun_explosion_pic.position = Vector2(0,-30)
		gun_anim.play("Gun_Explosion")
		gun3.broken = true
		gun3_destroyed_particles.emitting = true
		damage3.show()
		damage3_1.show()

func damage():
	if health > 0:
		health -= 1
	else:
		ship_collision.set_deferred("disabled", true)
		big_explosion_pic.show()
		big_explosion_anim.play("Big_explosion")
		await big_explosion_anim.animation_finished
		big_explosion_pic.hide()
		big_explosion_anim.play("fade_out")
		await big_explosion_anim.animation_finished
		queue_free()
		
	damage_progress()
