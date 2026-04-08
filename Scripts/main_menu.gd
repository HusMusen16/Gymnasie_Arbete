extends Node2D


@onready var endless_button: TextureButton = $UI/Endless_button
@onready var highscore_label: Label = $UI/Endless_button/Highscore_label
@onready var gamemode_label:Label = $UI/Endless_button/gamemode

@onready var mothership_surge_button: TextureButton = $UI/Mothership_surge_button
@onready var gamemode2_label:Label = $UI/Mothership_surge_button/gamemode

@onready var spacestation_defence_button: TextureButton = $UI/Spacestation_defense_button
@onready var gamemode3_label: Label = $UI/Spacestation_defense_button/gamemode

@onready var tutorial_button: TextureButton = $UI/Tutorial_button
@onready var tutorial_label:Label = $UI/Tutorial_button/tutorial

@onready var lasers = $Lasers
@onready var plasmas = $Plasmas
@onready var endless_highscore_label: Label = $UI/Endless_button/Highscore_label


var plasma_scene: PackedScene = load("res://Scenes/plasma_blast.tscn")
var laser_scene: PackedScene = load("res://Scenes/laser.tscn")


################### GENERAL FUNCTIONS ###################
func _ready() -> void:
	endless_highscore_label.text = "Current Highscore: %s" %[str(LevelManager.endless_highscore)]


func _process(_delta: float) -> void:
	#Endless knappens zoom
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
		
	
	#Mothership surge knappens zoom
	if mothership_surge_button.is_hovered():
		mothership_surge_button.global_position = Vector2(850,830)
		mothership_surge_button.scale = Vector2(2,2)
		gamemode2_label.show()
	else:
		gamemode2_label.hide()
		mothership_surge_button.global_position = Vector2(895,881)
		mothership_surge_button.scale = Vector2(1,1)
		
	
	#Spacestation defence knappens zoom
	if spacestation_defence_button.is_hovered():
		spacestation_defence_button.global_position = Vector2(1728,346)
		spacestation_defence_button.scale = Vector2(2,2)
		gamemode3_label.show()
	else:
		gamemode3_label.hide()
		spacestation_defence_button.global_position = Vector2(1775,394)
		spacestation_defence_button.scale = Vector2(1,1)
		
	
	#Tutorial knappens beteende
	if tutorial_button.is_hovered():
		tutorial_button.global_position = Vector2(1540, 690)
		tutorial_button.scale = Vector2(1.5,1.5)
		tutorial_label.show()
	else:
		tutorial_label.hide()
		tutorial_button.global_position = Vector2(1633, 774)
		tutorial_button.scale = Vector2(1,1)


func _on_player_laser(type: Variant, pos: Variant, dir: Variant) -> void:
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
	LevelManager.initiate_mothership_surge_mode_selection_menu()


func _on_spacestation_defense_button_pressed() -> void:
	LevelManager.initiate_defend_spacestation_mode_selection_menu()


func _on_endless_button_pressed() -> void:
	LevelManager.start_endless_mode()


func _on_tutorial_button_pressed() -> void:
	LevelManager.start_tutorial_mode()
