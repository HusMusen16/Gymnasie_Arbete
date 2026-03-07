extends Line2D
class_name LASER

const SPEED = 1500

@onready var dissipation_timer: Timer = $"Dissipation Timer"
@onready var ray_cast: RayCast2D = $RayCast2D

var has_ricochet = false



################ GENERAL FUNKTIONS #################
func _physics_process(delta: float):
	if not has_ricochet:
		_laser_movement(delta)
	else:
		ricochet(delta)
		
	_laser_colliding()


func _on_dissipation_timer_timeout() -> void:
	queue_free()


func _laser_colliding():
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
	#Identical to _laser_movement but the + and - are reversed
	if rotation_degrees == 0:
		global_position[1] += SPEED * delta
		
	elif rotation_degrees == 180 or rotation_degrees == -180:
		global_position[1] -= SPEED * delta
		
	elif rotation_degrees == 45 or rotation_degrees == -45:
		global_position[0] -= pow(pow((SPEED * delta), 2)/2,0.5) * rotation_degrees/45
		global_position[1] += pow(pow((SPEED * delta), 2)/2,0.5)
		
	elif rotation_degrees == 90 or rotation_degrees == -90:
		global_position[0] -= SPEED * delta * rotation_degrees/90
		
	elif rotation_degrees == 135 or rotation_degrees == -135:
		global_position[0] -= pow(pow((SPEED * delta), 2)/2,0.5) * rotation_degrees/135
		global_position[1] -= pow(pow((SPEED * delta), 2)/2,0.5)
