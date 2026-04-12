extends Node2D


"""
The tutorial level is where every new recruit learns how to master
their ship. Consists of multiple stages starting with an introduction
followed by movement, targeting, an introduction the the enemies and
lastly the ending.
"""



############################# PACKED SCENES ####################################
var laser_scene: PackedScene = load("res://Scenes/laser.tscn")
var meteor_scene: PackedScene = load("res://Scenes/meteor.tscn")
var enemy_scene: PackedScene = load("res://Scenes/enemy_1.tscn")
var plasma_scene: PackedScene = load("res://Scenes/plasma_blast.tscn")
var mother_ship_scene: PackedScene = load("res://Scenes/mother_ship.tscn")
var enemy_chaser_scene: PackedScene = load("res://Scenes/enemy_chaser.tscn")



############################ ON READY VARIABLES ################################
#Player nodes
@onready var player: PLAYER = $Player
@onready var lasers: Node = $Lasers
@onready var plasmas: Node = $Plasmas

#HUD
@onready var health_bar: ProgressBar = $HUD/PlayerHealth/HealthBar
@onready var speed_boost_countdown_bar: ProgressBar = $HUD/SpeedBoostCooldown/SpeedBoost_countdown
@onready var speed_boost_label: Label = $HUD/SpeedBoostCooldown/Label
@onready var speedboostcooldown: ColorRect = $HUD/SpeedBoostCooldown
@onready var playerhealth:ColorRect = $HUD/PlayerHealth
@onready var playerbonushealth: ColorRect = $HUD/PlayerBonusHealth
@onready var plasma_countdown_bar: ProgressBar = $HUD/PlasmaBlastCooldown/plasma_countdown
@onready var plasma_label: Label = $HUD/PlasmaBlastCooldown/Label
@onready var plasmablastcooldown: ColorRect = $HUD/PlasmaBlastCooldown
@onready var explanation_label: Label = $HUD/Explanation_Text

#SFX
@onready var damage_audio: AudioStreamPlayer = $DamageSound

#General
@onready var pause_scene = $"Pause menu"
@onready var input_cooldown: Timer = $Input_cooldown
@onready var spawnpoint: Marker2D = $Spawnpoint



############################# STATE VARIABLES + ################################
#The stages every new recruit goes through
enum {INTRO, MOVEMENT, TARGETING, ENEMIES, ENDING}
var state = INTRO



################################ VARIABLES #####################################
var level_number = 4
var paused = false
var player_paused = false
var player_input = []
var lasers_shot = 0

##The variable that allowes stages inside the states
var moment = 1

var input_allowed: bool = false
var enemy_spawned: bool = false
var enemy = null
var timer_in_progress: bool = false



################ GENERAL HELP FUNCTIONS ###############
func _ready() -> void:
	"""
	Makes sure to hide the curser and gives the level manager the
	number of the level (necessary if the restart button 
	in the pause menu is pressed).
	Also temporarily locks the players ability to shoot and boost
	"""
	LevelManager.current_gamemode = level_number
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	player.laser_locked = true
	player.plasma_locked = true
	player.speed_boost_locked = true



################## GAME LOOP #####################
func _physics_process(_delta: float) -> void:
	"""
	checks if the pause button is pressed and calls the pause function.
	This is also where the stages (states) of the training is handled.
	"""
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
	"""
	The intro stage (state). This stage only contains dialogue from
	the instructor while the player is paused.
	"""
	##Makes sure the player is paused
	if not player_paused:
		_pause_player()
	
	
	################# DIALOGUE ##################
	if moment == 1 and not timer_in_progress:
		timer_in_progress = true
		explanation_label.text = "\nHello recruit, welcome to the 16th naval regiments fighter training.\n I am Instructor Johnson and will be guiding you today."
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
		
		timer_in_progress = true
		playerbonushealth.show()
		explanation_label.text = "\nYour ship is also capable of picking up bonus health in the shape of green boxes 
		which stacks to your main pool or if that is full, your secondary pool which is located under your main bar."
		input_cooldown.start(12)
		await input_cooldown.timeout
		
		input_allowed = false
		moment = 1
		state = MOVEMENT


func _movement():
	"""
	The movement stage (state). Here the recruit learns how to manouver
	the ship.
	moment 1 is completed if the recruit moves in all directions
	moment 2 is completed if the recuit uses the speed boost
	"""
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
		player.speed_boost_locked = false
		if Input.is_action_just_pressed("Speed boost"):
			input_allowed = false
			state = TARGETING
			moment = 1
			print("moment_changed")


func _targeting():
	"""
	The targeting stage (state). This is where the recruit learns how to use 
	the ships armament.
	
	moment 1 is completed if you fire 10 regular laser. The ability to
	shoot regular lasers is also unlocked here.
	
	moment 2 is completed by firing one plasma blast. The ability to
	fire plasma blasts is also unlocked here 
	"""
	if moment == 1:
		explanation_label.text = "\nExcellent flying! Now try firing your state of the art 
		laser canon using SPACEBAR"
		explanation_label.show()
		player.laser_locked = false
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
		player.plasma_locked = false
		if Input.is_action_just_pressed("shoot_plasma") and moment == 2:
			moment = 3
			timer_in_progress = true
			explanation_label.text = "\nExcellent shooting! Just like extra health, your ship can also pick up
			blue boxes, temporarily removing the cooldown of the plasma blast cannon"
		
			input_cooldown.start(12)
			await input_cooldown.timeout
			
			state = ENEMIES
			
			moment = 1
			input_allowed = false


