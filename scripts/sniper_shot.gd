# projectile.gd
extends Node3D



# @export var player_path: NodePath <--- REMOVE THIS
# @onready var player: CharacterBody3D = get_node_or_null(player_path) <--- REMOVE THIS

var player: CharacterBody3D # <--- ADD THIS: This will be set by the spawner/launcher
var bonk: AudioStreamPlayer3D
@onready var raycast: RayCast3D = $RayCast3D
@onready var direction = Vector3.ZERO
@onready var charge 
signal gone
var enemy_list = []
var boom = preload("res://scenes/explosion.tscn")
var exploded = false

func _process(_delta: float) -> void:
	# Make sure raycast is updated instantly
	raycast.force_raycast_update()
	if raycast.is_colliding():
		if !exploded and charge >= 3:
			exploded = true
			var hollow = boom.instantiate()
			get_tree().current_scene.add_child(hollow)
			hollow.setup(charge - 1)
			hollow.global_position = raycast.get_collision_point()
			
		print("its_colliding")
		var collider = raycast.get_collider()

		if collider.has_method("take_damage") and collider not in enemy_list:
			enemy_list.append(collider)
			print("damaging:", collider)
			collider.take_damage(1 * charge, direction.normalized())
			bonk.play()


		# Play sound or effect
		

	# Optional: delay destroy after small time for FX
	await get_tree().create_timer(0.2).timeout
	emit_signal("gone")
	queue_free()



	
