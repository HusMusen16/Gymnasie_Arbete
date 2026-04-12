extends Node2D

"""
This is a scene that pops up in between the transistion from main menu to 
the defend space station mode (level_3) that lets you select the amount of 
time you need to defend the space station to win with a standard of 180.
"""



############################ ON READY VARIABLES ################################
@onready var input_text: LineEdit = $Control/VBoxContainer/LineEdit
@onready var funny_anim:AnimationPlayer = $Funny_anim
@onready var why_label: Label = $"Control/Why?"


########################### BTTTON PRESSED FUNCTIONS ###########################
func _on_button_pressed() -> void:
	"""
	Almost identical to middle_screen_mothership except the variable names
	and values are changed to reflect seconds instead of the number of 
	motherships.
	
	survival_time = the amount of time needed to protect the space station.
					Inputed via the LineEdit called input_text.
	valid_number = a boolean variable that is used to communicate if the
				   inputed value is valid or not.
	"""
	var survival_time = input_text.text
	var valid_number:bool = true
	
	for letter in survival_time:
		if letter.is_valid_ascii_identifier() or letter == "," or letter  == ".":
			valid_number = false
			
	if not valid_number:
		survival_time = 180
	else:
		survival_time = int(survival_time)
		if survival_time == 0:
			survival_time = 180
	
	if survival_time >= 60 * 60 * 24 * 364 * 51:
		#The number above is precisly 51 years
		why_label.text = "This little 
		maneuver is 
		gonna cost us 
		51 years"
		funny_anim.play("why??")
		await funny_anim.animation_finished
	
	elif survival_time >= 60 * 60 * 4:
		why_label.text = "You need 
		to touch grass"
		funny_anim.play("why??")
		await funny_anim.animation_finished
		
	elif survival_time >= 60*60:
		funny_anim.play("why??")
		await funny_anim.animation_finished
	
	
	LevelManager.spacestation_survival_time = survival_time
	LevelManager.start_defend_spacestation_mode()
