extends Node2D

var laser_scene: PackedScene = load("res://Scenes/laser.tscn")
var meteor_scene: PackedScene = load("res://Scenes/meteor.tscn")
var enemy_scene: PackedScene = load("res://Scenes/enemy_1.tscn")
var plasma_scene: PackedScene = load("res://Scenes/plasma_blast.tscn")
var mother_ship_scene: PackedScene = load("res://Scenes/mother_ship.tscn")
var enemy_chaser_scene: PackedScene = load("res://Scenes/enemy_chaser.tscn")

enum {INTRO, MOVEMENT, TARGETING, ENEMIES, ENDING}
var state = INTRO

var level_number = 4
var paused = false
var player_paused = false
var player_input = []
var lasers_shot = 0

var moment = 1
#var times_paused = 0
var input_allowed: bool = false
var enemy_spawned: bool = false
var enemy = null
var timer_in_progress: bool = false

#Player nodes
@onready var player: PLAYER = $Player
@onready var lasers: Node = $Lasers
@onready var health_bar: ProgressBar = $HUD/PlayerHealth/HealthBar
@onready var damage_audio: AudioStreamPlayer = $DamageSound
@onready var speed_boost_countdown_bar: ProgressBar = $HUD/SpeedBoostCooldown/SpeedBoost_countdown
@onready var speed_boost_label: Label = $HUD/SpeedBoostCooldown/Label
@onready var speedboostcooldown: ColorRect = $HUD/SpeedBoostCooldown
@onready var playerhealth:ColorRect = $HUD/PlayerHealth

#Plasma Nodes
@onready var plasmas: Node = $Plasmas
@onready var plasma_countdown_bar: ProgressBar = $HUD/PlasmaBlastCooldown/plasma_countdown
@onready var plasma_label: Label = $HUD/PlasmaBlastCooldown/Label
@onready var plasmablastcooldown: ColorRect = $HUD/PlasmaBlastCooldown

@onready var pause_scene = $"Pause menu"
@onready var explanation_label: Label = $HUD/Explanation_Text
@onready var input_cooldown: Timer = $Input_cooldown
@onready var spawnpoint: Marker2D = $Spawnpoint

func _ready() -> void:
	LevelManager.current_gamemode = level_number


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		_pause_game()
	
	match state:
		INTRO:
			_intro()
		MOVEMENT:
			_movement()
		TARGETING:
			_targeting()
		ENEMIES:
			_enemies()
		ENDING:
			_ending()


################## STATE FUNKTIONS ################
func _intro():
	if not player_paused:
		_pause_player()
	if moment == 1 and not timer_in_progress:
		timer_in_progress = true
		explanation_label.text = "\nHello cadet, welcome to the 16th naval regiments fighter training.\n I am Instructor Johnson and will be guiding you today."
		input_cooldown.start(8)
		await input_cooldown.timeout
		moment = 2
	
	elif moment == 2 and not timer_in_progress:
		timer_in_progress = true
		explanation_label.text = "At the moment you are piloting the fighter-class FC-43 valkyrie. 
		Make sure to get used to the controlls under the training,\nEarth depends on it."
		input_cooldown.start(10)
		await input_cooldown.timeout
		moment = 3
	
	elif moment == 3 and not timer_in_progress:
		timer_in_progress = true
		explanation_label.text = "\nFor controlling the ship, use the controll board in front of you. 
		It is made similar to a keyboard for ease of use."
		input_cooldown.start(12)
		await input_cooldown.timeout
		moment = 4
		
	elif moment == 4 and not timer_in_progress:
		timer_in_progress = true
		playerhealth.show()
		explanation_label.text = "The ship is also equipped with a HUD system, short for heads up display. 
		It will show you vital information about your ship 
		such as its structural integrity in the top right corner"
		input_cooldown.start(9)
		await input_cooldown.timeout
		
		input_allowed = false
		moment = 1
		state = MOVEMENT


func _movement():
	if moment == 1:
		if player_paused:
			_pause_player()
		explanation_label.text = "\nTry to controll your ship using WASD"
		if Input.is_action_just_pressed("down") and "down" not in player_input:
			player_input.append("down")
		if Input.is_action_just_pressed("up") and "up" not in player_input:
			player_input.append("up")
		if Input.is_action_just_pressed("right") and "right" not in player_input:
			player_input.append("right")
		if Input.is_action_just_pressed("left") and "left" not in player_input:
			player_input.append("left")
		
		if len(player_input) >= 4:
			moment = 2
			
			
	elif moment == 2:
		explanation_label.text = "Your engine is also capable of producing a short boost in your current direction. 
		It also produces a temporary shield that makes you invincible and capable of ramming most of your enemies. 
		You can see its cooldown in your bottom left corner.
		Press ENTER to use it"
		speedboostcooldown.show()
		if Input.is_action_just_pressed("Speed boost"):
			input_allowed = false
			state = TARGETING
			moment = 1
			print("moment_changed")


