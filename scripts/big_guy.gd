class_name Player
extends CharacterBody3D

@export var speed = 12.0
@export var jump_force = 10.0
@export var gravity = 0.8

@export var acceleration = 10.0
@export var deceleration = 8.0

@export var sensitivity = 0.01

@onready var cam = $Camera3D
@onready var gc = $GrappleController

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var move_vec = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if input_dir.length() != 0:
		velocity.x = lerpf(velocity.x, move_vec.x * speed, acceleration * delta)
		velocity.z = lerpf(velocity.z, move_vec.z * speed, acceleration * delta)
	else:
		velocity.x = lerpf(velocity.x, 0.0, deceleration * delta)
		velocity.z = lerpf(velocity.z, 0.0, deceleration * delta)
	
	# Jumping / Gravity
	if !is_on_floor():
		velocity.y -= gravity
	
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() || gc.launched:
			velocity.y += jump_force
			gc.retract()
	
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity)
		cam.rotate_x(-event.relative.y * sensitivity)
		cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -90, 90)
