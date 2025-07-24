extends Node

@onready var big_guy: CharacterBody3D = get_parent()


@export var rope : Node3D
@export var ray: RayCast3D 

@export var rest_length = 2.0
@export var stiffness = 20.0
@export var damping = 1.0

var launched = false
var target: Vector3


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("hook"):
		launch()
	if Input.is_action_just_released("hook"):
		retract()

	if launched:
		handle_grapple(delta)
		
	update_rope()

func launch():
	if ray.is_colliding():
		target = ray.get_collision_point()
		launched = true 
		
	
func retract():
	launched = false
	
func handle_grapple(delta: float):
	var target_dir = big_guy.global_position.direction_to(target)
	var target_dist = big_guy.global_position.distance_to(target)
	
	var displacement = target_dist - rest_length
	
	var force = Vector3.ZERO
	
	if displacement > 0:
		var spring_force_magnitude = stiffness * displacement 
		var spring_force = target_dir * spring_force_magnitude
		
		var vel_dot = big_guy.velocity.dot(target_dir)
		var damping = -damping * vel_dot * target_dir
		
		force = spring_force + damping
		
	big_guy.velocity += force * delta

func update_rope():
	if !launched:
		rope.visible = false
		return
	
	rope.visible = true 
	
	var dist = big_guy.global_position.distance_to(target)
	
	rope.look_at(target)
	
	rope.scale = Vector3(1,1,dist)
