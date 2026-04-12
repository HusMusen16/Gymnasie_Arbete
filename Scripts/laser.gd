extends Line2D
class_name LASER

"""
EXPLANATION OF THE UNIT

The standard laser of the federation of Earth. 
Each FC-43 valkyrie (the player ship) is able to shoot this 
laser at an unrestricted fire rate. 
Able to oneshot all enemies except motherships where the 
laser instead will ricochet.  
"""



############################## ON READY VARIABLE ###############################
@onready var dissipation_timer: Timer = $"Dissipation Timer"
@onready var ray_cast: RayCast2D = $RayCast2D



################################ VARIABLES #####################################
var has_ricochet = false
var allow_ricochet_rotation: bool = true



############################# CONSTANTS ########################################
const SPEED = 1500



################ GENERAL FUNKTIONS #################
func _physics_process(delta: float):
	"""
	makes sure the laser is constantly moving or ricocheting (moving
	in opposite direction) and if it is colliding.  
	"""
	if not has_ricochet:
		_laser_movement(delta)
	else:
		ricochet(delta)
		
	_laser_colliding()


func _on_dissipation_timer_timeout() -> void:
	"""
	Makes sure the laser despawns after a certain amount of time 
	to improve performance.
	"""
	queue_free()


func _laser_colliding():
	"""
	Checks if the laser is colliding and in that case what the collider
	is and damages it if it's a meteor or enemy_1 (ENEMY). Also makes 
	sure the laser ricochets of motherships.  
	"""
	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		if collider is METEOR:
			collider.explode()
		if collider is ENEMY or collider is ENEMY_CHASER:
			collider.explode()
			queue_free()
		if collider is MOTHERSHIP:
			has_ricochet = true



################ MOVEMENT FUNKTIONS ####################
func _laser_movement(delta: float):
	"""
	The basic movement of the laser. Checks its rotation and moves it
	in that direction. Rotation is inherited from the player.
	"""
	if rotation_degrees == 0:
		global_position[1] -= SPEED * delta
		
	elif rotation_degrees == 180 or rotation_degrees == -180:
		global_position[1] += SPEED * delta
		
	elif rotation_degrees == 45 or rotation_degrees == -45:
		global_position[0] += pow(pow((SPEED * delta), 2)/2,0.5) * rotation_degrees/45
		global_position[1] -= pow(pow((SPEED * delta), 2)/2,0.5)
		
	elif rotation_degrees == 90 or rotation_degrees == -90:
		global_position[0] += SPEED * delta * rotation_degrees/90
		
	elif rotation_degrees == 135 or rotation_degrees == -135:
		global_position[0] += pow(pow((SPEED * delta), 2)/2,0.5) * rotation_degrees/135
		global_position[1] += pow(pow((SPEED * delta), 2)/2,0.5)


func ricochet(delta):
	"""
	Identical to _laser_movement but the rotation is 
	reversed. A seperate function is necessary to make sure it 
	doesnt get trapped in a state of constant ricochets.
	"""
	if rotation_degrees == 0:
		global_position[1] -= SPEED * delta
		if allow_ricochet_rotation:
			allow_ricochet_rotation = false
			rotation_degrees = 180
		
	elif rotation_degrees == 180 or rotation_degrees == -180:
		global_position[1] += SPEED * delta
		if allow_ricochet_rotation:
			allow_ricochet_rotation = false
			rotation_degrees = 0
		
	elif rotation_degrees == 45 or rotation_degrees == -45:
		global_position[0] += pow(pow((SPEED * delta), 2)/2,0.5) * rotation_degrees/45
		global_position[1] -= pow(pow((SPEED * delta), 2)/2,0.5)
		if allow_ricochet_rotation:
			allow_ricochet_rotation = false
			rotation_degrees = 135 * rotation_degrees/-45
		
	elif rotation_degrees == 90 or rotation_degrees == -90:
		global_position[0] += SPEED * delta * rotation_degrees/90
		if allow_ricochet_rotation:
			allow_ricochet_rotation = false
			rotation_degrees = -rotation_degrees
		
	elif rotation_degrees == 135 or rotation_degrees == -135:
		global_position[0] += pow(pow((SPEED * delta), 2)/2,0.5) * rotation_degrees/135
		global_position[1] += pow(pow((SPEED * delta), 2)/2,0.5)
		if allow_ricochet_rotation:
			allow_ricochet_rotation = false
			rotation_degrees = 45 * rotation_degrees/-135
