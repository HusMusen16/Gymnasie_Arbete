extends Line2D
class_name PLASMA

const SPEED = 1500

@onready var explosion_timer: Timer = $explosion_timer
@onready var ray_cast: RayCast2D = $RayCast2D
@onready var explosion_picture: Sprite2D = $Explosion_picture
@onready var anim: AnimationPlayer = $ExplosionAnimation
@onready var explosion_area: Area2D = $ExplosionArea

var moving: bool = true

func _plasma_colliding():
	pass


func _plasma_movement(delta: float):
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
	if moving:
		_plasma_movement(delta)
	if ray_cast.is_colliding():
		explosion_timer.stop()
		explosion_timer.timeout.emit()
		



func _on_explosion_timer_timeout() -> void:
	moving = false
	explosion_area.monitoring = true
	self.self_modulate = Color(0,0,0,0)
	explosion_picture.show()
	anim.play("plasma_explosion")
	await  anim.animation_finished
	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is ENEMY:
		body.explode()
	if body is METEOR:
		body.explode()
