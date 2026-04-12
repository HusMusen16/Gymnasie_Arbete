extends Node2D
class_name LEVEL



"""
The script containing the code for all the different gamemodes/levels except the
tutorial. Is this way as all levels except tutorial shares a lot of functions and
code.
"""

"""
level_number = 1  endless mode
level_number = 2  Mothership surge mode
level_number = 3  Defend space station mode
"""



############################# PACKED SCENES ##############################
var laser_scene: PackedScene = load("res://Scenes/laser.tscn")
var meteor_scene: PackedScene = load("res://Scenes/meteor.tscn")
var enemy_scene: PackedScene = load("res://Scenes/enemy_1.tscn")
var plasma_scene: PackedScene = load("res://Scenes/plasma_blast.tscn")
var mother_ship_scene: PackedScene = load("res://Scenes/mother_ship.tscn")
var victory_screen: PackedScene = load("res://Scenes/victory_screen.tscn")
var defeat_screen: PackedScene = load("res://Scenes/defeat_screen.tscn")
var spacestation_scene: PackedScene = load("res://Scenes/space_station.tscn")
var chaser_scene: PackedScene = load("res://Scenes/enemy_chaser.tscn")
var health_pickup: PackedScene = load("res://Scenes/health_pickup.tscn")
var unlimited_plasma_pickup: PackedScene = load("res://Scenes/unlimited_plasma_powerup.tscn")



############################ ON READY VARIABLES ###########################
#General nodes
@onready var pause_scene = $"Pause menu"
@onready var bg_purple = $BG/BG_Purple
@onready var items = $Items

#HUD nodes
@onready var health_bar: ProgressBar = $HUD/PlayerHealth/HealthBar
@onready var speed_boost_countdown_bar: ProgressBar = $HUD/SpeedBoostCooldown/SpeedBoost_countdown
@onready var speed_boost_label: Label = $HUD/SpeedBoostCooldown/Label
@onready var bonus_health_bar: ProgressBar = $HUD/PlayerBonusHealth/BonusHealthBar
@onready var bonus_health_bg: ColorRect = $HUD/PlayerBonusHealth
@onready var plasma_countdown_bar: ProgressBar = $HUD/PlasmaBlastCooldown/plasma_countdown
@onready var plasma_label: Label = $HUD/PlasmaBlastCooldown/Label

#Timer nodes
@onready var item_spawn_timer: Timer = $Item_Spawn_Timer
@onready var meteor_timer: Timer = $Meteor_Timer
@onready var enemy_timer: Timer = $Enemy_Timer
@onready var mother_timer: Timer = $Mother_Timer
@onready var damage_timer: Timer = $Damage_Timer
@onready var chaser_timer: Timer = $Chaser_Timer

#Player nodes
@onready var player: PLAYER = $Player
@onready var lasers: Node = $Lasers
@onready var plasmas: Node = $Plasmas
@onready var damage_audio: AudioStreamPlayer = $DamageSound

#Enemy Nodes 
@onready var meteors: Node = $Meteors
@onready var enemies: Node = $Enemies
@onready var motherships: PathFollow2D = $MotherPath/MotherShips
@onready var chasers: Node = $Chasers

#Nodes specific for level 1
@onready var bigstar1 = $BG/BigStar1
@onready var bigstar2 = $BG/BigStar2
@onready var kills_text = $HUD/Kills/KillsText
@onready var kills_text_bg = $HUD/Kills
@onready var difficulty_timer = $Difficulty_timer

#Nodes specific for level 2
@onready var blackhole = $BG/BlackHole
@onready var surge_motherships: PathFollow2D = $MotherPath/Surge_MotherShips
@onready var surge_mother_timer: Timer = $Surge_Mother_Timer
@onready var kill_progress: Label = $HUD/MothershipKills/Label
@onready var kill_progress_bg: ColorRect = $HUD/MothershipKills

#Nodes specific for level 3
@onready var galaxy = $BG/Galaxy
@onready var space_station_health_bar = $HUD/SpaceStationHealth/SpaceStationHealthBar
@onready var space_station_health_bar_bg = $HUD/SpaceStationHealth
@onready var time_left_label:Label = $HUD/SpaceStationHealth/time_left_label



############################ EXPORT VARIABLES #################################

##The number of the level, see further info in the level.gd script.
@export var level_number: int = 0
##Spawnrate of the standard enemy in seconds.
@export var enemy_spawnrate: float = 2
##Spawnrate of the chaser enemy in seconds. Does not affect level 2.
@export var chaser_spawnrate: float = 5
##Spawnrate of the mothership enemy in seconds. Does not affect level 3.
@export var mothership_spawnrate: float = 10
##Spawnrate of the meteors in seconds.
@export var meteor_spawnrate: float = 2
##Spawnrate of items in seconds. A max of 10 can be active at a time.
@export var item_spawnrate: float = 20
##Time until spawnrates increase in seconds. Is stackable. Does not affect items.
@export var difficulty_timer_time: float = 50



