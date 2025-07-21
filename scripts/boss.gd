extends CharacterBody3D

var player = null
var hp = 200
var state_machine 
var speed = 3.0

const VISION_RANGE = 30.0
const JUMP_ATK_DMG_RANGE = 7.0
const NORMAL_ATK_RANGE = 4.0
const JUMP_ATK_RANGE = 10.0
const NORMAL_DMG = 5
const JUMP_ATK_DMG = 15
var jump_attack_force = 10.0  # Adjust to how far/fast you want him to move
var gravity = 20.0          # Adjust this to control fall speed
@export var player_path : NodePath

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D



func _ready() -> void:
	player = get_node(player_path)
	state_machine = animation_tree.get("parameters/playback")
	
func _physics_process(delta: float) -> void:
	
	velocity.y -= gravity * delta
	
	match state_machine.get_current_node():
		"Idle":
			animation_tree.set("parameters/conditions/Walking",false)
		"Walking":
			
			velocity = Vector3.ZERO
			
			nav_agent.set_target_position(player.global_position)
			var next_nav_point = nav_agent.get_next_path_position()
			#usa-se o normalized para o inimigo ir na mesma velocidade na diagonal
			velocity = (next_nav_point - global_position).normalized() * speed
			look_at(Vector3(next_nav_point.x,global_position.y,next_nav_point.z), Vector3.UP)
			animation_tree.set("parameters/conditions/Normal_attack", target_in_melee_range())
			animation_tree.set("parameters/conditions/Jump_attack",target_in_jmp_att_range())
			move_and_slide()
		"Attack":
			animation_tree.set("parameters/conditions/Run", !target_in_melee_range())
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
		"Jump_attack":
			
			animation_tree.set("parameters/conditions/Run", !target_in_melee_range())
			animation_tree.set("parameters/conditions/Attack", target_in_melee_range())

			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			move_and_slide()
		"Death":
			pass
	
func is_aware():
	return global_position.distance_to(player.global_position) < VISION_RANGE
	
func target_in_melee_range():
	return global_position.distance_to(player.global_position) < NORMAL_ATK_RANGE

func target_in_jmp_att_range():
	return NORMAL_ATK_RANGE + 3.0 < global_position.distance_to(player.global_position) and global_position.distance_to(player.global_position) < JUMP_ATK_RANGE  
	
func hit_player():
	if target_in_melee_range():
		var dir = global_position.direction_to(player.global_position)
		player.hit(NORMAL_DMG,dir)
		
func hit_jmp_player():
	if target_in_jmp_dmg_range():
		var dir = global_position.direction_to(player.global_position)
		player.hit(JUMP_ATK_DMG,dir)
		
func target_in_jmp_dmg_range():
	return global_position.distance_to(player.global_position) < JUMP_ATK_DMG_RANGE
	
func do_jump_attack_push():
	var dir = (player.global_position - global_position)
	dir.y = 0
	var jump_vector = dir.normalized() * min(dir.length(), 3.0)
	velocity.x = jump_vector.x / 0.8  # Spread movement over 0.5 seconds
	velocity.z = jump_vector.z / 0.8  # Spread movement over 0.5 seconds
	velocity.y = 12.0  # tweak this for jump height
