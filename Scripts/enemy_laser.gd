extends Line2D
class_name ENEMY_LASER

"""
EXPLANATION OF THE UNIT

The standard laser of the enemy
Is used by their standard unit (enemy_1) and motherships.
"""
############################ ON READY VARIABLES ################################
@onready var ray_cast: RayCast2D = $RayCast2D



################################ VARIABLES #####################################
var SPEED = 1500
var dir = Vector2(0, 0)
var type = ENEMY



################################ FUNCTIONS #####################################
func _physics_process(delta: float) -> void:
	"""
	makes sure the laser is constantly checking for collision
	and moving
	"""
	_movement(delta)
	_laser_colliding()


func _movement(delta):
	"""
	Moves the laser in the direction of the player and makes
	sure its rotation is correct.
	dir = direction to the player
	delta = makes sure the movement is not affected by
	the frame rate
	"""
	global_position.x += dir[0] * SPEED * delta
	global_position.y += dir[1] * SPEED * delta
	rotation = dir.angle() + PI/2


func _laser_colliding():
	"""
	checks if the raycast of the laser is colliding.
	If it is colliding it checks if the collider is either
	a meteor or player and in that case damages them and then
	removes itself.
	"""
	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		if collider is METEOR:
			collider.damage()
			queue_free()
		if collider is PLAYER:
			collider.damage(type)
			queue_free()


func _on_dissipation_timer_timeout() -> void:
	"""
	Makes sure the laser despawns after a certain amount
	of time to reduce the amount of entities active at a 
	time, thus helping with performance.
	"""
	queue_free()
