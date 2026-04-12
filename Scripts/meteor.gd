extends CharacterBody2D
class_name METEOR



"""
EXPLANATION OF THE UNIT

A standard space rock that is recommended to avoid.
Is capable of damaging the player and all enemies
except the mothership.
"""

############################ PRELOAD SCENES ####################################
##list of all the possible meteor sprites
const meteors = [preload("res://assets/PNG/Meteors/meteorBrown_big1.png"),
				preload("res://assets/PNG/Meteors/meteorBrown_big3.png"),
				preload("res://assets/PNG/Meteors/meteorBrown_big4.png"),
				preload("res://assets/PNG/Meteors/meteorBrown_big2.png"),
				preload("res://assets/PNG/Meteors/meteorGrey_big1.png"),
				preload("res://assets/PNG/Meteors/meteorGrey_big2.png"),
				preload("res://assets/PNG/Meteors/meteorGrey_big3.png"),
				preload("res://assets/PNG/Meteors/meteorGrey_big4.png")]



############################# ON READY VARIABLES ###############################
@onready var sprite: Sprite2D = $Sprite2D
@onready var explosion_pic: Sprite2D = $Explosion_Pic
@onready var anim: AnimationPlayer = $Explosion_animation
@onready var meteor_collision: CollisionShape2D = $CollisionShape2D
@onready var collision_area: Area2D = $CollisionArea
@onready var destuction_audio: AudioStreamPlayer2D = $Destruction_Audio



########################### VARIABLES ################################
#The random rotation, speed and sprite of the meteor
var random_rotation_number = RandomNumberGenerator.new().randf_range(0.01, 0.1)
var random_meteor_number = RandomNumberGenerator.new().randf_range(0, 7)
var random_speed_x = RandomNumberGenerator.new().randf_range(0,500)
var random_speed_y = RandomNumberGenerator.new().randf_range(0,500)

#Health only applies for enemy_laser
var health = 3
var dead: bool = false

#The randomized direction for the meteor.
var dir_x = [1,-1].pick_random()
var dir_y = [1,-1].pick_random()

#The coordinates for the width and hight of the spawnable area 
var width = [-1000, 5500]
var hight = [-1000, 3500]



################ STANDARD FUNCTIONS ################
func _ready() -> void:
	"""
	Makes sure to give the meteor its randomized sprite.
	"""
	sprite.texture = meteors[random_meteor_number]


func _physics_process(_delta: float) -> void:
	"""
	makes sure the meteor is constantly moving and rotating.
	also makes sure to check whether or not it is outside the game area.
	"""
	global_rotation += random_rotation_number
	_movement()
	if not dead:
		_outside_play_area()



################## MOVEMENT FUNCTIONS ##################
func _outside_play_area():
	"""
	Checks if the meteor is outside the game area and in that case despawns 
	it to improve performance.
	first parentheses:
		if the meteors position is left or right of the game area and
		therefore outside.
	second parentheses:
		if the meteors position is above or below the game area and
		therefore outside.
	"""
	if (width[0] > self.global_position.x or self.global_position.x > width[1]) or (hight[0] > self.global_position.y or self.global_position.y > hight[1]):
		queue_free()


func _movement():
	"""
	Moves the meteor with the random speed in the random direction.
	"""
	velocity.x = random_speed_x * dir_x
	velocity.y = random_speed_y * dir_y
	move_and_slide()



################## DAMAGE FUNCTIONS #################
func explode():
	"""
	Explodes the meteor showing the explosion sprite and animation. Also
	increases your score (kills) and disables its collision. Lastly 
	removes itself from the scene tree.
	if not dead is there to prevent it from dying multiple times.
	"""
	if not dead:
		LevelManager.kills += 1
		dead = true
		collision_area.set_deferred("monitoring", false)
		meteor_collision.set_deferred("disabled", true)
		sprite.hide()
		explosion_pic.show()
		anim.play("exploding")
		destuction_audio.play()
		await anim.animation_finished
		queue_free()


func damage():
	"""
	This funktion is only called when enemy_laser is colliding with it.
	If the meteor is hit by enemy_laser 3 times it will explode and
	makes sure the score (kills) is not increased as it wasn't the 
	players kill.  
	"""
	if not dead:
		health -= 1
		if health <= 0:
			LevelManager.kills -= 1
			explode()


func _on_collision_area_body_entered(body: Node2D) -> void:
	"""
	Checks if the meteor is colliding with a body and will damage it
	if it happens to be a enemy_1 (ENEMY), enemy_chaser or player.
	This will also make it explode. If it collides with a mothership,
	it will also explode but without dealing any damage to the mothership.
	"""
	if body is ENEMY or body is ENEMY_CHASER: 
		body.explode()
		LevelManager.kills -= 1
	elif body is PLAYER:
		body.damage(METEOR)
		explode()
	elif body is MOTHERSHIP:
		explode()
