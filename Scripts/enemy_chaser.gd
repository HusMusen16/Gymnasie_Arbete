extends CharacterBody2D
class_name ENEMY_CHASER



"""
EXPLANATION OF THE UNIT

A variation of the standard unit (enemy_1) that slowly 
closes the gap to its target before detonating, dealing
damage to everything in its way.
"""


############################# ON READY VARIABLE ################################
@onready var anim: AnimationPlayer = $ExplosionAnimation
@onready var explosion_picture: Sprite2D = $Explosion_Picture
@onready var main_sprite: Sprite2D = $Main_Sprite
@onready var debris: Node2D = $Debris_sprites
@onready var ship_collision: CollisionShape2D = $CollisionShape2D
@onready var explosion_radius: Area2D = $ExplosionRadius
@onready var explosion_audio: AudioStreamPlayer2D = $Explosion_Audio


########################### VARIABLES ############################
var dead:bool = false

## Either player, spacestation or null
var target = null
var spacestation_damaged = false

############################# CONSTANTS ########################################
const SPEED = 200



################# GENERAL FUNKTIONS ##############
func explode():
	"""
	Destroys the enemy ship and plays an explosion animation
	Also increases your kills by 1 and disables its own collision
	It does however enable its explosion area to deal damage 
	to players, enemies and asteroids that are inside
	"""
	if not dead:
		dead = true
		explosion_radius.monitoring = true
		LevelManager.kills += 1
		
		ship_collision.set_deferred("disabled", true)
		main_sprite.hide()
		debris.show()
		explosion_picture.show()
		
		anim.play("Exploding")
		explosion_audio.play()
		await anim.animation_finished
		explosion_radius.monitoring = false
		var tween = create_tween()
		tween.tween_property(debris, "modulate:a", 0, 1)
		await tween.finished
		queue_free()


func _physics_process(_delta: float) -> void:
	"""
	Makes sure it continues to move towards its target unless
	the it itself or the target is dead.
	"""
	if target and not dead:
		var dir = global_position.direction_to(target.global_position)
		_movement(dir)


################## MOVEMENT FUNKTIONS #####################
func _movement(dir):
	"""
	Moves the enemy towards its target with a constant speed
	dir = direction to target
	"""
	velocity.x = dir[0] * SPEED
	velocity.y = dir[1] * SPEED
	move_and_slide()


################## DETONATION FUNKTIONS #################
func _on_detonation_sensor_body_entered(body: Node2D) -> void:
	"""
	a area that makes the enemy explode if a player or 
	space station is within it
	"""
	if body is PLAYER or body is SPACESTATION:
		explode()


func _on_explosion_radius_body_entered(body: Node2D) -> void:
	"""
	The area where the its explosion deals damage
	will deal damage to everything, even fellow enemies
	"""
	if body is PLAYER:
		body.damage(ENEMY_CHASER)

	elif body is SPACESTATION and not spacestation_damaged:
		#spacestation_damaged is necessary as it otherwise will deal damage again if the game is paused and unpaused
		body.health -= 10
		spacestation_damaged = true
		
	elif body is METEOR:
		body.explode()

	elif body is ENEMY:
		body.explode()
	
	elif body is ENEMY_CHASER:
		body.explode()
	
	elif body is MOTHERSHIP:
		body.damage()
