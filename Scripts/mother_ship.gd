extends CharacterBody2D
class_name  MOTHERSHIP

var player = null
var number = 0
var rotation_comparison = null
var rotation_checked: bool = false
var player_lost: bool = false

var health = 5
var just_spawned: bool = true

#Gun scenes
@onready var gun1 = $Guns/Gun
@onready var gun2 = $Guns/Gun2
@onready var gun3 = $Guns/Gun3

#General
@onready var ship_collision: CollisionPolygon2D = $Ship_Collision
@onready var player_data_timer: Timer = $Player_Data_Timer
@onready var gun_anim: AnimationPlayer = $Guns/Explosion_anim
@onready var escape_timer: Timer = $Escape_Timer

#Damage Sprites
@onready var damage1: Sprite2D = $Damage/Damage1
@onready var damage1_1: Sprite2D = $Damage/Damage1_1
@onready var damage2: Sprite2D = $Damage/Damage2
@onready var damage2_1: Sprite2D = $Damage/Damage2_1
@onready var damage3: Sprite2D = $Damage/Damage3
@onready var damage3_1: Sprite2D = $Damage/Damage3_1

#Explosion sprites and related 
@onready var big_explosion_pic: Sprite2D = $Big_explosion_pic
@onready var big_explosion_anim: AnimationPlayer = $Big_explosion_anim
@onready var Gun_explosion_pic: Sprite2D = $Guns/Gun_explosion_pic
@onready var gun1_destroyed_particles: GPUParticles2D = $Guns/GunParticles
@onready var gun2_destroyed_particles: GPUParticles2D = $Guns/Gun2Particles
@onready var gun3_destroyed_particles: GPUParticles2D = $Guns/Gun3Particles

#Sound Nodes
@onready var FTL_jump_sound_player: AudioStreamPlayer2D = $FTL_Jump_Sound
@onready var damage_sound_player: AudioStreamPlayer2D = $DamageSoundPlayer
@onready var destruction_audio_player: AudioStreamPlayer2D = $Destruction_Audio


############### GENERAL FUNKTIOSN ###############
func _physics_process(_delta: float) -> void:
	if rotation_comparison != null and not rotation_checked: 
		gun1.rotation_adjustment = rotation_comparison
		gun2.rotation_adjustment = rotation_comparison
		gun3.rotation_adjustment = rotation_comparison
		rotation_checked = true
	if player_lost:
		_on_player_data_timer_timeout()


################# DAMAGE FUNKTIONS ##############
func _damage_progress():
	if health == 3:
		gun1.hide()
		gun_anim.play("Gun_Explosion")
		gun1.broken = true
		gun1_destroyed_particles.emitting = true
		damage1.show()
		damage1_1.show()
	elif health == 2:
		gun2.hide()
		Gun_explosion_pic.position = Vector2(0,-82)
		gun_anim.play("Gun_Explosion")
		gun2.broken = true
		gun2_destroyed_particles.emitting = true
		damage2.show()
		damage2_1.show()
	elif health == 1:
		gun3.hide()
		Gun_explosion_pic.position = Vector2(0,-30)
		gun_anim.play("Gun_Explosion")
		gun3.broken = true
		gun3_destroyed_particles.emitting = true
		damage3.show()
		damage3_1.show()
		escape_timer.start(-1)


func damage():
	if health > 0:
		health -= 1
		damage_sound_player.play()
		if health == 0:
			LevelManager.mothership_kills += 1
			LevelManager.kills += 5
			ship_collision.set_deferred("disabled", true)
			big_explosion_pic.show()
			big_explosion_anim.play("Big_explosion")
			destruction_audio_player.play()
			await big_explosion_anim.animation_finished
			big_explosion_pic.hide()
			big_explosion_anim.play("fade_out")
			await big_explosion_anim.animation_finished
			await destruction_audio_player.finished
			queue_free()
		
	_damage_progress()


func ftl_jump():
	if just_spawned:
		self.visible = true
		FTL_jump_sound_player.play()
		big_explosion_anim.play("FTL-Jump in")
		just_spawned = false
	else:
		big_explosion_anim.play("FTL-Jump out")
		FTL_jump_sound_player.play()
		await big_explosion_anim.animation_finished
		queue_free()

#################### TIMERS ##################
func _on_player_data_timer_timeout() -> void:
	if player != null:
		gun1.player = player
		gun2.player = player
		gun3.player = player
		player_data_timer.stop()
	else:
		gun1.player = null
		gun2.player = null
		gun3.player = null


func _on_escape_timer_timeout() -> void:
	if health > 0:
		ftl_jump()
