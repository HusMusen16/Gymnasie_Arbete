extends CharacterBody2D
class_name SPACESTATION

"""
EXPLANATION OF THE UNIT

These naval space stations are the standard of the Federation
of Earth. It is equipped with 4 very capable main cannons
capable of defending its parameters from entire enemy fleets
without assistance. It also has advanced armour able to 
deflect even the strongest of projectiles. Because of this,
they are incredibly advanced and therefore things can 
easily go wrong with them leaving them defenseless. If this
happens it is of highest importance that they are 
protected until they are back online again.
"""



############################### ON READY VARIABLES #############################
@onready var explosion_sprites: Node2D = $Sub_explosion_sprites
@onready var explosion_anim:AnimationPlayer = $ExplosionAnim
@onready var explosion_sprite: Sprite2D = $Explosion_sprite



################################### VARIABLES ##################################
var health = 100



################################## FUNCTIONS ###################################
func explode():
	"""
	The function handling the animation for the space stations 
	explosion. Is called when level_3 is lost (when health reaches
	0).
	"""
	for sprite in explosion_sprites.get_children():
		sprite.show()
		sprite.play()
		await sprite.animation_finished
		sprite.hide()
	explosion_sprite.show()
	explosion_anim.play("explosion")
	await explosion_anim.animation_finished
	explosion_anim.play("fade out")
