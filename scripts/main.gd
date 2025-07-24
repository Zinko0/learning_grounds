extends Node3D

@export var hit_rect : ColorRect
@onready var spawns = $spawns
@onready var nav_region = $NavigationRegion3D
@export var tick : TextureRect 
@export var boombar : ProgressBar

var enemy = preload("res://scenes/boss.tscn")
var instance

func _ready() -> void:
	$Control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	randomize()
	
func _process(_delta: float) -> void:
	
	pass

func _on_proto_controller_player_hit() -> void:
	hit_rect.visible = true
	await get_tree().create_timer(0.2).timeout
	hit_rect.visible = false

func get_random_child(parent_node):
	var random_id = randi() % parent_node.get_child_count()
	return parent_node.get_child(random_id)

func _on_timer_timeout() -> void:

	var spawn_point = get_random_child(spawns).global_position
	instance = enemy.instantiate()
	instance.connect("hit_landed", Callable(self," _on_proto_controller_player_hit"))
	nav_region.add_child(instance)
	instance.global_position = spawn_point

	




func _on_proto_controller_enemy_hit() -> void:
	tick.visible = true
	await get_tree().create_timer(0.2).timeout
	tick.visible = false


func _on_proto_controller_boom() -> void:
	boombar.visible = true
	$Control/boombar/ProgressBar.visible = true
	


func _on_proto_controller_noboom() -> void:
	boombar.visible = false
	$Control/boombar/ProgressBar.visible = false
