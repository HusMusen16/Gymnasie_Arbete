extends CharacterBody2D
class_name ENEMY_CHASER


@onready var anim: AnimationPlayer = $ExplosionAnimation
@onready var explosion_picture: Sprite2D = $Explosion_Picture
@onready var main_sprite: Sprite2D = $Main_Sprite
@onready var debris: Node2D = $Debris_sprites
@onready var ship_collision: CollisionShape2D = $CollisionShape2D
@onready var explosion_radius: Area2D = $ExplosionRadius

var dead:bool = false
var target = null

const SPEED = 200


################# GENERAL FUNKTIONS ##############
func explode():
	if not dead:
		dead = true
		explosion_radius.monitoring = true
		LevelManager.kills += 1
		ship_collision.set_deferred("disabled", true)
		main_sprite.hide()
		debris.show()
		explosion_picture.show()
		anim.play("Exploding")
		await anim.animation_finished
		explosion_radius.monitoring = false
		var tween = create_tween()
		tween.tween_property(debris, "modulate:a", 0, 1)
		await tween.finished
		queue_free()


func _physics_process(_delta: float) -> void:
	if target and not dead:
		var dir = global_position.direction_to(target.global_position)
		_movement(dir)


################## MOVEMENT FUNKTIONS #####################
func _movement(dir):
	velocity.x = dir[0] * SPEED
	velocity.y = dir[1] * SPEED
	move_and_slide()


################## DETONATION FUNKTIONS #################
func _on_detonation_sensor_body_entered(body: Node2D) -> void:
	if body is PLAYER or body is SPACESTATION:
		explode()


func _on_explosion_radius_body_entered(body: Node2D) -> void:
	if body is PLAYER:
		body.damage(ENEMY_CHASER)
		print("player")
	elif body is SPACESTATION:
		body.health -= 5
		print("spacestation")
	elif body is METEOR:
		body.explode()
		print("Meteor")
	elif body is ENEMY:
		body.explode()
		print("enemy")
