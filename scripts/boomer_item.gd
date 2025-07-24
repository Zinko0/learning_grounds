extends Node3D

@onready var sniper = preload("res://scenes/p_launcher.tscn")
@onready var point = preload("res://scenes/point.tscn")
@export var distance : ProgressBar

func equip(player : CharacterBody3D):
	if player.equipped :
		print("cant equip that shit")
		return
	
	player.equipped = true 
	
	var sniper_instance = point.instantiate()

	# Add to the player
	player.camera.add_child(sniper_instance)

	# Optional: Set its position/rotation (local)
	sniper_instance.position = Vector3(0.659, -0.489, -0.607)
	sniper_instance.rotation = Vector3(0.0, -81.4, 0.0)
	
	
	var launcher = sniper.instantiate()
	
	player.camera.add_child(launcher)
	
	launcher.position = Vector3.ZERO
	launcher.player = player
	launcher.camera = player.camera
	launcher.distance = distance
	