########################### VARIABLES ##############################
var health = 100
var allow_mothership_spawn: bool = true
var mothership_spawning: bool = false
var safe: bool = false
var victorious: bool = false

var has_lost: bool = false

var paused: bool = false

#Variabler för level 2
var allow_surge_mothership_spawn: bool = true
var surge_mothership_spawning: bool = false
var mothership_kills = 0

#Variabler för level 3
var spacestation_position = Vector2(0,0)
var spacestation = null
var win_timer = null



################# GENERAL FUNKTIONS #################
func _ready() -> void:
	"""
	Makes sure the cursor is hidden, that the level manager knows what level
	it is and that all timers are correct. It also makes sure to fix 
	things depending on what level it is.
	"""
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	LevelManager.current_gamemode = level_number
	enemy_timer.wait_time = enemy_spawnrate
	mother_timer.wait_time = mothership_spawnrate
	surge_mother_timer.wait_time = mothership_spawnrate
	meteor_timer.wait_time = meteor_spawnrate
	chaser_timer.wait_time = chaser_spawnrate
	item_spawn_timer.wait_time = item_spawnrate
	
	
	if level_number == 1:
		"""
		Fixes background for level 1 and starts the timer for enemy
		chaser. Shows the score in the HUD
		"""
		kills_text_bg.show()
		bigstar1.show()
		bigstar1.play("default")
		bigstar2.show()
		bigstar2.play("default")
		
		chaser_timer.autostart = true
		chaser_timer.start(-1)

	elif level_number == 2:
		"""
		Fixes background for level 2. Shows the amount of 
		necessary mothership kills in the HUD
		"""
		bg_purple.play("default")
		kill_progress_bg.show()
		blackhole.show()
		blackhole.play("default")
		
	elif level_number == 3:
		"""
		Fixes background for level 3. Shows the current spacestation
		health in the HUD. Stops the mothership timer and Starts the 
		enemy chaser timer. Adds the spacestation scene. Creates and
		starts the timer that makes you win.  
		"""
		space_station_health_bar_bg.show()
		galaxy.show()
		galaxy.play("default")
		
		mother_timer.stop()
		
		spacestation = spacestation_scene.instantiate()
		self.add_child(spacestation)
		spacestation.global_position = Vector2(2300,1225)
		spacestation_position = spacestation.global_position
		
		chaser_timer.autostart = true
		chaser_timer.start(-1)
		
		#Time until you win
		win_timer = Timer.new()
		add_child(win_timer)
		win_timer.wait_time = LevelManager.spacestation_survival_time
		win_timer.one_shot = true
		win_timer.start()
		win_timer.timeout.connect(_on_win_timer_timeout)


func _physics_process(_delta: float) -> void:
	############# GENERAL ###############
	"""
	Makes sure the motership pathfollower2d progresses unless the
	game is paused. Also makes sure motherships are spawned correctly
	and that the game pauses when the pause button is pressed
	(currently ESC)
	"""
	if level_number != 3 and not paused:
		motherships.progress_ratio += 0.0002
		#motherships.global_position = path_follower.global_position
	
	if not victorious and level_number != 3:
		_mothership_spawn_manager()
	
	if Input.is_action_just_pressed("Pause"):
		_pause_game()
			
	
	############# LEVEL 1 ###############
	if level_number == 1:
		"""
		Makes sure the score (kills_text) is updated in level 1
		"""
		kills_text.text = str(LevelManager.kills)
	
	############ LEVEL 2 ##############
	elif level_number == 2:
		"""
		Makes sure the current amount of killed motherships
		is updated (mothership_kills) and that its background has
		the correct size. Also makes sure the surge mothership
		pathfollower2d is updated and checks if you have won.
		Only does this if you are playing level 2.
		"""
		mothership_kills = LevelManager.mothership_kills
		kill_progress.text = (str(mothership_kills) + "/" + str(LevelManager.mothership_kill_goal) + " motherships")
		if kill_progress_bg.size.x <= kill_progress.size.x + 10:
			kill_progress_bg.size.x = kill_progress.size.x + 24
			
		if not paused:
			surge_motherships.progress_ratio += 0.0002
			
		if mothership_kills >= LevelManager.mothership_kill_goal and not victorious:
			victorious = true
			_victory()
			
	########### LEVEL 3 ##############
	elif level_number == 3:
		"""
		If you are playing level 3 it makes sure that the correct
		spacestation health and time left until you win is shown.
		Also checks if you have lost. 
		"""
		if spacestation.health <= 0 and not has_lost:
			has_lost = true
			win_timer.paused = true
			_defeat()
		space_station_health_bar.value = spacestation.health
		time_left_label.text = "time left: " + str(round(win_timer.time_left))


