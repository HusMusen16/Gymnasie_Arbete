extends CharacterBody2D
class_name PLAYER



var ACC = 1000
var speed = 900
var can_shoot_plasma: bool = true
var dead: bool = false
var has_died: bool = false
var speed_boost_allowed: bool = true

"""
Lägg till en rektangel till spelaren där meteorer och fiender 
inte kan spawna
"""

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

signal player_hit(type)
signal laser(type, pos, dir)
signal plasma_countdown(time)
signal speed_boost_countdown(time)


############### GENERAL FUNKTIONS ###############
func _movement(delta: float) -> void:
	"""
	Rörelse för spelaren
	direction = riktningsvector 
	"""
	var direction = Input.get_vector("left", "right", "up", "down")
	
	velocity.x = move_toward(velocity.x, speed * direction[0], ACC * delta)
	velocity.y = move_toward(velocity.y, speed * direction[1], ACC * delta)
	
	move_and_slide()
	#print(direction)
	
	#Slår på och stänger av raketens partiklar
	if direction[0] != 0 or direction[1] != 0:
		thrusters.emitting = true
	else:
		thrusters.emitting = false
	
	
 	#Horizontal och vertikal rotation
	if direction[1] == 1:
		self.rotation_degrees = 180
		
	elif direction[1] == -1:
		self.rotation_degrees = 0
		
	elif direction[0] == -1 or direction[0] == 1:
		self.rotation_degrees = 90*direction[0]

	
	#diagonal riktning
	elif direction[0] < 0 and direction[1] < 0 or direction[0] > 0 and direction[1] < 0:
		self.rotation_degrees = -45*direction[0]/direction[1]
		
	elif direction[0] < 0 and direction[1] > 0 or direction[0] > 0 and direction[1] > 0:
		self.rotation_degrees = 135*direction[0]/direction[1]


func _physics_process(delta: float) -> void:
	if not dead:
		if Input.is_action_just_pressed("Speed boost") and speed_boost_allowed:
			speed_boost_allowed = false
			_speed_boost()
			speed_boost_timer.start()
			
		else:
			_movement(delta)
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
	#Möjliga vinklar 0, 180, 90, -90, 45, -45, 135, -135
	var boost_factor = 2
	if self.global_rotation_degrees == 0:
		velocity.y = move_toward(velocity.y, -speed * boost_factor, ACC)
		
	elif self.global_rotation_degrees == -180:
		velocity.y = move_toward(velocity.y, speed * boost_factor, ACC)
		
	elif self.global_rotation_degrees == -90 or self.global_rotation_degrees == 90:
		velocity.x = move_toward(velocity.x, speed * self.global_rotation_degrees/90 * boost_factor, ACC)
		
	elif self.global_rotation_degrees == -45 or self.global_rotation_degrees == 45:
		var direction = sqrt(2)/2
		velocity.x = move_toward(velocity.x, speed * direction * self.global_rotation_degrees/45 * boost_factor, ACC)
		velocity.y = move_toward(velocity.y, speed * -direction * boost_factor, ACC)
		
	elif self.global_rotation_degrees == -135 or self.global_rotation_degrees == 135:
		var direction = sqrt(2)/2
		velocity.x = move_toward(velocity.x, speed * direction * self.global_rotation_degrees/135 * boost_factor, ACC)
		velocity.y = move_toward(velocity.y, speed * direction * boost_factor, ACC)
		
	move_and_slide()


################### DAMAGE FUNKTIONS ###################
func _shooting():
	if Input.is_action_just_pressed("shoot_laser"):
		laser.emit("laser", laser_source.global_position, self.rotation_degrees)
		
		gun_audio.play()
		flash_duration.start(0)
		gun_flash.emitting = true
	
	if Input.is_action_just_pressed("shoot_plasma") and can_shoot_plasma:
		laser.emit("plasma", laser_source.global_position, self.rotation_degrees)
		
		plasma_gun_audio.play()
		shoot_timer.start(0)
		can_shoot_plasma = false


func damage(type):
	player_hit.emit(type)


func destroyed():
	explosion_pic.show()
	player_sprite.hide()
	anim.play("exploding")
	await anim.animation_finished


###################### TIMERS ###################
func _on_shoot_timer_timeout() -> void:
	can_shoot_plasma = true


func _on_flash_duration_timeout() -> void:
	gun_flash.emitting = false


func _on_speed_boost_timeout() -> void:
	speed_boost_allowed = true
