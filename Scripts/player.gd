extends CharacterBody2D

@export var speed = 500

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



func _process(delta: float) -> void:
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed
	move_and_slide()
	
	var vector_x = Input.get_axis("left", "right")
	var vector_y = Input.get_axis("up", "down")
	if vector_x == 0 or vector_y == 0:
		rotation_degrees = 0
	if vector_x > 0:
		rotation_degrees = -90
	if vector_x < 0:
		rotation_degrees = 90
	if vector_y < 0:
		rotation_degrees = 180
	
		
		
