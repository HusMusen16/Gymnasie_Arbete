extends Line2D
class_name LASER

const SPEED = 1500

@onready var dissipation_timer: Timer = $"Dissipation Timer"
@onready var ray_cast: RayCast2D = $RayCast2D



func _laser_colliding():
	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		if collider is METEOR:
			collider.explode()


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


func _physics_process(delta: float):
	_laser_movement(delta)
	_laser_colliding()


func _on_dissipation_timer_timeout() -> void:
	queue_free()
	
