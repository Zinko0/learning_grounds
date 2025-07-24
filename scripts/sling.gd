extends Node3D

const PROJECTILE = preload("res://scenes/slingshot.tscn")


@onready var timer: Timer = $Timer
@export var player: CharacterBody3D  # assign the actual Player node in the inspector
@export var camera : Camera3D
@onready var bonk : AudioStreamPlayer3D = $bonk
@onready var succ: AudioStreamPlayer3D = $succ
@onready var shot: AudioStreamPlayer3D = $shot

var charging = false
var charge = 1







func _physics_process(_delta: float) -> void:
	if not is_instance_valid(player): # Safety check: is the player still valid before shooting?
		print("Warning: Player is not valid, cannot shoot sling.")
		return
	if charging: 
		charge += 0.02
		charge = min(5, charge)
		
	if Input.is_action_just_pressed("shoot"):
		charging = true
	
	if Input.is_action_just_released("shoot"):
		shot.play()
		var type = randi() % 3
		charging = false

		var attack = PROJECTILE.instantiate()
		attack.player = player
		attack.bonk = bonk

		var direction = -camera.global_transform.basis.z.normalized()
		attack.global_position = camera.global_position
		attack.look_at(attack.global_position + direction, Vector3.UP)
		attack.direction = direction
		attack.initial_speed *= charge
		attack.type = type
		

		get_tree().current_scene.add_child(attack)
		attack.call_deferred("setup")
		charge = 1  # Reset charge

		


	
