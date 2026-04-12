extends Node2D

"""
The main menu of the game and where almost everything is selected.
"""



############################ PACKED SCENES #####################################
var plasma_scene: PackedScene = load("res://Scenes/plasma_blast.tscn")
var laser_scene: PackedScene = load("res://Scenes/laser.tscn")



########################### ON READY VARIABLES #################################
@onready var endless_button: TextureButton = $UI/Endless_button
@onready var highscore_label: Label = $UI/Endless_button/Highscore_label
@onready var gamemode_label:Label = $UI/Endless_button/gamemode

@onready var mothership_surge_button: TextureButton = $UI/Mothership_surge_button
@onready var gamemode2_label:Label = $UI/Mothership_surge_button/gamemode

@onready var spacestation_defense_button: TextureButton = $UI/Spacestation_defense_button
@onready var gamemode3_label: Label = $UI/Spacestation_defense_button/gamemode

@onready var tutorial_button: TextureButton = $UI/Tutorial_button
@onready var tutorial_label:Label = $UI/Tutorial_button/tutorial

@onready var lasers = $Lasers
@onready var plasmas = $Plasmas
@onready var endless_highscore_label: Label = $UI/Endless_button/Highscore_label

@onready var quit_button: TextureButton = $UI/VBoxContainer/Quit_button
@onready var reset_highscore_button: TextureButton = $UI/VBoxContainer/Reset_Highscore_button



################### GENERAL FUNCTIONS ###################
func _ready() -> void:
	"""
	Makes sure that the cursor is visible and that shown highscore is 
	updated.
	"""
	endless_highscore_label.text = "Current Highscore: %s" %[str(LevelManager.endless_highscore)]
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _process(_delta: float) -> void:
	"""
	Makes sure to check if every button is hovered upon.
	If it is it will increase its scale to make it pop up. Because
	it moves, its coordinates is also changed. It will also show
	a label showing what gamemode the button is for.
	If it is not hovered upon it will make sure its scale and 
	position is reverted. It will also hide labels again.
	"""
	
	#The endless buttons behavior
	if endless_button.is_hovered():
		endless_button.global_position = Vector2(468,240)
		endless_button.scale = Vector2(2,2)
		highscore_label.show()
		gamemode_label.show()
	else:
		highscore_label.hide()
		gamemode_label.hide()
		endless_button.global_position = Vector2(504,276)
		endless_button.scale = Vector2(1,1)
		
	
	#The mothership surge buttons behavior
	if mothership_surge_button.is_hovered():
		mothership_surge_button.global_position = Vector2(850,830)
		mothership_surge_button.scale = Vector2(2,2)
		gamemode2_label.show()
	else:
		gamemode2_label.hide()
		mothership_surge_button.global_position = Vector2(895,881)
		mothership_surge_button.scale = Vector2(1,1)
		
	
	#The space station defense buttons behavior
	if spacestation_defense_button.is_hovered():
		spacestation_defense_button.global_position = Vector2(1728,346)
		spacestation_defense_button.scale = Vector2(2,2)
		gamemode3_label.show()
	else:
		gamemode3_label.hide()
		spacestation_defense_button.global_position = Vector2(1775,394)
		spacestation_defense_button.scale = Vector2(1,1)
		
	
	#The Tutorial buttons behavior
	if tutorial_button.is_hovered():
		tutorial_button.global_position = Vector2(1540, 690)
		tutorial_button.scale = Vector2(1.5,1.5)
		tutorial_label.show()
	else:
		tutorial_label.hide()
		tutorial_button.global_position = Vector2(1633, 774)
		tutorial_button.scale = Vector2(1,1)
	
	"""
	These buttons behave different to the others in the sense that 
	they will get darker if hovered upon and reverted if not.
	"""
	#The quit buttons behavior
	if quit_button.is_hovered():
		quit_button.modulate = Color(0.8,0.8,0.8,1)
	else:
		quit_button.modulate = Color(1,1,1,1)
	
	
	#The reset highscore buttons behavior
	if reset_highscore_button.is_hovered():
		reset_highscore_button.modulate = Color(0.8,0.8,0.8,1)
	else:
		reset_highscore_button.modulate = Color(1,1,1,1)


func _on_player_laser(type: Variant, pos: Variant, dir: Variant) -> void:
	"""
	spawns a laser or plasma blast from the player if you shoot. 
	The fully functional player ship is implemented in the name of 
	the game as a kind of "easter egg". 
	This is a signal from the player.
	"""
	if type == "laser":
		var laser = laser_scene.instantiate()
		lasers.add_child(laser)
		laser.position = pos
		laser.rotation_degrees = dir
	elif type == "plasma":
		var plasma = plasma_scene.instantiate()
		plasmas.add_child(plasma)
		plasma.position = pos
		plasma.rotation_degrees = dir



################### BUTTONS PRESSED ######################
func _on_mothership_surge_button_pressed() -> void:
	"""
	Sends you to the middle_screen_mothership scene via the Level Manager.
	From that the level_2 (mothership surge mode) scene is started.
	"""
	LevelManager.initiate_mothership_surge_mode_selection_menu()


func _on_spacestation_defense_button_pressed() -> void:
	"""
	Sends you to the middle_screen_space_station scene via the Level Manager.
	From that the level_3 (defend space station mode) scene is started.
	"""
	LevelManager.initiate_defend_spacestation_mode_selection_menu()


func _on_endless_button_pressed() -> void:
	"""
	Sends you to the level_1 (endless mode) scene via the Level Manager.
	"""
	LevelManager.start_endless_mode()


func _on_tutorial_button_pressed() -> void:
	"""
	Sends you to the level_4 (the tutorial) scene via the Level Manager.
	"""
	LevelManager.start_tutorial_mode()


func _on_quit_button_pressed() -> void:
	"""
	Quits the game via the Level Manager.
	"""
	LevelManager.quit_game()


func _on_reset_highscore_button_pressed() -> void:
	"""
	Resets the current highscore via the Level Manager and updates the
	shown highscore.
	"""
	LevelManager.reset_highscore()
	endless_highscore_label.text = "Current Highscore: %s" %[str(LevelManager.endless_highscore)]
