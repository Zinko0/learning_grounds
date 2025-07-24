# projectile.gd
extends Node3D

@export var initial_speed := 70.0
@export var slowdown_rate := 5.0
@export var min_return_speed := 25.0
@export var return_acceleration := 10.0
@export var despawn_distance := 2.0
var hit_list = []
var mult
signal gone
signal good_timing
signal reset
# @export var player_path: NodePath <--- REMOVE THIS
# @onready var player: CharacterBody3D = get_node_or_null(player_path) <--- REMOVE THIS

var player: CharacterBody3D # <--- ADD THIS: This will be set by the spawner/launcher
var bonk: AudioStreamPlayer3D
@onready var raycast: RayCast3D = $RayCast3D
@onready var distance 

var velocity: Vector3
var returning := false
var goated = false
var mess = false


func _physics_process(delta: float) -> void:
	distance.value = global_position.distance_to(player.global_position)
	if not returning:
		var current_speed = velocity.length()
		current_speed = max(0.0, current_speed - slowdown_rate * delta)
		distance.value = global_position.distance_to(player.global_position)
		if current_speed <= 0.0:
			returning = true
			hit_list = []
			return
		velocity = velocity.normalized() * current_speed
	else:
		if player: # Null check is still good practice, but less likely to be needed now
			var to_player = (player.global_position - global_position).normalized()
			var return_speed = min_return_speed + return_acceleration * delta
			velocity = to_player * return_speed
		else:
			emit_signal("gone")
			if !goated : emit_signal("reset")
			queue_free() # Despawn if player somehow becomes null (e.g., player dies)
			return

		if player and global_position.distance_to(player.global_position) < despawn_distance:
			emit_signal("gone")
			if !goated : emit_signal("reset")
			queue_free()
			return
		elif not player: # Also despawn if player is null and it's trying to return
			emit_signal("gone")
			if !goated : emit_signal("reset")
			queue_free()
			return

	global_position += velocity * delta * mult/2

	raycast.force_raycast_update()
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider and collider.has_method("take_damage") and collider not in hit_list:
			collider.take_damage(1, velocity.normalized())
			bonk.play()
			hit_list.append(collider)
		elif collider and !collider.has_method("take_damage"):
			velocity = (player.global_position - global_position).normalized() * min_return_speed
			returning = true
			hit_list = []
			return
	if Input.is_action_just_pressed("shoot") and not mess:
		if !goated and global_position.distance_to(player.global_position) < 10:
			emit_signal("good_timing")
			goated = true
		else:
			emit_signal("reset")
			goated = false
			mess = true
