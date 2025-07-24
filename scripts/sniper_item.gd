extends Node3D

@onready var sniper = preload("res://scenes/sniper.tscn")

func equip(player : CharacterBody3D):
	if player.equipped :
		print("cant equip that shit")
		return
	
	player.equipped = true 
	
	var sniper_instance = sniper.instantiate()

	# Add to the player
	player.camera.add_child(sniper_instance)

	# Optional: Set its position/rotation (local)
	sniper_instance.position = Vector3(0.466, -0.201, -0.669)
	sniper_instance.rotation = Vector3(-0.03, -179.0, 0.0)
	sniper_instance.player = player
	sniper_instance.camera = player.camera
	
	queue_free()

	# Optional: If player has a weapon mount point (like a bone or socket), attach to it:
	# var hand = player.get_node("Skeleton3D/hand_r")
	# hand.add_child(sniper_instance)
