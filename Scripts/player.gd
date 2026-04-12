extends CharacterBody2D
class_name PLAYER

"""
EXPLANATION OF THE UNIT

The FC-43 valkyrie is the most advanced fighter of the
federation of earth and is thus equipped with the latest
and greatest armaments and armour.  The ship is capable 
of taking down entire enemy fleets before seizing 
operation itself. It is currently only in use by the 16th 
naval regiment also known as the valkyries of the skies. 
This regiment only has the greatest of pilots and is 
regarded as humanities last hope if all goes downhill.
"""



############################ ON READY VARIABLES ################################
@onready var thrusters: GPUParticles2D = $Rocket
@onready var gun_flash:GPUParticles2D = $GunFlash
@onready var laser_source: Marker2D = $LaserSource
@onready var shoot_timer: Timer = $ShootTimer
@onready var flash_duration: Timer = $FlashDuration
@onready var gun_audio: AudioStreamPlayer = $GunSound
@onready var plasma_gun_audio: AudioStreamPlayer = $PlasmaGunSound
@onready var explosion_pic: Sprite2D = $Explosion_Pic
@onready var anim: AnimationPlayer = $Explosion_animation
@onready var player_sprite: Sprite2D = $Sprite2D
@onready var speed_boost_timer: Timer = $Speed_Boost
@onready var ram_area: Area2D = $RamArea
@onready var unlimited_plasma_reset_timer: Timer = $Unlimited_Plasma_Reset_Timer
@onready var shield_sprite: Sprite2D = $ShieldSprite



################################### VARIABLES ##################################
var ACC = 20
var speed = 900
var can_shoot_plasma: bool = true
var dead: bool = false
var has_died: bool = false
var speed_boost_allowed: bool = true
var shield_active: bool = false
var unlimited_power: bool = false

#Necessary for the tutorial
var laser_locked: bool = false
var plasma_locked: bool = false
var speed_boost_locked: bool = false



#################################### SIGNALS ###################################

##Shows what type of enemy caused the damage
signal player_hit(type)
##Gives the type of laser (plasma or regular) shoot and the players current position and direction
signal laser(type, pos, dir)
##Gives the time left until plasma blast is usable again.
signal plasma_countdown(time)
##Gives the time left until speed boost is usable again.
signal speed_boost_countdown(time)
##This signal is emited by health_pickup when picked up.
signal picked_up_item(type)



############### GENERAL FUNKTIONS ###############
func _movement():
	"""
	The movement of the player. Also handles that the thrusters particles
	is turned on and off and that the ship is correctly rotated.
	direction = the direction vectors gotten from keyboard inputs.
	"""
	
	########### MOVEMENT #############
	var direction = Input.get_vector("left", "right", "up", "down")
	
	velocity.x = move_toward(velocity.x, speed * direction[0], ACC)
	velocity.y = move_toward(velocity.y, speed * direction[1], ACC)
	
	move_and_slide()
	
	#Turns the rockets particles on and off depending if you are moving or not
	if direction[0] != 0 or direction[1] != 0:
		thrusters.emitting = true
	else:
		thrusters.emitting = false
	
	################ ROTATION ################
 	#Horizontal and vertical directions
	if direction[1] == 1:
		self.rotation_degrees = 180
		
	elif direction[1] == -1:
		self.rotation_degrees = 0
		
	elif direction[0] == -1 or direction[0] == 1:
		self.rotation_degrees = 90*direction[0]

	#diagonal directions
	elif direction[0] < 0 and direction[1] < 0 or direction[0] > 0 and direction[1] < 0:
		self.rotation_degrees = -45*direction[0]/direction[1]
		
	elif direction[0] < 0 and direction[1] > 0 or direction[0] > 0 and direction[1] > 0:
		self.rotation_degrees = 135*direction[0]/direction[1]


func _physics_process(_delta: float) -> void:
	"""
	Makes sure the player can move and shoot if it is not dead. It also sends
	out signals to the levels on how long cooldown is left for plasma blast and
	speed boost.
	"""
	if not dead:
		if Input.is_action_just_pressed("Speed boost") and speed_boost_allowed and not speed_boost_locked:
			#makes sure there is no conflict regarding movement when speed boosting
			speed_boost_allowed = false
			_speed_boost()
			speed_boost_timer.start()
			
		else:
			_movement()
			_shooting()
			
			if not can_shoot_plasma:
				var time = shoot_timer.time_left
				plasma_countdown.emit(time)
			else:
				plasma_countdown.emit(0)
				
			if not speed_boost_allowed:
				var time = speed_boost_timer.time_left
				speed_boost_countdown.emit(time)
			else:
				speed_boost_countdown.emit(0)


