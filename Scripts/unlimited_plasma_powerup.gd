extends Node2D

"""
EXPLANATION OF THE UNIT

A blue box that randomly spawn in endless- or defend space
station mode. It removes the cooldown for the players
plasma blast for certain amout of time.
"""




############################### FUNCTIONS ######################################
func _on_area_2d_body_entered(body: Node2D) -> void:
	"""
	if a body enters the area and the body is the player,
	a function will be called in the player script and this 
	scene will be removed from the scene tree.
	"""
	if body is PLAYER:
		body.unlimited_plasma_blast()
		queue_free()
