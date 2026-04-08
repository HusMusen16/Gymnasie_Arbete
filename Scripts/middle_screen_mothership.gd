extends Node2D

@onready var input_text: LineEdit = $Control/VBoxContainer/LineEdit
@onready var funny_anim:AnimationPlayer = $Funny_anim
@onready var why_label: Label = $"Control/Why?"


func _on_button_pressed() -> void:
	var kill_goal = input_text.text
	var valid_number:bool = true
	
	for letter in kill_goal:
		if letter.is_valid_ascii_identifier():
			valid_number = false
			
	if not valid_number:
		kill_goal = 3
	else:
		kill_goal = int(kill_goal)
		if kill_goal == 0:
			kill_goal = 3
	
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
	
	
	LevelManager.mothership_kill_goal = kill_goal
	LevelManager.start_mothership_surge_mode()
	
