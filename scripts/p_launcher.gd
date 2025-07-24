extends Node3D

const PROJECTILE = preload("res://scenes/projectile.tscn")


@onready var timer: Timer = $Timer
@export var player: CharacterBody3D  # assign the actual Player node in the inspector
@export var camera : Camera3D
@onready var bonk : AudioStreamPlayer3D = $bonk
@onready var succ : AudioStreamPlayer3D = $succ
@onready var distance : ProgressBar 
@onready var hand = $hand
var mult = 1
var shot = false
signal boom
signal noboom


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(player): # Safety check: is the player still valid before shooting?
		print("Warning: Player is not valid, cannot shoot sniper.")
		return
	if timer.is_stopped() and Input.is_action_pressed("shoot") and !shot:
		distance.visible = true
		distance.child.visible = true
		shot = true
		emit_signal("boom")
		timer.start(0.6)
		var attack = PROJECTILE.instantiate()
		attack.connect("gone", Callable(self, "refresh_p"))
		attack.connect("reset", Callable(self, "reset"))
		attack.connect("good_timing", Callable(self, "enhance"))
		attack.mult = mult
		get_tree().current_scene.add_child(attack)
		attack.distance = distance
		var direction = -camera.global_transform.basis.z.normalized()
		attack.global_position = global_position
		attack.look_at(attack.global_position + direction, Vector3.UP)
		attack.velocity = direction * attack.initial_speed  # Initial velocity
		attack.player = player
		attack.bonk = bonk
		hand.boom.visible = false


func refresh_p():
	shot = false
	emit_signal("noboom")
	hand.boom.visible = true
	distance.visible = false
	distance.child.visible = false

	
	
func enhance():
	mult = min(mult + 0.9, 2.7)
	succ.play()
	succ.pitch_scale += 0.2
	succ.pitch_scale = min(1.6,succ.pitch_scale)
	hand.emission += 7
	
	
func reset():
	mult = 1
	succ.pitch_scale = 1
	hand.emission = 2
	