func _victory():
	"""
	This function is called when you have won. Makes the cursor visible
	and makes sure to add the victory sceen to the scene tree. Also 
	removes all enemies.
	"""
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	victorious = true
	var victoryscreen = victory_screen.instantiate()
	self.add_child(victoryscreen)
	
	#Removes all enemy_1
	var enemy = enemies.get_children()
	enemy_timer.stop()
	for i in range(len(enemy)):
		enemy[i].explode()
	
	#Removes all enemy_chaser
	if level_number != 2:
		var chaser = chasers.get_children()
		chaser_timer.stop()
		for i in range(len(chaser)):
			chaser[i].explode()
	
	#Removes all meteors
	var meteor = meteors.get_children()
	meteor_timer.stop()
	for i in range(len(meteor)):
		meteor[i].explode()
	
	#Removes all motherships
	var mothership = motherships.get_children()
	mother_timer.stop()
	for i in range(len(mothership)):
		mothership[i].health = 1
		mothership[i].damage()
		if level_number == 2:
			LevelManager.mothership_kills -= 1
	
	#Removes all surge motherships if playing level 2
	if level_number == 2:
		var surge_mothership = surge_motherships.get_children()
		surge_mother_timer.stop()
		for i in range(len(surge_mothership)):
			surge_mothership[i].health = 1
			surge_mothership[i].damage()
			LevelManager.mothership_kills -= 1


func _defeat():
	"""
	This function is called when you have lost. Makes the cursor visible.
	Makes sure to remove the reference for the player from all enemies.
	"""
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	#Removes player reference from enemy_1
	var enemy = enemies.get_children()
	for i in range(len(enemy)):
		enemy[i].player = null
	
	#Removes player reference from enemy_chaser
	var chaser = chasers.get_children()
	for i in range(len(chaser)):
		chaser[i].target = null
	
	#Removes player reference from motherships
	var mothership = motherships.get_children()
	for i in range(len(mothership)):
		mothership[i].player = null
		mothership[i]._on_player_data_timer_timeout()
	
	#Removes player reference from surge motherhship
	var surge_mothership = surge_motherships.get_children()
	for i in range(len(surge_mothership)):
		surge_mothership[i].player = null
		surge_mothership[i]._on_player_data_timer_timeout()
	
	#Explodes the spacestation if it exists and the level is level 3
	if level_number == 3 and spacestation != null:
		spacestation.explode()
	
	#Makes sure you cannot lose multiple times and that the player explodes
	has_lost = true
	player.dead = true
	player.destroyed()
	
	#Checks if you have beaten your highscore if the level is level 1
	if level_number == 1:
		LevelManager.check_highscore()
		
	#Adds the defeat sceen to the scene tree.
	var defeatscreen = defeat_screen.instantiate()
	self.add_child(defeatscreen)


func _pause_game():
	"""
	Pauses and unpauses the level tree (therefore excluding Level Manager).
	Does this by disabling all the levels child nodes process mode with
	the exception of the pause scene (so the menus buttons work). Here is
	also were the pause menu is shown and hidden.
	
	if is_instance_valid() is necessary as the game crashes without it
	if you try to pause it again after pressing restart.
	"""
	if not paused and not has_lost and not victorious:
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
			child.process_mode = Node.PROCESS_MODE_INHERIT
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		paused = false
		pause_scene.hide()



################## SPAWN FUNKTIONS ###################
func _spawn_meteor():
	"""
	Spawns meteor. The enem gets a random spawnpoint that is further
	than 1220 units from the player. Also makes sure there is a 
	maximum of 60 meteors at a time and that they stop spawning if 
	the player has lost.
	"""
	if len(meteors.get_children()) <= 60 and not has_lost:
		var meteor = meteor_scene.instantiate()
		meteors.add_child(meteor)
		meteor.global_position.x = randf_range(-100, 4600)
		meteor.global_position.y = randf_range(-100, 2800)
		while meteor.global_position.distance_to(player.global_position) < 1220:
			meteor.global_position.x = randf_range(-100, 4600)
			meteor.global_position.y = randf_range(-100, 2800)


