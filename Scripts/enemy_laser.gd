extends Line2D
class_name ENEMY_LASER

const SPEED = 1500

var dir = Vector2(0, 0)

func _movement(dir,delta):
	global_position.x += dir.x * SPEED * delta
	global_position.y += dir.y * SPEED * delta
	rotation = dir.angle() + PI/2

func _physics_process(delta: float) -> void:
	_movement(dir,delta)
	
