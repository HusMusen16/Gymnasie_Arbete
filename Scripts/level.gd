extends Node2D
class_name LEVEL


var laser_scene: PackedScene = load("res://Scenes/laser.tscn")
var meteor_scene: PackedScene = load("res://Scenes/meteor.tscn")
var enemy_scene: PackedScene = load("res://Scenes/enemy_1.tscn")
var plasma_scene: PackedScene = load("res://Scenes/plasma_blast.tscn")
var mother_ship_scene: PackedScene = load("res://Scenes/mother_ship.tscn")
var victory_screen: PackedScene = load("res://Scenes/victory_screen.tscn")
var defeat_screen: PackedScene = load("res://Scenes/defeat_screen.tscn")
var spacestation_scene: PackedScene = load("res://Scenes/space_station.tscn")
var chaser_scene: PackedScene = load("res://Scenes/enemy_chaser.tscn")


@onready var pause_scene = $"Pause menu"

#Player nodes
@onready var player: PLAYER = $Player
@onready var lasers: Node = $Lasers
@onready var health_bar: ProgressBar = $HUD/PlayerHealth/HealthBar
@onready var damage_timer: Timer = $Damage_Timer
@onready var damage_audio: AudioStreamPlayer = $DamageSound
@onready var speed_boost_countdown_bar: ProgressBar = $HUD/SpeedBoostCooldown/SpeedBoost_countdown
@onready var speed_boost_label: Label = $HUD/SpeedBoostCooldown/Label

#Plasma Nodes
@onready var plasmas: Node = $Plasmas
@onready var plasma_countdown_bar: ProgressBar = $HUD/PlasmaBlastCooldown/plasma_countdown
@onready var plasma_label: Label = $HUD/PlasmaBlastCooldown/Label

#Meteor Nodes 
@onready var meteors: Node = $Meteors
@onready var meteor_timer: Timer = $Meteor_Timer

#Enemy Nodes
@onready var enemies: Node = $Enemies
@onready var enemy_timer: Timer = $Enemy_Timer

#Mothership Nodes
@onready var motherships: Node = $MotherPath/PathFollower/MotherShips
@onready var mother_timer: Timer = $Mother_Timer
@onready var path_follower: PathFollow2D = $MotherPath/PathFollower

#Nodes specific for level 1
@onready var kills_text = $HUD/Kills/KillsText
@onready var kills_text_bg = $HUD/Kills
@onready var difficulty_timer = $Difficulty_timer

#Nodes specific for level 2
@onready var surge_follower: PathFollow2D = $MotherPath/SurgeFollower
@onready var surge_motherships: Node2D = $MotherPath/SurgeFollower/SurgeMotherShips
@onready var surge_mother_timer: Timer = $Surge_Mother_Timer
@onready var kill_progress: Label = $HUD/MothershipKills/Label
@onready var kill_progress_bg: ColorRect = $HUD/MothershipKills

#Nodes specific for level 3
@onready var chasers: Node = $Chasers
@onready var chaser_timer: Timer = $Chaser_Timer
@onready var space_station_health_bar = $HUD/SpaceStationHealth/SpaceStationHealthBar
@onready var space_station_health_bar_bg = $HUD/SpaceStationHealth


"""
level_number = 1  endless mode
level_number = 2  Mothership surge mode
level_number = 3  Defend space station mode
"""

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
##Time until spawnrates increase in seconds. Is stackable.
@export var difficulty_timer_time: float = 50

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
	LevelManager.current_gamemode = level_number
	enemy_timer.wait_time = enemy_spawnrate
	mother_timer.wait_time = mothership_spawnrate
	surge_mother_timer.wait_time = mothership_spawnrate
	meteor_timer.wait_time = meteor_spawnrate
	chaser_timer.wait_time = chaser_spawnrate
	
	if level_number == 1:
		kills_text_bg.show()
		
		chaser_timer.autostart = true
		chaser_timer.start(-1)
	
	elif level_number == 2:
		kill_progress_bg.show()
	
	elif level_number == 3:
		space_station_health_bar_bg.show()
		
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
		win_timer.wait_time = 180
		win_timer.one_shot = true
		win_timer.start()
		win_timer.timeout.connect(_on_win_timer_timeout)


