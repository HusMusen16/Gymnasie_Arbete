extends Node2D

"""
EXPLANATION OF THE UNIT

A green box that randomly spawns on endless- and mothership 
surge mode that gives the player back health when 
collided with.
"""


################################# FUNCTIONS ####################################
func _on_area_2d_body_entered(body: Node2D) -> void:
	"""
	if a body enters the area and the body is the player,
	a signal will be emited from the player and this 
	scene will be removed from the scene tree.
	"""
	if body is PLAYER:
		body.picked_up_item.emit("health")
		queue_free()