func _targeting():
	if moment == 1:
		explanation_label.text = "\nExcellent flying! Now try firing your state of the art 
		laser canon using SPACEBAR"
		explanation_label.show()
		if Input.is_action_just_pressed("shoot_laser"):
			lasers_shot += 1
		if lasers_shot >= 10:
			lasers_shot = 0
			moment = 2
	elif moment == 2:
		explanation_label.text = "Your ship is also equipped with the experimental plasma blast cannon.
		You can fire it by pressing either RIGHT or LEFT SHIFT. 
		Note that due to its experimental status it has a cooldown which
		you can see in your bottom right"
		plasmablastcooldown.show()
		if Input.is_action_just_pressed("shoot_plasma"):
			state = ENEMIES
			
			moment = 1
			input_allowed = false


func _enemies():
	if moment == 1:
		if not player_paused:
			explanation_label.text = "\nExcellent shooting! Now it is time for you to get to know the enemies of our federation."
			_pause_player()
			input_cooldown.start(3)
		
		if input_allowed:
			explanation_label.text = "\nExcellent shooting! Now it is time for you to get to know the enemies of our federation.
			press W to continue"
		
			if Input.is_action_just_pressed("up") and player_paused:
				moment = 2
				_pause_player()
				input_allowed = false
			
	elif moment == 2:
		if not enemy_spawned:
			explanation_label.text = "\nFirst off is their standard unit, destroy it with your weapon of choice."
			enemy_spawned = true
			enemy = enemy_scene.instantiate()
			self.add_child(enemy)
			enemy.global_position = spawnpoint.global_position 
			
		elif not enemy and not timer_in_progress:
			timer_in_progress = true
			explanation_label.text = "\nWell done, that will show them."
			input_cooldown.start(5)
			await input_cooldown.timeout
			moment = 3
			enemy_spawned = false
			
	elif moment == 3:
		if not enemy_spawned:
			explanation_label.text = "\nNext up, their suicide bombers, make sure to keep your distance 
			as they will not hesitate to blow themselves up to get you."
			enemy_spawned = true
			enemy = enemy_chaser_scene.instantiate()
			self.add_child(enemy)
			enemy.global_position = spawnpoint.global_position 
			
		elif not enemy and not timer_in_progress:
			timer_in_progress = true
			explanation_label.text = "\nJust helps to show how inhumane they are, sacrificing their own."
			input_cooldown.start(5)
			await input_cooldown.timeout
			moment = 4
			enemy_spawned = false
	
	elif moment == 4 and input_allowed:
		if not enemy_spawned:
			explanation_label.text = "\nFor the grand finale, their Mothership, 
			these abominations will require 5 plasma blasts to bring down."
			enemy_spawned = true
			enemy = mother_ship_scene.instantiate()
			self.add_child(enemy)
			enemy.tutorial = true
			enemy.global_position = spawnpoint.global_position 
			enemy.modulate = Color(1,1,1,1)
		elif not enemy and not timer_in_progress:
			timer_in_progress = true
			explanation_label.text = "Excellent marksmanship. 
			Make sure to exterminate motherships quickly.
			Otherwise they might flee out of terror when they are critically damaged"
			input_cooldown.start(8)
			await input_cooldown.timeout
			
			input_allowed = false
			moment = 1
			enemy_spawned = false
			state = ENDING


func _ending():
	explanation_label.text = "\nYou have proven yourself worthy of the title of Valkyrie of the Skies.\n You can exit the training by pressing ESCAPE and RETURN TO THE MAIN MENU"


################# PAUSE FUNKTIONS ###############
func _pause_game():
	if not paused:
			for child in self.get_children():
				child.process_mode = Node.PROCESS_MODE_DISABLED
			pause_scene.process_mode = Node.PROCESS_MODE_INHERIT
			paused = true
			pause_scene.show()
			
	elif paused:
		for child in self.get_children():
			child.process_mode = Node.PROCESS_MODE_INHERIT
		if player_paused:
			_pause_player()
		paused = false
		pause_scene.hide()


func _pause_player():
	if not player_paused:
		player_paused = true
		player.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		player.process_mode = Node.PROCESS_MODE_INHERIT
		player_paused = false


####################### SIGNALS ##################
func _on_pause_menu_unpause_game() -> void:
	_pause_game()


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


func _on_player_plasma_countdown(time: Variant) -> void:
	plasma_countdown_bar.value = time * 25
	if plasma_countdown_bar.value <= 0:
		plasma_label.show()
	else:
		plasma_label.hide()


func _on_player_speed_boost_countdown(time: Variant) -> void:
	speed_boost_countdown_bar.value = time * 25
	if speed_boost_countdown_bar.value <= 0:
		speed_boost_label.show()
	else:
		speed_boost_label.hide()


#################### TIMERS ####################
func _on_input_cooldown_timeout() -> void:
	timer_in_progress = false
	input_allowed = true
