extends Node2D


@onready var button = $UI/Endless_button


func _physics_process(_delta: float) -> void:
	pass


func _on_endless_button_pressed() -> void:
	LevelManager.start_endless_mode()
	LevelManager.start_endless_mode()

func _on_mothership_surge_button_pressed() -> void:
	LevelManager.start_mothership_surge_mode()


func _on_spacestation_defense_button_pressed() -> void:
	LevelManager.start_defend_spacestation_mode()
