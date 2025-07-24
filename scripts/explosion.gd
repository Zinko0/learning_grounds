extends Node3D

@onready var timer: Timer = $Timer
@onready var damage
@onready var area: Area3D = $Area3D




func _ready():
	timer.start(0.4)

func setup(damage_p):
	damage = damage_p
	area.scale *= damage / 1.5
	


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage, Vector3.ZERO)
		
	


func _on_timer_timeout() -> void:
	queue_free()