func _physics_process(_delta: float) -> void:
	############# GENERAL ###############
	if level_number != 3 and not paused:
		path_follower.progress_ratio += 0.0002
		motherships.global_position = path_follower.global_position
	
	if not victorious and level_number != 3:
		_mothership_spawn_manager()
	
	if Input.is_action_just_pressed("Pause"):
		_pause_game()
			
	
	############# LEVEL 1 ###############
	if level_number == 1:
		kills_text.text = str(LevelManager.kills)
	
	############ LEVEL 2 ##############
	elif level_number == 2:
		mothership_kills = LevelManager.mothership_kills
		kill_progress.text = (str(mothership_kills) + "/3 motherships")
		if not paused:
			surge_follower.progress_ratio += 0.0002
			surge_motherships.global_position = surge_follower.global_position
		if mothership_kills >= 3 and not victorious:
			victorious = true
			_victory()
			
	########### LEVEL 3 ##############
	elif level_number == 3:
		if spacestation.health <= 0 and not has_lost:
			has_lost = true
			_defeat()
		space_station_health_bar.value = spacestation.health


func _victory():
	victorious = true
	var victoryscreen = victory_screen.instantiate()
	self.add_child(victoryscreen)
	
	#tar bort standard fiender
	var enemy = enemies.get_children()
	enemy_timer.stop()
	for i in range(len(enemy)):
		enemy[i].explode()
	
	#tar bort chasers
	if level_number != 2:
		var chaser = chasers.get_children()
		chaser_timer.stop()
		for i in range(len(chaser)):
			chaser[i].explode()
	
	#tar bort meteorer
	var meteor = meteors.get_children()
	meteor_timer.stop()
	for i in range(len(meteor)):
		meteor[i].explode()
	
	#tar bort motherships
	var mothership = motherships.get_children()
	mother_timer.stop()
	for i in range(len(mothership)):
		mothership[i].health = 1
		mothership[i].damage()
		if level_number == 2:
			LevelManager.mothership_kills -= 1
	
	#tar bort motherships
	if level_number == 2:
		var surge_mothership = surge_motherships.get_children()
		surge_mother_timer.stop()
		for i in range(len(surge_mothership)):
			surge_mothership[i].health = 1
			surge_mothership[i].damage()
			LevelManager.mothership_kills -= 1


func _defeat():
	var enemy = enemies.get_children()
	for i in range(len(enemy)):
		enemy[i].player = null
	
	if level_number != 2:
		var chaser = chasers.get_children()
		for i in range(len(chaser)):
			chaser[i].target = null
	
	var mothership = motherships.get_children()
	for i in range(len(mothership)):
		mothership[i].player = null
		mothership[i].player_lost = true
		
	if level_number == 2:
		var surge_mothership = surge_motherships.get_children()
		for i in range(len(surge_mothership)):
			surge_mothership[i].player = null
			surge_mothership[i].player_lost = true
			
	has_lost = true
	player.dead = true
	player.destroyed()
	
	if level_number == 1:
		LevelManager.check_highscore()
		
	var defeatscreen = defeat_screen.instantiate()
	self.add_child(defeatscreen)


func _pause_game():
	if not paused and not has_lost:
			for child in self.get_children():
				child.process_mode = Node.PROCESS_MODE_DISABLED
			pause_scene.process_mode = Node.PROCESS_MODE_INHERIT
			paused = true
			pause_scene.show()
			
	elif paused:
		for child in self.get_children():
			child.process_mode = Node.PROCESS_MODE_INHERIT
		paused = false
		pause_scene.hide()


################## SPAWN FUNKTIONS ###################
func _spawn_enemy():
	if len(enemies.get_children()) <= 60 and not has_lost:
		var enemy = enemy_scene.instantiate()
		enemies.add_child(enemy)
		enemy.player = player
		enemy.global_position.x = randf_range(-100, 4600)
		enemy.global_position.y = randf_range(-100, 2800)
		while enemy.global_position.distance_to(player.global_position) < 1220:
			enemy.global_position.x = randf_range(-100, 4600)
			enemy.global_position.y = randf_range(-100, 2800)


