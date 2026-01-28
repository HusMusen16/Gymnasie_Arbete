extends Line2D
class_name ENEMY_LASER

var SPEED = 1500

var dir = Vector2(0, 0)
var type = ENEMY

@onready var ray_cast: RayCast2D = $RayCast2D


func _movement(delta):
	global_position.x += dir[0] * SPEED * delta
	global_position.y += dir[1] * SPEED * delta
	rotation = dir.angle() + PI/2


func _laser_colliding():
	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		if collider is METEOR:
			collider.damage()
			queue_free()
		if collider is PLAYER:
			collider.damage(type)
			queue_free()


func _physics_process(delta: float) -> void:
	_movement(delta)
	_laser_colliding()
	
