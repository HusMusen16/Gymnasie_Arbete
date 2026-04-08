extends Node2D

@onready var input_text: LineEdit = $Control/VBoxContainer/LineEdit
@onready var funny_anim:AnimationPlayer = $Funny_anim
@onready var why_label: Label = $"Control/Why?"



func _on_button_pressed() -> void:
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
			survival_time = 3
	
	if survival_time >= 60 * 60 * 24 * 364 * 51:
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