func _spawn_mothership(): 
	if not victorious:
		mothership_spawning = false
		var mother_ship = mother_ship_scene.instantiate()
		motherships.add_child(mother_ship)
		if not has_lost:
			mother_ship.player = player
		mother_ship.rotation_comparison = path_follower
		mother_ship.ftl_jump()


func _spawn_surge_mothership():
	if not victorious:
		surge_mothership_spawning = false
		var surge_mothership = mother_ship_scene.instantiate()
		surge_motherships.add_child(surge_mothership)
		if not has_lost:
			surge_mothership.player = player
		surge_mothership.rotation_comparison = surge_follower
		surge_mothership.ftl_jump()


func _mothership_spawn_manager():
	var mothershipcount = motherships.get_children()
	
	if len(mothershipcount) == 0 and not mothership_spawning:
		allow_mothership_spawn = true
		
	if allow_mothership_spawn:
		mother_timer.start(-1)
		allow_mothership_spawn = false
		mothership_spawning = true
		
	if level_number == 2:
		var surge_mothershipcount = surge_motherships.get_children()
	
		if len(surge_mothershipcount) == 0 and not surge_mothership_spawning:
			allow_surge_mothership_spawn = true
		
		if allow_surge_mothership_spawn:
			surge_mother_timer.start(-1)
			allow_surge_mothership_spawn = false
			surge_mothership_spawning = true


func _spawn_meteor():
	if len(meteors.get_children()) <= 60 and not has_lost:
		var meteor = meteor_scene.instantiate()
		meteors.add_child(meteor)
		meteor.global_position.x = randf_range(-100, 4600)
		meteor.global_position.y = randf_range(-100, 2800)
		while meteor.global_position.distance_to(player.global_position) < 1220:
			meteor.global_position.x = randf_range(-100, 4600)
			meteor.global_position.y = randf_range(-100, 2800)


func _spawn_enemy_chaser(target):
	if len(chasers.get_children()) <= 60 and not has_lost:
		var chaser = chaser_scene.instantiate()
		chasers.add_child(chaser)
		chaser.target = target
		chaser.global_position.x = randf_range(-100, 4600)
		chaser.global_position.y = randf_range(-100, 2800)
		while chaser.global_position.distance_to(target.global_position) < 2000:
			chaser.global_position.x = randf_range(-100, 4600)
			chaser.global_position.y = randf_range(-100, 2800)



###################### TIMERS ############################
func _on_meteor_timer_timeout() -> void:
	_spawn_meteor()


func _on_enemy_timer_timeout() -> void:
	_spawn_enemy()


func _on_damage_timer_timeout() -> void:
	safe = false


func _on_mother_timer_timeout() -> void:
	_spawn_mothership()


func _on_surge_mother_timer_timeout() -> void:
	_spawn_surge_mothership()


func _on_chaser_timer_timeout() -> void:
	if level_number == 1:
		_spawn_enemy_chaser(player)
	
	elif level_number == 3:
		_spawn_enemy_chaser(spacestation)


func _on_win_timer_timeout():
	_victory()


###################### SIGNALS ###########################
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


func _on_player_player_hit(type: Variant) -> void:
	if not safe and not victorious:
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
		health_bar.value = health
		
		if health <= 0 and level_number != 3 and not has_lost :
			_defeat()
			
		elif health <= 0 and level_number == 3:
			health = 100
			player.global_position = spacestation_position
			
		else:
			safe = true
			damage_timer.start(-1)


func _on_difficulty_timer_timeout() -> void:
	if enemy_timer.wait_time > 0.2:
		enemy_timer.wait_time -= 0.2
	if chaser_timer.wait_time > 0.2:
		chaser_timer.wait_time -= 0.2
	if mother_timer.wait_time >= 0.3:
		mother_timer.wait_time -= 0.3
	if meteor_timer.wait_time >= 0.2:
		meteor_timer.wait_time -= 0.2
	if level_number == 2:
		if surge_mother_timer.wait_time >= 0.3:
			surge_mother_timer.wait_time -= 0.3


func _on_pause_menu_unpause_game() -> void:
	_pause_game()


func _on_player_speed_boost_countdown(time: Variant) -> void:
	speed_boost_countdown_bar.value = time * 25
	if speed_boost_countdown_bar.value <= 0:
		speed_boost_label.show()
	else:
		speed_boost_label.hide()