func _spawn_enemy():
	"""
	Spawns enemy_1. The enemy gets the reference to the player
	and gets a random spawnpoint that is further than 1220 units from
	the player. Also makes sure there is a maximum of 60 enemy_1 at
	a time and that they stop spawning if the player has lost.
	"""
	if len(enemies.get_children()) <= 60 and not has_lost:
		var enemy = enemy_scene.instantiate()
		enemies.add_child(enemy)
		enemy.player = player
		enemy.global_position.x = randf_range(-100, 4600)
		enemy.global_position.y = randf_range(-100, 2800)
		while enemy.global_position.distance_to(player.global_position) < 1220:
			enemy.global_position.x = randf_range(-100, 4600)
			enemy.global_position.y = randf_range(-100, 2800)


func _spawn_enemy_chaser(target):
	"""
	Spawns enemy_chaser. The enemy gets the reference to the player
	and gets a random spawnpoint that is further than 1220 units from
	the player. Also makes sure there is a maximum of 60 enemy_chasers 
	at a time and that they stop spawning if the player has lost.
	"""
	if len(chasers.get_children()) <= 60 and not has_lost:
		var chaser = chaser_scene.instantiate()
		chasers.add_child(chaser)
		chaser.target = target
		chaser.global_position.x = randf_range(-100, 4600)
		chaser.global_position.y = randf_range(-100, 2800)
		while chaser.global_position.distance_to(target.global_position) < 2000:
			chaser.global_position.x = randf_range(-100, 4600)
			chaser.global_position.y = randf_range(-100, 2800)


func _spawn_mothership(): 
	"""
	Spawns the mothership. Gets a reference to the player and has
	its animation played when it enter the game. Also gets a 
	rotation comparison for its guns and makes the variable
	mothership_spawning false.
	"""
	if not victorious:
		mothership_spawning = false
		var mother_ship = mother_ship_scene.instantiate()
		motherships.add_child(mother_ship)
		if not has_lost:
			mother_ship.player = player
		mother_ship.rotation_comparison = motherships
		mother_ship.ftl_jump()


func _spawn_surge_mothership():
	"""
	Identical to _spawn_mothership except with different variable names.
	Only called during level 2.
	"""
	if not victorious:
		surge_mothership_spawning = false
		var surge_mothership = mother_ship_scene.instantiate()
		surge_motherships.add_child(surge_mothership)
		if not has_lost:
			surge_mothership.player = player
		surge_mothership.rotation_comparison = surge_motherships
		surge_mothership.ftl_jump()


func _mothership_spawn_manager():
	"""
	Handles the spawning of motherships and surge motherships. Checks 
	if there already is a mothership or if the timer to spawn one is 
	active. if not, it will start that timer which will spawn a 
	mothership.
	
	mothershipcount = amount of active motherships (has a value of 1 or 0)
	surge_mothershipcount = amount of active surge motherships (has a value of 1 or 0)
	"""
	
	#Regular motherships
	var mothershipcount = motherships.get_children()
	
	if len(mothershipcount) == 0 and not mothership_spawning:
		allow_mothership_spawn = true
		
	if allow_mothership_spawn:
		mother_timer.start(-1)
		allow_mothership_spawn = false
		mothership_spawning = true
		
	if level_number == 2:
		#Surge motherships
		var surge_mothershipcount = surge_motherships.get_children()
	
		if len(surge_mothershipcount) == 0 and not surge_mothership_spawning:
			allow_surge_mothership_spawn = true
		
		if allow_surge_mothership_spawn:
			surge_mother_timer.start(-1)
			allow_surge_mothership_spawn = false
			surge_mothership_spawning = true


func _spawn_item():
	"""
	Spawns items if there is less than 10. Gives the item a random position
	and decides using a random number on what item to spawn, 
	health_pickup or unlimited_plasma_powerup, with a 66% respectivly 
	33% chance of being chosen.
	The exceptions are level 2 where only health_pickup can spawn
	and level 3 where only unlimited_plasma_powerup can spawn.
	
	type_decider = the random number that decides what item will spawn.
	"""
	if len(items.get_children()) <= 10:
		var type_decider = randi() % 3
		
		#health_pickup
		if (type_decider == 1 or type_decider == 2) and level_number != 3 or level_number == 2 :
			var item = health_pickup.instantiate()
			items.add_child(item)
			item.global_position.x = randf_range(30, 4500)
			item.global_position.y = randf_range(30,2640)
		
		#unlimited_plasma_powerup
		elif type_decider == 0 and level_number != 2 or level_number == 3:
			var item = unlimited_plasma_pickup.instantiate()
			items.add_child(item)
			item.global_position.x = randf_range(30, 4500)
			item.global_position.y = randf_range(30,2640)



