extends CharacterBody2D
class_name PLAYER

var ACC = 1000
var speed = 700
var can_shoot: bool = true

@onready var thrusters: GPUParticles2D = $Rocket
@onready var gun_flash:GPUParticles2D = $GunFlash
@onready var laser_source: Marker2D = $LaserSource
@onready var shoot_timer: Timer = $ShootTimer
@onready var flash_duration: Timer = $FlashDuration


signal laser(pos, dir)


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
	
	
 	#Horizontal och vertikal
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


func _shooting(delta:float) -> void:
	if Input.is_action_just_pressed("shoot") and can_shoot:
		laser.emit(laser_source.global_position, self.rotation_degrees)
		
		shoot_timer.start(0)
		can_shoot = false
		
		flash_duration.start(0)
		gun_flash.emitting = true

func _process(delta: float) -> void:
	_movement(delta)
	_shooting(delta)
	

func _on_shoot_timer_timeout() -> void:
	can_shoot = true

func _on_flash_duration_timeout() -> void:
	gun_flash.emitting = false
