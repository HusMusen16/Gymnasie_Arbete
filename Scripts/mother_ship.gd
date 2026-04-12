extends CharacterBody2D
class_name  MOTHERSHIP

"""
EXPLANATION OF THE UNIT

The heaviest armed and armored ship of the enemies main
invasion fleet. Is equipped with thick armour requiring 
5 plasma blasts to destroy. It is also equipped with 3 
cannons firing bigger and stronger lasers than normal
at the player.
"""



############################## ON READY VARIABLES ##############################
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



################################## VARIABLES ###################################
var player = null
var number = 0
var rotation_comparison = null
var rotation_checked: bool = false

var health = 5
var just_spawned: bool = true
var tutorial: bool = false




################# DAMAGE FUNKTIONS ##############
func _damage_progress():
	"""
	The damage progression of the ship. The first and last damage does nothing 
	visually. The 3 after that however removes one gun each with an animation
	and also adds visual damage to the hull of the ship. 
	"""
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
	"""
	the funktion that removes the ships health when damaged. Also kills the ship
	when the health reaches 0. Here is also where _damage_progress() is called.
	"""
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
	"""
	plays the animation for when the ship first enters the game area. Also has 
	an animation if it escapes from combat. When it first spawns in the ship
	is not visible as you otherwise can see it teleport to its actual position.
	"""
	if just_spawned:
		FTL_jump_sound_player.play()
		big_explosion_anim.play("FTL-Jump in")
		self.visible = true
		just_spawned = false
	else:
		big_explosion_anim.play("FTL-Jump out")
		FTL_jump_sound_player.play()
		await big_explosion_anim.animation_finished
		queue_free()



#################### TIMERS ##################
func _on_player_data_timer_timeout() -> void:
	"""
	When the timer runs out the ship will be able to give its guns references for 
	the player and the ships parent node motherships (in the level scene) for 
	a reference to when the rotation of the ship changes (rotation_comparison), 
	otherwise the cannons will not point in the correct direction.
	It is also called when the player dies to remove the reference to the player
	from the guns. 
	The funktion is necessary as the _ready() funktion refuses to give the guns
	the reference to the player.  
	"""
	if rotation_comparison != null: 
		gun1.rotation_adjustment = rotation_comparison
		gun2.rotation_adjustment = rotation_comparison
		gun3.rotation_adjustment = rotation_comparison
	if player != null:
		gun1.player = player
		gun2.player = player
		gun3.player = player
	else:
		gun1.player = null
		gun2.player = null
		gun3.player = null


func _on_escape_timer_timeout() -> void:
	"""
	this timer activates in the _damage_progess() funktion and will cause the
	ship to escape after a certain amount of time when no cannons are left to
	defend it. It will not do this in the tutorial though.
 	"""
	if health > 0 and not tutorial:
		ftl_jump()
