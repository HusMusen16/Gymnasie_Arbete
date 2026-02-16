extends Node2D
class_name LEVEL


var laser_scene: PackedScene = load("res://Scenes/laser.tscn")
var meteor_scene: PackedScene = load("res://Scenes/meteor.tscn")
var enemy_scene: PackedScene = load("res://Scenes/enemy_1.tscn")
var plasma_scene: PackedScene = load("res://Scenes/plasma_blast.tscn")
var mother_ship_scene: PackedScene = load("res://Scenes/mother_ship.tscn")
var victory_screen: PackedScene = load("res://Scenes/victory_screen.tscn")
var defeat_screen: PackedScene = load("res://Scenes/defeat_screen.tscn")


#Player nodes
@onready var player: PLAYER = $Player
@onready var lasers: Node = $Lasers

#Plasma Nodes
@onready var plasmas: Node = $Plasmas
@onready var plasma_countdown_bar: ProgressBar = $UI/ColorRect2/plasma_countdown
@onready var plasma_label: Label = $UI/ColorRect2/Label

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

#Health related Nodes
@onready var health_bar: ProgressBar = $UI/ColorRect/HealthBar
@onready var damage_timer: Timer = $Damage_Timer

#Nodes specific for level 1
@onready var kills_text = $UI/ColorRect4/Kills
@onready var kills_text_bg = $UI/ColorRect4

#Nodes specific for level 2
@onready var surge_follower: PathFollow2D = $MotherPath/SurgeFollower
@onready var surge_motherships: Node2D = $MotherPath/SurgeFollower/SurgeMotherShips
@onready var surge_mother_timer: Timer = $Surge_Mother_Timer
@onready var kill_progress: Label = $UI/ColorRect3/Label
@onready var kill_progress_bg: ColorRect = $UI/ColorRect3


"""
level_number = 1  endless mode
level_number = 2  Mothership surge mode
level_number = 3  Defend space station mode
"""
@export var level_number = 0
@export var enemy_spawnrate = 2
@export var mothership_spawnrate = 10


var health = 100
var allow_mothership_spawn: bool = true
var mothership_spawning: bool = false
var safe: bool = false
var victorious: bool = false
var has_not_won: bool = true

#Variabler för level 2
var allow_surge_mothership_spawn: bool = true
var surge_mothership_spawning: bool = false
var mothership_kills = 0


################# GENERAL FUNKTIONS #################
func _ready() -> void:
	enemy_timer.wait_time = enemy_spawnrate
	mother_timer.wait_time = mothership_spawnrate
	surge_mother_timer.wait_time = mothership_spawnrate
	if level_number == 1:
		kills_text_bg.show()
		
	if level_number == 2:
		kill_progress_bg.show()

func _physics_process(_delta: float) -> void:
	################ MOTHER SHIP CODE ################
	if level_number != 3:
		path_follower.progress_ratio += 0.0002
		motherships.global_position = path_follower.global_position
	
	if level_number == 2:
		mothership_kills = LevelManager.mothership_kills
		kill_progress.text = (str(mothership_kills) + "/3 motherships")
		surge_follower.progress_ratio += 0.0002
		surge_motherships.global_position = surge_follower.global_position
		
		if mothership_kills >= 3 and has_not_won:
			has_not_won = false
			victory()
	
	if level_number == 1:
		kills_text.text = str(LevelManager.kills)
	
	if not victorious or level_number != 3:
		_mothership_spawn_manager()


func victory():
	victorious = true
	var victoryscreen = victory_screen.instantiate()
	self.add_child(victoryscreen)
	victoryscreen.current_level = level_number
	
	var enemy = enemies.get_children()
	enemy_timer.stop()
	for i in range(len(enemy)):
		enemy[i].explode()
		
	var meteor = meteors.get_children()
	meteor_timer.stop()
	for i in range(len(meteor)):
		meteor[i].explode()
	
	var mothership = motherships.get_children()
	mother_timer.stop()
	for i in range(len(mothership)):
		mothership[i].health = 0
		mothership[i].damage()
		
	if level_number == 2:
		var surge_mothership = surge_motherships.get_children()
		surge_mother_timer.stop()
		for i in range(len(surge_mothership)):
			surge_mothership[i].health = 0
			surge_mothership[i].damage()


func defeat():
	var defeatscreen = defeat_screen.instantiate()
	self.add_child(defeatscreen)
	defeatscreen.current_level = level_number



################## SPAWN FUNKTIONS ###################
func _spawn_enemy():
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
		mother_ship.Player = player
		mother_ship.rotation_comparison = path_follower


func _spawn_surge_mothership():
	if not victorious:
		surge_mothership_spawning = false
		var surge_mothership = mother_ship_scene.instantiate()
		surge_motherships.add_child(surge_mothership)
		surge_mothership.Player = player
		surge_mothership.rotation_comparison = surge_follower


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
	var meteor = meteor_scene.instantiate()
	meteors.add_child(meteor)
	meteor.global_position.x = randf_range(-100, 4600)
	meteor.global_position.y = randf_range(-100, 2800)
	while meteor.global_position.distance_to(player.global_position) < 1220:
		meteor.global_position.x = randf_range(-100, 4600)
		meteor.global_position.y = randf_range(-100, 2800)



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
			health -= 5
		elif type == METEOR:
			health -= 10
		elif type == MOTHERSHIP:
			health -= 10
		health_bar.value = health
		
		if health <= 0 and level_number != 3:
			defeat()
			
		elif health <= 0 and level_number == 3:
			pass
			
		else:
			safe = true
			damage_timer.start(-1)