func _speed_boost():
	"""
	The function handling the speed boost. Checks what the current rotation is 
	and boosts the movement in that direction. Also activates the shield and its
	damage area.
	
	boost_factor = the factor the top speed is increased by.
	boost_ACC = the acceleration for the boost
	"""
	
	#Possible angles 0, 180, 90, -90, 45, -45, 135, -135
	
	var boost_factor = 2.5
	var boost_ACC = 1000
	
	shield_active = true
	
	############### MOVEMENT ##############
	if self.global_rotation_degrees == 0:
		velocity.y = move_toward(velocity.y, -speed * boost_factor, boost_ACC)
		
	elif self.global_rotation_degrees == -180:
		velocity.y = move_toward(velocity.y, speed * boost_factor, boost_ACC)
		
	elif self.global_rotation_degrees == -90 or self.global_rotation_degrees == 90:
		velocity.x = move_toward(velocity.x, speed * self.global_rotation_degrees/90 * boost_factor, boost_ACC)
		
	elif self.global_rotation_degrees == -45 or self.global_rotation_degrees == 45:
		var direction = sqrt(2)/2
		velocity.x = move_toward(velocity.x, speed * direction * self.global_rotation_degrees/45 * boost_factor, boost_ACC)
		velocity.y = move_toward(velocity.y, speed * -direction * boost_factor, boost_ACC)
		
	elif self.global_rotation_degrees == -135 or self.global_rotation_degrees == 135:
		var direction = sqrt(2)/2
		velocity.x = move_toward(velocity.x, speed * direction * self.global_rotation_degrees/135 * boost_factor, boost_ACC)
		velocity.y = move_toward(velocity.y, speed * direction * boost_factor, boost_ACC)
	
	########### SHIELD ############
	move_and_slide()
	anim.play("shield_activated")
	await anim.animation_finished
	shield_active = false



################### DAMAGE FUNKTIONS ###################
func _shooting():
	"""
	The function that handles the shooting of lasers and plasma blasts.
	Listens for inputs and emits signals and plays audio and animation when detected.
	"""
	if Input.is_action_just_pressed("shoot_laser") and not laser_locked:
		laser.emit("laser", laser_source.global_position, self.rotation_degrees)
		
		gun_audio.play()
		flash_duration.start(0)
		gun_flash.emitting = true
	
	elif Input.is_action_just_pressed("shoot_plasma") and not plasma_locked:
		#Is active for a certain amount of time after picking up the unlimited_plasma_pickup 
		if unlimited_power:
			laser.emit("plasma", laser_source.global_position, self.rotation_degrees)
			plasma_gun_audio.play()
		
		#The normal state
		elif can_shoot_plasma:
			laser.emit("plasma", laser_source.global_position, self.rotation_degrees)
		
			plasma_gun_audio.play()
			shoot_timer.start(0)
			can_shoot_plasma = false


func damage(type):
	"""
	Emits a signal to the level unless the shield from the speed boost is active.
	Is accessed from funktions where the enemy deals damage to the player.
	type = the enemy that deals damage
 	"""
	if not shield_active:
		player_hit.emit(type)


func destroyed():
	"""
	Handles how the ship should look when destroyed/when the game is lost.
	Makes sure to hide the player and shield sprites and shows the 
	explosion animation and sprite.
	"""
	shield_sprite.hide()
	explosion_pic.show()
	player_sprite.hide()
	anim.play("exploding")


func _on_ram_area_body_entered(body: Node2D) -> void:
	"""
	The area activated when the shield in _speed_boost() is active.
	Will damage the enemies below if they enter the area.
	"""
	if body is ENEMY or body is ENEMY_CHASER or body is METEOR:
		body.explode()


func unlimited_plasma_blast():
	"""
	The funktion that handles what happens when you get access to unlimited plasma blasts powerup.
	Will start a timer so the power up doesn't last forever.
	"""
	unlimited_power = true
	unlimited_plasma_reset_timer.start(-1)



###################### TIMERS ###################
func _on_shoot_timer_timeout() -> void:
	"""
	This timeout will make you able to shoot the plasma blast again. 
	"""
	can_shoot_plasma = true


func _on_flash_duration_timeout() -> void:
	"""
	The duration of the muzzle flash from the regular laser.
	disables the muzzle flash particles on timeout
	"""
	gun_flash.emitting = false


func _on_speed_boost_timeout() -> void:
	"""
	This timeout will make you able to use the speed boost again. 
	"""
	speed_boost_allowed = true


func _on_unlimited_plasma_reset_timer_timeout() -> void:
	"""
	This timeout will stop the unlimited plasma_powerup from having
	an affect.
	"""
	unlimited_power = false