func _enemies():
	"""
	The enemies stage (state). Here the recruit learns about all the 
	kind of enemies (with the exception of meteors as they are not 
	part of the enemy fleet, they're just rocks)
	
	moment 1 is just dialogue. The player is paused here and you 
	move on to the next moment by pressing w after a certain amount 
	of time.
	
	moment 2 is completed by destroying a enemy_1.  
	
	moment 3 is completed by destroying a enemy_chaser
	
	moment 4 is completed by destroying a mothership
	
	moment 2 to 4 consists of first spawning the enemy and showing a 
	text. The variable enemy has the current enemy as its reference
	and when it gets killed enemy will have no value. When this happens
	another text will appear and after a certain amount of time the next
	moment will start.
	"""
	if moment == 1:
		if not player_paused:
			_pause_player()
			explanation_label.text = "\nNow it is time for you to get to know the enemies of our federation."
			input_cooldown.start(3)
		
		if input_allowed:
			explanation_label.text = "\nNow it is time for you to get to know the enemies of our federation.
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
			
			timer_in_progress = true
			explanation_label.text = "You must also make sure to complete your 
			objective as quickly as possible as the enemies will send 
			more and more reinforcements over time."
			input_cooldown.start(10)
			await input_cooldown.timeout
			
			input_allowed = false
			moment = 1
			enemy_spawned = false
			state = ENDING


func _ending():
	"""
	The ending stage (state). Here the recruit is congratulated for 
	completing the training.
	"""
	explanation_label.text = "\nYou have proven yourself worthy of the title of Valkyrie of the Skies.\n You can exit the training by pressing ESCAPE and RETURN TO THE MAIN MENU"



################# PAUSE FUNKTIONS ###############
func _pause_game():
	"""
	Pauses and unpauses the level tree (therefore excluding Level Manager).
	Does this by disabling all the levels child nodes process mode with
	the exception of the pause scene (so the menus buttons work). Here is
	also were the pause menu is shown and hidden.
	
	if is_instance_valid() is necessary as the game crashes without it
	if you try to pause it again after pressing restart.
	"""
	if not paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		for child in self.get_children():
			if is_instance_valid(child):
				child.process_mode = Node.PROCESS_MODE_DISABLED
		if is_instance_valid(pause_scene):
			pause_scene.process_mode = Node.PROCESS_MODE_INHERIT
			paused = true
			pause_scene.show()
			
	elif paused:
		for child in self.get_children():
			if is_instance_valid(child):
				child.process_mode = Node.PROCESS_MODE_INHERIT
		#Makes sure that conflicts with _pause_player() is avoided
		if player_paused:
			_pause_player()
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		paused = false
		pause_scene.hide()


func _pause_player():
	"""
	Pauses and unpauses only the player ship hindering and enabling
	its movement and shooting. 
	Works by disabling and enabling the players process mode.
	"""
	if not player_paused:
		player_paused = true
		player.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		player.process_mode = Node.PROCESS_MODE_INHERIT
		player_paused = false



####################### SIGNALS ##################
func _on_pause_menu_unpause_game() -> void:
	"""
	A signal from the pause menu node. Unpauses the game.
	Is only called when the restart button is pressed.
	"""
	_pause_game()


func _on_player_laser(type: Variant, pos: Variant, dir: Variant) -> void:
	"""
	A signal from the player. Creates a laser or plasma scene when
	emited. Gives the projectile its spawnpoint (the player) and 
	direction
	
	type = the type of projectile, laser or plasma.
	pos = the position of the player
	dir = the direction the player was looking at when fired.
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


func _on_player_plasma_countdown(time: Variant) -> void:
	"""
	A signal from the player. Gives how long time is left until the
	plasma blast is available again so it can be shown in the HUD.
	Also shows a text when it is usable and hides it when its not.
	
	time = time left until plasma blast is usable.
	"""
	plasma_countdown_bar.value = time * 25
	if plasma_countdown_bar.value <= 0:
		plasma_label.show()
	else:
		plasma_label.hide()


func _on_player_speed_boost_countdown(time: Variant) -> void:
	"""
	A signal from the player. Gives how long time is left until the
	speed boost is available again so it can be shown in the HUD.
	Also shows a text when it is usable and hides it when its not.
	
	time = time left until the speed boost is usable.
	"""
	speed_boost_countdown_bar.value = time * 25
	if speed_boost_countdown_bar.value <= 0:
		speed_boost_label.show()
	else:
		speed_boost_label.hide()



#################### TIMERS ####################
func _on_input_cooldown_timeout() -> void:
	"""
	A timer used to sometimes disable input for a time or sometimes
	to allow for dialogue to move forward.
	"""
	timer_in_progress = false
	input_allowed = true
