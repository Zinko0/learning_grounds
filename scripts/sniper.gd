extends Node3D

const PROJECTILE = preload("res://scenes/sniper_shot.tscn")


@onready var timer: Timer = $Timer
@onready var charger_time: Timer = $charger_time
@export var player: CharacterBody3D  # assign the actual Player node in the inspector
@export var camera : Camera3D
@onready var bonk : AudioStreamPlayer3D = $bonk
@onready var shot: AudioStreamPlayer3D = $shot
@onready var charge = 0
@onready var succ: AudioStreamPlayer3D = $succ
@onready var hollow_purple: MeshInstance3D = $hollow_purple







func _physics_process(_delta: float) -> void:
	if not is_instance_valid(player): # Safety check: is the player still valid before shooting?
		return
	if Input.is_action_just_pressed("shoot"):
		charger_time.start(1)
	
	if Input.is_action_just_released("shoot"):
		if charge == 0:
			charger_time.stop()
			return
		$trail.visible = true
		timer.start(3)
		charger_time.stop()
		hollow_purple.visible = false
		var attack = PROJECTILE.instantiate()
		#connect signals
		attack.connect("gone", Callable(self, "no_trail"))
		get_tree().current_scene.add_child(attack)
		var direction = -camera.global_transform.basis.z.normalized()
		attack.global_position = camera.global_position
		attack.look_at(attack.global_position + direction, Vector3.UP)
		attack.raycast.target_position = Vector3.FORWARD * 1000
		attack.direction = (attack.raycast.target_position - attack.global_position).normalized()
		attack.player = player
		attack.bonk = bonk
		attack.charge = charge
		shot.pitch_scale = 1 - (charge*0.1)
		shot.play()
		charge = 0

func no_trail():
	$trail.visible = false
	succ.pitch_scale = 1
	hollow_purple.mesh.radius = 0.001
	hollow_purple.mesh.height = 0.001
	hollow_purple.mesh.surface_get_material(0).emission = Color(0.974, 0.346, 0.72)



func _on_charger_time_timeout() -> void:
	if charge >= 5:
		return
	if !hollow_purple.visible:
		hollow_purple.visible = true
	charge += 1
	var material = hollow_purple.mesh.surface_get_material(0)
	material.emission_enabled = true
	material.emission *= 1.2
	charger_time.start(1)
	succ.pitch_scale += 0.2
	hollow_purple.mesh.height += 0.02
	hollow_purple.mesh.radius += 0.02
	succ.play()
