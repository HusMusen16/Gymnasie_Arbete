extends CharacterBody2D
class_name SPACESTATION

@onready var explosion_sprites: Node2D = $Sub_explosion_sprites
@onready var explosion_anim:AnimationPlayer = $ExplosionAnim
@onready var explosion_sprite: Sprite2D = $Explosion_sprite

var health = 100


func explode():
	for sprite in explosion_sprites.get_children():
		sprite.show()
		sprite.play()
		await sprite.animation_finished
		sprite.hide()
	explosion_sprite.show()
	explosion_anim.play("explosion")
	await explosion_anim.animation_finished
	explosion_anim.play("fade out")
