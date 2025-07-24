extends Node3D

@export var initial_speed := 10.0
@export var max_distance := 50.0
@export var gravity := 9.8
@export var drag := 5.0

@onready var timer: Timer = $Timer
@onready var testicle: MeshInstance3D = $testicle


var velocity: Vector3 = Vector3.ZERO
var direction: Vector3 = Vector3.ZERO
var traveled_distance: float = 0.0
var is_stuck: bool = false

var hit_list = []
var collider_enemy
var type
var first = true

var player: CharacterBody3D
var bonk: AudioStreamPlayer3D
@onready var raycast: RayCast3D = $RayCast3D
var BOOM = preload("res://scenes/explosion.tscn")


func _ready() -> void:
	velocity = direction * initial_speed
	





func _physics_process(delta: float) -> void:
	if first:
		first = false
		var mat: StandardMaterial3D
		if testicle.material_override == null:
			mat = StandardMaterial3D.new()
			testicle.material_override = mat
		else:
			mat = testicle.material_override.duplicate() as StandardMaterial3D
			testicle.material_override = mat

		# Enable emission and boost its strength
		mat.emission_enabled = true
		mat.emission_energy_multiplier = 10  # You can raise this to make it brighter

		# Now match the color
		match type:
			1:
				print("1")
				mat.albedo_color = Color(0.878, 0.161, 0.0)
				mat.emission = Color(0.878, 0.161, 0.0)

			2:
				print("2")
				mat.albedo_color = Color(0.371, 0.133, 0.332)
				mat.emission = Color(0.371, 0.133, 0.332)

			0:
				print("3")
				mat.albedo_color = Color(0.064, 0.124, 0.01)
				mat.emission = Color(0.064, 0.124, 0.01)

		# Apply it to the mesh
		testicle.mesh.surface_set_material(0, mat)

	if is_stuck:
		return  # Don't move anymore if stuck

	if traveled_distance >= max_distance or velocity.length() < 0.1:
		queue_free()
		return

	# Apply gravity and drag
	velocity.y -= gravity * delta
	velocity = velocity.move_toward(Vector3.ZERO, drag * delta)

	# Calculate motion and check distance
	var motion = velocity * delta
	traveled_distance += motion.length()

	# Raycast ahead
	raycast.target_position = motion.normalized() * 1.5
	raycast.force_raycast_update()

	if raycast.is_colliding():
		
		
		var collision_point = raycast.get_collision_point()
		var collision_normal = raycast.get_collision_normal()

		# Snap to collision point
		global_position = collision_point

		# Optional: Align to surface normal
		look_at(global_position + collision_normal, Vector3.UP)

		# Optional: Parent to the hit object if needed (e.g., for moving targets)
		var collider = raycast.get_collider()
		if collider == player:
			return
		if collider and collider is Node3D:
			reparent_to(collider)
		if collider.has_method("take_damage"):
			collider_enemy = collider
			print("collided with:", collider_enemy)
			damage_func()
		is_stuck = true
		velocity = Vector3.ZERO
		return

	# Move if no collision
	global_position += motion


func reparent_to(new_parent: Node3D):
	var current_transform = global_transform
	get_parent().remove_child(self)
	new_parent.add_child(self)
	global_transform = current_transform
	
func damage_func():
	print("bullet type:", type)
	bonk.play()
	match type:
		1:
			timer.start(0.5)
		
		2:
			var exp = BOOM.instantiate()
			get_tree().current_scene.add_child(exp)
			exp.setup(3)
			exp.global_position = global_position
			
		
		0:
			collider_enemy.stuck = true
			collider_enemy.take_damage(1, Vector3.ZERO)
			await get_tree().create_timer(5).timeout
			collider_enemy.stuck = false
		
		
			


func _on_timer_timeout() -> void:
	timer.start(0.5)
	collider_enemy.take_damage(1, Vector3.ZERO)


func _on_despawn_timeout() -> void:
	queue_free()