###################### TIMERS ############################
func _on_meteor_timer_timeout() -> void:
	"""
	The timer that decides when a meteor should spawn.
	"""
	_spawn_meteor()


func _on_enemy_timer_timeout() -> void:
	"""
	The timer that decides when a enemy_1 should spawn.
	"""
	_spawn_enemy()


func _on_chaser_timer_timeout() -> void:
	"""
	The timer that decides when a enemy_chaser should spawn.
	Also decides its target depending on the level (level_number).
	"""
	if level_number == 1:
		_spawn_enemy_chaser(player)
	
	elif level_number == 3:
		_spawn_enemy_chaser(spacestation)


func _on_mother_timer_timeout() -> void:
	"""
	The timer that decides when a mothership should spawn.
	"""
	_spawn_mothership()


func _on_surge_mother_timer_timeout() -> void:
	"""
	The timer that decides when a surge_mothership should spawn.
	"""
	_spawn_surge_mothership()


func _on_damage_timer_timeout() -> void:
	"""
	The timer that decides how long the player is immortal after taking
	damage.
	"""
	safe = false


func _on_win_timer_timeout():
	"""
	Decides after how long you should win if you are playing
	level 3.
	"""
	_victory()


func _on_item_spawn_timer_timeout() -> void:
	"""
	The timer that decides when a item should spawn.
	"""
	_spawn_item()


func _on_difficulty_timer_timeout() -> void:
	"""
	The timer that increases difficulty over time. Does this by reducing spawn time 
	until a minimum have been achieved.
	"""
	if enemy_timer.wait_time > 0.2:
		enemy_timer.wait_time -= 0.2
	if chaser_timer.wait_time > 0.2:
		chaser_timer.wait_time -= 0.2
	if mother_timer.wait_time > 0.3:
		mother_timer.wait_time -= 0.3
	if meteor_timer.wait_time > 0.2:
		meteor_timer.wait_time -= 0.2
	if level_number == 2:
		if surge_mother_timer.wait_time > 0.3:
			surge_mother_timer.wait_time -= 0.3



###################### SIGNALS ###########################
func _on_player_laser(type: Variant, pos: Variant, dir: Variant) -> void:
	"""
	A signal from the player. Spawns a laser or plasma blast
	from the player ship giving a direction and spawnpoint.
	
	type = the type of projectile, either laser or plasma
	pos = the spawnpoint of the projectile, the front of the player ship.
	dir = the direction of the projectile / the direction the player was facing 
		  when shooting.
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


func _on_player_player_hit(type: Variant) -> void:
	"""
	A signal from the player. If the player has not lost, won or taken damage recently
	(not safe) it will take damage followed with a sound (damage_audio) and make you
	temporarily invournable (damage_timer).
	It will also make sure to update the current health shown in the HUD and make
	sure to splite the health correctly between the bonus health (from health_pickup)
	and regular health.
	Lastly it will also check if you have died and end the game or respawn you at 
	the space station if the level is level 3. 
	
	type = the type of enemy that dealt damage to the player as they deal different
		   amounts of damage.
	"""
	if not safe and not victorious and not has_lost:
		if type == ENEMY:
			health -= 3
			damage_audio.play()
		elif type == ENEMY_CHASER:
			health -= 10
			damage_audio.play()
		elif type == METEOR:
			health -= 10
			damage_audio.play()
		elif type == MOTHERSHIP:
			health -= 7
			damage_audio.play()
			
		if health <= 100:
			health_bar.value = health
			bonus_health_bar.value = 0
		else:
			health_bar.value = 100
			bonus_health_bar.value = (health - 100)*2
		
		if health <= 0 and level_number != 3 and not has_lost :
			_defeat()
			
		elif health <= 0 and level_number == 3:
			health = 100
			player.global_position = spacestation_position
			
		else:
			safe = true
			damage_timer.start(-1)


func _on_player_picked_up_item(type: Variant) -> void:
	"""
	A signal from the player. Applies health from health_pickup if it has been
	collided with. Health can be a maximum of 150. Makes sure to split the
	shown health correctly between the health bar and the bonus health bar.
	
	type = the type of item picked up, currently only health.
	"""
	if type == "health" and health <= 150:
		health += 20
		if health > 150:
			health = 150
			
		if health <= 100:
			health_bar.value = health
			bonus_health_bar.value = 0
		else:
			health_bar.value = 100
			bonus_health_bar.value = (health - 100)*2


func _on_pause_menu_unpause_game() -> void:
	"""
	A signal from the pause menu node. Unpauses the game.
	Is only called when the restart button is pressed.
	"""
	_pause_game()
