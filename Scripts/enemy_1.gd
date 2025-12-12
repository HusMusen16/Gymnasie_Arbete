extends CharacterBody2D

var player = null

@onready var x_timer: Timer = $X_timer
@onready var y_timer: Timer = $Y_timer

var choice = [0,1,2,3,4,5]

const SPEED = 500


func _movement(dir, distance):
	"
	var random_speed_x = RandomNumberGenerator.new().randf_range(0,150)
	var random_speed_y = RandomNumberGenerator.new().randf_range(0,150)
	var dir_x = [1,-1].pick_random()
	var dir_y = [1,-1].pick_random()"
	#Eventuellt fixa en timer som avaktiverar deras rörelse en slumpvis tid om ett specifikt värde från en lista slumpas fram
	#Implementera ovantstående
	
	"
	velocity.x = dir[0] * SPEED + random_speed_x * dir_x
	velocity.y = dir[1] * SPEED + random_speed_y * dir_y"
	
	var choice_x = choice.pick_random()
	var choice_y = choice.pick_random()
	
	if choice_x == 0:
		velocity.x = dir[0] * SPEED
	else:
		velocity.x = 0
		
	if choice_y == 0:
		velocity.y = dir[1] * SPEED
	else:
		velocity.y = 0
	move_and_slide()




#################### STATE MACHINE #########################
func _physics_process(delta: float) -> void:
	if player:
		var dir = global_position.direction_to(player.global_position)
		var distance = global_position.distance_to(player.global_position)
		if distance > 500:
			_CHASING(dir, distance)
		else:
			_ATTACKING(dir, distance)
			




####################### STATES ###############################
func _CHASING(dir, distance):
	_movement(dir, distance)

func _ATTACKING(dir, distance):
	velocity = dir * SPEED * 0.1
	move_and_slide()
	print("attacking", distance)
