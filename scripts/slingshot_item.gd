extends Node3D

@onready var sniper = preload("res://scenes/sling.tscn")

func equip(player : CharacterBody3D):
	if player.equipped :
		print("cant equip that shit")
		return
	
	player.equipped = true 
	
	var sniper_instance = sniper.instantiate()

	# Add to the player
	player.camera.add_child(sniper_instance)

	# Optional: Set its position/rotation (local)
	sniper_instance.position = Vector3(0.659, -0.489, -0.607)
	sniper_instance.rotation = Vector3(0.0, -81.4, 0.0)
	sniper_instance.player = player
	sniper_instance.camera = player.camera
