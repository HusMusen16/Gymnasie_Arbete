extends Node2D
"""
This is a scene that pops up in between the transistion from main menu to 
the mothership surge mode (level_2) that lets you select the amount of 
killed motherships necessary to win with a standard of 3.
"""



######################## ON READY VARIABLES ####################################
@onready var input_text: LineEdit = $Control/VBoxContainer/LineEdit
@onready var funny_anim:AnimationPlayer = $Funny_anim
@onready var why_label: Label = $"Control/Why?"



########################## BUTTONS PRESSED FUNCTIONS ###########################
func _on_button_pressed() -> void:
	"""
	The button that starts the mothership surge mode (level_2) via the 
	Level Manager when pressed.
	
	kill_goal = the amount of motherships you need to destroy to win. Is
				inputed via the LineEdit called input_text
	valid_number = a boolean variable that is used to communicate if the
				   inputed value is valid or not.
	"""
	var kill_goal = input_text.text
	var valid_number:bool = true
	
	"""
	Checks if the value contains a letter or a "," or ".".
	If it does it is set as not valid.
	If the value is not valid a standard value of 3 will be selected, the
	same will happen if the value is set to 0.
	"""
	for letter in kill_goal:
		if letter.is_valid_ascii_identifier() or letter == "," or letter  == ".":
			valid_number = false
			
	if not valid_number:
		kill_goal = 3
	else:
		kill_goal = int(kill_goal)
		if kill_goal == 0:
			kill_goal = 3
	
	"""
	"Easter egg" texts that pops up if you set a completly unrealistic goal.
	"""
	if kill_goal >= 1_000_000:
		why_label.text = "This little 
		maneuver is 
		gonna cost us 
		51 years"
		funny_anim.play("why?")
		await funny_anim.animation_finished
	
	elif kill_goal >= 10_000:
		why_label.text = "Are you okay?"
		funny_anim.play("why?")
		await funny_anim.animation_finished
		
	elif kill_goal >= 100:
		funny_anim.play("why?")
		await funny_anim.animation_finished
	
	#Level Manager handles the communication of the goal between scenes.
	LevelManager.mothership_kill_goal = kill_goal
	LevelManager.start_mothership_surge_mode()
